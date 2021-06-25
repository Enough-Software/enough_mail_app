import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/mime_cache.dart';
import 'package:enough_mail_app/services/app_service.dart';
import 'dart:async';

import 'package:enough_mail_app/services/notification_service.dart';

import '../locator.dart';

abstract class MimeSourceSubscriber {
  void onMailLoaded(MimeMessage mime, int mimeSourceIndex, MimeSource source);
  void onMailAdded(MimeMessage mime, MimeSource source);
  void onMailVanished(MimeMessage mime, MimeSource source);
  void onMailFlagsUpdated(MimeMessage mime, MimeSource source);
}

abstract class MimeSource {
  final MailClient mailClient;
  int get size;
  final _subscribers = <MimeSourceSubscriber>[];
  late StreamSubscription<MailLoadEvent> _mailLoadEventSubscription;
  late StreamSubscription<MailVanishedEvent> _mailVanishedEventSubscription;
  late StreamSubscription<MailUpdateEvent> _mailUpdatedEventSubscription;
  Future? _downloadFuture;
  Future? get downloadFuture => _downloadFuture;

  String? get name;

  bool get suppportsDeleteAll;

  bool get isSequenceIdBased;

  MimeSource search(MailSearch search);

  bool get supportsMessageFolders => (mailClient.mailboxes?.length != 0);
  bool get shouldBlockImages => isJunk || isTrash;

  bool get isJunk;
  bool get isTrash;

  bool get isArchive;

  Future<List<DeleteResult>> deleteAllMessages();

  bool get supportsSearching;

  MimeSource(this.mailClient, {MimeSourceSubscriber? subscriber}) {
    if (subscriber != null) {
      _subscribers.add(subscriber);
    }
    _registerEvents();
  }

  Future<bool> init();

  void remove(MimeMessage? mimeMessage);

  void dispose() {
    _deregisterEvents();
  }

  void addSubscriber(MimeSourceSubscriber subscriber) {
    _subscribers.add(subscriber);
  }

  void removeSubscriber(MimeSourceSubscriber subscriber) {
    _subscribers.remove(subscriber);
  }

  MimeMessage? getMessageAt(int index);

  void addMessage(MimeMessage message);

  void _registerEvents() {
    _mailLoadEventSubscription =
        mailClient.eventBus.on<MailLoadEvent>().listen(_onMessageAdded);
    _mailVanishedEventSubscription =
        mailClient.eventBus.on<MailVanishedEvent>().listen(_onMessageVanished);
    _mailUpdatedEventSubscription =
        mailClient.eventBus.on<MailUpdateEvent>().listen(_onMailFlagsUpdated);
  }

  void _deregisterEvents() {
    _mailLoadEventSubscription.cancel();
    _mailVanishedEventSubscription.cancel();
    _mailUpdatedEventSubscription.cancel();
  }

  void _onMessageAdded(MailLoadEvent e) {
    print('${DateTime.now()}: ${e.message.decodeSubject()}');
    if (e.mailClient == mailClient) {
      bool sendNotification;
      if (matches(e.message)) {
        addMessage(e.message);
        _notifyMessageAdded(e.message);
        sendNotification = locator<AppService>()
            .isInBackground; // it should also show a notification when the user is on a different page...
        //TODO update uidNext for background service
      } else {
        sendNotification = true;
      }
      if (sendNotification) {
        locator<NotificationService>().sendLocalNotificationForMailLoadEvent(e);
      }
    }
    // else {
    //   locator<ScaffoldService>().showTextSnackBar(e.message.decodeSubject());
    // }
  }

  /// Checks if the specified new [messages] matches this mime source.
  /// The default implementation always returns true.
  bool matches(MimeMessage message) {
    return true;
  }

  void _notifyMessageAdded(MimeMessage mime) {
    for (final subscriber in _subscribers) {
      subscriber.onMailAdded(mime, this);
    }
  }

  void removeVanishedMessages(MessageSequence? sequence);

  void _onMessageVanished(MailVanishedEvent e) {
    if (!e.isEarlier && e.mailClient == mailClient) {
      removeVanishedMessages(e.sequence);
    }
  }

  void _notifyVanished(MimeMessage mime) {
    for (final subscriber in _subscribers) {
      subscriber.onMailVanished(mime, this);
    }
  }

