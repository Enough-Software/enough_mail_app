import 'package:collection/collection.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../account/model.dart';
import '../account/provider.dart';
import '../models/async_mime_source.dart';
import '../models/message.dart';
import '../models/message_source.dart';
import '../notification/model.dart';
import '../notification/service.dart';
import '../settings/provider.dart';
import 'service.dart';

part 'provider.g.dart';

/// Provides the message source for the given account
@Riverpod(keepAlive: true)
class Source extends _$Source {
  @override
  Future<MessageSource> build({
    required Account account,
    Mailbox? mailbox,
  }) {
    if (account is RealAccount) {
      return ref.watch(
        realSourceProvider(account: account, mailbox: mailbox).future,
      );
    }
    if (account is UnifiedAccount) {
      return ref.watch(
        unifiedSourceProvider(account: account, mailbox: mailbox).future,
      );
    }
    throw UnimplementedError('for account $account');
  }
}

/// Provides the message source for the given account
@Riverpod(keepAlive: true)
class UnifiedSource extends _$UnifiedSource {
  @override
  Future<MultipleMessageSource> build({
    required UnifiedAccount account,
    Mailbox? mailbox,
  }) async {
    Future<AsyncMimeSource> resolve(
      RealAccount realAccount,
      Mailbox? mailbox,
    ) async {
      var usedMailbox = mailbox;
      final flag = mailbox?.identityFlag;

      if (mailbox != null && mailbox.isVirtual && flag != null) {
        final mailboxTree = await ref.watch(
          mailboxTreeProvider(account: realAccount).future,
        );
        usedMailbox = mailboxTree.firstWhereOrNull(
          (m) => m?.flags.contains(flag) ?? false,
        );
      }

      final source = await ref.watch(
        realMimeSourceProvider(
          account: realAccount,
          mailbox: usedMailbox,
        ).future,
      );

      return source;
    }

    final accounts = account.accounts;
    final futureSources = accounts.map(
      (a) => resolve(a, mailbox),
    );
    final mimeSources = await Future.wait(futureSources);

    return MultipleMessageSource(
      mimeSources,
      account.name,
      mailbox?.identityFlag ?? MailboxFlag.inbox,
      account: account,
    );
  }
}

/// Provides the message source for the given account
@Riverpod(keepAlive: true)
class RealSource extends _$RealSource implements MimeSourceSubscriber {
  @override
  Future<MailboxMessageSource> build({
    required RealAccount account,
    Mailbox? mailbox,
  }) async {
    final source = await ref.watch(
      realMimeSourceProvider(account: account, mailbox: mailbox).future,
    )
      ..addSubscriber(this);

    return MailboxMessageSource.fromMimeSource(
      source,
      account.email,
      mailbox ?? source.mailbox,
      account: account,
    );
  }

  @override
  void onMailArrived(
    MimeMessage mime,
    AsyncMimeSource source, {
    int index = 0,
  }) {
    source.mailClient.lowLevelIncomingMailClient
        .logApp('new message: ${mime.decodeSubject()}');
    if (!mime.isSeen && source.isInbox) {
      NotificationService.instance
          .sendLocalNotificationForMail(mime, source.mailClient.account.email);
    }
  }

  @override
  void onMailCacheInvalidated(AsyncMimeSource source) {
    // ignore
  }

  @override
  void onMailFlagsUpdated(MimeMessage mime, AsyncMimeSource source) {
    if (mime.isSeen) {
      NotificationService.instance.cancelNotificationForMail(mime);
    }
  }

  @override
  void onMailVanished(MimeMessage mime, AsyncMimeSource source) {
    NotificationService.instance.cancelNotificationForMail(mime);
  }
}

//// Loads the mailbox tree for the given account
@Riverpod(keepAlive: true)
Future<Tree<Mailbox?>> mailboxTree(
  MailboxTreeRef ref, {
  required Account account,
}) async {
  if (account is RealAccount) {
    final source = await ref.watch(realSourceProvider(account: account).future);

    return source.mimeSource.mailClient
        .listMailboxesAsTree(createIntermediate: false);
  } else if (account is UnifiedAccount) {
    final mailboxes = [
      MailboxFlag.inbox,
      MailboxFlag.drafts,
      MailboxFlag.sent,
      MailboxFlag.trash,
      MailboxFlag.archive,
      MailboxFlag.junk,
    ].map((f) => Mailbox.virtual(f.name, [f])).toList();

    return Tree<Mailbox?>(Mailbox.virtual('', []))
      ..populateFromList(mailboxes, (child) => null);
  } else {
    throw UnimplementedError('for account $account');
  }
}

