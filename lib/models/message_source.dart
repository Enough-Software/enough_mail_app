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
  final cache = MessageCache();
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

  bool _supportsDeleteAll = false;
  bool get supportsDeleteAll => _supportsDeleteAll;
  set supportsDeleteAll(bool value) {
    _supportsDeleteAll = value;
    notifyListeners();
  }

  bool get shouldBlockImages;
  bool get isJunk;
  bool get isArchive;
  bool get supportsMessageFolders;

  Future<bool> init();

  Future<void> waitForDownload();

  Future<List<DeleteResult>> deleteAllMessages();

  Future<Message> waitForMessageAt(int index) async {
    var message = getMessageAt(index);
    await waitForDownload();
    return message;
  }

  Message _getFromCache(int index) {
    return cache[index];
  }

  Message _getUncachedMessage(int index);

  void addToCache(Message message) {
    cache.add(message);
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

  void remove(Message message);

  void removeFromCache(Message message) {
    cache.remove(message);
    notifyListeners();
  }

  @override
  void onMailFlagsUpdated(MimeMessage mime, MimeSource source) {
    final message = cache.getWithMime(mime, source.mailClient);
    if (message != null) {
      message.updateFlags(mime.flags);
    }
  }

  @override
  void onMailLoaded(MimeMessage mime, MimeSource source) {
    final message =
        cache.getWithMimeSequenceId(mime.sequenceId, source.mailClient);
    // print('onMailLoaded: updating $message for mime ${mime.sequenceId}');
    if (message != null) {
      message.updateMime(mime);
    }
  }

  @override
  void onMailVanished(MimeMessage mime, MimeSource source) {
    final message = cache.getWithMime(mime, source.mailClient);
    remove(message);
  }

  @override
  void onMailAdded(MimeMessage mime, MimeSource source) {
    // the source index is rather 0, here:
    final message = Message(mime, source.mailClient, this, 0);
    cache.insert(message);
    print('onMailAdded: ${mime.decodeSubject()}');
    notifyListeners();
  }

  Future<void> deleteMessage(BuildContext context, Message message) async {
    remove(message);
    removeFromCache(message);
    final deleteResult =
        await message.mailClient.deleteMessage(message.mimeMessage);
    if (deleteResult?.isUndoable == true) {
      locator<ScaffoldService>().showTextSnackBar(
        context,
        'Deleted',
        undo: () async {
          await message.mailClient.undoDeleteMessages(deleteResult);
          //TODO update mimeMessage's UID and sequence ID?
          // TODO add mime message to mime source again?
          cache.insert(message);
          notifyListeners();
        },
      );
    }
  }

  Future<void> deleteMessages(
      BuildContext context, List<Message> messages) async {
    for (final message in messages) {
      remove(message);
      cache.remove(message);
    }
    notifyListeners();
    final sequenceByClient = orderByClient(messages);
    final resultsByClient = <MailClient, DeleteResult>{};
    for (final client in sequenceByClient.keys) {
      final sequence = sequenceByClient[client];
      final deleteResult = await client.deleteMessages(sequence);
      if (deleteResult?.isUndoable == true) {
        resultsByClient[client] = deleteResult;
      }
    }
    if (context != null) {
      locator<ScaffoldService>().showTextSnackBar(
        context,
        'Deleted ${messages.length} message(s)',
        undo: resultsByClient.isEmpty
            ? null
            : () async {
                for (final client in resultsByClient.keys) {
                  await client.undoDeleteMessages(resultsByClient[client]);
                }
                //TODO update mimeMessage's UID and sequence ID?
                // TODO add mime message to mime source again?
                // TODO what should I do when not all delete are undoable?
                for (final message in messages) {
                  cache.insert(message);
                }
                notifyListeners();
              },
      );
    }
  }

  Future<void> markAsJunk(BuildContext context, Message message) {
    return moveMessage(context, message, MailboxFlag.junk, 'Marked as spam');
  }

  Future<void> markAsNotJunk(BuildContext context, Message message) {
    return moveMessage(context, message, MailboxFlag.inbox, 'Moved to inbox');
  }

  Future<void> moveMessage(BuildContext context, Message message,
      MailboxFlag targetMailboxFlag, String notification) async {
    remove(message);
    removeFromCache(message);
    final moveResult = await message.mailClient
        .moveMessageToFlag(message.mimeMessage, targetMailboxFlag);
    if (moveResult?.isUndoable == true) {
      locator<ScaffoldService>().showTextSnackBar(
        context,
        notification,
        undo: () async {
          final undoResponse = await message.mailClient.undoMove(moveResult);
          //TODO update message's UID and sequence ID?
          cache.insert(message);
          notifyListeners();
        },
      );
    }
  }

  Future<void> moveMessages(BuildContext context, List<Message> messages,
      MailboxFlag targetMailboxFlag, String notification) async {
    for (final message in messages) {
      remove(message);
      cache.remove(message);
    }
    notifyListeners();
    final sequenceByClient = orderByClient(messages);
    final resultsByClient = <MailClient, MoveResult>{};
    for (final client in sequenceByClient.keys) {
      final sequence = sequenceByClient[client];
      final moveResult =
          await client.moveMessagesToFlag(sequence, targetMailboxFlag);
      if (moveResult?.isUndoable == true) {
        resultsByClient[client] = moveResult;
      }
    }
    if (context != null && resultsByClient.isNotEmpty) {
      locator<ScaffoldService>().showTextSnackBar(
        context,
        notification,
        undo: () async {
          for (final client in resultsByClient.keys) {
            await client.undoMove(resultsByClient[client]);
          }
          //TODO update mimeMessage's UID and sequence ID?
          // TODO add mime message to mime source again?
          // TODO what should I do when not all delete are undoable?
          for (final message in messages) {
            cache.insert(message);
          }
          notifyListeners();
        },
      );
    }
  }

  Future<void> moveToInbox(BuildContext context, Message message) async {
    return moveMessage(context, message, MailboxFlag.inbox, 'Moved to inbox');
  }

  Future<void> archive(BuildContext context, Message message) {
    return moveMessage(context, message, MailboxFlag.archive, 'Archived');
  }

  Future<void> markAsSeen(Message msg, bool seen) {
    msg.isSeen = seen;
    return msg.mailClient.flagMessage(msg.mimeMessage, isSeen: seen);
  }

  Future<void> markAsFlagged(Message msg, bool flagged) {
    msg.isFlagged = flagged;
    return msg.mailClient.flagMessage(msg.mimeMessage, isFlagged: flagged);
  }

  Future<void> markMessagesAsSeen(List<Message> messages, bool seen) {
    messages.forEach((msg) => msg.isSeen = seen);
    return storeMessageFlags(messages, MessageFlags.seen,
        seen ? StoreAction.add : StoreAction.remove);
  }

  Future<void> markMessagesAsFlagged(List<Message> messages, bool flagged) {
    messages.forEach((msg) => msg.isFlagged = flagged);
    return storeMessageFlags(messages, MessageFlags.flagged,
        flagged ? StoreAction.add : StoreAction.remove);
  }

  Map<MailClient, MessageSequence> orderByClient(List<Message> messages) {
    final sequenceByClient = <MailClient, MessageSequence>{};
    for (final msg in messages) {
      final client = msg.mailClient;
      if (sequenceByClient.containsKey(client)) {
        sequenceByClient[client].addMessage(msg.mimeMessage);
      } else {
        sequenceByClient[client] = MessageSequence.fromMessage(msg.mimeMessage);
      }
    }
    return sequenceByClient;
  }

  Future<void> storeMessageFlags(
      List<Message> messages, String flag, StoreAction action) async {
    final sequenceByClient = orderByClient(messages);
    for (final client in sequenceByClient.keys) {
      final sequence = sequenceByClient[client];
      await client.store(sequence, [flag], action: action);
    }
  }
}

