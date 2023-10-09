import 'package:collection/collection.dart' show IterableExtension;
import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/foundation.dart';

import '../account/model.dart';
import '../locator.dart';
import '../logger.dart';
import '../services/i18n_service.dart';
import '../services/notification_service.dart';
import '../services/scaffold_messenger_service.dart';
import '../util/indexed_cache.dart';
import 'async_mime_source.dart';
import 'message.dart';

/// Manages messages
abstract class MessageSource extends ChangeNotifier
    implements MimeSourceSubscriber {
  /// Creates a new message source with the optional [parent].
  ///
  /// Set [isSearch] to `true` in case this message source is deemed
  /// to be a search.
  MessageSource({MessageSource? parent, this.isSearch = false})
      : _parentMessageSource = parent;

  /// Retrieves the parent source's name
  String? get parentName => _parentMessageSource?.name;

  /// The number of messages in this source
  int get size;

  /// Is the source empty?
  ///
  /// Compare [size]
  bool get isEmpty => size == 0;

  /// The cache for messages
  final cache = IndexedCache<Message>();

  String? _description;

  /// the description of this source
  String? get description => _description;

  set description(String? value) {
    _description = value;
    notifyListeners();
  }

  String? _name;

  /// The name of this source
  String? get name => _name;
  set name(String? value) {
    _name = value;
    notifyListeners();
  }

  /// The account associated with this source
  Account get account;

  bool _supportsDeleteAll = false;

  /// Does this source support to delete all messages?
  ///
  /// Compare [deleteAllMessages] and [markAllMessagesSeen]
  bool get supportsDeleteAll => _supportsDeleteAll;
  set supportsDeleteAll(bool value) {
    _supportsDeleteAll = value;
    notifyListeners();
  }

  final MessageSource? _parentMessageSource;

  /// Is this message source a search?
  final bool isSearch;

  bool get shouldBlockImages;
  bool get isJunk;
  bool get isArchive;
  bool get isTrash;
  bool get isSent;
  bool get supportsMessageFolders;
  bool get supportsSearching;

  /// Initializes this source
  Future<void> init();

  /// Deletes all messages
  ///
  /// Only available when [supportsDeleteAll] is `true`
  Future<List<DeleteResult>> deleteAllMessages({bool expunge = false});

  /// Marks all messages as seen (read) `true` or unseen (unread) when `false` is given
  ///
  /// Only available when [supportsDeleteAll] is `true`
  Future<void> markAllMessagesSeen(bool seen);

  /// Retrieves the message for the given [index]
  Future<Message> getMessageAt(int index) async {
    var message = cache[index];
    if (message == null) {
      message = await loadMessage(index);
      cache[index] = message;
    }

    return message;
  }

  /// Loads the message for the given [index]
  Future<Message> loadMessage(int index);

  /// Retrieves the next message
  Future<Message?> next(Message current) {
    if (current.sourceIndex >= size - 1) {
      return Future.value();
    }

    return getMessageAt(current.sourceIndex + 1);
  }

  /// Retrieves the previous message
  Future<Message?> previous(Message current) {
    if (current.sourceIndex == 0) {
      return Future.value();
    }

    return getMessageAt(current.sourceIndex - 1);
  }

  /// Retrieves the mime source for the given [message]
  AsyncMimeSource? getMimeSource(Message message);

  /// Removes the given message from the internally used cache
  bool removeFromCache(Message message, {bool notify = true}) {
    final removed = cache.remove(message);
    if (removed) {
      final sourceIndex = message.sourceIndex;
      cache.forEachWhere(
        (msg) => msg.sourceIndex > sourceIndex,
        (msg) => msg.sourceIndex--,
      );
    }
    final parent = _parentMessageSource;
    if (parent != null) {
      final mime = message.mimeMessage;
      parent.removeMime(mime);
    }
    if (removed && notify) {
      notifyListeners();
    }

    return removed;
  }

  @override
  void onMailFlagsUpdated(MimeMessage mime, AsyncMimeSource source) {
    final message = cache.getWithMime(mime);
    if (message != null) {
      message.updateFlags(mime.flags);
    }
  }

  @override
  void onMailVanished(MimeMessage mime, AsyncMimeSource source) {
    final message = cache.getWithMime(mime);

    if (message != null) {
      removeFromCache(message);
    }
  }

  @override
  void onMailArrived(
    MimeMessage mime,
    AsyncMimeSource source, {
    int index = 0,
  }) {
    // the source index is 0 since this is the new first message:
    final message = Message(mime, this, index);
    insertIntoCache(index, message);
    notifyListeners();
  }

  /// Inserts the [message] at the given [index].
  void insertIntoCache(int index, Message message) {
    cache.insert(index, message);
  }

  /// Deletes the given message
  ///
  /// Just forwards to [deleteMessages]
  @Deprecated('use deleteMessages instead')
  Future<void> deleteMessage(Message message) => deleteMessages(
        [message],
        locator<I18nService>().localizations.resultDeleted,
      );

  /// Deletes the given messages
  Future<void> deleteMessages(
    List<Message> messages,
    String notification,
  ) {
    final notificationService = locator<NotificationService>();
    for (final message in messages) {
      _removeMessageFromCacheAndCancelNotification(
        message,
        notificationService,
        notify: false,
      );
    }
    notifyListeners();

    return _deleteMessages(messages, notification);
  }

  Future<void> _deleteMessages(
    List<Message> messages,
    String notification,
  ) async {
    final messagesBySource = orderByMimeSource(messages);
    final resultsBySource = <AsyncMimeSource, DeleteResult>{};
    for (final source in messagesBySource.keys) {
      final mimes = messagesBySource[source]!;
      final deleteResult = await source.deleteMessages(mimes);
      if (deleteResult.canUndo) {
        resultsBySource[source] = deleteResult;
      }
    }
    locator<ScaffoldMessengerService>().showTextSnackBar(
      notification,
      undo: resultsBySource.isEmpty
          ? null
          : () async {
              for (final source in resultsBySource.keys) {
                await source.undoDeleteMessages(resultsBySource[source]!);
              }
              _reAddMessages(messages);
              notifyListeners();
            },
    );
  }

  Future<void> markAsJunk(Message message) => moveMessageToFlag(
        message,
        MailboxFlag.junk,
        locator<I18nService>().localizations.resultMovedToJunk,
      );

  Future<void> markAsNotJunk(Message message) => moveMessageToFlag(
        message,
        MailboxFlag.inbox,
        locator<I18nService>().localizations.resultMovedToInbox,
      );

  Future<void> moveMessageToFlag(
    Message message,
    MailboxFlag targetMailboxFlag,
    String notification,
  ) =>
      moveMessage(
        message,
        message.source
                .getMimeSource(message)
                ?.mailClient
                .getMailbox(targetMailboxFlag) ??
            Mailbox(
              encodedName: 'inbox',
              encodedPath: 'inbox',
              flags: [],
              pathSeparator: '/',
            ),
        notification,
      );

  Future<void> moveMessage(
    Message message,
    Mailbox targetMailbox,
    String notification,
  ) async {
    _removeMessageFromCacheAndCancelNotification(
      message,
      locator<NotificationService>(),
      notify: false,
    );
    final mailClient = message.source.getMimeSource(message)?.mailClient;
    if (mailClient == null) {
      throw Exception('Unable to retrieve mime source for $message');
    }
    final moveResult =
        await mailClient.moveMessage(message.mimeMessage, targetMailbox);
    notifyListeners();
    if (moveResult.canUndo) {
      locator<ScaffoldMessengerService>().showTextSnackBar(
        notification,
        undo: () async {
          await mailClient.undoMoveMessages(moveResult);
          insertIntoCache(message.sourceIndex, message);
          notifyListeners();
        },
      );
    }
  }

  void _removeMessageFromCacheAndCancelNotification(
    Message message,
    NotificationService notificationService, {
    bool notify = true,
  }) {
    notificationService.cancelNotificationForMailMessage(message);
    removeFromCache(message, notify: notify);
  }

  Future<void> moveMessagesToFlag(
    List<Message> messages,
    MailboxFlag targetMailboxFlag,
    String notification,
  ) async {
    final notificationService = locator<NotificationService>();
    for (final message in messages) {
      _removeMessageFromCacheAndCancelNotification(
        message,
        notificationService,
        notify: false,
      );
    }
    final messagesBySource = orderByMimeSource(messages);
    final resultsBySource = <AsyncMimeSource, MoveResult>{};
    for (final source in messagesBySource.keys) {
      final messages = messagesBySource[source]!;
      final moveResult =
          await source.moveMessagesToFlag(messages, targetMailboxFlag);
      if (moveResult.canUndo) {
        resultsBySource[source] = moveResult;
      }
    }
    notifyListeners();
    if (resultsBySource.isNotEmpty) {
      locator<ScaffoldMessengerService>().showTextSnackBar(
        notification,
        undo: () async {
          for (final source in resultsBySource.keys) {
            await source.undoMoveMessages(resultsBySource[source]!);
          }
          _reAddMessages(messages);
          notifyListeners();
        },
      );
    }
  }

  Future<void> moveMessages(
    List<Message> messages,
    Mailbox targetMailbox,
    String notification,
  ) async {
    final notificationService = locator<NotificationService>();
    for (final message in messages) {
      _removeMessageFromCacheAndCancelNotification(
        message,
        notificationService,
        notify: false,
      );
    }
    final source = getMimeSource(messages.first);
    final parent = _parentMessageSource;
    if (source != null) {
      final mimes = messages.map((m) => m.mimeMessage).toList();
      final moveResult = await source.moveMessages(mimes, targetMailbox);
      notifyListeners();
      locator<ScaffoldMessengerService>().showTextSnackBar(
        notification,
        undo: moveResult.canUndo
            ? () async {
                await source.undoMoveMessages(moveResult);
                _reAddMessages(messages);
                notifyListeners();
              }
            : null,
      );
    } else if (parent != null) {
      return parent.moveMessages(messages, targetMailbox, notification);
    }
  }

  void _reAddMessages(List<Message> messages) {
    messages.sort((m1, m2) => m1.sourceIndex.compareTo(m2.sourceIndex));
    for (final message in messages) {
      insertIntoCache(message.sourceIndex, message);
    }
  }

  Future<void> moveToInbox(Message message) async => moveMessageToFlag(
        message,
        MailboxFlag.inbox,
        locator<I18nService>().localizations.resultMovedToInbox,
      );

  Future<void> archive(Message message) => moveMessageToFlag(
        message,
        MailboxFlag.archive,
        locator<I18nService>().localizations.resultArchived,
      );

  Future<void> markAsSeen(Message msg, bool isSeen) {
    final source = getMimeSource(msg);
    if (source != null) {
      onMarkedAsSeen(msg, isSeen);
      if (isSeen) {
        locator<NotificationService>().cancelNotificationForMailMessage(msg);
      }

      return source.store([msg.mimeMessage], [MessageFlags.seen]);
    }
    msg.isSeen = isSeen;
    final parent = _parentMessageSource;
    final parentMsg = parent?.cache.getWithMime(msg.mimeMessage);
    if (parent != null && parentMsg != null) {
      return parent.markAsSeen(parentMsg, isSeen);
    }

    return msg.source.storeMessageFlags(
      [msg],
      [MessageFlags.seen],
      action: isSeen ? StoreAction.add : StoreAction.remove,
    );
  }

  void onMarkedAsSeen(Message msg, bool isSeen) {
    msg.isSeen = isSeen;
    final parent = _parentMessageSource;
    if (parent != null) {
      final parentMsg = parent.cache.getWithMime(msg.mimeMessage);
      if (parentMsg != null) {
        parent.onMarkedAsSeen(parentMsg, isSeen);
      }
    }
  }

  Future<void> markAsFlagged(Message msg, bool isFlagged) {
    onMarkedAsFlagged(msg, isFlagged);

    return msg.source.storeMessageFlags(
      [msg],
      [MessageFlags.flagged],
      action: isFlagged ? StoreAction.add : StoreAction.remove,
    );
  }

  void onMarkedAsFlagged(Message msg, bool isFlagged) {
    msg.isFlagged = isFlagged;
    final parent = _parentMessageSource;
    if (parent != null) {
      final parentMsg = parent.cache.getWithMime(msg.mimeMessage);
      if (parentMsg != null) {
        parent.onMarkedAsFlagged(parentMsg, isFlagged);
      }
    }
  }

  Future<void> markMessagesAsSeen(List<Message> messages, bool isSeen) {
    final notificationService = locator<NotificationService>();
    for (final msg in messages) {
      onMarkedAsSeen(msg, isSeen);
      if (isSeen) {
        notificationService.cancelNotificationForMailMessage(msg);
      }
    }

    return storeMessageFlags(
      messages,
      [MessageFlags.seen],
      action: isSeen ? StoreAction.add : StoreAction.remove,
    );
  }

  Future<void> markMessagesAsFlagged(List<Message> messages, bool flagged) {
    for (final msg in messages) {
      msg.isFlagged = flagged;
    }

    return storeMessageFlags(
      messages,
      [MessageFlags.flagged],
      action: flagged ? StoreAction.add : StoreAction.remove,
    );
  }

  Map<AsyncMimeSource, List<MimeMessage>> orderByMimeSource(
    List<Message> messages,
  ) {
    final mimesBySource = <AsyncMimeSource, List<MimeMessage>>{};
    for (final message in messages) {
      final source = getMimeSource(message);
      if (source == null) {
        if (kDebugMode) {
          print(
              'unable to locate mime-source for message ${message.mimeMessage}');
        }
        continue;
      }
      final existingMessages = mimesBySource[source];
      if (existingMessages != null) {
        existingMessages.add(message.mimeMessage);
      } else {
        mimesBySource[source] = [message.mimeMessage];
      }
    }

    return mimesBySource;
  }

  // Map<MailClient, MessageSequence> orderByClient(List<Message?> messages) {
  //   final sequenceByClient = <MailClient, MessageSequence>{};
  //   for (final msg in messages) {
  //     final client = msg!.mailClient;
  //     if (sequenceByClient.containsKey(client)) {
  //       sequenceByClient[client]!.addMessage(msg.mimeMessage);
  //     } else {
  //       sequenceByClient[client] = MessageSequence.fromMessage(msg.mimeMessage);
  //     }
  //   }
  //   return sequenceByClient;
  // }

  Future<void> storeMessageFlags(
    List<Message> messages,
    List<String> flags, {
    StoreAction action = StoreAction.add,
  }) {
    final messagesBySource = orderByMimeSource(messages);
    final futures = <Future<void>>[];
    for (final source in messagesBySource.keys) {
      final messages = messagesBySource[source]!;
      final future = source.store(messages, flags, action: action);
      futures.add(future);
    }
    return Future.wait(futures);
  }

  MessageSource search(MailSearch search);

  void removeMime(MimeMessage mimeMessage) {
    final existingMessage = cache.getWithMime(mimeMessage);
    if (existingMessage != null) {
      removeFromCache(existingMessage);
    }
  }

  Future<void> refresh() async {
    clear();
    cache.clear();
    await init();
    notifyListeners();
  }

  void clear();

  /// Fetches the message contents for the partial [message].
  ///
  /// Compare [MailClient]'s `fetchMessageContents()` call.
  Future<MimeMessage> fetchMessageContents(
    Message message, {
    int? maxSize,
    bool markAsSeen = false,
    List<MediaToptype>? includedInlineTypes,
    Duration? responseTimeout,
  }) async {
    final mimeSource = getMimeSource(message);
    if (mimeSource == null) {
      throw Exception('Unable to detect mime source from $message');
    }

    final mimeMessage = await mimeSource.fetchMessageContents(
      message.mimeMessage,
      maxSize: maxSize,
      markAsSeen: markAsSeen,
      includedInlineTypes: includedInlineTypes,
      responseTimeout: responseTimeout,
    );
    message.updateMime(mimeMessage);

    return mimeMessage;
  }

  /// Fetches the message contents for the partial [message].
  ///
  /// Compare [MailClient]'s `fetchMessagePart()` call.
  Future<MimePart> fetchMessagePart(
    Message message, {
    required String fetchId,
    Duration? responseTimeout,
  }) {
    final mimeSource = getMimeSource(message);
    if (mimeSource == null) {
      throw Exception('Unable to detect mime source from $message');
    }

    return mimeSource.fetchMessagePart(
      message.mimeMessage,
      fetchId: fetchId,
      responseTimeout: responseTimeout,
    );
  }

  // void replaceMime(Message message, MimeMessage mime) {
  //   final mimeSource = getMimeSource(message);
  //   remove(message);
  //   mimeSource.addMessage(mime);
  //   onMailAdded(mime, mimeSource);
  // }
}

