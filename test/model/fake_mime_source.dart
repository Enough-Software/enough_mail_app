import 'dart:math';

import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/src/models/async_mime_source.dart';

class FakeMimeSource extends PagedCachedMimeSource {
  FakeMimeSource({
    required int size,
    super.maxCacheSize,
    this.name = '',
    DateTime? startDate,
    Duration? differencePerMessage,
  })  : _startDate = startDate ?? DateTime(2022, 04, 16, 08),
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
        ) {
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

  static List<MimeMessage> generateMessages({
    required int size,
    String name = '',
    DateTime? startDate,
    Duration? differencePerMessage,
  }) {
    final messages = <MimeMessage>[];
    for (int i = size; --i >= 0;) {
      messages.add(
        _generateMessage(
          size - i,
          size,
          name,
          startDate ?? DateTime(2022, 04, 16, 08),
          differencePerMessage ?? const Duration(minutes: 5),
        ),
      );
    }

    return messages;
  }

  static MimeMessage _generateMessage(
    int sequenceId,
    int size,
    String name,
    DateTime startDate,
    Duration differencePerMessage,
  ) =>
      MimeMessage()
        ..sequenceId = sequenceId
        ..guid = sequenceId
        ..uid = sequenceId
        ..addHeader(MailConventions.headerSubject, '${name}Subject $sequenceId')
        ..addHeader(
          MailConventions.headerDate,
          DateCodec.encodeDate(_generateDate(
            size - sequenceId,
            startDate,
            differencePerMessage,
          )),
        );

  static DateTime _generateDate(
    int index,
    DateTime startDate,
    Duration differencePerMessage,
  ) =>
      startDate.subtract(differencePerMessage * index);

  MimeMessage createMessage(int sequenceId) => _generateMessage(
        sequenceId,
        size,
        name,
        _startDate,
        _differencePerMessage,
      );

  @override
  final String name;

  @override
  int get size => messages.length;

  final _random = Random();

  @override
  Future<DeleteResult> deleteMessages(List<MimeMessage> messages) {
    messages.sort((a, b) => (b.sequenceId ?? 0).compareTo(a.sequenceId ?? 0));
    for (final message in messages) {
      final sequenceId = message.sequenceId ?? -1;
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
          pathSeparator: '/',
        ),
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
      pathSeparator: '/',
    );

    return [
      DeleteResult(
        DeleteAction.flag,
        sequence,
        mailbox,
        sequence,
        mailbox,
        mailClient,
        canUndo: false,
      ),
    ];
  }

  @override
  Future<void> init() => Future.value();

  @override
  // TODO(RV): implement isArchive
  bool get isArchive => throw UnimplementedError();

  @override
  // TODO(RV): implement isJunk
  bool get isJunk => throw UnimplementedError();

  @override
  // TODO(RV): implement isSent
  bool get isSent => throw UnimplementedError();

  @override
  // TODO(RV): implement isTrash
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
    removed.forEach(messages.remove);
  }

  @override
  AsyncMimeSource search(MailSearch search) {
    // TODO(RV): implement search
    throw UnimplementedError();
  }

  @override
  bool get supportsDeleteAll => true;

  @override
  // TODO(RV): implement supportsMessageFolders
  bool get supportsMessageFolders => throw UnimplementedError();

  @override
  // TODO(RV): implement supportsSearching
  bool get supportsSearching => throw UnimplementedError();

  @override
  void dispose() {
    // TODO(RV): implement dispose
  }

  @override
  final MailClient mailClient;

  @override
  Future<void> store(
    List<MimeMessage> messages,
    List<String> flags, {
    StoreAction action = StoreAction.add,
  }) {
    // TODO(RV): implement store
    throw UnimplementedError();
  }

  @override
  Future<void> storeAll(
    List<String> flags, {
    StoreAction action = StoreAction.add,
  }) {
    // TODO(RV): implement storeAll
    throw UnimplementedError();
  }

  @override
  Future<DeleteResult> undoDeleteMessages(DeleteResult deleteResult) {
    // TODO(RV): implement undoDeleteMessages
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
  }) {
    // TODO(RV): implement fetchMessageContents
    throw UnimplementedError();
  }

  @override
  // TODO(RV): implement isInbox
  bool get isInbox => throw UnimplementedError();

  @override
  Future<MimePart> fetchMessagePart(
    MimeMessage message, {
    required String fetchId,
    Duration? responseTimeout,
  }) {
    // TODO(RV): implement fetchMessagePart
    throw UnimplementedError();
  }

  @override
  Future<void> sendMessage(
    MimeMessage message, {
    MailAddress? from,
    bool appendToSent = true,
    Mailbox? sentMailbox,
    bool use8BitEncoding = false,
    List<MailAddress>? recipients,
  }) {
    // TODO(RV): implement sendMessage
    throw UnimplementedError();
  }

  @override
  // TODO(RV): implement mailbox
  Mailbox get mailbox => throw UnimplementedError();
}