  void _onMailFlagsUpdated(MailUpdateEvent e) {
    if (e.mailClient == mailClient) {
      _notifyFlagsUpdated(e.message);
      // //final uid = e.message.uid;
      // final sequenceId = e.message.sequenceId;
      // var message = _getMessageFromCache(sequenceId);
      // // uid != null
      // //     ? messages.firstWhere((m) => m.mimeMessage.uid == uid,
      // //         orElse: () => null)
      // //     : messages.firstWhere((m) => m.mimeMessage.sequenceId == sequenceId,
      // //         orElse: () => null);
      // // print(
      // //     'message updated: uid=$uid, id=$sequenceId, flags=${e.message.flags}. Found existing message: $message');
      // if (message != null) {
      //   _notifyFlagsUpdated(message);
      // }
    }
  }

  void _notifyFlagsUpdated(MimeMessage mime) {
    for (final subscriber in _subscribers) {
      subscriber.onMailFlagsUpdated(mime, this);
    }
  }

  void _notifyLoaded(MimeMessage mime, int sourceIndex) {
    for (final subscriber in _subscribers) {
      subscriber.onMailLoaded(mime, sourceIndex, this);
    }
  }

  /// Marks all messages as seen (read) `true` or unseen (unread) when `false` is given
  ///
  /// Only available when `supportsDeleteAll` is `true`
  /// Returns `true` when the call succeeded
  Future<bool> markAllMessagesSeen(bool seen);

  void clear();
}

class MailboxMimeSource extends MimeSource {
  Mailbox? mailbox;
  int? messagesExistAtInit;
  final _requestedPages = <int>[];
  final _cache = MimeCache();
  final int pageSize;

  @override
  int get size => mailbox?.messagesExists ?? 0;

  @override
  String? get name => mailbox?.name;

  @override
  bool get suppportsDeleteAll =>
      (mailbox != null) && (mailbox!.isTrash || mailbox!.isJunk);

  @override
  bool get isJunk => mailbox?.isJunk ?? false;

  @override
  bool get isTrash => mailbox?.isTrash ?? false;

  @override
  bool get isArchive => mailbox?.isArchive ?? false;

  @override
  bool get supportsSearching => true;

  MailboxMimeSource(MailClient mailClient, this.mailbox,
      {this.pageSize = 40, MimeSourceSubscriber? subscriber})
      : super(mailClient, subscriber: subscriber);

  @override
  Future<bool> init() async {
    try {
      if (mailbox == null) {
        mailbox = await mailClient.selectInbox();
      } else {
        mailbox = await mailClient.selectMailbox(mailbox!);
      }
      messagesExistAtInit = mailbox!.messagesExists;
      if (messagesExistAtInit! > 0) {
        // pre-cache first page:
        if (mailClient.supportsThreading &&
            !(mailbox!.isTrash ||
                mailbox!.isSent ||
                mailbox!.isDrafts ||
                mailbox!.isJunk)) {
          final since = DateTime.now().subtract(const Duration(days: 90));
          await mailClient.fetchThreadData(
              since: since, setThreadSequences: true);
        }
        await _download(0);
      }
      return true;
    } catch (e, s) {
      print('Error while initializing mime source for $mailbox: $e $s');
      return false;
    }
  }

  @override
  void addMessage(MimeMessage message) {
    _cache.insert(message);
  }

  @override
  void removeVanishedMessages(MessageSequence? sequence) {
    final ids = sequence!.toList();
    MimeMessage? message;
    for (var id in ids) {
      if (sequence.isUidSequence == true) {
        message = _cache.getForUid(id);
      } else {
        message = _cache.getForSequenceId(id);
      }
      if (message != null) {
        _cache.remove(message);
      }
      if (message != null) {
        _notifyVanished(message);
      }
    }
  }

  @override
  Future<List<DeleteResult>> deleteAllMessages() async {
    final deleteResult = await mailClient.deleteAllMessages(mailbox!);
    mailbox!.messagesExists = 0;
    return [deleteResult];
  }

  @override
  void remove(MimeMessage? mimeMessage) {
    mailbox?.messagesExists--;
    _cache.remove(mimeMessage);
  }

  @override
  MimeSource search(MailSearch search) {
    return SearchMimeSource(mailClient, search, mailbox);
  }

  @override
  MimeMessage? getMessageAt(int index) {
    //print('getMessageAt($index)');
    if (index >= size) {
      throw StateError('Invalid index $index for MimeSource with size $size');
    }
    final existingMessage = _cache[index];
    if (existingMessage == null) {
      final pageIndex = index ~/ pageSize;
      if (!_requestedPages.contains(pageIndex)) {
        _queue(pageIndex);
      }
    }
    //print('getMessageAt($index) yields ID $sequenceId');
    return existingMessage;
  }