class MailboxMessageSource extends MessageSource {
  MailboxMessageSource.fromMimeSource(
    this._mimeSource,
    String description,
    String name, {
    required this.account,
    super.parent,
    super.isSearch,
  }) {
    _description = description;
    _name = name;
    _mimeSource.addSubscriber(this);
  }

  @override
  final RealAccount account;

  @override
  int get size => _mimeSource.size;

  final AsyncMimeSource _mimeSource;

  @override
  void dispose() {
    _mimeSource.removeSubscriber(this);
    _mimeSource.dispose();
    super.dispose();
  }

  @override
  Future<Message> loadMessage(int index) async {
    //print('get uncached $index');
    final mime = await _mimeSource.getMessage(index);

    return Message(mime, this, index);
  }

  @override
  Future<void> init() async {
    await _mimeSource.init();
    name ??= _mimeSource.name;
    supportsDeleteAll = _mimeSource.supportsDeleteAll;
  }

  @override
  Future<List<DeleteResult>> deleteAllMessages({bool expunge = false}) async {
    final removedMessages = cache.getAllCachedEntries();
    cache.clear();
    final futureResults = _mimeSource.deleteAllMessages(expunge: expunge);
    clear();
    notifyListeners();
    final results = await futureResults;
    final parent = _parentMessageSource;
    if (parent != null) {
      for (final removedMessage in removedMessages) {
        final mime = removedMessage.mimeMessage;
        parent.removeMime(mime);
      }
    }

    return results;
  }

