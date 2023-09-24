import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/async_mime_source.dart';
import 'package:enough_mail_app/models/offline_mime_source.dart';
import 'package:enough_mail_app/models/offline_mime_storage_factory.dart';

/// Creates [AsyncMimeSource] instances
class AsyncMimeSourceFactory {
  /// Creates a new [AsyncMimeSourceFactory]
  ///
  /// Set [isOfflineModeSupported] to `true`
  const AsyncMimeSourceFactory({
    required bool isOfflineModeSupported,
    OfflineMimeStorageFactory storageFactory =
        const OfflineMimeStorageFactory(),
  })  : _isOfflineModeSupported = isOfflineModeSupported,
        _storageFactory = storageFactory;

  /// Should the generated mime source support being used in offline mode?
  final bool _isOfflineModeSupported;
  final OfflineMimeStorageFactory _storageFactory;

  /// Creates a new mailbox-based mime source
  AsyncMimeSource createMailboxMimeSource(
      MailClient mailClient, Mailbox mailbox) {
    final onlineSource = AsyncMailboxMimeSource(mailbox, mailClient);
    if (_isOfflineModeSupported) {
      final storage = _storageFactory.getMailboxStorage(
        mailAccount: mailClient.account,
        mailbox: mailbox,
      );
      return OfflineMailboxMimeSource(
        mailAccount: mailClient.account,
        mailbox: mailbox,
        onlineMimeSource: onlineSource,
        storage: storage,
      );
    }
    return onlineSource;
  }

  Future<void> init() => _storageFactory.init();
}
