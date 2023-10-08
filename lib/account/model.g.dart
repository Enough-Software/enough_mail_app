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
    )
      ..excludeFromUnified = json['excludeFromUnified'] as bool
      ..signaturePlain = json['signaturePlain'] as String?
      ..userName = json['userName'] as String?;

Map<String, dynamic> _$RealAccountToJson(RealAccount instance) =>
    <String, dynamic>{
      'mailAccount': instance.mailAccount,
      'excludeFromUnified': instance.excludeFromUnified,
      'signaturePlain': instance.signaturePlain,
      'userName': instance.userName,
      'appExtensions': instance.appExtensions,
    };
