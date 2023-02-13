import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/hive/hive.dart';
import 'package:enough_mail_app/models/offline_mime_storage.dart';

/// Provides access to storage facilities
class OfflineMimeStorageFactory {
  const OfflineMimeStorageFactory();

  Future<void> init() => HiveMailboxMimeStorage.initGlobal();

  OfflineMimeStorage getMailboxStorage({
    required MailAccount mailAccount,
    required Mailbox mailbox,
  }) {
    return HiveMailboxMimeStorage(mailAccount: mailAccount, mailbox: mailbox);
  }
}