  @override
  Future<bool> markAllMessagesSeen(bool seen) async {
    cache.markAllMessageSeen(seen);
    await _mimeSource.storeAll(
      [MessageFlags.seen],
      action: seen ? StoreAction.add : StoreAction.remove,
    );

    return true;
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
  bool get isSent => _mimeSource.isSent;

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
      localizations.searchQueryDescription(name!),
      localizations.searchQueryTitle(search.query),
      account: account,
      parent: this,
      isSearch: true,
    );
  }

  @override
  AsyncMimeSource? getMimeSource(Message message) => _mimeSource;

  @override
  void clear() {
    cache.clear();
    _mimeSource.clear();
  }

  @override
  void onMailCacheInvalidated(AsyncMimeSource source) {
    cache.clear();
    notifyListeners();
  }
}

class _MultipleMessageSourceId {
  const _MultipleMessageSourceId(this.source, this.index);
  final AsyncMimeSource source;
  final int index;
}

/// Provides a unified source of several messages sources.
/// Each message is ordered by date
class MultipleMessageSource extends MessageSource {
  /// Creates a new [MultipleMessageSource]
  MultipleMessageSource(
    this.mimeSources,
    String name,
    MailboxFlag? flag, {
    required this.account,
    super.parent,
    super.isSearch,
  }) {
    for (final s in mimeSources) {
      s.addSubscriber(this);
      _multipleMimeSources.add(_MultipleMimeSource(s));
    }
    _name = name;
    _flag = flag;
    _description = mimeSources.map((s) => s.mailClient.account.name).join(', ');
  }

