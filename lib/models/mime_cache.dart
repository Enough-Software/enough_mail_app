import 'package:enough_mail/enough_mail.dart';
import 'package:collection/collection.dart' show IterableExtension;

class MimeCache {
  final int maxCacheSize;
  final List<_MimeWithSourceIndex> _messages = [];

  MimeCache({this.maxCacheSize = 100});

  MimeMessage operator [](int index) =>
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

  bool remove(MimeMessage mime) {
    final mimeWithSourceIndex =
        _messages.firstWhereOrNull((m) => m.mime == mime);
    if (mimeWithSourceIndex != null) {
      bool removed = _messages.remove(mimeWithSourceIndex);
      final sequenceId = mime.sequenceId;
      if (sequenceId != null) {
        for (final msg in _messages) {
          if (msg.mime.sequenceId >= sequenceId) {
            msg.mime.sequenceId--;
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

  MimeMessage getForUid(final int uid) {
    return _messages.firstWhereOrNull((msg) => msg.mime.uid == uid)?.mime;
  }

  MimeMessage getForSequenceId(final int sequenceId) {
    return _messages
        .firstWhereOrNull((msg) => msg.mime.sequenceId == sequenceId)
        ?.mime;
  }
}

class _MimeWithSourceIndex {
  final MimeMessage mime;
  int sourceIndex;

  _MimeWithSourceIndex(this.mime, this.sourceIndex);
}
