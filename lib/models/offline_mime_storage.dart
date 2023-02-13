import 'dart:async';

import 'package:enough_mail/enough_mail.dart';

/// Provides persistence storage for mime messages
abstract class OfflineMimeStorage {
  const OfflineMimeStorage();

  /// Initializes this offline storage
  Future<void> init();

  /// Cleans up the storage when the [account] has been removed
  Future<void> onAccountRemoved();

  /// Saves the contents of  the given [mimeMessage]
  Future<void> saveMessageContents(MimeMessage mimeMessage);

  /// Fetches the message contents for the partial [mimeMessage].
  Future<MimeMessage?> fetchMessageContents(
    MimeMessage mimeMessage, {
    bool markAsSeen = false,
    List<MediaToptype>? includedInlineTypes,
  });

  /// Saves the given list of mime message envelope data
  Future<void> saveMessageEnvelopes(
    List<MimeMessage> messages,
  );

  /// Load the mime message envelopes for the given [account] and [mailbox]
  Future<List<MimeMessage>?> loadMessageEnvelopes(
    MessageSequence sequence,
  );

  /// Deletes the given [message].
  Future<void> deleteMessage(MimeMessage message);

  /// Moves the [messages] into the [targetMailbox]
  Future<void> moveMessages(List<MimeMessage> messages, Mailbox targetMailbox);
}