  // MimeMessage _getMessageFromCache(int sequenceId) {
  //   return _cache.firstWhere((m) => m.sequenceId == sequenceId,
  //       orElse: () => null);
  // }

  // MimeMessage _getMessageFromCacheWithUid(int uid) {
  //   return _cache.firstWhere((m) => m.uid == uid, orElse: () => null);
  // }

  void _queue(int pageIndex) {
    //print('queuing $pageIndex');
    _requestedPages.insert(0, pageIndex);
    if (_requestedPages.length > 5) {
      // just skip the olded referenced messages
      _requestedPages.removeLast();
    }
    if (_requestedPages.length == 1) {
      _downloadFuture = _download(pageIndex);
    }
  }

  Future<void> _download(int pageIndex) async {
    // print('downloading $pageIndex');
    await mailClient.stopPollingIfNeeded();
    final sequence =
        MessageSequence.fromPage(pageIndex + 1, pageSize, messagesExistAtInit);
    final mimeMessages = await mailClient.fetchMessageSequence(sequence,
        fetchPreference: FetchPreference.envelope);
    _requestedPages.remove(pageIndex);
    final now = DateTime.now();
    mimeMessages.sort(
        (m1, m2) => (m2.decodeDate() ?? now).compareTo(m1.decodeDate() ?? now));
    var sourceIndex = pageIndex * pageSize;
    _cache.addAll(mimeMessages, sourceIndex);
    for (final mime in mimeMessages) {
      // print('$sourceIndex: ${mime.decodeDate()}: ${mime.decodeSubject()}');
      _notifyLoaded(mime, sourceIndex);
      sourceIndex++;
    }

    if (_requestedPages.isNotEmpty) {
      pageIndex = _requestedPages.first;
      _downloadFuture = _download(pageIndex);
    } else {
      mailClient.startPolling();
    }
  }

  @override
  bool get isSequenceIdBased => true;

  @override
  Future<bool> markAllMessagesSeen(bool seen) async {
    final sequence = MessageSequence.fromAll();
    try {
      await mailClient.store(sequence, [MessageFlags.seen],
          action: seen ? StoreAction.add : StoreAction.remove);
      return true;
    } catch (e, s) {
      print('unable to mark all messages as seen($seen): $e $s');
    }
    return false;
  }

  @override
  void clear() {
    _cache.clear();
    _requestedPages.clear();
    mailbox!.messagesExists = 0;
    //mailbox = Mailbox()..messagesExists = 0;
  }
}

class SearchMimeSource extends MimeSource {
  final MailSearch mailSearch;
  final Mailbox? mailbox;
  late MailSearchResult searchResult;
  @override
  int get size => searchResult.length;

  SearchMimeSource(MailClient mailClient, this.mailSearch, this.mailbox)
      : super(mailClient);

  @override
  Future<bool> init() async {
    searchResult = await mailClient.searchMessages(mailSearch);
    return true;
  }

  @override
  Future<List<DeleteResult>> deleteAllMessages() async {
    if (size == 0) {
      return [];
    }
    final deleteResult =
        await mailClient.deleteMessages(searchResult.pagedSequence.sequence);
    searchResult = MailSearchResult.empty(mailSearch);
    return [deleteResult];
  }

  @override
  matches(MimeMessage message) {
    return mailSearch.matches(message);
  }

  @override
  bool get isArchive => mailbox!.isArchive;

  @override
  bool get isJunk => mailbox!.isJunk;

  @override
  bool get isTrash => mailbox!.isTrash;

  @override
  String get name => mailSearch.query;

  @override
  MimeSource search(MailSearch search) {
    throw UnimplementedError();
  }

  @override
  bool get shouldBlockImages => isTrash || isJunk;

  @override
  bool get supportsSearching => false;

  @override
  bool get suppportsDeleteAll => true;

  @override
  MimeMessage? getMessageAt(int index) {
    if (searchResult.isAvailable(index)) {
      return searchResult[index];
    }
    if (!searchResult.isPageRequestedFor(index)) {
      _downloadFuture =
          mailClient.searchMessagesNextPage(searchResult).then((messages) {
        var sourceIndex = searchResult.pagedSequence.pageSize *
            (index ~/ searchResult.pagedSequence.pageSize);
        for (final mime in messages) {
          _notifyLoaded(mime, sourceIndex);
          sourceIndex++;
        }
      });
    }
    return null;
    // final message = MimeMessage();
    // final id = searchResult.messageIdAt(index);
    // print('getMessageAt($index) yields empty $id');
    // if (searchResult.isUidBased) {
    //   message.uid = id;
    // } else {
    //   message.sequenceId = id;
    // }
    // return message;
  }

