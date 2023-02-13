// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mail_operation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoreFlagsOperation _$StoreFlagsOperationFromJson(Map<String, dynamic> json) =>
    StoreFlagsOperation(
      flags: (json['flags'] as List<dynamic>).map((e) => e as String).toList(),
      sequence:
          MessageSequence.fromJson(json['sequence'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StoreFlagsOperationToJson(
        StoreFlagsOperation instance) =>
    <String, dynamic>{
      'flags': instance.flags,
      'sequence': instance.sequence,
    };
