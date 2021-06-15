import 'package:enough_mail/enough_mail.dart';
import 'message.dart';

enum ComposeAction { answer, forward, newMessage }

class ComposeData {
  Message? get originalMessage =>
      (originalMessages?.isNotEmpty ?? false) ? originalMessages!.first : null;
  final List<Message?>? originalMessages;
  final MessageBuilder messageBuilder;
  final ComposeAction action;
  final String? resumeHtmlText;
  final Future? future;

  ComposeData(this.originalMessages, this.messageBuilder, this.action,
      {this.resumeHtmlText, this.future});

  ComposeData resume(String htmlText) {
    return ComposeData(originalMessages, messageBuilder, action,
        resumeHtmlText: htmlText);
  }
}