  @override
  final UnifiedAccount account;

  @override
  Future<void> init() async {
    final futures = mimeSources.map((source) => source.init());
    await Future.wait(futures);
    supportsDeleteAll = mimeSources.any((s) => s.supportsDeleteAll);
  }

  /// The integrated mime sources
  final List<AsyncMimeSource> mimeSources;
  final _multipleMimeSources = <_MultipleMimeSource>[];
  MailboxFlag? _flag;
  final _indicesCache = <_MultipleMessageSourceId>[];

  @override
  int get size {
    var complete = 0;
    for (final s in mimeSources) {
      complete += s.size;
    }
    //print('MultipleMessageSource.size: $complete');

    return complete;
  }

  @override
  void dispose() {
    for (final s in mimeSources) {
      s
        ..removeSubscriber(this)
        ..dispose();
    }
    super.dispose();
  }

  Future<Message> _next(int index) async {
    final previousCall = index == 0 ? null : _nextCalls[index - 1];
    if (previousCall != null) {
      // ensure that messages are retrieved sequentially
      await previousCall;
    }
    _MultipleMimeSourceMessage? newestMessage;
    final futures = _multipleMimeSources.map((source) => source.peek());
    final sourceMessages = await Future.wait(futures);
    DateTime? newestTime;
    for (final sourceMessage in sourceMessages) {
      if (sourceMessage != null) {
        var date = sourceMessage.mimeMessage.decodeDate();
        if (date == null) {
          date = DateTime.now();
          if (kDebugMode) {
            print('unable to decode date for $index on '
                '${sourceMessage.source.mimeSource.mailClient.account.name} '
                'message is empty: ${sourceMessage.mimeMessage.isEmpty}.');
          }
        }
        if (newestTime == null || date.isAfter(newestTime)) {
          newestMessage = sourceMessage;
          newestTime = date;
        }
      }
    }
    if (newestMessage == null) {
      throw Exception('Unable to get next message for index $index');
    }
    newestMessage.source.pop();
    // newestSource._currentIndex could have changed in the meantime
    _indicesCache.add(
      _MultipleMessageSourceId(
        newestMessage.source.mimeSource,
        newestMessage.index,
      ),
    );

    final message = _UnifiedMessage(
      newestMessage.mimeMessage,
      this,
      index,
      newestMessage.source.mimeSource,
    );

    return message;
  }

