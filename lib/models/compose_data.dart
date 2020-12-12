import 'package:enough_mail/enough_mail.dart';

import 'message.dart';

enum ComposeAction { answer, forward, newMessage }

class ComposeData {
  final Message originalMessage;
  final MessageBuilder messageBuilder;
  final ComposeAction action;

  ComposeData(this.originalMessage, this.messageBuilder, this.action);
}
