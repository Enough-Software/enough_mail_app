import 'dart:async';

import 'package:collection/collection.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/foundation.dart';

import '../logger.dart';
import '../util/indexed_cache.dart';

/// Let other classes get notified about changes in a mime source
abstract class MimeSourceSubscriber {
  ///  Notifies about a single new message
  void onMailArrived(MimeMessage mime, AsyncMimeSource source, {int index = 0});

  ///  Notifies about a single removed message
  void onMailVanished(MimeMessage mime, AsyncMimeSource source);

  ///  Notifies about a flags change for a single message
  void onMailFlagsUpdated(MimeMessage mime, AsyncMimeSource source);

  ///  Notifies about the required to reload the cache
  void onMailCacheInvalidated(AsyncMimeSource source);
}

/// Defines a low level mime message source
abstract class AsyncMimeSource {
  /// Creates a new mime source
  AsyncMimeSource() {
    logger.d('Creating $this / $runtimeType');
  }

  /// The mail client associated with this source
  MailClient get mailClient;

  /// Retrieves the mailbox associated with this source
  Mailbox get mailbox;

  /// The name of this source
  String get name;

  /// Retrieves the size of this source
  int get size;

  /// Is this a source of presumably spam messages?
  bool get isJunk;

  /// Is this a source of already deleted messages?
  bool get isTrash;

  /// Is this a source of sent messages?
  bool get isSent;

  /// Is this a source of archived messages?
  bool get isArchive;

  /// Is this a source for inbox?
  bool get isInbox;

  /// Does this source support deleting all messages?
  bool get supportsDeleteAll;

  /// Does this source support message folders, e.g. for moving?
  bool get supportsMessageFolders;

  /// Does this source support [search]?
  bool get supportsSearching;

  /// Should external resources be blocked for this source?
  bool get shouldBlockImages => isJunk || isTrash;

  /// Searches this source, compare [supportsSearching]
  AsyncMimeSource search(MailSearch search);

  /// Initializes this mime source
  Future<void> init();

  /// Retrieves the message at [index]
  Future<MimeMessage> getMessage(int index);

  /// Deletes the given [messages]
  ///
  /// Compare [deleteAllMessages]
  /// Compare [undoDeleteMessages]
  Future<DeleteResult> deleteMessages(List<MimeMessage> messages);

  /// Reverts the deletion as defined in the [deleteResult]
  Future<DeleteResult> undoDeleteMessages(DeleteResult deleteResult);

  /// Deletes all messages.
  ///
  /// Set [expunge] to `true` to wipe the folder. In that case
  /// the delete operation cannot be undone.
  ///
  /// Compare [deleteMessages]
  Future<List<DeleteResult>> deleteAllMessages({bool expunge = false});

  /// Moves [messages] to [targetMailbox]
  ///
  /// Compare [undoMoveMessages]
  /// Compare [moveMessagesToFlag]
  Future<MoveResult> moveMessages(
    List<MimeMessage> messages,
    Mailbox targetMailbox,
  );

  /// Moves [messages] to the mailbox that is flagged with [targetMailboxFlag]
  ///
  /// Compare [undoMoveMessages]
  /// Compare [moveMessages]
  Future<MoveResult> moveMessagesToFlag(
    List<MimeMessage> messages,
    MailboxFlag targetMailboxFlag,
  );

  /// Reverts the move as defined in the [moveResult]
  Future<MoveResult> undoMoveMessages(MoveResult moveResult);

  /// Adds or removes [flags] to/from the given [messages]
  Future<void> store(
    List<MimeMessage> messages,
    List<String> flags, {
    StoreAction action = StoreAction.add,
  });

  /// Adds or removes [flags]to all messages
  Future<void> storeAll(
    List<String> flags, {
    StoreAction action = StoreAction.add,
  });

  /// Fetches the message contents for the partial [message].
  ///
  /// Compare [MailClient]'s `fetchMessageContents()` call.
  Future<MimeMessage> fetchMessageContents(
    MimeMessage message, {
    int? maxSize,
    bool markAsSeen = false,
    List<MediaToptype>? includedInlineTypes,
    Duration? responseTimeout,
  });

  /// Fetches a message part / attachment for the partial [mimeMessage].
  ///
  /// Compare [MailClient]'s `fetchMessagePart()` call.
  Future<MimePart> fetchMessagePart(
    MimeMessage message, {
    required String fetchId,
    Duration? responseTimeout,
  });