  @override
  Future<Message> loadMessage(int index) async {
    if (index < _indicesCache.length) {
      final id = _indicesCache[index];
      final mime = await id.source.getMessage(id.index);

      return _UnifiedMessage(mime, this, index, id.source);
    }
    // print(
    //     'get uncached $index with lastUncachedIndex=$_lastUncachedIndex and size $size');
    int diff = index - _indicesCache.length;
    while (diff > 0) {
      final sourceIndex = index - diff;
      await getMessageAt(sourceIndex);
      diff--;
    }
    var nextCall = _nextCalls[index];
    if (nextCall == null) {
      nextCall = _next(index);
      _nextCalls[index] = nextCall;
    }
    final nextMessage = await nextCall;
    await _nextCalls.remove(index);

    return nextMessage;
  }

  final _nextCalls = <int, Future<Message>>{};

  @override
  bool removeFromCache(Message message, {bool notify = true}) {
    _indicesCache.removeAt(message.sourceIndex);

    return super.removeFromCache(message, notify: notify);
  }

  @override
  Future<List<DeleteResult>> deleteAllMessages({bool expunge = false}) async {
    final removedMessages = cache.getAllCachedEntries();
    cache.clear();
    _indicesCache.clear();
    final futures = <Future<List<DeleteResult>>>[];
    for (final multipleMimeSource in _multipleMimeSources) {
      futures.add(multipleMimeSource.deleteAllMessages(expunge: expunge));
    }
    notifyListeners();
    final parent = _parentMessageSource;
    if (parent != null) {
      for (final removedMessage in removedMessages) {
        parent.removeMime(removedMessage.mimeMessage);
      }
    }
    final futureResults = await Future.wait(futures);
    final results = <DeleteResult>[];

    futureResults.forEach(results.addAll);

    return results;
  }

