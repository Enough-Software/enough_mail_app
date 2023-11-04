import 'package:enough_mail/enough_mail.dart';
import 'hive/hive.dart';
import 'offline_mime_storage.dart';

/// Provides access to storage facilities
class OfflineMimeStorageFactory {
  const OfflineMimeStorageFactory();

  Future<void> init() => HiveMailboxMimeStorage.initGlobal();

  OfflineMimeStorage getMailboxStorage({
    required MailAccount mailAccount,
    required Mailbox mailbox,
  }) =>
      HiveMailboxMimeStorage(mailAccount: mailAccount, mailbox: mailbox);
}