  /// Informs this source about a new incoming [message]
  /// at the optional [index].
  ///
  /// Note this message does not necessarily match to this sources.
  Future<void> onMessageArrived(MimeMessage message, {int? index});

  /// Informs this source about the [sequence] having been removed
  /// on the server.
  Future<void> onMessagesVanished(MessageSequence sequence);

  /// Is called when message flags have been updated on the server.
  Future<void> onMessageFlagsUpdated(MimeMessage message);

  /// Cleans up any resources
  void dispose();

  /// Clears this source
  void clear();

  /// Synchronizes messages manually after reconnecting to a mail service
  /// that does not support QRESYNC.
  ///
  /// This call will receive the latest 20 (or less) messages
  /// retrieved from the service.
  Future<void> resyncMessagesManually(
    List<MimeMessage> messages,
  );

  final _subscribers = <MimeSourceSubscriber>[];

  /// Adds a subscriber
  void addSubscriber(MimeSourceSubscriber subscriber) {
    _subscribers.add(subscriber);
  }

  /// Removes a subscriber
  void removeSubscriber(MimeSourceSubscriber subscriber) {
    _subscribers.remove(subscriber);
  }

  /// Notifies subscribers about a new mime message
  void notifySubscriberOnMessageArrived(MimeMessage mime) {
    for (final subscriber in _subscribers) {
      logger.d('$this: notify subscriber $subscriber');
      subscriber.onMailArrived(mime, this);
    }
  }

  /// Notifies subscribers about a message that has been removed on the server
  void notifySubscribersOnMessageVanished(MimeMessage mime) {
    for (final subscriber in _subscribers) {
      subscriber.onMailVanished(mime, this);
    }
  }

  /// Notifies subscribers about a message for which the flags have changed
  /// on the server
  void notifySubscribersOnMessageFlagsUpdated(MimeMessage mime) {
    for (final subscriber in _subscribers) {
      subscriber.onMailFlagsUpdated(mime, this);
    }
  }

  /// Notifies subscribers about an invalidated cache for this source
  void notifySubscribersOnCacheInvalidated() {
    for (final subscriber in _subscribers) {
      subscriber.onMailCacheInvalidated(this);
    }
  }

  /// Sends the specified [message].
  ///
  /// Use [MessageBuilder] to create new messages.
  ///
  /// Specify [from] as the originator in case it differs from the `From`
  /// header of the message.
  ///
  /// Optionally set [appendToSent] to `false` in case the message should NOT
  /// be appended to the SENT folder.
  /// By default the message is appended. Note that some mail providers
  /// automatically append sent messages to
  /// the SENT folder, this is not detected by this API.
  ///
  /// You can also specify if the message should be sent using 8 bit encoding
  /// with [use8BitEncoding], which default to `false`.
  ///
  /// Optionally specify the [recipients], in which case the recipients
  /// defined in the message are ignored.
  ///
  /// Optionally specify the [sentMailbox] when the mail system does not
  /// support mailbox flags.
  Future<void> sendMessage(
    MimeMessage message, {
    MailAddress? from,
    bool appendToSent = true,
    Mailbox? sentMailbox,
    bool use8BitEncoding = false,
    List<MailAddress>? recipients,
  });
}

/// Keeps messages in a temporary cache
abstract class CachedMimeSource extends AsyncMimeSource {
  /// Creates a new cached mime source
  CachedMimeSource({int maxCacheSize = IndexedCache.defaultMaxCacheSize})
      : cache = IndexedCache<MimeMessage>(maxCacheSize: maxCacheSize);

  /// The cache for the received mime messages
  final IndexedCache<MimeMessage> cache;

  @override
  Future<MimeMessage> getMessage(int index) {
    final existingMessage = cache[index];
    if (existingMessage != null) {
      return Future.value(existingMessage);
    }

    return loadMessage(index);
  }

  /// Loads the message at the given index
  Future<MimeMessage> loadMessage(int index);

  @override
  Future<void> onMessageArrived(MimeMessage message, {int? index}) async {
    final usedIndex = await addMessage(message, index: index);
    notifySubscriberOnMessageArrived(message);

    return handleOnMessageArrived(usedIndex, message);
  }

