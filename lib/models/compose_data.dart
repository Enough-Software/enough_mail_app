import 'package:enough_mail/enough_mail.dart';
import 'message.dart';

enum ComposeAction { answer, forward, newMessage }

typedef void MessageFinalizer(MessageBuilder messageBuilder);

class ComposeData {
  Message? get originalMessage =>
      (originalMessages?.isNotEmpty ?? false) ? originalMessages!.first : null;
  final List<Message?>? originalMessages;
  final MessageBuilder messageBuilder;
  final ComposeAction action;
  final String? resumeHtmlText;
  final Future? future;
  List<MessageFinalizer>? finalizers;

  ComposeData(this.originalMessages, this.messageBuilder, this.action,
      {this.resumeHtmlText, this.future, this.finalizers});

  ComposeData resume(String htmlText) {
    return ComposeData(originalMessages, messageBuilder, action,
        resumeHtmlText: htmlText, finalizers: finalizers);
  }

  /// Adds a finalizer
  ///
  /// A finalizer will be called before generating the final message.
  /// This can be used to update the message builder depending on the chosen sender or recipients, etc.
  void addFinalizer(MessageFinalizer finalizer) {
    finalizers ??= <MessageFinalizer>[];
    finalizers!.add(finalizer);
  }

  /// Finalizes the message builder.
  ///
  /// Compare [addFinalizer]
  void finalize() {
    final callbacks = finalizers;
    if (callbacks != null) {
      for (final callback in callbacks) {
        callback(messageBuilder);
      }
    }
  }
}
