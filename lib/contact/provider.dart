import 'package:enough_mail/enough_mail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../account/model.dart';
import '../account/provider.dart';
import '../logger.dart';
import '../mail/service.dart';
import 'model.dart';

part 'provider.g.dart';

/// Loads the contacts for the given [account]
@Riverpod(keepAlive: true)
Future<ContactManager> contactsLoader(
  ContactsLoaderRef ref, {
  required RealAccount account,
}) async {
  final mailClient = EmailService.instance
      .createMailClient(account.mailAccount, account.name, null);
  try {
    await mailClient.connect();
    final mailbox = await mailClient.selectMailboxByFlag(MailboxFlag.sent);
    if (mailbox.messagesExists > 0) {
      var startId = mailbox.messagesExists - 100;
      if (startId < 1) {
        startId = 1;
      }
      final sentMessages = await mailClient.fetchMessageSequence(
        MessageSequence.fromRangeToLast(startId),
        fetchPreference: FetchPreference.envelope,
      );
      final addressesByEmail = <String, MailAddress>{};
      for (final message in sentMessages) {
        _addAddresses(message.to, addressesByEmail);
        _addAddresses(message.cc, addressesByEmail);
        _addAddresses(message.bcc, addressesByEmail);
      }
      final manager = ContactManager(addressesByEmail.values.toList());
      final updatedAccount = account.copyWith(contactManager: manager);
      ref.read(realAccountsProvider.notifier).replaceAccount(
            oldAccount: account,
            newAccount: updatedAccount,
            save: false,
          );

      return manager;
    }
  } catch (e, s) {
    logger.e('unable to load sent messages: $e', error: e, stackTrace: s);
  } finally {
    await mailClient.disconnect();
  }

  return ContactManager([]);
}

void _addAddresses(
  List<MailAddress>? addresses,
  Map<String, MailAddress> addressesByEmail,
) {
  if (addresses == null) {
    return;
  }
  for (final address in addresses) {
    final email = address.email.toLowerCase();
    final existing = addressesByEmail[email];
    if (existing == null || !existing.hasPersonalName) {
      addressesByEmail[email] = address;
    }
  }
}
