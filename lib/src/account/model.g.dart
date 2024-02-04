// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RealAccount _$RealAccountFromJson(Map<String, dynamic> json) => RealAccount(
      MailAccount.fromJson(json['mailAccount'] as Map<String, dynamic>),
      appExtensions: (json['appExtensions'] as List<dynamic>?)
          ?.map((e) => AppExtension.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RealAccountToJson(RealAccount instance) =>
    <String, dynamic>{
      'mailAccount': instance.mailAccount,
      'appExtensions': instance.appExtensions,
    };