  @override
  void addMessage(MimeMessage message) {
    searchResult.addMessage(message);
  }

  @override
  void remove(MimeMessage? mimeMessage) {
    searchResult.removeMessage(mimeMessage!);
  }

  @override
  void removeVanishedMessages(MessageSequence? sequence) {
    final messages = searchResult.removeMessageSequence(sequence!);
    for (final message in messages) {
      _notifyVanished(message);
    }
  }

  @override
  bool get isSequenceIdBased => !searchResult.isUidBased;

  @override
  Future<bool> markAllMessagesSeen(bool seen) async {
    final sequence = searchResult.pagedSequence.sequence;

    if (sequence.isEmpty) {
      return Future.value(true);
    }
    try {
      await mailClient.store(sequence, [MessageFlags.seen],
          action: seen ? StoreAction.add : StoreAction.remove);
      return true;
    } catch (e, s) {
      print('unable to mark searched message sequence as seen($seen): $e $s');
    }
    return false;
  }

  @override
  void clear() {
    searchResult = MailSearchResult.empty(mailSearch);
  }
}

// class CachedMimeMessage {
//   final MimeMessage mimeMessage;
//   final int sourceIndex;
//   CachedMimeMessage(this.mimeMessage, this.sourceIndex);
// }

// class ThreadedMimeSource extends MimeSource {
//   Mailbox mailbox;
//   ThreadResult threadResult;

//   @override
//   bool get isArchive => mailbox.isArchive;

//   @override
//   bool get isJunk => mailbox.isJunk;

//   @override
//   bool get isSequenceIdBased => false;

//   @override
//   bool get isTrash => mailbox.isTrash;

//   @override
//   String get name => mailbox.name;

//   @override
//   int get size => threadResult
//       .length; //there can be more messages, depending on the used `since` parameter

//   ThreadedMimeSource(this.mailbox, MailClient mailClient,
//       {MimeSourceSubscriber subscriber})
//       : super(mailClient, subscriber: subscriber);

//   @override
//   Future<bool> init() async {
//     if (mailbox == null) {
//       mailbox = await mailClient.selectInbox();
//     }
//     final since = DateTime.now().subtract(const Duration(days: 90));
//     threadResult = await mailClient.fetchThreads(
//       mailbox: mailbox,
//       since: since,
//       threadPreference: ThreadPreference.latest,
//       fetchPreference: FetchPreference.envelope,
//       pageSize: 40,
//     );
//     return true;
//   }

//   @override
//   MimeMessage getMessageAt(int index) {
//     int sourceIndex = threadResult.length - (index + 1);
//     final thread = threadResult[sourceIndex];
//     if (thread != null) {
//       return thread.latest;
//     }
//     final id = threadResult.threadData[sourceIndex].latestId;
//     print(
//         'thread at $index: needs to be loaded for ${threadResult.isUidBased ? 'uid' : 'seqId'} $id');
//     final mime = MimeMessage();
//     if (threadResult.isUidBased) {
//       mime.uid = id;
//     } else {
//       mime.sequenceId = id;
//     }
//     // this fetches n pages for n unloaded messages:
//     if (!threadResult.isPageRequestedFor(sourceIndex)) {
//       print('request next page for $index');
//       _downloadFuture =
//           mailClient.fetchThreadsNextPage(threadResult).then((messages) {
//         for (final mime in messages) {
//           _notifyLoaded(mime);
//         }
//       });
//     }
//     return mime;
//   }

//   @override
//   void addMessage(MimeMessage message) {
//     // TODO: implement addMessage
//   }

//   @override
//   Future<List<DeleteResult>> deleteAllMessages() {
//     // TODO: implement deleteAllMessages
//     throw UnimplementedError();
//   }

//   @override
//   Future<bool> markAllMessagesSeen(bool seen) {
//     // TODO: implement markAllMessagesSeen
//     throw UnimplementedError();
//   }

//   @override
//   void remove(MimeMessage mimeMessage) {
//     // TODO: implement remove
//   }

//   @override
//   void removeVanishedMessages(MessageSequence sequence) {
//     // TODO: implement removeVanishedMessages
//   }

//   @override
//   MimeSource search(MailSearch search) {
//     // TODO: implement search
//     throw UnimplementedError();
//   }

//   @override
//   // TODO: implement supportsSearching
//   bool get supportsSearching => false;

//   @override
//   // TODO: implement suppportsDeleteAll
//   bool get suppportsDeleteAll => false;

//   @override
//   void clear() {
//     // TODO: implement clear
//   }
// }
