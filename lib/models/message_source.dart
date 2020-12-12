import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/locator.dart';
import 'package:enough_mail_app/models/message_cache.dart';
import 'package:enough_mail_app/models/mime_source.dart';
import 'package:enough_mail_app/services/scaffold_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'message.dart';

abstract class MessageSource extends ChangeNotifier
    implements MimeSourceSubscriber {
  int get size;
  bool get isEmpty => (size == 0);
  final _cache = MessageCache();
  String _description;
  set description(String value) {
    _description = value;
    notifyListeners();
  }

  String get description => _description;

  String _name;
  set name(String value) {
    _name = value;
    notifyListeners();
  }

  String get name => _name;

  Future<bool> init();

  Future<void> waitForDownload();

  Future<Message> waitForMessageAt(int index) async {
    var message = getMessageAt(index);
    await waitForDownload();
    return message;
  }

  Message _getFromCache(int index) {
    return _cache[index];
  }

  Message _getUncachedMessage(int index);

  void addToCache(Message message) {
    _cache.add(message);
  }

  Message getMessageAt(int index) {
    var message = _getFromCache(index);
    if (message == null) {
      message = _getUncachedMessage(index);
      addToCache(message);
    }
    return message;
  }

  Message next(Message current) {
    return getMessageAt(current.sourceIndex + 1);
  }

  Message previous(Message current) {
    return getMessageAt(current.sourceIndex - 1);
  }

  void remove(Message message) {
    _cache.remove(message);
    notifyListeners();
  }

  @override
  void onMailFlagsUpdated(MimeMessage mime, MimeSource source) {
    final message = _cache.getWithMime(mime, source.mailClient);
    if (message != null) {
      message.updateFlags(mime.flags);
    }
  }

  @override
  void onMailLoaded(MimeMessage mime, MimeSource source) {
    final message =
        _cache.getWithMimeSequenceId(mime.sequenceId, source.mailClient);
    // print('onMailLoaded: updating $message for mime ${mime.sequenceId}');
    if (message != null) {
      message.updateMime(mime);
    }
  }

  @override
  void onMailVanished(MimeMessage mime, MimeSource source) {
    final message = _cache.getWithMime(mime, source.mailClient);
    remove(message);
  }

  @override
  void onMailAdded(MimeMessage mime, MimeSource source) {
    // the source index is rather 0, here:
    final message = Message(mime, source.mailClient, this, 0);
    _cache.insert(message);
    print('onMailAdded: ${mime.decodeSubject()}');
    notifyListeners();
  }

  Future<MailResponse> deleteMessage(
      BuildContext context, Message message) async {
    remove(message);
    //return message.mailClient.flagMessage(message.mimeMessage, isDeleted: true);
    //TODO use returning mail sequence to allow undo delete
    final response =
        await message.mailClient.deleteMessage(message.mimeMessage);
    if (response.result?.isUndoable == true) {
      locator<ScaffoldService>().showTextSnackBar(context, 'Deleted',
          undo: () async {
        final undoResponse =
            await message.mailClient.undoDeleteMessages(response.result);
        if (undoResponse.isOkStatus) {
          //TODO update mimeMessage's UID and sequence ID
          _cache.insert(message);
          notifyListeners();
        }
      });
    }
    return response;
  }
}

class MailboxMessageSource extends MessageSource {
  @override
  int get size => _mimeSource.size;

  MimeSource _mimeSource;

  MailboxMessageSource(Mailbox mailbox, MailClient mailClient) {
    //mailbox ??= mailClient.selectedMailbox;
    _mimeSource = MimeSource(mailClient, mailbox, subscriber: this);
    _description = mailClient.account.email;
    _name = mailbox?.name;
  }

  @override
  void dispose() {
    _mimeSource.removeSubscriber(this);
    _mimeSource.dispose();
    super.dispose();
  }

  @override
  Message _getUncachedMessage(int index) {
    //print('get uncached $index');
    var mime = _mimeSource.getMessageAt(index);
    return Message(mime, _mimeSource.mailClient, this, index);
  }

