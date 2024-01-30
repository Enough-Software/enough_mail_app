import 'package:enough_mail/enough_mail.dart';
import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

/// The result of the notification service initialization
enum NotificationServiceInitResult {
  /// App was launched by a notification
  appLaunchedByNotification,

  /// App was launched normally
  normal,
}

/// Details to identify a mail message in a notification
@JsonSerializable()
class MailNotificationPayload {
  /// Creates a new payload
  const MailNotificationPayload({
    required this.guid,
    required this.uid,
    required this.sequenceId,
    required this.accountEmail,
    required this.subject,
    required this.size,
  });

  /// Creates a new payload from the given [mimeMessage]
  MailNotificationPayload.fromMail(
    MimeMessage mimeMessage,
    this.accountEmail,
  )   : uid = mimeMessage.uid ?? 0,
        guid = mimeMessage.guid ?? 0,
        sequenceId = mimeMessage.sequenceId ?? 0,
        subject = mimeMessage.decodeSubject() ?? '',
        size = mimeMessage.size ?? 0;

  /// Creates a new payload from the given [json]
  factory MailNotificationPayload.fromJson(Map<String, dynamic> json) =>
      _$MailNotificationPayloadFromJson(json);

  /// The global unique identifier of the message
  final int guid;

  /// The unique identifier of the message
  final int uid;

  /// The sequence id of the message
  @JsonKey(name: 'id')
  final int sequenceId;

  /// The email address of the account
  @JsonKey(name: 'account-email')
  final String accountEmail;

  /// The subject of the message
  final String subject;

  /// The size of the message
  final int size;

  /// Creates JSON from this payoad
  Map<String, dynamic> toJson() => _$MailNotificationPayloadToJson(this);
}
