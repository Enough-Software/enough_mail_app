import 'package:collection/collection.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../offline_mime_storage.dart';

part 'hive_mime_storage.g.dart';

/// A mime storage using Hive as its backend
///
/// idea:
/// use 2-3 structures for each mailbox:
/// 1) list of SequenceId-UID-GUID elements - to be loaded when mailbox is
///    opened, possibly along with envelope data of first page to speed up
///     loading
/// 2) possibly envelope data by GUID (contains flags, subject, senders, recipients, date, has-attachment, possibly message preview)
/// 3) downloaded message data by GUID - this may not (yet) contain attachments
///
/// new message:
///   add to 1 (plus first page of envelope data) and 2
/// downloaded message:
///   add to 3
/// delete message:
///    remove from 1, 2 and 3
/// delete all messages:
///    clear 1, 2 and 3
/// store/flag message:
///    update 2 and 3
class HiveMailboxMimeStorage extends OfflineMimeStorage {
  HiveMailboxMimeStorage({
    required MailAccount mailAccount,
    required Mailbox mailbox,
  })  : _mailAccount = mailAccount,
        _mailbox = mailbox,
        _boxNameIds = _getBoxName(mailAccount, mailbox, 'ids'),
        _boxNameEnvelopes = _getBoxName(mailAccount, mailbox, 'envelopes'),
        _boxNameFullMessages = _getBoxName(mailAccount, mailbox, 'full');

  static const _keyMessageIds = 'ids';
  final MailAccount _mailAccount;
  final Mailbox _mailbox;
  final String _boxNameIds;
  final String _boxNameEnvelopes;
  final String _boxNameFullMessages;
  late Box<List> _boxIds;
  late LazyBox<StorageMessageEnvelope> _boxEnvelopes;
  late LazyBox<String> _boxFullMessages;
  late List<StorageMessageId> _allMessageIds;

  static String _getBoxName(
          MailAccount mailAccount, Mailbox mailbox, String name) =>
      '${mailAccount.email}_${mailbox.encodedPath.replaceAll('/', '_')}_$name';

  static Future<void> initGlobal() async {
    Hive.registerAdapter(StorageMessageIdAdapter());
    Hive.registerAdapter(StorageMessageEnvelopeAdapter());
    await Hive.initFlutter();
  }

  @override
  Future<void> init() {
    Future<void> initIds() async {
      _boxIds = await Hive.openBox<List>(_boxNameIds);
      _allMessageIds = _boxIds.get(_keyMessageIds)?.cast<StorageMessageId>() ??
          <StorageMessageId>[];
    }

    Future<void> initEnvelopes() async {
      _boxEnvelopes =
          await Hive.openLazyBox<StorageMessageEnvelope>(_boxNameEnvelopes);
    }

    Future<void> initFullMessages() async {
      _boxFullMessages = await Hive.openLazyBox<String>(_boxNameFullMessages);
    }

    return Future.wait([initIds(), initEnvelopes(), initFullMessages()]);
  }

  @override
  Future<List<MimeMessage>?> loadMessageEnvelopes(
    MessageSequence sequence,
  ) async {
    print('load offline message for ${_mailAccount.name}');
    final ids = sequence.toList(_mailbox.messagesExists);
    final allIds = _allMessageIds;
    if (allIds.length < ids.length) {
      print('${_mailAccount.name}: not enough ids (${allIds.length})');
      return null;
    }
    final envelopes = <MimeMessage>[];
    final isUid = sequence.isUidSequence;
    for (final id in ids) {
      final messageId = allIds.firstWhereOrNull((messageId) =>
          isUid ? messageId.uid == id : messageId.sequenceId == id);
      if (messageId == null) {
        print(
            '${_mailAccount.name}: ${isUid ? 'uid' : 'sequence-id'} $id not found in allIds');
        return null;
      }
      final messageEnvelope = await _boxEnvelopes.get(messageId.guid);
      if (messageEnvelope == null) {
        print(
            '${_mailAccount.name}: message data not found for guid ${messageId.guid} belonging to ${isUid ? 'uid' : 'sequence-id'} $id ');
        return null;
      }
      final mimeMessage = messageEnvelope.toMimeMessage();
      envelopes.add(mimeMessage);
    }
    print('${_mailAccount.name}: all messages loaded offline :-)');
    return envelopes;
  }