  @override
  AsyncMimeSource getMimeSource(Message message) {
    if (message is _UnifiedMessage) {
      return message.mimeSource;
    }
    logger.e('Unable to retrieve mime source for $message');

    return mimeSources.first;
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
  bool get isSent => mimeSources.every((source) => source.isSent);

  @override
  bool get supportsSearching =>
      mimeSources.any((source) => source.supportsSearching);

  @override
  MessageSource search(MailSearch search) {
    final searchMimeSources = mimeSources
        .where((source) => source.supportsSearching)
        .map((source) => source.search(search))
        .toList();
    final localizations = locator<I18nService>().localizations;
    final searchMessageSource = MultipleMessageSource(
      searchMimeSources,
      localizations.searchQueryTitle(search.query),
      _flag,
      account: account,
      parent: this,
      isSearch: true,
    );
    searchMessageSource._description =
        localizations.searchQueryDescription(name ?? '');

    return searchMessageSource;
  }

  @override
  Future<void> markAllMessagesSeen(bool seen) async {
    cache.markAllMessageSeen(seen);
    final futures = <Future>[];
    for (final mimeSource in mimeSources) {
      futures.add(mimeSource.storeAll([MessageFlags.seen]));
    }
    await Future.wait(futures);
  }

  @override
  void insertIntoCache(int index, Message message) {
    final mimeSource = getMimeSource(message);
    _indicesCache.insert(index, _MultipleMessageSourceId(mimeSource, index));
    final multipleSource = _multipleMimeSources
        .firstWhereOrNull((element) => element.mimeSource == mimeSource);
    multipleSource?.onMailArrived();
    for (var i = index + 1; i < _indicesCache.length; i++) {
      final id = _indicesCache[i];
      if (id.source == mimeSource) {
        _indicesCache[i] = _MultipleMessageSourceId(mimeSource, id.index + 1);
      }
    }
    super.insertIntoCache(index, message);
  }

  @override
  void onMailArrived(
    MimeMessage mime,
    AsyncMimeSource source, {
    int index = 0,
  }) {
    // find out index:
    final mimeDate = mime.decodeDate() ?? DateTime.now();
    var msgIndex = 0;
    while (cache[msgIndex] != null &&
        (cache[msgIndex]?.mimeMessage.decodeDate()?.isAfter(mimeDate) ??
            false)) {
      msgIndex++;
    }
    super.onMailArrived(mime, source, index: msgIndex);
  }

  @override
  void onMailCacheInvalidated(AsyncMimeSource source) {
    _indicesCache.clear();
    _nextCalls.clear();
    cache.clear();
    for (final multipleSource in _multipleMimeSources) {
      multipleSource.onMailCacheInvalidated();
    }
    notifyListeners();
  }

  @override
  void clear() {
    _indicesCache.clear();
    _nextCalls.clear();
    for (final multipleSource in _multipleMimeSources) {
      multipleSource.clear();
    }
  }
}

class _UnifiedMessage extends Message {
  _UnifiedMessage(
    super.mimeMessage,
    super.source,
    super.sourceIndex,
    this.mimeSource,
  );

