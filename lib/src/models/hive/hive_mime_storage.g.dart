// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_mime_storage.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StorageMessageIdAdapter extends TypeAdapter<StorageMessageId> {
  @override
  final int typeId = 1;

  @override
  StorageMessageId read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StorageMessageId(
      sequenceId: fields[0] as int,
      uid: fields[1] as int,
      guid: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, StorageMessageId obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.sequenceId)
      ..writeByte(1)
      ..write(obj.uid)
      ..writeByte(2)
      ..write(obj.guid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StorageMessageIdAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StorageMessageEnvelopeAdapter
    extends TypeAdapter<StorageMessageEnvelope> {
  @override
  final int typeId = 2;

  @override
  StorageMessageEnvelope read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StorageMessageEnvelope(
      flags: (fields[0] as List?)?.cast<String>(),
      uid: fields[1] as int,
      guid: fields[2] as int,
      sequenceId: fields[3] as int,
      sender: fields[4] as String?,
      from: (fields[5] as List?)?.cast<String>(),
      replyTo: (fields[6] as List?)?.cast<String>(),
      to: (fields[7] as List?)?.cast<String>(),
      cc: (fields[8] as List?)?.cast<String>(),
      bcc: (fields[9] as List?)?.cast<String>(),
      subject: fields[10] as String?,
      date: fields[11] as DateTime?,
      messageId: fields[12] as String?,
      inReplyTo: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, StorageMessageEnvelope obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.flags)
      ..writeByte(1)
      ..write(obj.uid)
      ..writeByte(2)
      ..write(obj.guid)
      ..writeByte(3)
      ..write(obj.sequenceId)
      ..writeByte(4)
      ..write(obj.sender)
      ..writeByte(5)
      ..write(obj.from)
      ..writeByte(6)
      ..write(obj.replyTo)
      ..writeByte(7)
      ..write(obj.to)
      ..writeByte(8)
      ..write(obj.cc)
      ..writeByte(9)
      ..write(obj.bcc)
      ..writeByte(10)
      ..write(obj.subject)
      ..writeByte(11)
      ..write(obj.date)
      ..writeByte(12)
      ..write(obj.messageId)
      ..writeByte(13)
      ..write(obj.inReplyTo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StorageMessageEnvelopeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
