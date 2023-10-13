import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../account/model.dart';
import '../account/providers.dart';
import '../events/app_event_bus.dart';
import '../locator.dart';
import '../models/async_mime_source.dart';
import '../models/async_mime_source_factory.dart';
import '../models/message_source.dart';
import '../services/providers.dart';

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
        realSourceProvider(account: realAccount, mailbox: usedMailbox).future,
      );

      return source.mimeSource;
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
class RealSource extends _$RealSource {
  static const _clientId = Id(name: 'Maily', version: '1.0');
  final _mailClientsPerAccount = <RealAccount, MailClient>{};
  final _mimeSourceFactory =
      const AsyncMimeSourceFactory(isOfflineModeSupported: false);

  @override
  Future<MailboxMessageSource> build({
    required RealAccount account,
    Mailbox? mailbox,
  }) async {
    final mailClient = await _getClientAndStopPolling(account);
    if (mailClient == null) {
      throw Exception('Unable to connect to server');
    }
    if (mailbox == null) {
      mailbox = await mailClient.selectInbox();
    } else {
      await mailClient.selectMailbox(mailbox);
    }
    final source = _mimeSourceFactory.createMailboxMimeSource(
      mailClient,
      mailbox,
    ); //..addSubscriber(this);
    // TODO(RV): add subscriber to send notification for unseen inbox mails

    return MailboxMessageSource.fromMimeSource(
      source,
      mailClient.account.email,
      mailbox.name,
      account: account,
    );
  }

  Future<MailClient?> _getClientAndStopPolling(RealAccount account) async {
    final client = await _getClientFor(account);
    await client.stopPollingIfNeeded();
    if (!client.isConnected) {
      await client.connect();
    }

    return client;
  }

  Future<MailClient> _getClientFor(
    RealAccount account,
  ) async =>
      _mailClientsPerAccount[account] ?? await _createClientFor(account);

  Future<MailClient> _createClientFor(
    RealAccount account, {
    bool store = true,
  }) async {
    final client = _createMailClient(account.mailAccount);
    if (store) {
      _mailClientsPerAccount[account] = client;
    }
    await client.connect();

    return client;
  }

  MailClient _createMailClient(MailAccount mailAccount) {
    final bool isLogEnabled = kDebugMode ||
        (mailAccount.attributes[RealAccount.attributeEnableLogging] ?? false);

    return MailClient(
      mailAccount,
      isLogEnabled: isLogEnabled,
      logName: mailAccount.name,
      eventBus: AppEventBus.eventBus,
      clientId: _clientId,
      refresh: _refreshToken,
      onConfigChanged: (account) =>
          ref.read(realAccountsProvider.notifier).save(),
      downloadSizeLimit: 32 * 1024,
    );
  }

  Future<OauthToken?> _refreshToken(
    MailClient mailClient,
    OauthToken expiredToken,
  ) {
    final providerId = expiredToken.provider;
    if (providerId == null) {
      throw MailException(
        mailClient,
        'no provider registered for token $expiredToken',
      );
    }
    final provider = locator<ProviderService>()[providerId];
    if (provider == null) {
      throw MailException(
        mailClient,
        'no provider "$providerId" found -  token: $expiredToken',
      );
    }
    final oauthClient = provider.oauthClient;
    if (oauthClient == null || !oauthClient.isEnabled) {
      throw MailException(
        mailClient,
        'provider $providerId has no valid OAuth configuration',
      );
    }

    return oauthClient.refresh(expiredToken);
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
@Riverpod(keepAlive: true)
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
