import 'package:enough_mail/enough_mail.dart';
import 'message.dart';

enum ComposeAction { answer, forward, newMessage }

enum ComposeMode { plainText, html }

typedef MessageFinalizer = void Function(MessageBuilder messageBuilder);

class ComposeData {
  Message? get originalMessage =>
      (originalMessages?.isNotEmpty ?? false) ? originalMessages!.first : null;
  final List<Message?>? originalMessages;
  final MessageBuilder messageBuilder;
  final ComposeAction action;
  final String? resumeText;
  final Future? future;
  final ComposeMode composeMode;
  List<MessageFinalizer>? finalizers;

  ComposeData(
    this.originalMessages,
    this.messageBuilder,
    this.action, {
    this.resumeText,
    this.future,
    this.finalizers,
    this.composeMode = ComposeMode.html,
  });

  ComposeData resume(String text, {ComposeMode? composeMode}) {
    return ComposeData(originalMessages, messageBuilder, action,
        resumeText: text,
        finalizers: finalizers,
        composeMode: composeMode ?? this.composeMode);
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
