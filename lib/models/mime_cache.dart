import 'package:enough_mail/enough_mail.dart';
import 'package:collection/collection.dart'
    show IterableExtension, ListEquality;

class MimeCache {
  final int maxCacheSize;
  final List<_MimeWithSourceIndex> _messages = [];

  MimeCache({this.maxCacheSize = 100});

  MimeMessage? operator [](int index) =>
      _messages.firstWhereOrNull((m) => m.sourceIndex == index)?.mime;

  void add(MimeMessage mime, int sourceIndex) {
    _messages.add(_MimeWithSourceIndex(mime, sourceIndex));
    trim();
  }

  void addAll(List<MimeMessage> mimes, int startSourceIndex) {
    for (final mime in mimes) {
      _messages.add(_MimeWithSourceIndex(mime, startSourceIndex));
      startSourceIndex++;
    }
    trim();
  }

  void clear() => _messages.clear();

  // MimeMessage removeAt(int index) {
  //   final mimeWithSourceIndex =
  //       _messages.firstWhereOrNull((m) => m.sourceIndex == index);
  //   if (mimeWithSourceIndex != null) {
  //     _messages.remove(mimeWithSourceIndex);
  //     return mimeWithSourceIndex.mime;
  //   }
  //   return null;
  // }

  bool remove(MimeMessage? mime) {
    final mimeWithSourceIndex =
        _messages.firstWhereOrNull((m) => m.mime == mime);
    if (mimeWithSourceIndex != null) {
      bool removed = _messages.remove(mimeWithSourceIndex);
      final sequenceId = mime!.sequenceId;
      if (sequenceId != null) {
        for (final msg in _messages) {
          if (msg.mime.sequenceId! >= sequenceId) {
            msg.mime.sequenceId = msg.mime.sequenceId! - 1;
          } else {
            msg.sourceIndex--;
          }
        }
      }
      return removed;
    }
    return false;
  }

  void trim() {
    if (_messages.length > maxCacheSize) {
      _messages.removeRange(0, _messages.length - maxCacheSize);
    }
  }

  void insert(final MimeMessage message) {
    for (final msg in _messages) {
      msg.sourceIndex++;
    }
    add(message, 0);
  }

  MimeMessage? getForUid(final int uid) {
    return _messages.firstWhereOrNull((msg) => msg.mime.uid == uid)?.mime;
  }

  MimeMessage? getForSequenceId(final int sequenceId) {
    return _messages
        .firstWhereOrNull((msg) => msg.mime.sequenceId == sequenceId)
        ?.mime;
  }

  /// Refreshes this cache with the data from the provided [newMessages].
  ///
  /// This is used after reconnecing to a mail service that does
  /// not support semi-automatic syncing like QRSYNC.
  RefreshResult refreshWith(List<MimeMessage> newMessages) {
    // for each message:
    // compare flags / compare if it is present at all and then update/add the message to the cache
    // for each message in cache with a sequence ID higher than the last message:
    //  check if the message is also available in messages, if not remove
    final oldestMessageSequenceId = newMessages.first.sequenceId!;
    final result = RefreshResult();
    for (final cachedWithSourceIndex in _messages) {
      final cachedMime = cachedWithSourceIndex.mime;
      if (cachedMime.uid != null &&
          cachedMime.sequenceId! >= oldestMessageSequenceId) {
        final newMessage =
            newMessages.firstWhereOrNull((m) => m.uid == cachedMime.uid);
        if (newMessage == null) {
          result.vanished.add(cachedMime);
        } else {
          // remove this is so that I later know which messages are to be added
          newMessages.remove(newMessage);
          final equals = const ListEquality().equals;
          if (!equals(newMessage.flags, cachedMime.flags)) {
            cachedMime.flags = newMessage.flags;
            result.updated.add(cachedMime);
          }
        }
      }
    }
    result.added.addAll(newMessages);
    return result;
  }
}

class RefreshResult {
  final vanished = <MimeMessage>[];
  final added = <MimeMessage>[];
  final updated = <MimeMessage>[];
}

class _MimeWithSourceIndex {
  final MimeMessage mime;
  int sourceIndex;

  _MimeWithSourceIndex(this.mime, this.sourceIndex);
}
