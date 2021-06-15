import 'package:enough_mail/enough_mail.dart';

import 'message.dart';
import 'package:collection/collection.dart' show IterableExtension;

class MessageCache {
  static const int defaultMaxSize = 100;
  final List<Message> _messages = <Message>[];
  List<Message> get allMessages => _messages;
  final int maxSize;

  MessageCache({this.maxSize = defaultMaxSize});

  Message? operator [](int index) =>
      _messages.firstWhereOrNull(((message) => message.sourceIndex == index));

  Message? getWithMime(MimeMessage mime, MailClient client) {
    return mime.uid != null
        ? getWithMimeUid(mime.uid, client)
        : getWithMimeSequenceId(mime.sequenceId, client);
  }

  Message? getWithMimeSequenceId(int? id, MailClient client) {
    return _messages.firstWhereOrNull(
        ((m) => m.mimeMessage?.sequenceId == id && m.mailClient == client));
  }

  Message? getWithMimeUid(int? uid, MailClient client) {
    return _messages.firstWhereOrNull(
        ((m) => m.mimeMessage?.uid == uid && m.mailClient == client));
  }

  Message? getWithSourceIndex(int sourceIndex) {
    return _messages.firstWhereOrNull(((m) => m.sourceIndex == sourceIndex));
  }

  Message? getWithMimeSourceIndex(int mimeSourceIndex, MailClient client) {
    return _messages.firstWhereOrNull(
        ((m) => m.sourceIndex == mimeSourceIndex && m.mailClient == client));
  }

  void add(Message message) {
    // assert(message.mimeMessage != null);
    _messages.add(message);
    if (_messages.length > maxSize) {
      _messages.removeAt(0);
    }
  }

  void insert(Message message) {
    var insertIndex = 0;
    for (final existing in _messages) {
      if (existing.sourceIndex >= message.sourceIndex) {
        existing.sourceIndex++;
      } else {
        insertIndex++;
      }
    }
    _messages.insert(insertIndex, message);
  }

  bool remove(Message toBeRemoved) {
    final isRemoved = _messages.remove(toBeRemoved);
    for (final message in _messages) {
      if (message.sourceIndex > toBeRemoved.sourceIndex) {
        message.sourceIndex--;
      }
    }
    return isRemoved;
  }

  void clear() {
    _messages.clear();
  }

  List<Message> getWithSequence(MessageSequence sequence, MailClient client) {
    final result = <Message>[];
    final ids = sequence.toList();
    for (final id in ids) {
      final message = sequence.isUidSequence
          ? getWithMimeUid(id, client)
          : getWithMimeSequenceId(id, client);
      if (message != null) {
        result.add(message);
      }
    }
    return result;
  }

  void markAllMessageSeen(bool seen) {
    for (final message in _messages) {
      message.isSeen = seen;
    }
  }
}