  @override
  Future<void> saveMessageContents(MimeMessage mimeMessage) async {
    final data = mimeMessage.mimeData;
    final guid = mimeMessage.guid;
    if (data != null && guid != null) {
      await _boxFullMessages.put(guid, data.toString());
    }
  }

  @override
  Future<void> saveMessageEnvelopes(List<MimeMessage> messages) async {
    final map = <int, StorageMessageEnvelope>{};
    final allMessageIds = _allMessageIds;
    var addedMessageIds = 0;
    for (final message in messages) {
      final guid = message.guid;
      if (guid != null) {
        final existingMessageId =
            allMessageIds.firstWhereOrNull((id) => id.guid == guid);
        final sequenceId = message.sequenceId!;
        final uid = message.uid!;
        if (existingMessageId == null) {
          addedMessageIds++;
          final messageId =
              StorageMessageId(sequenceId: sequenceId, uid: uid, guid: guid);
          allMessageIds.add(messageId);
        }
        map[guid] = StorageMessageEnvelope.fromMessage(
          message: message,
          uid: uid,
          guid: guid,
          sequenceId: sequenceId,
        );
      }
    }
    final futures = [
      _boxEnvelopes.putAll(map),
      _boxIds.put(_keyMessageIds, allMessageIds)
    ];
    print(
        '${_mailAccount.name}: saved message envelopes :-)  (ids: $addedMessageIds (total: ${allMessageIds.length}) / envelopes: ${map.length})');
    await Future.wait(futures);
  }

  @override
  Future<MimeMessage?> fetchMessageContents(
    MimeMessage mimeMessage, {
    bool markAsSeen = false,
    List<MediaToptype>? includedInlineTypes,
  }) async {
    final guid = mimeMessage.guid;
    if (guid == null) {
      return null;
    }
    final existingContent = await _boxFullMessages.get(guid);
    if (existingContent == null) {
      return null;
    }
    return MimeMessage.parseFromText(existingContent);
  }

  @override
  Future<void> onAccountRemoved() {
    final futures = [
      Hive.deleteBoxFromDisk(_boxNameIds),
      Hive.deleteBoxFromDisk(_boxNameEnvelopes),
      Hive.deleteBoxFromDisk(_boxNameFullMessages),
    ];
    return Future.wait(futures);
  }

  @override
  Future<void> deleteMessage(MimeMessage message) {
    final guid = message.guid;
    if (guid == null) {
      return Future.value();
    }
    print('delete message with guid $guid from storage');
    _allMessageIds.removeWhere((id) => id.guid == guid);
    return Future.wait([
      _boxIds.put(_keyMessageIds, _allMessageIds),
      _boxEnvelopes.delete(guid),
      _boxFullMessages.delete(guid),
    ]);
  }

  @override
  Future<void> moveMessages(List<MimeMessage> messages, Mailbox targetMailbox) {
    // TODO: implement moveMessages
    throw UnimplementedError();
  }
}

/// Stores hive mail operations
class TextHiveStorage {
  TextHiveStorage._();

  /// Retrieves access to the text hive storage
  static TextHiveStorage get instance => _instance;
  static final TextHiveStorage _instance = TextHiveStorage._();

  static const String _keyTextBox = '_texts';
  Box<String>? _textBox;

  /// Stores the [value]
  ///
  /// Compare [load]
  Future<void> save(String key, String value) async {
    final box = _textBox ?? await Hive.openBox<String>(_keyTextBox);
    _textBox ??= box;
    await box.put(key, value);
  }

  /// Loads the value previously stored with [key].
  ///
  /// Compare [save]
  Future<String?> load(String key) async {
    final box = _textBox ?? await Hive.openBox<String>(_keyTextBox);
    _textBox ??= box;
    return box.get(key);
  }
}

/// Contains the message IDs in a dense data structure
@HiveType(typeId: 1)
class StorageMessageId {
  /// Creates a new [StorageMessageId]
  const StorageMessageId({
    required this.sequenceId,
    required this.uid,
    required this.guid,
  });

