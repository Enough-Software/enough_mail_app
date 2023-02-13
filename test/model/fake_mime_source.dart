import 'dart:math';

import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/async_mime_source.dart';
import 'package:enough_mail_app/util/indexed_cache.dart';

class FakeMimeSource extends PagedCachedMimeSource {
  FakeMimeSource({
    required int size,
    int maxCacheSize = IndexedCache.defaultMaxCacheSize,
    this.name = '',
    DateTime? startDate,
    Duration? differencePerMessage,
  })  : _startDate = startDate ?? DateTime(2022, 04, 16, 08, 00),
        _differencePerMessage =
            differencePerMessage ?? const Duration(minutes: 5),
        mailClient = MailClient(
          MailAccount.fromManualSettings(
            name: name,
            email: 'test@domain.com',
            incomingHost: 'imap.domain.com',
            outgoingHost: 'smtp.domain.com',
            password: 'password',
          ),
        ),
        super(maxCacheSize: maxCacheSize) {
    messages = generateMessages(
      size: size,
      name: name,
      startDate: _startDate,
      differencePerMessage: _differencePerMessage,
    );
  }

  final DateTime _startDate;
  final Duration _differencePerMessage;
  List<MimeMessage> messages = [];

  static List<MimeMessage> generateMessages(
      {required int size,
      String name = '',
      DateTime? startDate,
      Duration? differencePerMessage}) {
    final messages = <MimeMessage>[];
    for (int i = size; --i >= 0;) {
      messages.add(
        _generateMessage(
          size - i,
          size,
          name,
          startDate ?? DateTime(2022, 04, 16, 08, 00),
          differencePerMessage ?? const Duration(minutes: 5),
        ),
      );
    }
    return messages;
  }

  static MimeMessage _generateMessage(int sequenceId, int size, String name,
          DateTime startDate, Duration differencePerMessage) =>
      MimeMessage()
        ..sequenceId = sequenceId
        ..guid = sequenceId
        ..uid = sequenceId
        ..addHeader(MailConventions.headerSubject, '${name}Subject $sequenceId')
        ..addHeader(
            MailConventions.headerDate,
            DateCodec.encodeDate(_generateDate(
                size - sequenceId, startDate, differencePerMessage)));

  static DateTime _generateDate(
          int index, DateTime startDate, Duration differencePerMessage) =>
      startDate.subtract(differencePerMessage * index);

  MimeMessage createMessage(int sequenceId) => _generateMessage(
      sequenceId, size, name, _startDate, _differencePerMessage);

  @override
  final String name;

  @override
  int get size => messages.length;

  final _random = Random();

  @override
  Future<DeleteResult> deleteMessages(List<MimeMessage> messages) {
    messages.sort((a, b) => b.sequenceId!.compareTo(a.sequenceId!));
    for (final message in messages) {
      final sequenceId = message.sequenceId!;
      this.messages.removeAt(sequenceId - 1);
      for (var i = sequenceId - 1; i < this.messages.length; i++) {
        this.messages[i].sequenceId = i + 1;
      }
    }
    return Future.value(
      DeleteResult(
        DeleteAction.flag,
        messages.toSequence(),
        Mailbox(
            encodedName: 'INBOX',
            encodedPath: 'INBOX',
            flags: [MailboxFlag.inbox],
            pathSeparator: '/'),
        null,
        null,
        mailClient,
        canUndo: false,
      ),
    );
  }

  @override
  Future<List<DeleteResult>> deleteAllMessages({bool expunge = false}) async {
    await Future.delayed(Duration(milliseconds: _random.nextInt(1000)));
    messages.clear();
    clear();
    final sequence = MessageSequence.fromAll();
    final mailbox = Mailbox(
        encodedName: 'INBOX',
        encodedPath: 'INBOX',
        flags: [MailboxFlag.inbox],
        pathSeparator: '/');
    return [
      DeleteResult(
          DeleteAction.flag, sequence, mailbox, sequence, mailbox, mailClient,
          canUndo: false)
    ];
  }

  @override
  Future<void> init() => Future.value();

  @override
  // TODO: implement isArchive
  bool get isArchive => throw UnimplementedError();

  @override
  // TODO: implement isJunk
  bool get isJunk => throw UnimplementedError();

  @override
  // TODO: implement isSent
  bool get isSent => throw UnimplementedError();

  @override
  // TODO: implement isTrash
  bool get isTrash => throw UnimplementedError();

  @override
  Future<List<MimeMessage>> loadMessages(MessageSequence sequence) async {
    await Future.delayed(Duration(milliseconds: _random.nextInt(200)));
    final indices = sequence.toList(size);
    final result = <MimeMessage>[];
    for (final index in indices) {
      final message = messages[index - 1];
      result.add(message);
    }
    return result;
  }

  Future<void> addFakeMessage(int sequenceId) =>
      onMessageArrived(createMessage(sequenceId));

  @override
  Future<void> handleOnMessageArrived(int index, MimeMessage message) async {
    messages.add(message);
  }

  @override
  Future<void> handleOnMessagesVanished(List<MimeMessage> removed) async {
    for (final msg in removed) {
      messages.remove(msg);
    }
  }

  @override
  AsyncMimeSource search(MailSearch search) {
    // TODO: implement search
    throw UnimplementedError();
  }

  @override
  bool get supportsDeleteAll => true;

  @override
  // TODO: implement supportsMessageFolders
  bool get supportsMessageFolders => throw UnimplementedError();

  @override
  // TODO: implement supportsSearching
  bool get supportsSearching => throw UnimplementedError();

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  final MailClient mailClient;

  @override
  Future<void> store(List<MimeMessage> messages, List<String> flags,
      {StoreAction action = StoreAction.add}) {
    // TODO: implement store
    throw UnimplementedError();
  }

  @override
  Future<void> storeAll(List<String> flags,
      {StoreAction action = StoreAction.add}) {
    // TODO: implement storeAll
    throw UnimplementedError();
  }

  @override
  Future<DeleteResult> undoDeleteMessages(DeleteResult deleteResult) {
    // TODO: implement undoDeleteMessages
    throw UnimplementedError();
  }

  @override
  Future<MoveResult> moveMessages(
      List<MimeMessage> messages, Mailbox targetMailbox) {
    // TODO: implement moveMessages
    throw UnimplementedError();
  }

  @override
  Future<MoveResult> moveMessagesToFlag(
      List<MimeMessage> messages, MailboxFlag targetMailboxFlag) {
    // TODO: implement moveMessagesToFlag
    throw UnimplementedError();
  }

  @override
  Future<MoveResult> undoMoveMessages(MoveResult moveResult) {
    // TODO: implement undoMoveMessages
    throw UnimplementedError();
  }

  @override
  Future<MimeMessage> fetchMessageContents(MimeMessage message,
      {int? maxSize,
      bool markAsSeen = false,
      List<MediaToptype>? includedInlineTypes,
      Duration? responseTimeout}) {
    // TODO: implement fetchMessageContents
    throw UnimplementedError();
  }

  @override
  // TODO: implement isInbox
  bool get isInbox => throw UnimplementedError();
}