  /// Adds the [message] and retrieves the used cache index.
  Future<int> addMessage(MimeMessage message, {int? index}) {
    int findIndex(DateTime? messageDate) {
      if (messageDate == null) {
        return 0;
      }
      final now = DateTime.now();
      var i = 0;
      while (cache[i] != null &&
          (cache[i]?.decodeDate() ?? now).isAfter(messageDate)) {
        i++;
      }

      return i;
    }

    final usedIndex = index ?? findIndex(message.decodeDate());
    cache.insert(usedIndex, message);

    return Future.value(usedIndex);
  }

  /// Handles a newly arrived message.
  ///
  /// Called from [onMessageArrived]
  Future<void> handleOnMessageArrived(int index, MimeMessage message);

  @override
  Future<void> onMessagesVanished(MessageSequence sequence) {
    bool uidMatcher(MimeMessage message, int uid) => message.uid == uid;
    bool sequenceIdMatcher(MimeMessage message, int sequenceId) =>
        message.sequenceId == sequenceId;
    bool uidLargerMatcher(MimeMessage message, int uid) =>
        (message.uid ?? 0) > uid;
    bool sequenceIdLargerMatcher(MimeMessage message, int sequenceId) =>
        (message.sequenceId ?? 0) > sequenceId;
    final messages = <MimeMessage>[];
    final equalsMatcher =
        sequence.isUidSequence ? uidMatcher : sequenceIdMatcher;
    final largerMatcher =
        sequence.isUidSequence ? uidLargerMatcher : sequenceIdLargerMatcher;

    final ids = sequence.toList()..sort((a, b) => b.compareTo(a));
    for (final id in ids) {
      final mime = cache.removeFirstWhere((m) => equalsMatcher(m, id));

      cache.forEachWhere(
        (m) => largerMatcher(m, id),
        (m) => m.sequenceId = (m.sequenceId ?? id) - 1,
      );
      if (mime != null) {
        notifySubscribersOnMessageVanished(mime);
        messages.add(mime);
      }
    }

    return handleOnMessagesVanished(messages);
  }

  /// Handles messages being deleted from service.
  ///
  /// Is called from [onMessagesVanished]
  Future<void> handleOnMessagesVanished(List<MimeMessage> messages);

  /// Deletes the [messages] from the cache
  void removeFromCache(List<MimeMessage> messages) {
    for (final message in messages) {
      cache.removeFirstWhere((element) => element.guid == message.guid);
    }
  }

  @override
  void clear() {
    cache.clear();
  }

  @override
  Future<void> onMessageFlagsUpdated(MimeMessage message) {
    final guid = message.guid;
    final sequenceId = message.sequenceId;
    final existing = guid != null
        ? cache.firstWhereOrNull(
            (element) => element.guid == guid,
          )
        : cache.firstWhereOrNull(
            (element) => element.sequenceId == sequenceId,
          );
    if (existing != null) {
      existing.flags = message.flags;
    }
    notifySubscribersOnMessageFlagsUpdated(existing ?? message);

    return Future.value();
  }

