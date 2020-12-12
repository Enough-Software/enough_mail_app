import 'base_event.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';

class AccountResolvedEvent extends BaseEvent {
  final MailAccount account;
  final MailClient mailClient;

  AccountResolvedEvent(BuildContext context, this.account, this.mailClient)
      : super(context);
}
