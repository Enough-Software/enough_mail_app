import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/foundation.dart';

import '../account/model.dart';
import '../events/app_event_bus.dart';
import '../locator.dart';
import '../models/async_mime_source.dart';
import '../models/async_mime_source_factory.dart';
import '../services/providers.dart';

/// Callback when the configuration of a mail client has changed,
/// typically when the OAuth token has been refreshed
typedef OnMailClientConfigChanged = Future<void> Function(MailAccount account);

/// Abstracts interaction and creation of mail clients / mime sources
class EmailService {
  EmailService._();
  static final _instance = EmailService._();

  /// Retrieves the singleton instance
  static EmailService get instance => _instance;

  static const _clientId = Id(name: 'Maily', version: '1.0');
  final _mimeSourceFactory =
      const AsyncMimeSourceFactory(isOfflineModeSupported: false);

  /// Creates a mime source for the given account
  Future<AsyncMimeSource> createMimeSource({
    required MailClient mailClient,
    Mailbox? mailbox,
  }) async {
    await mailClient.connect();
    if (mailbox == null) {
      mailbox = await mailClient.selectInbox();
    } else {
      await mailClient.selectMailbox(mailbox);
    }
    final source = _mimeSourceFactory.createMailboxMimeSource(
      mailClient,
      mailbox,
    ); //..addSubscriber(this);

    return source;
  }

  /// Creates a mail client for the given account
  MailClient createMailClient(
    MailAccount mailAccount,
    OnMailClientConfigChanged? onMailClientConfigChanged,
  ) {
    final bool isLogEnabled = kDebugMode ||
        (mailAccount.attributes[RealAccount.attributeEnableLogging] ?? false);

    return MailClient(
      mailAccount,
      isLogEnabled: isLogEnabled,
      logName: mailAccount.name,
      eventBus: AppEventBus.eventBus,
      clientId: _clientId,
      refresh: _refreshToken,
      onConfigChanged: onMailClientConfigChanged,
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
    // TODO(RV): replace provider service with a riverpod provider
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

  /// Connects a MailAccount.
  ///
  /// Adapts the authentication user name if necessary
  Future<ConnectedAccount?> connectFirstTime(
    MailAccount mailAccount,
    OnMailClientConfigChanged? onMailClientConfigChanged,
  ) async {
    var usedMailAccount = mailAccount;
    var mailClient = createMailClient(
      usedMailAccount,
      onMailClientConfigChanged,
    );
    try {
      await mailClient.connect();
    } on MailException {
      await mailClient.disconnect();
      final email = usedMailAccount.email;
      var preferredUserName =
          usedMailAccount.incoming.serverConfig.getUserName(email);
      if (preferredUserName == null || preferredUserName == email) {
        final atIndex = mailAccount.email.lastIndexOf('@');
        preferredUserName = usedMailAccount.email.substring(0, atIndex);
        usedMailAccount =
            usedMailAccount.copyWithAuthenticationUserName(preferredUserName);
        await mailClient.disconnect();
        mailClient = createMailClient(
          usedMailAccount,
          onMailClientConfigChanged,
        );
        try {
          await mailClient.connect();
        } on MailException {
          await mailClient.disconnect();

          return null;
        }
      }
    }

    return ConnectedAccount(usedMailAccount, mailClient);
  }
}
