import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/locator.dart';
import 'package:enough_mail_app/models/message_cache.dart';
import 'package:enough_mail_app/models/mime_source.dart';
import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_mail_app/services/notification_service.dart';
import 'package:enough_mail_app/services/scaffold_messenger_service.dart';
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

  final MessageSource _parentMessageSource;

  MessageSource({MessageSource parent}) : _parentMessageSource = parent;

  bool get shouldBlockImages;
  bool get isJunk;
  bool get isArchive;
  bool get isTrash;
  bool get supportsMessageFolders;
  bool get supportsSearching;

  Future<bool> init();

  Future<void> waitForDownload();

  /// Deletes all messages
  ///
  /// Only available when `supportsDeleteAll` is `true`
  Future<List<DeleteResult>> deleteAllMessages();

  /// Marks all messages as seen (read) `true` or unseen (unread) when `false` is given
  ///
  /// Only available when `supportsDeleteAll` is `true`
  /// Returns `true` when the call succeeded
  Future<bool> markAllMessagesSeen(bool seen);

  Future<Message> waitForMessageAt(int index) async {
    var message = getMessageAt(index);
    if (message?.mimeMessage?.envelope == null) {
      await waitForDownload();
    }
    return message;
  }

  Message _getUncachedMessage(int index);

  Message getMessageAt(int index) {
    var message = cache[index];
    if (message == null) {
      message = _getUncachedMessage(index);
      cache.add(message);
    }
    return message;
  }

  Message next(Message current) {
    return getMessageAt(current.sourceIndex + 1);
  }

  Message previous(Message current) {
    return getMessageAt(current.sourceIndex - 1);
  }

  MimeSource getMimeSource(Message message);

  void remove(Message message) {
    final mimeSource = getMimeSource(message);
    mimeSource.remove(message.mimeMessage);
    cache.remove(message);
    if (_parentMessageSource != null) {
      _parentMessageSource.removeMime(message.mimeMessage, message.mailClient);
    }
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
    final message = source.isSequenceIdBased
        ? cache.getWithMimeSequenceId(mime.sequenceId, source.mailClient)
        : cache.getWithMimeUid(mime.uid, source.mailClient);

    if (message != null) {
      message.updateMime(mime);
      // } else {
      //   print(
      //       'onMailLoaded: message not found for mime ${source.isSequenceIdBased ? 'ID' : 'UID'} ${source.isSequenceIdBased ? mime.sequenceId : mime.uid}');
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

  Future<void> deleteMessage(Message message) {
    return deleteMessages(
        [message], locator<I18nService>().localizations.resultDeleted);
  }

  Future<void> deleteMessages(
      List<Message> messages, String notification) async {
    final notificationService = locator<NotificationService>();
    for (final message in messages) {
      _removeMessageAndCancelNotification(message, notificationService);
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
    locator<ScaffoldMessengerService>().showTextSnackBar(
      notification,
      undo: resultsByClient.isEmpty
          ? null
          : () async {
              for (final client in resultsByClient.keys) {
                final undelete =
                    await client.undoDeleteMessages(resultsByClient[client]);
                if (undelete.originalSequence?.isNotEmpty == true) {
                  final originalUids = undelete.originalSequence.toList();
                  final newUids = undelete.targetSequence.toList();
                  for (var i = 0; i < originalUids.length; i++) {
                    final originalUid = originalUids[i];
                    final message = messages.firstWhere(
                        (m) => m.mimeMessage.uid == originalUid,
                        orElse: () => null);
                    if (message != null) {
                      message.mimeMessage.uid = newUids[i];
                    }
                  }
                }
              }
              // TODO what should I do when not all delete are undoable?
              for (final message in messages) {
                cache.insert(message);
              }
              notifyListeners();
            },
    );
  }

  Future<void> markAsJunk(Message message) {
    return moveMessage(message, MailboxFlag.junk,
        locator<I18nService>().localizations.resultMovedToJunk);
  }

  Future<void> markAsNotJunk(Message message) {
    return moveMessage(message, MailboxFlag.inbox,
        locator<I18nService>().localizations.resultMovedToInbox);
  }

  Future<void> moveMessage(Message message, MailboxFlag targetMailboxFlag,
      String notification) async {
    _removeMessageAndCancelNotification(
        message, locator<NotificationService>());
    final moveResult = await message.mailClient
        .moveMessageToFlag(message.mimeMessage, targetMailboxFlag);
    if (moveResult?.isUndoable == true) {
      locator<ScaffoldMessengerService>().showTextSnackBar(
        notification,
        undo: () async {
          final undoResponse =
              await message.mailClient.undoMoveMessages(moveResult);
          if (undoResponse.targetSequence?.isNotEmpty == true) {
            message.mimeMessage.uid =
                undoResponse.targetSequence.toList().first;
          }
          cache.insert(message);
          notifyListeners();
        },
      );
    }
  }

  void _removeMessageAndCancelNotification(
      Message message, NotificationService notificationService) {
    remove(message);
    notificationService.cancelNotificationForMailMessage(message);
  }

  Future<void> moveMessages(List<Message> messages,
      MailboxFlag targetMailboxFlag, String notification) async {
    final notificationService = locator<NotificationService>();
    for (final message in messages) {
      _removeMessageAndCancelNotification(message, notificationService);
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
    if (resultsByClient.isNotEmpty) {
      locator<ScaffoldMessengerService>().showTextSnackBar(
        notification,
        undo: () async {
          for (final client in resultsByClient.keys) {
            await client.undoMoveMessages(resultsByClient[client]);
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

  Future<void> moveToInbox(Message message) async {
    return moveMessage(message, MailboxFlag.inbox,
        locator<I18nService>().localizations.resultMovedToInbox);
  }

  Future<void> archive(Message message) {
    return moveMessage(message, MailboxFlag.archive,
        locator<I18nService>().localizations.resultArchived);
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

  MessageSource search(MailSearch search);

  void removeMime(MimeMessage mimeMessage, MailClient mailClient) {
    final existingMessage = cache.getWithMime(mimeMessage, mailClient);
    if (existingMessage != null) {
      remove(existingMessage);
    }
  }

  Future<bool> refresh() async {
    clear();
    cache.clear();
    final result = await init();
    notifyListeners();
    return result;
  }

  void clear();

  // void replaceMime(Message message, MimeMessage mime) {
  //   final mimeSource = getMimeSource(message);
  //   remove(message);
  //   mimeSource.addMessage(mime);
  //   onMailAdded(mime, mimeSource);
  // }
}

class MailboxMessageSource extends MessageSource {
  @override
  int get size => _mimeSource.size;

  MimeSource _mimeSource;

  MailboxMessageSource(Mailbox mailbox, MailClient mailClient) {
    _mimeSource = MailboxMimeSource(mailClient, mailbox, subscriber: this);
    _description = mailClient.account.email;
    _name = mailbox?.name;
  }

  MailboxMessageSource.fromMimeSource(
      this._mimeSource, String description, String name,
      {MessageSource parent})
      : super(parent: parent) {
    _description = description;
    _name = name;
    _mimeSource.addSubscriber(this);
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
    name ??= _mimeSource.name;
    supportsDeleteAll = _mimeSource.suppportsDeleteAll;
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
    final removedMessages = cache.allMessages.toList();
    cache.clear();
    final futureResults = _mimeSource.deleteAllMessages();
    clear();
    notifyListeners();
    final results = await futureResults;
    if (_parentMessageSource != null) {
      for (final removedMessage in removedMessages) {
        _parentMessageSource.removeMime(
            removedMessage.mimeMessage, removedMessage.mailClient);
      }
    }
    return results;
  }

  @override
  Future<bool> markAllMessagesSeen(bool seen) async {
    cache.markAllMessageSeen(seen);
    final marked = await _mimeSource.markAllMessagesSeen(seen);
    return marked;
  }

  @override
  bool get shouldBlockImages => _mimeSource.shouldBlockImages;

  @override
  bool get isJunk => _mimeSource.isJunk;

  @override
  bool get isArchive => _mimeSource.isArchive;

  @override
  bool get isTrash => _mimeSource.isTrash;

  @override
  bool get supportsMessageFolders => _mimeSource.supportsMessageFolders;

  @override
  bool get supportsSearching => _mimeSource.supportsSearching;

  @override
  MessageSource search(MailSearch search) {
    final searchSource = _mimeSource.search(search);
    final localizations = locator<I18nService>().localizations;
    return MailboxMessageSource.fromMimeSource(
        searchSource,
        localizations.searchQueryDescription(name),
        localizations.searchQueryTitle(search.query),
        parent: this);
  }

  @override
  MimeSource getMimeSource(Message message) {
    return _mimeSource;
  }

  void clear() {
    _mimeSource.clear();
  }
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
  MailboxFlag _flag;

  MultipleMessageSource(this.mimeSources, String name, MailboxFlag flag,
      {MessageSource parent})
      : super(parent: parent) {
    mimeSources.forEach((s) {
      s.addSubscriber(this);
      _multipleMimeSources.add(_MultipleMimeSource(s));
    });
    _name = name;
    _flag = flag;
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
        var date = mime.decodeDate();
        if (date == null) {
          date = DateTime.now();
          print(
              'unable to decode date for $_lastUncachedIndex on ${mimeSources[i].mailClient.account.name} message is empty: ${mime.isEmpty}.');
        }
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
    // print(
    //     'get uncached $index with lastUncachedIndex=$_lastUncachedIndex and size $size');
    int diff = (index - _lastUncachedIndex);
    while (diff > 1) {
      final nextMessage = _next();
      nextMessage.sourceIndex = index - diff;
      cache.add(nextMessage);
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
    final removedMessages = cache.allMessages.toList();
    cache.clear();
    final futures = <Future<List<DeleteResult>>>[];
    for (final mimeSource in mimeSources) {
      futures.add(mimeSource.deleteAllMessages());
    }
    clear();
    notifyListeners();
    if (_parentMessageSource != null) {
      for (final removedMessage in removedMessages) {
        _parentMessageSource.removeMime(
            removedMessage.mimeMessage, removedMessage.mailClient);
      }
    }
    final futureResults = await Future.wait(futures);
    final results = <DeleteResult>[];
    for (final result in futureResults) {
      if (result != null) {
        results.addAll(result);
      }
    }
    return results;
  }

  @override
  MimeSource getMimeSource(Message message) {
    return mimeSources
        .firstWhere((source) => source.mailClient == message.mailClient);
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

  @override
  bool get isTrash => mimeSources.every((source) => source.isTrash);

  @override
  bool get supportsSearching =>
      mimeSources.every((source) => source.supportsSearching);

  @override
  MessageSource search(MailSearch search) {
    final searchMimeSources = <MimeSource>[];
    for (final mimeSource in mimeSources) {
      final searchMimeSource = mimeSource.search(search);
      searchMimeSources.add(searchMimeSource);
    }
    final localizations = locator<I18nService>().localizations;
    final searchMessageSource = MultipleMessageSource(
        searchMimeSources, localizations.searchQueryTitle(search.query), _flag,
        parent: this);
    searchMessageSource._description =
        localizations.searchQueryDescription(name);
    searchMessageSource._supportsDeleteAll = true;
    return searchMessageSource;
  }

  @override
  Future<bool> markAllMessagesSeen(bool seen) async {
    cache.markAllMessageSeen(seen);
    final futures = <Future>[];
    for (final mimeSource in mimeSources) {
      futures.add(mimeSource.markAllMessagesSeen(seen));
    }
    final result = await Future.wait(futures);
    return result.every((element) => element == true);
  }

  @override
  void clear() {
    _lastUncachedIndex = 0;
    for (final multipleSource in _multipleMimeSources) {
      multipleSource.clear();
    }
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
    if (_currentIndex >= mimeSource.size) {
      return null;
    }
    final mime = mimeSource.getMessageAt(_currentIndex);
    _currentIndex++;
    return mime;
  }

  void clear() {
    _currentIndex = 0;
    _currentMessage = null;
    mimeSource.clear();
  }
}

class SingleMessageSource extends MessageSource {
  Message singleMessage;
  SingleMessageSource(MessageSource parent) : super(parent: parent);

  @override
  Message _getUncachedMessage(int index) {
    return singleMessage;
  }

  @override
  Future<List<DeleteResult>> deleteAllMessages() {
    throw UnimplementedError();
  }

  @override
  Future<bool> init() {
    return Future.value(true);
  }

  @override
  bool get isArchive => false;

  @override
  bool get isJunk => false;

  @override
  bool get isTrash => false;

  @override
  MessageSource search(MailSearch search) {
    throw UnimplementedError();
  }

  @override
  bool get shouldBlockImages => false;

  @override
  int get size => 1;

  @override
  bool get supportsMessageFolders => false;

  @override
  bool get supportsSearching => false;

  @override
  Future<void> waitForDownload() {
    return Future.value();
  }

  @override
  MimeSource getMimeSource(Message message) {
    return _parentMessageSource?.getMimeSource(message);
  }

  @override
  Future<bool> markAllMessagesSeen(bool seen) {
    return Future.value(false);
  }

  @override
  void clear() {
    // nothing to implement
  }
}

class ListMessageSource extends MessageSource {
  List<Message> messages;
  ListMessageSource(MessageSource parent) : super(parent: parent);

  @override
  Message _getUncachedMessage(int index) => messages[index];

  @override
  Future<List<DeleteResult>> deleteAllMessages() {
    throw UnimplementedError();
  }

  @override
  Future<bool> init() {
    return Future.value(true);
  }

  @override
  bool get isArchive => false;

  @override
  bool get isJunk => false;

  @override
  bool get isTrash => false;

  @override
  MessageSource search(MailSearch search) {
    throw UnimplementedError();
  }

  @override
  bool get shouldBlockImages => false;

  @override
  int get size => messages.length;

  @override
  bool get supportsMessageFolders => false;

  @override
  bool get supportsSearching => false;

  @override
  Future<void> waitForDownload() {
    return Future.value();
  }

  @override
  MimeSource getMimeSource(Message message) {
    return _parentMessageSource?.getMimeSource(message);
  }

  @override
  Future<bool> markAllMessagesSeen(bool seen) {
    return Future.value(false);
  }

  @override
  void clear() {
    messages.clear();
  }
}

// class ThreadedMailboxMessageSource extends MailboxMessageSource {
//   ThreadedMailboxMessageSource(Mailbox mailbox, MailClient mailClient)
//       : super.fromMimeSource(ThreadedMimeSource(mailbox, mailClient),
//             mailClient.account.email, mailbox?.name) {
//     _mimeSource.addSubscriber(this);
//   }
// }