  @override
  Future<bool> init() async {
    final result = await _mimeSource.init();
    name ??= _mimeSource.mailbox?.name;
    return result;
  }

  @override
  Future<void> waitForDownload() {
    final future = _mimeSource.downloadFuture;
    if (future != null) {
      return future;
    }
    return Future.value();
  }
}

class MultipleMessageSource extends MessageSource {
  @override
  int get size {
    var complete = 0;
    mimeSources.forEach((s) {
      complete += s.size;
    });
    return complete;
  }

  final List<MimeSource> mimeSources;
  final _multipleMimeSources = <_MultipleMimeSource>[];
  int _lastUncachedIndex = 0;

  MultipleMessageSource(this.mimeSources, String name) {
    mimeSources.forEach((s) {
      s.addSubscriber(this);
      _multipleMimeSources.add(_MultipleMimeSource(s));
    });
    _name = name;
    _description =
        mimeSources.map((s) => s.mailClient.account.email).join(', ');
  }

  @override
  Future<bool> init() async {
    final futures = mimeSources.map((source) => source.init());
    final results = await Future.wait(futures);
    return !results.any((result) => (result == false));
  }

  @override
  void dispose() {
    mimeSources.forEach((s) {
      s.removeSubscriber(this);
      s.dispose();
    });
    super.dispose();
  }

  Message _next() {
    final mimes = <MimeMessage>[];
    var newestIndex = 0;
    DateTime newestTime;
    for (var i = 0; i < _multipleMimeSources.length; i++) {
      final source = _multipleMimeSources[i];
      final mime = source.peek();
      if (mime.isEmpty) {
        //TODO
        //await waitForDownload();
      }
      mimes.add(mime);
      var date = mime.decodeDate();
      if (date == null) {
        date = DateTime.now();
        print(
            'unable to decode date for $_lastUncachedIndex on ${mimeSources[i].mailClient.account.name} message is empty: ${mime.isEmpty}.');
      }

      //PROBLEM: initially the MIME messages will just be empty
      // and are only populated after successful loading....
      // if (mime.decodeDate() == null) {
      //   print('UNABLE TO DECODE DATE FOR mime ${mime.bodyRaw}');
      // }
      if (newestTime == null) {
        newestTime = date;
      } else if (date.isAfter(newestTime)) {
        newestIndex = i;
        newestTime = date;
      }
    }
    final newestSource = _multipleMimeSources[newestIndex];
    final newestMime = newestSource.pop();
    return Message(newestMime, newestSource.mimeSource.mailClient, this, null);
  }

  @override
  Message _getUncachedMessage(int index) {
    //print('get uncached $index');
    int diff = (index - _lastUncachedIndex);
    while (diff > 1) {
      final nextMessage = _next();
      nextMessage.sourceIndex = index - diff;
      addToCache(nextMessage);
      diff--;
    }
    // problem: what if user scrolls up a loooong way again?
    final nextMessage = _next();
    nextMessage.sourceIndex = index;
    _lastUncachedIndex = index;
    return nextMessage;
  }

  @override
  Future<void> waitForDownload() {
    final futures = <Future>[];
    for (final mimeSource in mimeSources) {
      if (mimeSource.downloadFuture != null) {
        futures.add(mimeSource.downloadFuture);
      }
    }
    return Future.wait(futures);
  }
}

class _MultipleMimeSource {
  final MimeSource mimeSource;
  int _currentIndex = 0;
  MimeMessage _currentMessage;

  _MultipleMimeSource(this.mimeSource);

  MimeMessage peek() {
    if (_currentMessage == null) {
      _currentMessage = _next();
    }
    return _currentMessage;
  }

  MimeMessage pop() {
    final mime = peek();
    _currentMessage = null;
    return mime;
  }

  MimeMessage _next() {
    final mime = mimeSource.getMessageAt(_currentIndex);
    _currentIndex++;
    return mime;
  }
}
