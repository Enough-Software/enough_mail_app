import 'package:enough_mail/enough_mail.dart';
import 'message.dart';

enum ComposeAction { answer, forward, newMessage }

class ComposeData {
  final Message originalMessage;
  final MessageBuilder messageBuilder;
  final ComposeAction action;
  final String resumeHtmlText;

  ComposeData(this.originalMessage, this.messageBuilder, this.action,
      {this.resumeHtmlText});

  ComposeData resume(String htmlText) {
    return ComposeData(originalMessage, messageBuilder, action,
        resumeHtmlText: htmlText);
  }
}