  final AsyncMimeSource mimeSource;
}

class _MultipleMimeSourceMessage {
  const _MultipleMimeSourceMessage(this.index, this.source, this.mimeMessage);
  final int index;
  final _MultipleMimeSource source;
  final MimeMessage mimeMessage;
}

class _MultipleMimeSource {
  _MultipleMimeSource(this.mimeSource);
  final AsyncMimeSource mimeSource;
  int _currentIndex = 0;
  _MultipleMimeSourceMessage? _currentMessage;

  Future<_MultipleMimeSourceMessage?> peek() async {
    _currentMessage ??= await _next();

    return _currentMessage;
  }

  void pop() {
    _currentMessage = null;
  }

  Future<_MultipleMimeSourceMessage?> _next() async {
    final index = _currentIndex;
    if (index >= mimeSource.size) {
      return null;
    }
    _currentIndex++;
    final mime = await mimeSource.getMessage(index);

    return _MultipleMimeSourceMessage(index, this, mime);
  }

  void clear() {
    _currentIndex = 0;
    _currentMessage = null;
    mimeSource.clear();
  }

  Future<List<DeleteResult>> deleteAllMessages({required bool expunge}) {
    if (mimeSource.supportsDeleteAll) {
      _currentIndex = 0;
      _currentMessage = null;
      return mimeSource.deleteAllMessages(expunge: expunge);
    }
    return Future.value([]);
  }

  void onMailCacheInvalidated() {
    _currentIndex = 0;
    _currentMessage = null;
  }

  void onMailArrived() {
    _currentIndex++;
  }
}

class SingleMessageSource extends MessageSource {
  SingleMessageSource(MessageSource? parent, {required this.account})
      : super(parent: parent);
  Message? singleMessage;

  @override
  final Account account;

  @override
  Future<Message> loadMessage(int index) => Future.value(singleMessage);

  @override
  Future<List<DeleteResult>> deleteAllMessages({bool expunge = false}) {
    throw UnimplementedError();
  }

  @override
  Future<void> init() => Future.value();

  @override
  bool get isArchive => false;

  @override
  bool get isJunk => false;

  @override
  bool get isTrash => false;

  @override
  bool get isSent => false;

  @override
  MessageSource search(MailSearch search) {
    throw UnimplementedError();
  }

  @override
  bool get shouldBlockImages => false;

