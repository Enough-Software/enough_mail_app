// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MailNotificationPayload _$MailNotificationPayloadFromJson(
        Map<String, dynamic> json) =>
    MailNotificationPayload(
      guid: json['guid'] as int,
      uid: json['uid'] as int,
      sequenceId: json['id'] as int,
      accountEmail: json['account-email'] as String,
      subject: json['subject'] as String,
      size: json['size'] as int,
    );

Map<String, dynamic> _$MailNotificationPayloadToJson(
        MailNotificationPayload instance) =>
    <String, dynamic>{
      'guid': instance.guid,
      'uid': instance.uid,
      'id': instance.sequenceId,
      'account-email': instance.accountEmail,
      'subject': instance.subject,
      'size': instance.size,
    };