//// Loads the mailbox tree for the given account
@riverpod
Future<Mailbox?> findMailbox(
  FindMailboxRef ref, {
  required Account account,
  required String encodedMailboxPath,
}) async {
  final tree = await ref.watch(mailboxTreeProvider(account: account).future);

  final mailbox =
      tree.firstWhereOrNull((m) => m?.encodedPath == encodedMailboxPath);

  return mailbox;
}

/// Provides the message source for the given account
@Riverpod(keepAlive: true)
Future<AsyncMimeSource> realMimeSource(
  RealMimeSourceRef ref, {
  required RealAccount account,
  Mailbox? mailbox,
}) async {
  final mailClient = ref.watch(
    mailClientSourceProvider(account: account, mailbox: mailbox),
  );

  return EmailService.instance.createMimeSource(
    mailClient: mailClient,
    mailbox: mailbox,
  );
}

/// Provides mail clients
@Riverpod(keepAlive: true)
class MailClientSource extends _$MailClientSource {
  @override
  MailClient build({
    required RealAccount account,
    Mailbox? mailbox,
  }) =>
      EmailService.instance.createMailClient(
        account.mailAccount,
        (mailAccount) => ref
            .watch(realAccountsProvider.notifier)
            .updateMailAccount(account, mailAccount),
      );

  /// Creates a new mailbox with the given [mailboxName]
  Future<void> createMailbox(
    String mailboxName,
    Mailbox? parentMailbox,
  ) async {
    final mailClient = state;
    await mailClient.createMailbox(mailboxName, parentMailbox: parentMailbox);

    return ref.refresh(mailboxTreeProvider(account: account));
  }

  /// Deletes the given [mailbox]
  Future<void> deleteMailbox(Mailbox mailbox) async {
    final mailClient = state;
    await mailClient.deleteMailbox(mailbox);

    return ref.refresh(mailboxTreeProvider(account: account));
  }
}

/// Carries out a search for mail messages
@riverpod
Future<MessageSource> mailSearch(
  MailSearchRef ref, {
  required MailSearch search,
}) async {
  final account =
      ref.watch(currentAccountProvider) ?? ref.watch(allAccountsProvider).first;
  final source = await ref.watch(sourceProvider(account: account).future);

  return source.search(search);
}

/// Loads the message source for the given payload
@riverpod
Future<Message> singleMessageLoader(
  SingleMessageLoaderRef ref, {
  required MailNotificationPayload payload,
}) async {
  final account = ref.watch(
    findAccountByEmailProvider(email: payload.accountEmail),
  );
  final source = await ref.watch(sourceProvider(account: account).future);

  return source.loadSingleMessage(payload);
}

/// Provides mail clients
@riverpod
Future<ConnectedAccount?> firstTimeMailClientSource(
  FirstTimeMailClientSourceRef ref, {
  required RealAccount account,
  Mailbox? mailbox,
}) =>
    EmailService.instance.connectFirstTime(
      account.mailAccount,
      (mailAccount) => ref
          .watch(realAccountsProvider.notifier)
          .updateMailAccount(account, mailAccount),
    );

/// Creates a new [MessageBuilder] based on the given [mailtoUri] uri
@riverpod
MessageBuilder mailto(
  MailtoRef ref, {
  required Uri mailtoUri,
  required MimeMessage originatingMessage,
}) {
  final settings = ref.watch(settingsProvider);
  final senders = ref.watch(sendersProvider);
  final searchFor = senders.map((s) => s.address).toList();
  final searchIn = originatingMessage.recipientAddresses
      .map((email) => MailAddress('', email))
      .toList();
  var fromAddress = MailAddress.getMatch(searchFor, searchIn);
  if (fromAddress == null) {
    if (settings.preferredComposeMailAddress != null) {
      fromAddress = searchFor.firstWhereOrNull(
        (address) => address.email == settings.preferredComposeMailAddress,
      );
    }
    fromAddress ??= searchFor.first;
  }

  return MessageBuilder.prepareMailtoBasedMessage(mailtoUri, fromAddress);
}

/// Provides the locally current active mailbox
@riverpod
Mailbox? currentMailbox(CurrentMailboxRef ref) => null;