  @override
  Future<void> resyncMessagesManually(
    List<MimeMessage> messages,
  ) async {
    // when mail server does not support QRESYNC, compare the latest messages
    // and check for changed flags (seen, flagged, ...) or vanished messages
    // fetch and compare the 20 latest messages:

    // For each message check for the following cases:
    // - message can be new (it will have a higher UID that the known
    // first message)
    // - message can have updated flags (GUID will still be the same)
    // - a previously cached message can now be deleted (sequence ID will match,
    //   but not the UID/GUID)
    //
    // Additional complications occur when not the same number of first messages
    //  are cached,
    // in that case the GUID/UID cannot be compared.
    //
    // Also, previously there might have been less messages in this
    // mime source than are now loaded.

    final firstCached = cache[0];
    final firstCachedUid = firstCached?.uid;
    if (firstCachedUid == null) {
      // When the latest message is not known, better reload all.
      // TODO(RV): Should a reload also be triggered when other messages are
      // not cached?
      cache.clear();
      notifySubscribersOnCacheInvalidated();

      return init();
    }
    // ensure not to change the underlying set of messages in case overrides
    // want to handle the messages as well:
    final messagesCopy = [...messages];

    // detect new messages:
    final newMessages = messagesCopy
        .where((message) => (message.uid ?? 0) > firstCachedUid)
        .toList();

    for (var i = newMessages.length; --i >= 0;) {
      final message = newMessages.elementAt(i);
      await onMessageArrived(message);
      messagesCopy.remove(message);
    }
    if (messagesCopy.isEmpty) {
      // only new messages have appeared... probably a sign to reload completely
      return;
    }
    final cachedMessages = List.generate(
      messagesCopy.length,
      (index) => cache[index + newMessages.length],
    );

    // detect removed messages:
    final removedMessages = List<MimeMessage>.from(
      cachedMessages.where((cached) =>
          cached != null &&
          messagesCopy.firstWhereOrNull((m) => m.guid == cached.guid) == null),
    );
    if (removedMessages.isNotEmpty) {
      final sequence = MessageSequence(isUidSequence: true);
      for (final removed in removedMessages) {
        final uid = removed.uid;
        if (uid != null) {
          sequence.add(uid);
        }
        cachedMessages.remove(removed);
      }
      if (sequence.isNotEmpty) {
        await onMessagesVanished(sequence);
      }
    }

    // detect messages with changed flags:
    final areListsEqual = const ListEquality().equals;
    for (final cached in cachedMessages) {
      if (cached != null) {
        final newMessage =
            messagesCopy.firstWhereOrNull((m) => m.guid == cached.guid);
        if (newMessage != null &&
            !areListsEqual(newMessage.flags, cached.flags)) {
          await onMessageFlagsUpdated(newMessage);
        }
      }
    }
  }
}

/// Keeps messages in a temporary cache and accesses them page-wise
abstract class PagedCachedMimeSource extends CachedMimeSource {
  /// Creates a new paged cached mime source
  PagedCachedMimeSource({
    this.pageSize = 30,
    super.maxCacheSize,
  });

  /// The size of a single page
  final int pageSize;

  final _pageLoadersByPageIndex = <int, Future<List<MimeMessage>>>{};

  @override
  Future<MimeMessage> loadMessage(int index) async {
    Future<List<MimeMessage>> queue(int pageIndex) {
      final sequence = MessageSequence.fromPage(pageIndex + 1, pageSize, size);
      final future = loadMessages(sequence);
      _pageLoadersByPageIndex[pageIndex] = future;

      return future;
    }

    final pageIndex = index ~/ pageSize;
    final completer = _pageLoadersByPageIndex[pageIndex] ?? queue(pageIndex);
    try {
      final messages = await completer;
      final int pageEndIndex = pageIndex * pageSize + messages.length - 1;
      if (cache[pageEndIndex] == null) {
        // messages have not been added by another thread yet:
        final receivingDate = DateTime.now();
        messages.sort((m1, m2) => (m1.decodeDate() ?? receivingDate)
            .compareTo(m2.decodeDate() ?? receivingDate));
        await _pageLoadersByPageIndex.remove(pageIndex);
        for (int i = 0; i < messages.length; i++) {
          final cacheIndex = pageEndIndex - i;
          final message = messages[i];
          cache[cacheIndex] = message;
        }
      }

      return messages[pageEndIndex - index];
    } on MailException {
      await _pageLoadersByPageIndex.remove(pageIndex);
      rethrow;
    }
  }

  /// Loads the messages defined by the [sequence]
  Future<List<MimeMessage>> loadMessages(MessageSequence sequence);
}

/// Provides online access to a specific mailbox
class AsyncMailboxMimeSource extends PagedCachedMimeSource {
  /// Creates a new mailbox source
  AsyncMailboxMimeSource(this.mailbox, this.mailClient);

  /// The mailbox
  @override
  final Mailbox mailbox;

  @override
  final MailClient mailClient;

  StreamSubscription<MailLoadEvent>? _mailLoadEventSubscription;
  StreamSubscription<MailVanishedEvent>? _mailVanishedEventSubscription;
  StreamSubscription<MailUpdateEvent>? _mailUpdatedEventSubscription;
  StreamSubscription<MailConnectionReEstablishedEvent>?
      _mailReconnectedEventSubscription;

  @override
  Future<void> init() {
    if (_mailLoadEventSubscription != null) {
      return Future.value();
    }

    _registerEvents();

    return mailClient.startPolling();
  }

  @override
  void dispose() {
    _deregisterEvents();
  }

