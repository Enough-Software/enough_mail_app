import 'dart:convert';

import 'package:enough_mail/enough_mail.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:enough_mail_app/models/offline_mime_storage.dart';

import 'hive/hive_mime_storage.dart';

part 'mail_operation.g.dart';

/// The type of a mail operation
enum MailOperationType {
  /// update flags like `/Seen`
  storeFlags,
  moveToFlag,
  moveToFolder,
}

/// Defines the API for a mail operation
abstract class MailOperation {
  /// Creates a new mail operation
  MailOperation(this.type);

  /// The type of the operation
  ///
  /// Note that new types need to be registered with the [MailOperationQueue]
  final MailOperationType type;

  /// Executes this mail operation
  Future<void> execute(MailClient mailClient, OfflineMimeStorage storage);
}

/// Works on [MailOperation]s and allows to queue them.
class MailOperationQueue {
  MailOperationQueue._(this._queue);
  static const String _keyQueue = 'mailOperationsQueue';
  final List<_QueuedMailOperation> _queue;

  /// Adds the mail operation at the beginning of this queue
  void prepend(MailOperation op, String email) {
    _queue.insert(0, _QueuedMailOperation(op, email));
    _storeQueue();
  }

  /// Inserts the mail operation at the beginning of this queue
  void append(MailOperation op, String email) {
    _queue.add(_QueuedMailOperation(op, email));
    _storeQueue();
  }

  Future<void> _storeQueue() async {
    final list = _queue.map((e) => e.toJson()).toList();
    final value = json.encode(list);
    TextHiveStorage.instance.save(_keyQueue, value);
  }

  /// Loads the [MailOperationQueue]
  static Future<MailOperationQueue> loadQueue() async {
    final savedData = await TextHiveStorage.instance.load(_keyQueue);
    if (savedData == null) {
      return MailOperationQueue._(<_QueuedMailOperation>[]);
    }
    final data = json.decode(savedData) as List;
    final entries = data.map((e) => _QueuedMailOperation.fromJson(e)).toList();
    return MailOperationQueue._(entries);
  }
}

class _QueuedMailOperation {
  _QueuedMailOperation(this.operation, this.email);

  factory _QueuedMailOperation.fromJson(Map<String, dynamic> input) {
    final String email = input['email']!;
    final type = MailOperationType.values[input['typeIndex']!];
    final Map<String, dynamic> data = input['operation']!;
    final MailOperation operation;
    switch (type) {
      case MailOperationType.storeFlags:
        operation = StoreFlagsOperation.fromJson(data);
        break;
      // case MailOperationType.moveToFlag:
      //   // TODO: Handle this case.
      //   break;
      // case MailOperationType.moveToFolder:
      //   // TODO: Handle this case.
      //   break;
      default:
        throw FormatException('Unsupported type $type');
    }
    return _QueuedMailOperation(operation, email);
  }

  final MailOperation operation;
  final String email;

  Map<String, dynamic> toJson() => {
        'email': email,
        'typeIndex': operation.type.index,
        //'operation': operation.toJson(),
      };
}

/// An operation to store flags
@JsonSerializable()
class StoreFlagsOperation extends MailOperation {
  /// Creates a new [StoreFlagsOperation]
  StoreFlagsOperation({
    required this.flags,
    required this.sequence,
  }) : super(MailOperationType.storeFlags);

  /// The flags to store
  final List<String> flags;

  /// The sequence of messages
  final MessageSequence sequence;

  // De-serialized the JSON to a store flags operation
  factory StoreFlagsOperation.fromJson(Map<String, dynamic> json) =>
      _$StoreFlagsOperationFromJson(json);

  /// Serializes the data to JSON
  Map<String, dynamic> toJson() => _$StoreFlagsOperationToJson(this);

  @override
  Future<void> execute(MailClient mailClient, OfflineMimeStorage storage) {
    // TODO: implement execute
    throw UnimplementedError();
  }
}