  /// The sequence ID
  @HiveField(0)
  final int sequenceId;
  @HiveField(1)

  /// The folder unique ID
  final int uid;

  /// The globally unique ID
  @HiveField(2)
  final int guid;
}

/// Message envelope, UID, GUID and flags
@HiveType(typeId: 2)
class StorageMessageEnvelope {
  const StorageMessageEnvelope({
    this.flags,
    required this.uid,
    required this.guid,
    required this.sequenceId,
    required this.sender,
    this.from,
    this.replyTo,
    this.to,
    this.cc,
    this.bcc,
    this.subject,
    this.date,
    this.messageId,
    this.inReplyTo,
  });

  factory StorageMessageEnvelope.fromEnvelope({
    required Envelope envelope,
    required int uid,
    required int guid,
    required int sequenceId,
    List<String>? flags,
  }) =>
      StorageMessageEnvelope(
        uid: uid,
        guid: guid,
        sequenceId: sequenceId,
        sender: envelope.sender?.encode(),
        from: _mapAddresses(envelope.from),
        replyTo: _mapAddresses(envelope.replyTo),
        to: _mapAddresses(envelope.to),
        cc: _mapAddresses(envelope.cc),
        bcc: _mapAddresses(envelope.bcc),
        subject: envelope.subject,
        date: envelope.date,
        messageId: envelope.messageId,
        inReplyTo: envelope.inReplyTo,
        flags: flags,
      );

  factory StorageMessageEnvelope.fromMessage({
    required MimeMessage message,
    required int uid,
    required int guid,
    required int sequenceId,
  }) {
    final envelope = message.envelope;
    if (envelope != null) {
      return StorageMessageEnvelope.fromEnvelope(
        envelope: envelope,
        uid: uid,
        guid: guid,
        sequenceId: sequenceId,
        flags: message.flags,
      );
    }
    return StorageMessageEnvelope(
      uid: uid,
      guid: guid,
      sequenceId: sequenceId,
      sender: message.sender?.encode(),
      from: _mapAddresses(message.from),
      replyTo: _mapAddresses(message.replyTo),
      to: _mapAddresses(message.to),
      cc: _mapAddresses(message.cc),
      bcc: _mapAddresses(message.bcc),
      subject: message.decodeSubject(),
      date: message.decodeDate(),
      messageId: message.getHeaderValue(MailConventions.headerMessageId),
      inReplyTo: message.getHeaderValue(MailConventions.headerInReplyTo),
      flags: message.flags,
    );
  }

  static List<String>? _mapAddresses(List<MailAddress>? addresses) =>
      addresses?.map((a) => a.encode()).toList();

  @HiveField(0)
  final List<String>? flags;
  @HiveField(1)
  final int uid;
  @HiveField(2)
  final int guid;
  @HiveField(3)
  final int sequenceId;
  @HiveField(4)
  final String? sender;
  @HiveField(5)
  final List<String>? from;
  @HiveField(6)
  final List<String>? replyTo;
  @HiveField(7)
  final List<String>? to;
  @HiveField(8)
  final List<String>? cc;
  @HiveField(9)
  final List<String>? bcc;
  @HiveField(10)
  final String? subject;
  @HiveField(11)
  final DateTime? date;
  @HiveField(12)
  final String? messageId;
  @HiveField(13)
  final String? inReplyTo;

  MimeMessage toMimeMessage() => MimeMessage.fromEnvelope(
        toEnvelope(),
        uid: uid,
        guid: guid,
        sequenceId: sequenceId,
        flags: flags,
      );

  Envelope toEnvelope() {
    List<MailAddress>? parseAddresses(List<String>? input) =>
        input?.map((s) => MailAddress.parse(s)).toList();
    MailAddress? parse(String? input) {
      if (input == null) {
        return null;
      }
      return MailAddress.parse(input);
    }

    return Envelope(
      date: date,
      subject: subject,
      sender: parse(sender),
      from: parseAddresses(from),
      replyTo: parseAddresses(replyTo),
      to: parseAddresses(to),
      cc: parseAddresses(cc),
      bcc: parseAddresses(cc),
      inReplyTo: inReplyTo,
      messageId: messageId,
    );
  }
}
