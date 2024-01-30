import 'package:enough_mail/enough_mail.dart';

import 'message.dart';

enum ComposeAction { answer, forward, newMessage }

enum ComposeMode { plainText, html }

typedef MessageFinalizer = void Function(MessageBuilder messageBuilder);

class ComposeData {
  ComposeData(
    this.originalMessages,
    this.messageBuilder,
    this.action, {
    this.resumeText,
    this.future,
    this.finalizers,
    this.composeMode = ComposeMode.html,
  });

  Message? get originalMessage {
    final originalMessages = this.originalMessages;

    return (originalMessages != null && originalMessages.isNotEmpty)
        ? originalMessages.first
        : null;
  }

  final List<Message?>? originalMessages;
  final MessageBuilder messageBuilder;
  final ComposeAction action;
  final String? resumeText;
  final Future? future;
  final ComposeMode composeMode;
  List<MessageFinalizer>? finalizers;

  ComposeData resume(String text, {ComposeMode? composeMode}) => ComposeData(
        originalMessages,
        messageBuilder,
        action,
        resumeText: text,
        finalizers: finalizers,
        composeMode: composeMode ?? this.composeMode,
      );

  /// Adds a finalizer
  ///
  /// A finalizer will be called before generating the final message.
  ///
  /// This can be used to update the message builder depending on the
  /// chosen sender or recipients, etc.
  void addFinalizer(MessageFinalizer finalizer) {
    final finalizers = (this.finalizers ?? <MessageFinalizer>[])
      ..add(finalizer);
    this.finalizers = finalizers;
  }

  /// Finalizes the message builder.
  ///
  /// Compare [addFinalizer]
  void finalize() {
    final finalizers = this.finalizers;
    if (finalizers != null) {
      for (final finalizer in finalizers) {
        finalizer(messageBuilder);
      }
    }
  }
}
