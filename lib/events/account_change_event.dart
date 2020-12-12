import 'package:enough_mail/enough_mail.dart';

class AccountChangeEvent {
  final MailClient client;
  final MailAccount account;

  AccountChangeEvent(this.client, this.account);
}