  void _registerEvents() {
    _mailLoadEventSubscription =
        mailClient.eventBus.on<MailLoadEvent>().listen((event) {
      if (event.mailClient == mailClient) {
        onMessageArrived(event.message);
      }
    });
    _mailVanishedEventSubscription =
        mailClient.eventBus.on<MailVanishedEvent>().listen((event) {
      final sequence = event.sequence;
      if (sequence != null && event.mailClient == mailClient) {
        onMessagesVanished(sequence);
      }
    });
    _mailUpdatedEventSubscription =
        mailClient.eventBus.on<MailUpdateEvent>().listen((event) {
      if (event.mailClient == mailClient) {
        onMessageFlagsUpdated(event.message);
      }
    });
    _mailReconnectedEventSubscription = mailClient.eventBus
        .on<MailConnectionReEstablishedEvent>()
        .listen(_onMailReconnected);
  }

  void _deregisterEvents() {
    _mailLoadEventSubscription?.cancel();
    _mailVanishedEventSubscription?.cancel();
    _mailUpdatedEventSubscription?.cancel();
    _mailReconnectedEventSubscription?.cancel();
    _mailLoadEventSubscription = null;
    _mailVanishedEventSubscription = null;
    _mailUpdatedEventSubscription = null;
    _mailReconnectedEventSubscription = null;
  }

  Future<void> _onMailReconnected(
    MailConnectionReEstablishedEvent event,
  ) async {
    if (event.mailClient == mailClient &&
        event.isManualSynchronizationRequired) {
      final messages = await event.mailClient
          .fetchMessages(fetchPreference: FetchPreference.envelope);
      if (messages.isEmpty) {
        logger.w(
          'MESSAGES ARE EMPTY FOR '
          '${event.mailClient.lowLevelOutgoingMailClient.logName}',
        );
        // since this is an unlikely outcome, the assumption is that this
        // an error and resync will be aborted, therefore.

        return;
      }
      await resyncMessagesManually(messages);
    }
  }

  @override
  Future<DeleteResult> deleteMessages(List<MimeMessage> messages) {
    removeFromCache(messages);
    final sequence = MessageSequence.fromMessages(messages);

    return mailClient.deleteMessages(sequence, messages: messages);
  }

  @override
  Future<DeleteResult> undoDeleteMessages(DeleteResult deleteResult) async {
    final result = await mailClient.undoDeleteMessages(deleteResult);
    await _reAddMessages(result);

    return result;
  }

  @override
  Future<List<DeleteResult>> deleteAllMessages({bool expunge = false}) async {
    clear();
    mailbox.messagesExists = 0;

    final result =
        await mailClient.deleteAllMessages(mailbox, expunge: expunge);

    return [result];
  }

  @override
  Future<MoveResult> moveMessages(
    List<MimeMessage> messages,
    Mailbox targetMailbox,
  ) {
    removeFromCache(messages);
    final sequence = MessageSequence.fromMessages(messages);

    return mailClient.moveMessages(sequence, targetMailbox, messages: messages);
  }

  @override
  Future<MoveResult> moveMessagesToFlag(
    List<MimeMessage> messages,
    MailboxFlag targetMailboxFlag,
  ) {
    removeFromCache(messages);
    final sequence = MessageSequence.fromMessages(messages);

    return mailClient.moveMessagesToFlag(
      sequence,
      targetMailboxFlag,
      messages: messages,
    );
  }

  @override
  Future<MoveResult> undoMoveMessages(MoveResult moveResult) async {
    final result = await mailClient.undoMoveMessages(moveResult);
    await _reAddMessages(result);

    return result;
  }

  Future<void> _reAddMessages(MessagesOperationResult result) async {
    final messages = result.messages;
    if (messages != null) {
      for (final message in messages) {
        await addMessage(message);
      }
    }
  }

  @override
  Future<void> store(
    List<MimeMessage> messages,
    List<String> flags, {
    StoreAction action = StoreAction.add,
  }) {
    final sequence = MessageSequence.fromMessages(messages);

    return mailClient.store(sequence, flags, action: action);
  }

  @override
  Future<void> storeAll(
    List<String> flags, {
    StoreAction action = StoreAction.add,
  }) {
    final sequence = MessageSequence.fromAll();

    return mailClient.store(sequence, flags, action: action);
  }

  @override
  bool get isArchive => mailbox.isArchive;

  @override
  bool get isJunk => mailbox.isJunk;

