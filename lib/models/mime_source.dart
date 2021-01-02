import 'package:enough_mail/enough_mail.dart';
import 'dart:async';

abstract class MimeSourceSubscriber {
  void onMailLoaded(MimeMessage mime, MimeSource source);
  void onMailAdded(MimeMessage mime, MimeSource source);
  void onMailVanished(MimeMessage mime, MimeSource source);
  void onMailFlagsUpdated(MimeMessage mime, MimeSource source);
}

//TODO this can be described as MailboxMimeSource, but there should be a SearchMimeSource and possibly
// other specialized mime sources as well
class MimeSource {
  final MailClient mailClient;
  Mailbox mailbox;
  int get size => mailbox.messagesExists;
  final _subscribers = <MimeSourceSubscriber>[];
  final List<MimeMessage> _cache = <MimeMessage>[];
  final _requestedPages = <int>[];
  int _pageSize;
  int _cacheSize;
  StreamSubscription<MailLoadEvent> _mailLoadEventSubscription;
  StreamSubscription<MailVanishedEvent> _mailVanishedEventSubscription;
  StreamSubscription<MailUpdateEvent> _mailUpdatedEventSubscription;

  Future _downloadFuture;
  Future get downloadFuture => _downloadFuture;

  MimeSource(this.mailClient, this.mailbox,
      {MimeSourceSubscriber subscriber,
      int pageSize = 20,
      int cacheSize = 100}) {
    _pageSize = pageSize;
    _cacheSize = cacheSize;
    if (subscriber != null) {
      _subscribers.add(subscriber);
    }
    _registerEvents();
  }

  get supportsMessageFolders => (mailClient.mailboxes?.length != 0);

  Future<bool> init() async {
    MailResponse<Mailbox> selectResponse;
    if (mailbox == null) {
      selectResponse = await mailClient.selectInbox();
    } else {
      selectResponse = await mailClient.selectMailbox(mailbox);
    }
    if (selectResponse.isOkStatus) {
      mailbox = selectResponse.result;
      // pre-cache first page:
      await _download(0);
      return true;
    } else {
      return false;
    }
  }

  void dispose() {
    _deregisterEvents();
  }

  void addSubscriber(MimeSourceSubscriber subscriber) {
    _subscribers.add(subscriber);
  }

  void removeSubscriber(MimeSourceSubscriber subscriber) {
    _subscribers.remove(subscriber);
  }

  MimeMessage _getMessageFromCache(int sequenceId) {
    return _cache.firstWhere((m) => m.sequenceId == sequenceId,
        orElse: () => null);
  }

  MimeMessage _getMessageFromCacheWithUid(int uid) {
    return _cache.firstWhere((m) => m.uid == uid, orElse: () => null);
  }

  MimeMessage getMessageAt(int index) {
    //print('getMessageAt($index)');
    if (index >= size) {
      throw StateError('Invalid index $index for MimeSource with size $size');
    }
    final sequenceId = (size - index);
    final existingMessage = _getMessageFromCache(sequenceId);
    if (existingMessage != null) {
      return existingMessage;
    }
    final pageIndex = index ~/ _pageSize;
    if (!_requestedPages.contains(pageIndex)) {
      _queue(pageIndex);
    }
    return MimeMessage()..sequenceId = sequenceId;
  }

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
      _notifyMessageAdded(e.message);
      //TODO implement
      // _cache.add(Message(e.message, e.mailClient));
      // notifyListeners();
    }
    // else {
    //   locator<ScaffoldService>().showTextSnackBar(e.message.decodeSubject());
    // }
  }

  void _notifyMessageAdded(MimeMessage mime) {
    for (final subscriber in _subscribers) {
      subscriber.onMailAdded(mime, this);
    }
  }

  void _onMessageVanished(MailVanishedEvent e) {
    if (!e.isEarlier && e.mailClient == mailClient) {
      final ids = e.sequence.toList();
      MimeMessage message;
      int sequenceId;
      for (var id in ids) {
        if (e.sequence.isUidSequence == true) {
          message = _getMessageFromCacheWithUid(id);
          sequenceId = message?.sequenceId;
        } else {
          sequenceId = id;
          message = _getMessageFromCache(id);
        }
        if (message != null) {
          _cache.remove(message);
        }
        if (sequenceId != null) {
          for (var message in _cache) {
            if (message.sequenceId >= sequenceId) {
              message.sequenceId--;
            }
          }
        }
        if (message != null) {
          _notifyVanished(message);
        }
      }
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
    //print('downloading $pageIndex');
    await mailClient.stopPollingIfNeeded();
    final response = await mailClient.fetchMessages(
        count: _pageSize,
        page: (pageIndex + 1),
        fetchPreference: FetchPreference.envelope);
    if (response.isOkStatus) {
      _requestedPages.remove(pageIndex);
      for (final mime in response.result) {
        final cached = _getMessageFromCache(mime.sequenceId);
        if (cached == null) {
          _cache.add(mime);
        }
        _notifyLoaded(mime);
      }
      if (_cache.length > _cacheSize) {
        _cache.removeRange(0, _cache.length - _cacheSize);
      }
    }
    if (_requestedPages.isNotEmpty) {
      pageIndex = _requestedPages.first;
      _downloadFuture = _download(pageIndex);
    } else {
      mailClient.startPolling();
    }
  }

  void _notifyLoaded(MimeMessage mime) {
    for (final subscriber in _subscribers) {
      subscriber.onMailLoaded(mime, this);
    }
  }

  Future<List<DeleteResult>> deleteAllMessages() async {
    final response = await mailClient.deleteAllMessages(mailbox);
    if (response.isOkStatus) {
      mailbox.messagesExists = 0;
      return [response.result];
    }
    return null;
  }

  void remove(MimeMessage mimeMessage) {
    _cache.remove(mimeMessage);
    mailbox.messagesExists--;
  }

  bool get shouldBlockImages => mailbox.isTrash || mailbox.isJunk;

  bool get isJunk => mailbox.isJunk;

  bool get isArchive => mailbox.isArchive;
}
