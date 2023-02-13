import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/locator.dart';
import 'package:enough_mail_app/models/account.dart';
import 'package:enough_mail_app/models/contact.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:flutter/foundation.dart';

class ContactService {
  Future<ContactManager> getForAccount(RealAccount account) async {
    var contactManager = account.contactManager;
    if (contactManager == null) {
      contactManager = await init(account);
      account.contactManager = contactManager;
    }
    return contactManager;
  }

  Future<ContactManager> init(RealAccount account) async {
    final mailClient = await locator<MailService>().createClientFor(account);
    try {
      final mailbox = await mailClient.selectMailboxByFlag(MailboxFlag.sent);
      if (mailbox.messagesExists > 0) {
        var startId = mailbox.messagesExists - 100;
        if (startId < 1) {
          startId = 1;
        }
        final sentMessages = await mailClient.fetchMessageSequence(
            MessageSequence.fromRangeToLast(startId),
            fetchPreference: FetchPreference.envelope);
        final addressesByEmail = <String, MailAddress>{};
        for (final message in sentMessages) {
          _addAddresses(message.to, addressesByEmail);
          _addAddresses(message.cc, addressesByEmail);
          _addAddresses(message.bcc, addressesByEmail);
        }
        return ContactManager(addressesByEmail.values.toList());
      }
    } catch (e, s) {
      if (kDebugMode) {
        print('unable to load sent messages: $e $s');
      }
    } finally {
      await mailClient.disconnect();
    }
    return ContactManager([]);
  }

  void _addAddresses(
      List<MailAddress>? addresses, Map<String, MailAddress> addressesByEmail) {
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
}