  @override
  bool get isSent => mailbox.isSent;

  @override
  bool get isTrash => mailbox.isTrash;

  @override
  bool get isInbox => mailbox.isInbox;

  @override
  String get name => mailbox.name;

  @override
  AsyncMimeSource search(MailSearch search) =>
      AsyncSearchMimeSource(search, mailbox, mailClient, this);

  @override
  int get size => mailbox.messagesExists;

  @override
  bool get supportsDeleteAll => isTrash || isJunk;

  @override
  bool get supportsMessageFolders => (mailClient.mailboxes?.length ?? 0) > 0;

  @override
  bool get supportsSearching => true;

  @override
  Future<List<MimeMessage>> loadMessages(MessageSequence sequence) =>
      mailClient.fetchMessageSequence(
        sequence,
        fetchPreference: FetchPreference.envelope,
      );

  @override
  Future<void> handleOnMessageArrived(int index, MimeMessage message) =>
      Future.value();

  @override
  Future<void> handleOnMessagesVanished(List<MimeMessage> messages) =>
      Future.value();

  @override
  Future<MimeMessage> fetchMessageContents(
    MimeMessage message, {
    int? maxSize,
    bool markAsSeen = false,
    List<MediaToptype>? includedInlineTypes,
    Duration? responseTimeout,
  }) =>
      mailClient.fetchMessageContents(
        message,
        maxSize: maxSize,
        markAsSeen: markAsSeen,
        includedInlineTypes: includedInlineTypes,
        responseTimeout: responseTimeout,
      );

  @override
  Future<MimePart> fetchMessagePart(
    MimeMessage message, {
    required String fetchId,
    Duration? responseTimeout,
  }) =>
      mailClient.fetchMessagePart(
        message,
        fetchId,
        responseTimeout: responseTimeout,
      );

  @override
  Future<void> sendMessage(
    MimeMessage message, {
    MailAddress? from,
    bool appendToSent = true,
    Mailbox? sentMailbox,
    bool use8BitEncoding = false,
    List<MailAddress>? recipients,
  }) =>
      mailClient.sendMessage(
        message,
        from: from,
        appendToSent: appendToSent,
        sentMailbox: sentMailbox,
        use8BitEncoding: use8BitEncoding,
        recipients: recipients,
      );

  @override
  String toString() => 'AsyncMailboxMimeSource(${mailClient.account.email}: '
      '${mailbox.name})';
}

/// Accesses search results
class AsyncSearchMimeSource extends AsyncMimeSource {
  /// Creates a new search mime source
  AsyncSearchMimeSource(
    this.mailSearch,
    this.mailbox,
    this.mailClient,
    this.parent,
  );

  /// The search terms
  final MailSearch mailSearch;

  /// The mailbox on which the search is done
  @override
  final Mailbox mailbox;

  /// The parent mime source
  final AsyncMimeSource parent;

  /// The search result
  late MailSearchResult searchResult;

  @override
  int get size => searchResult.length;

  @override
  final MailClient mailClient;

  @override
  Future<void> init() async {
    try {
      searchResult = await mailClient.searchMessages(mailSearch);
    } catch (e, s) {
      searchResult = MailSearchResult.empty(mailSearch);
      if (kDebugMode) {
        print('Unable to search: $e $s');
      }
    }
  }

  @override
  Future<List<DeleteResult>> deleteAllMessages({bool expunge = false}) async {
    if (size == 0) {
      return [];
    }
    final sequence = searchResult.pagedSequence.sequence;
    clear();
    final deleteResult = await mailClient.deleteMessages(sequence);

    return [deleteResult];
  }

  @override
  bool get isArchive => mailbox.isArchive;

  @override
  bool get isJunk => mailbox.isJunk;

  @override
  bool get isTrash => mailbox.isTrash;

  @override
  bool get isSent => mailbox.isSent;

  @override
  bool get isInbox => mailbox.isInbox;

  @override
  String get name => mailSearch.query;

  @override
  bool get shouldBlockImages => isTrash || isJunk;

  @override
  bool get supportsSearching => false;

  @override
  bool get supportsDeleteAll => searchResult.isNotEmpty;

  @override
  void clear() {
    searchResult = MailSearchResult.empty(mailSearch);
  }

