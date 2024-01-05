import 'dart:async';

import 'package:enough_mail/enough_mail.dart';

import 'async_mime_source.dart';
import 'offline_mime_storage.dart';

/// Provides access to messages that have been stored offline
class OfflineMailboxMimeSource extends PagedCachedMimeSource {
  /// Creates a new [OfflineMailboxMimeSource]
  OfflineMailboxMimeSource({
    required MailAccount mailAccount,
    required this.mailbox,
    required PagedCachedMimeSource onlineMimeSource,
    required OfflineMimeStorage storage,
  })  : _mailAccount = mailAccount,
        _onlineMimeSource = onlineMimeSource,
        _storage = storage;

  final MailAccount _mailAccount;
  @override
  final Mailbox mailbox;
  final PagedCachedMimeSource _onlineMimeSource;
  final OfflineMimeStorage _storage;

  late StreamSubscription<MailLoadEvent> _mailLoadEventSubscription;
  late StreamSubscription<MailVanishedEvent> _mailVanishedEventSubscription;
  late StreamSubscription<MailUpdateEvent> _mailUpdatedEventSubscription;
  late StreamSubscription<MailConnectionReEstablishedEvent>
      _mailReconnectedEventSubscription;

  @override
  Future<void> init() async {
    _subscribeEvents();
    final futures = [_onlineMimeSource.init(), _storage.init()];
    await Future.wait(futures);
  }

  @override
  void dispose() {
    _unsubscribeEvents();
  }

  @override
  Future<MimeMessage> fetchMessageContents(
    MimeMessage message, {
    int? maxSize,
    bool markAsSeen = false,
    List<MediaToptype>? includedInlineTypes,
    Duration? responseTimeout,
  }) async {
    final contents = await _storage.fetchMessageContents(
      message,
      markAsSeen: markAsSeen,
      includedInlineTypes: includedInlineTypes,
    );
    if (contents != null) {
      return contents;
    }
    final onlineContents = await _onlineMimeSource.fetchMessageContents(
      message,
      maxSize: maxSize,
      markAsSeen: markAsSeen,
      includedInlineTypes: includedInlineTypes,
      responseTimeout: responseTimeout,
    );
    await _storage.saveMessageContents(onlineContents);

    return onlineContents;
  }

  @override
  Future<MimePart> fetchMessagePart(
    MimeMessage message, {
    required String fetchId,
    Duration? responseTimeout,
  }) =>
      _onlineMimeSource.fetchMessagePart(
        message,
        fetchId: fetchId,
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
      _onlineMimeSource.sendMessage(
        message,
        from: from,
        appendToSent: appendToSent,
        sentMailbox: sentMailbox,
        use8BitEncoding: use8BitEncoding,
        recipients: recipients,
      );

  @override
  Future<void> handleOnMessageArrived(int index, MimeMessage message) =>
      Future.wait([
        _storage.saveMessageEnvelopes([message]),
        if (message.mimeData != null) _storage.saveMessageContents(message),
      ]);

  @override
  Future<void> handleOnMessagesVanished(List<MimeMessage> messages) =>
      Future.wait(
        messages.map(_storage.deleteMessage),
      );

  @override
  bool get isArchive => mailbox.isArchive;

  @override
  bool get isInbox => mailbox.isInbox;

  @override
  bool get isJunk => mailbox.isJunk;

  @override
  bool get isSent => mailbox.isSent;

  @override
  bool get isTrash => mailbox.isTrash;

  @override
  Future<List<MimeMessage>> loadMessages(MessageSequence sequence) async {
    final messages = await _storage.loadMessageEnvelopes(sequence);
    if (messages != null) {
      return messages;
    }
    final onlineMessages = await _onlineMimeSource.loadMessages(sequence);
    await _storage.saveMessageEnvelopes(onlineMessages);

    return onlineMessages;
  }

  @override
  MailClient get mailClient => _onlineMimeSource.mailClient;

  @override
  Future<MoveResult> moveMessages(
    List<MimeMessage> messages,
    Mailbox targetMailbox,
  ) async {
    // TODO(RV): this and most other offline ops should be done with a queue
    // Some ops can be done offline and an later online, e.g. store flags
    // Some ops must update their offline part after having finished it online,
    // e.g. move, append - because the UID and sequence ID can only be known
    // after storing it online
    // What happens with ops that go back and forth, e.g. delete, then un-delete
    // or archive message and then delete message while being offline?
    final result =
        await _onlineMimeSource.moveMessages(messages, targetMailbox);
    await _storage.moveMessages(messages, targetMailbox);

    return result;
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
  Future<List<DeleteResult>> deleteAllMessages({bool expunge = false}) {
    // TODO(RV): implement deleteAllMessages
    throw UnimplementedError();
  }

  @override
  Future<DeleteResult> deleteMessages(List<MimeMessage> messages) {
    // TODO(RV): implement deleteMessages
    throw UnimplementedError();
  }

  @override
  Future<DeleteResult> undoDeleteMessages(DeleteResult deleteResult) {
    // TODO(RV): implement undoDeleteMessages
    throw UnimplementedError();
  }

  @override
  String get name => _onlineMimeSource.name;

  @override
  AsyncMimeSource search(MailSearch search) {
    // TODO(RV): implement search
    throw UnimplementedError();
  }

  @override
  int get size => mailbox.messagesExists;

  @override
  Future<void> store(
    List<MimeMessage> messages,
    List<String> flags, {
    StoreAction action = StoreAction.add,
  }) =>
      Future.wait(
        [
          _storage.saveMessageEnvelopes(messages),
          _onlineMimeSource.store(
            messages,
            flags,
            action: action,
          ),
        ],
      );

  @override
  Future<void> storeAll(
    List<String> flags, {
    StoreAction action = StoreAction.add,
  }) {
    // TODO(RV): implement storeAll
    throw UnimplementedError();
  }

  @override
  bool get supportsDeleteAll => _onlineMimeSource.supportsDeleteAll;

  @override
  bool get supportsMessageFolders => _onlineMimeSource.supportsMessageFolders;

  @override
  bool get supportsSearching => _onlineMimeSource.supportsSearching;

  void _subscribeEvents() {
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
    // _mailReconnectedEventSubscription = mailClient.eventBus
    //     .on<MailConnectionReEstablishedEvent>()
    //     .listen(_onMailReconnected);
  }

  void _unsubscribeEvents() {
    _mailLoadEventSubscription.cancel();
    _mailVanishedEventSubscription.cancel();
    _mailUpdatedEventSubscription.cancel();
    _mailReconnectedEventSubscription.cancel();
  }
}
