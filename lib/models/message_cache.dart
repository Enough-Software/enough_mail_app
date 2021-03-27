import 'package:enough_mail/enough_mail.dart';

import 'message.dart';

class MessageCache {
  static const int defaultMaxSize = 100;
  final List<Message> _messages = <Message>[];
  final int maxSize;

  MessageCache({this.maxSize = defaultMaxSize});

  Message operator [](int index) =>
      _messages.firstWhere((message) => message.sourceIndex == index,
          orElse: () => null);

  Message getWithMime(MimeMessage mime, MailClient client) {
    return mime.uid != null
        ? getWithMimeUid(mime.uid, client)
        : getWithMimeSequenceId(mime.sequenceId, client);
  }

  Message getWithMimeSequenceId(int id, MailClient client) {
    return _messages.firstWhere(
        (m) => m.mimeMessage.sequenceId == id && m.mailClient == client,
        orElse: () => null);
  }

  Message getWithMimeUid(int uid, MailClient client) {
    return _messages.firstWhere(
        (m) => m.mimeMessage.uid == uid && m.mailClient == client,
        orElse: () => null);
  }

  Message getWithSourceIndex(int sourceIndex) {
    return _messages.firstWhere((m) => m.sourceIndex == sourceIndex,
        orElse: () => null);
  }

  void add(Message message) {
    _messages.add(message);
    if (_messages.length > maxSize) {
      _messages.removeAt(0);
    }
  }

  void insert(Message message) {
    for (final existing in _messages) {
      if (existing.sourceIndex >= message.sourceIndex) {
        existing.sourceIndex++;
      }
    }
    _messages.insert(message.sourceIndex, message);
  }

  bool remove(Message toBeRemoved) {
    if (toBeRemoved == null) {
      return false;
    }
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