  @override
  Future<DeleteResult> deleteMessages(List<MimeMessage> messages) async {
    final sequence = MessageSequence.fromMessages(messages);
    searchResult.removeMessageSequence(sequence);

    return parent.deleteMessages(messages);
  }

  @override
  Future<DeleteResult> undoDeleteMessages(DeleteResult deleteResult) {
    // TODO(RV): add sequence back to search result - or rather
    // the sequence after undoing it
    //searchResult.addMessageSequence(deleteResult.originalSequence);

    return parent.undoDeleteMessages(deleteResult);
  }

  @override
  void dispose() {
    // nothing to dispose
  }

  @override
  Future<MimeMessage> getMessage(int index) =>
      searchResult.getMessage(index, mailClient, mailbox: mailbox);

  @override
  Future<void> onMessageArrived(MimeMessage message, {int? index}) {
    if (mailSearch.matches(message)) {
      searchResult.addMessage(message);
      notifySubscriberOnMessageArrived(message);
    }

    return Future.value();
  }

  @override
  Future<void> onMessageFlagsUpdated(MimeMessage message) {
    final uid = message.uid;
    final existing =
        searchResult.messages.firstWhereOrNull((m) => m.uid == uid);
    if (existing != null) {
      existing.flags = message.flags;
      notifySubscribersOnMessageFlagsUpdated(existing);
    }

    return Future.value();
  }

  @override
  Future<void> onMessagesVanished(MessageSequence sequence) {
    if (sequence.isUidSequence == searchResult.pagedSequence.isUidSequence) {
      searchResult
          .removeMessageSequence(sequence)
          .forEach(notifySubscribersOnMessageVanished);
    }

    return Future.value();
  }

  @override
  Future<void> store(
    List<MimeMessage> messages,
    List<String> flags, {
    StoreAction action = StoreAction.add,
  }) =>
      parent.store(messages, flags, action: action);

  @override
  Future<void> storeAll(
    List<String> flags, {
    StoreAction action = StoreAction.add,
  }) async {
    final sequence = searchResult.pagedSequence.sequence;
    if (sequence.isEmpty) {
      return Future.value();
    }
    await mailClient.store(sequence, flags, action: action);
  }

  @override
  bool get supportsMessageFolders => parent.supportsMessageFolders;

  @override
  Future<void> resyncMessagesManually(List<MimeMessage> messages) {
    // just redo the full search for now.
    notifySubscribersOnCacheInvalidated();

    return init();
  }

  @override
  AsyncMimeSource search(MailSearch search) {
    throw UnimplementedError();
  }

  @override
  Future<MoveResult> moveMessages(
    List<MimeMessage> messages,
    Mailbox targetMailbox,
  ) {
    // TODO(RV): implement moveMessages
    throw UnimplementedError();
  }

  @override
  Future<MoveResult> moveMessagesToFlag(
    List<MimeMessage> messages,
    MailboxFlag targetMailboxFlag,
  ) {
    // TODO(RV): implement moveMessagesToFlag
    throw UnimplementedError();
  }

  @override
  Future<MoveResult> undoMoveMessages(MoveResult moveResult) {
    // TODO(RV): implement undoMoveMessages
    throw UnimplementedError();
  }

  @override
  Future<MimeMessage> fetchMessageContents(
    MimeMessage message, {
    int? maxSize,
    bool markAsSeen = false,
    List<MediaToptype>? includedInlineTypes,
    Duration? responseTimeout,
  }) =>
      mailClient.fetchMessageContents(
        message,
        maxSize: maxSize,
        markAsSeen: markAsSeen,
        includedInlineTypes: includedInlineTypes,
        responseTimeout: responseTimeout,
      );

  @override
  Future<MimePart> fetchMessagePart(
    MimeMessage message, {
    required String fetchId,
    Duration? responseTimeout,
  }) =>
      mailClient.fetchMessagePart(
        message,
        fetchId,
        responseTimeout: responseTimeout,
      );

  @override
  Future<void> sendMessage(
    MimeMessage message, {
    MailAddress? from,
    bool appendToSent = true,
    Mailbox? sentMailbox,
    bool use8BitEncoding = false,
    List<MailAddress>? recipients,
  }) =>
      mailClient.sendMessage(
        message,
        from: from,
        appendToSent: appendToSent,
        sentMailbox: sentMailbox,
        use8BitEncoding: use8BitEncoding,
        recipients: recipients,
      );
}
