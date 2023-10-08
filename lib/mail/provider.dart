import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../account/model.dart';
import '../account/providers.dart';
import '../events/app_event_bus.dart';
import '../locator.dart';
import '../models/async_mime_source_factory.dart';
import '../models/message_source.dart';
import '../services/providers.dart';

part 'provider.g.dart';

/// Provides the message source for the given account
@Riverpod(keepAlive: true)
class Source extends _$Source {
  static const _clientId = Id(name: 'Maily', version: '1.0');
  final _mailClientsPerAccount = <RealAccount, MailClient>{};
  final _mimeSourceFactory =
      const AsyncMimeSourceFactory(isOfflineModeSupported: false);

  @override
  Future<MessageSource> build({required Account account, Mailbox? mailbox}) {
    if (account is RealAccount) {
      return _buildRealAccount(account, mailbox);
    } else if (account is UnifiedAccount) {
      return _buildUnifiedAccount(account, mailbox);
    } else {
      throw UnimplementedError();
    }
  }

  Future<MessageSource> _buildRealAccount(
    RealAccount account, [
    Mailbox? mailbox,
  ]) async {
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

  Future<MessageSource> _buildUnifiedAccount(
    UnifiedAccount account, [
    Mailbox? mailbox,
  ]) {
    throw UnimplementedError();
  }

  Future<MailClient?> _getClientAndStopPolling(RealAccount account) async {
    final client = await getClientFor(account);
    await client.stopPollingIfNeeded();
    if (!client.isConnected) {
      await client.connect();
    }

    return client;
  }

  Future<MailClient> getClientFor(
    RealAccount account,
  ) async =>
      _mailClientsPerAccount[account] ?? await createClientFor(account);

  Future<MailClient> createClientFor(
    RealAccount account, {
    bool store = true,
  }) async {
    final client = createMailClient(account.mailAccount);
    if (store) {
      _mailClientsPerAccount[account] = client;
    }
    await client.connect();
    await _loadMailboxesFor(client);

    return client;
  }

  MailClient createMailClient(MailAccount mailAccount) {
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

  Future<void> _loadMailboxesFor(MailClient client) async {
    //final account = getAccountFor(client.account);
    // if (account == null) {
    //   if (kDebugMode) {
    //     print('Unable to find account for ${client.account}');
    //   }

    //   return;
    // }
    final mailboxTree =
        await client.listMailboxesAsTree(createIntermediate: false);
    // final settings = _settings;
    // if (settings.folderNameSetting != FolderNameSetting.server) {
    //   _setMailboxNames(settings, client);
    // }

    // _mailboxesPerAccount[account] = mailboxTree;
  }
}