class MailboxMessageSource extends MessageSource {
  @override
  int get size => _mimeSource.size;

  MimeSource _mimeSource;

  MailboxMessageSource(Mailbox mailbox, MailClient mailClient) {
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
    final mailbox = _mimeSource.mailbox;
    name ??= mailbox?.name;
    if (mailbox != null) {
      supportsDeleteAll = (mailbox.isTrash || mailbox.isJunk);
    }
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

  @override
  Future<List<DeleteResult>> deleteAllMessages() async {
    final results = await _mimeSource.deleteAllMessages();
    if (results?.isNotEmpty ?? false) {
      cache.clear();
      notifyListeners();
    }
    return results;
  }

  @override
  void remove(Message message) {
    _mimeSource.remove(message.mimeMessage);
  }

  @override
  bool get shouldBlockImages => _mimeSource.shouldBlockImages;

  @override
  bool get isJunk => _mimeSource.isJunk;

  @override
  bool get isArchive => _mimeSource.isArchive;

  @override
  bool get supportsMessageFolders => _mimeSource.supportsMessageFolders;
}

class MultipleMessageSource extends MessageSource {
  @override
  int get size {
    var complete = 0;
    mimeSources.forEach((s) {
      complete += s.size;
    });
    //print('MultipleMessageSource.size: $complete');
    return complete;
  }

  final List<MimeSource> mimeSources;
  final _multipleMimeSources = <_MultipleMimeSource>[];
  int _lastUncachedIndex = 0;

  MultipleMessageSource(this.mimeSources, String name, MailboxFlag flag) {
    mimeSources.forEach((s) {
      s.addSubscriber(this);
      _multipleMimeSources.add(_MultipleMimeSource(s));
    });
    _name = name;
    supportsDeleteAll =
        (flag == MailboxFlag.trash) || (flag == MailboxFlag.junk);
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
      if (mime != null) {
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
        if (newestTime == null || date.isAfter(newestTime)) {
          newestIndex = i;
          newestTime = date;
        }
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

  @override
  Future<List<DeleteResult>> deleteAllMessages() async {
    final results = <DeleteResult>[];
    for (final mimeSource in mimeSources) {
      final mimeResults = await mimeSource.deleteAllMessages();
      if (mimeResults != null) {
        results.addAll(mimeResults);
      }
    }
    if (results.isNotEmpty) {
      cache.clear();
      notifyListeners();
    }
    return results;
  }

  MimeSource getMimeSource(Message message) {
    return mimeSources
        .firstWhere((source) => source.mailClient == message.mailClient);
  }

  @override
  void remove(Message message) {
    final mimeSource = getMimeSource(message);
    mimeSource.remove(message.mimeMessage);
  }

  @override
  bool get shouldBlockImages =>
      mimeSources.any((source) => source.shouldBlockImages);

  @override
  bool get isJunk => mimeSources.every((source) => source.isJunk);

  @override
  bool get supportsMessageFolders =>
      mimeSources.every((source) => source.supportsMessageFolders);

  @override
  bool get isArchive => mimeSources.every((source) => source.isArchive);
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
    if (_currentIndex >= mimeSource.size) {
      return null;
    }
    final mime = mimeSource.getMessageAt(_currentIndex);
    _currentIndex++;
    return mime;
  }
}