  @override
  int get size => 1;

  @override
  bool get supportsMessageFolders =>
      _parentMessageSource?.supportsMessageFolders ?? false;

  @override
  bool get supportsSearching => false;

  @override
  AsyncMimeSource? getMimeSource(Message message) =>
      _parentMessageSource?.getMimeSource(message);

  @override
  Future<void> markAllMessagesSeen(bool seen) => Future.value();

  @override
  void clear() {
    // nothing to implement
  }

  @override
  void onMailCacheInvalidated(AsyncMimeSource source) {
    // TODO: implement onMailCacheInvalidated
  }
}

class ListMessageSource extends MessageSource {
  ListMessageSource(
    MessageSource parent,
  )   : account = parent.account,
        super(parent: parent);

  late List<Message> messages;

  @override
  final Account account;

  void initWithMimeMessages(
    List<MimeMessage> mimeMessages, {
    bool reverse = true,
  }) {
    var result = mimeMessages
        .mapIndexed((index, mime) => Message(mime, this, index))
        .toList();
    if (reverse) {
      result = result.reversed.toList();
    }
    messages = result;
  }

  @override
  Future<Message> loadMessage(int index) => Future.value(messages[index]);

  @override
  Future<List<DeleteResult>> deleteAllMessages({bool expunge = false}) {
    throw UnimplementedError();
  }

  @override
  Future<void> init() => Future.value();

  @override
  bool get isArchive => false;

  @override
  bool get isJunk => false;

  @override
  bool get isTrash => false;

  @override
  bool get isSent => false;

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
  AsyncMimeSource? getMimeSource(Message message) =>
      _parentMessageSource?.getMimeSource(message);

  @override
  Future<void> markAllMessagesSeen(bool seen) => Future.value();

  @override
  void clear() {
    messages.clear();
  }

  @override
  void onMailCacheInvalidated(AsyncMimeSource source) {
    // TODO: implement onMailCacheInvalidated
  }
}

class ErrorMessageSource extends MessageSource {
  ErrorMessageSource(this.account);
  @override
  final Account account;

  @override
  Future<Message> loadMessage(int index) {
    throw UnimplementedError();
  }

  @override
  void clear() {}

  @override
  Future<List<DeleteResult>> deleteAllMessages({bool expunge = false}) {
    throw UnimplementedError();
  }

  @override
  AsyncMimeSource getMimeSource(Message message) {
    throw UnimplementedError();
  }

  @override
  Future<void> init() => Future.value();

  @override
  bool get isArchive => false;

  @override
  bool get isJunk => false;

  @override
  bool get isTrash => false;

  @override
  bool get isSent => false;

  @override
  Future<void> markAllMessagesSeen(bool seen) {
    throw UnimplementedError();
  }

  @override
  MessageSource search(MailSearch search) {
    throw UnimplementedError();
  }

  @override
  bool get shouldBlockImages => false;

  @override
  int get size => 0;

  @override
  bool get supportsMessageFolders => false;

  @override
  bool get supportsSearching => false;

  @override
  void onMailCacheInvalidated(AsyncMimeSource source) {
    // TODO: implement onMailCacheInvalidated
  }
}

// class ThreadedMailboxMessageSource extends MailboxMessageSource {
//   ThreadedMailboxMessageSource(Mailbox mailbox, MailClient mailClient)
//       : super.fromMimeSource(ThreadedMimeSource(mailbox, mailClient),
//             mailClient.account.email, mailbox?.name) {
//     _mimeSource.addSubscriber(this);
//   }
// }

extension _ExtensionsOnMessageIndexedCache on IndexedCache<Message> {
  Message? getWithMime(MimeMessage mime) {
    final guid = mime.guid;
    if (guid != null) {
      return firstWhereOrNull(
        (msg) => msg.mimeMessage.guid == guid,
      );
    }

    return null;
  }

  // Message? getWithSourceIndex(int sourceIndex, MailClient mailClient) =>
  //     firstWhereOrNull((msg) =>
  //         msg.mailClient == mailClient && msg.sourceIndex == sourceIndex);

  void markAllMessageSeen(bool seen) {
    final messages = getAllCachedEntries();
    for (final message in messages) {
      message.isSeen = seen;
    }
  }
}
