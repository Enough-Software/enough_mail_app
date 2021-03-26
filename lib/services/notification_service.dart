import 'package:enough_mail_app/models/message_source.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_serialization/enough_serialization.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:enough_mail_app/models/message.dart' as maily;
import 'package:enough_mail/enough_mail.dart';

import '../locator.dart';
import '../routes.dart';

enum NotificationServiceInitResult { appLaunchedByNotification, normal }

class NotificationService {
  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  int _lastNotificationId;

  Future<NotificationServiceInitResult> init(
      {bool checkForLaunchDetails = true}) async {
    // print('init notification service...');
    // set up local notifications:
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    final android = AndroidInitializationSettings('ic_stat_notification');
    final ios = IOSInitializationSettings(
        onDidReceiveLocalNotification: _onDidReceiveLocalNotification);
    final macos = MacOSInitializationSettings();
    final initSettings =
        InitializationSettings(android: android, iOS: ios, macOS: macos);
    await _flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: _selectNotification);
    if (checkForLaunchDetails) {
      final launchDetails = await _flutterLocalNotificationsPlugin
          .getNotificationAppLaunchDetails();
      if (launchDetails?.payload != null) {
        // print(
        //     'got notification launched details: $launchDetails with payload ${launchDetails?.payload}');
        await _selectNotification(launchDetails.payload);
        return NotificationServiceInitResult.appLaunchedByNotification;
      }
    }

    return NotificationServiceInitResult.normal;
  }

  Future _onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    print('iOS onDidReceiveLocalNotification $id $title $body $payload');
  }

  Future _selectNotification(String payloadText) async {
    print('select notification: $payloadText');
    if (payloadText.startsWith('msg:')) {
      payloadText = payloadText.substring('msg:'.length);
      try {
        final payload = _MailNotificationPayload();
        Serializer().deserialize(payloadText, payload);
        final mailClient = await locator<MailService>()
            .getClientForAccountWithEmail(payload.accountEmail);
        if (mailClient.selectedMailbox == null) {
          await mailClient.selectInbox();
        }
        final mimeMessage = MimeMessage()
          ..sequenceId = payload.id
          ..uid = payload.uid
          ..size = payload.size;
        final currentMessageSource = locator<MailService>().messageSource;
        final messageSource = SingleMessageSource(currentMessageSource);
        final message =
            maily.Message(mimeMessage, mailClient, messageSource, 0);
        messageSource.singleMessage = message;
        locator<NavigationService>()
            .push(Routes.mailDetails, arguments: message);
      } on MailException catch (e, s) {
        print('Unable to fetch notification message $payloadText: $e $s ');
      }
    }
  }

  Future sendLocalNotificationForMailLoadEvent(MailLoadEvent event) {
    return sendLocalNotificationForMail(event.message, event.mailClient);
  }

  Future sendLocalNotificationForMailMessage(maily.Message message) {
    return sendLocalNotificationForMail(
        message.mimeMessage, message.mailClient);
  }

  Future sendLocalNotificationForMail(
      MimeMessage mimeMessage, MailClient mailClient) {
    final notificationId = getId(mimeMessage, mailClient);
    if (notificationId == _lastNotificationId) {
      return Future.value();
    }
    _lastNotificationId = notificationId;
    var from = mimeMessage.from?.isNotEmpty ?? false
        ? mimeMessage.from.first.personalName
        : mimeMessage.sender?.personalName;
    if (from == null || from.isEmpty) {
      from = mimeMessage.from?.isNotEmpty ?? false
          ? mimeMessage.from.first.email
          : mimeMessage.sender?.email;
    }
    final subject = mimeMessage.decodeSubject();
    final payload = _MailNotificationPayload.fromMail(mimeMessage, mailClient);
    final payloadText = 'msg:' + Serializer().serialize(payload);
    return sendLocalNotification(notificationId, from, subject,
        payloadText: payloadText, when: mimeMessage.decodeDate());
  }

  int getId(MimeMessage mimeMessage, MailClient mailClient) {
    return mailClient.account.email.hashCode +
        mimeMessage.uid +
        mimeMessage.sequenceId;
  }

  Future sendLocalNotification(int id, String title, String text,
      {String payloadText, DateTime when, bool channelShowBadge = true}) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'maily', 'Mail', 'You have new mail',
        importance: Importance.max,
        priority: Priority.high,
        channelShowBadge: channelShowBadge,
        showWhen: true,
        when: when?.millisecondsSinceEpoch,
        playSound: false);
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin
        .show(id, title, text, platformChannelSpecifics, payload: payloadText);
  }

  void cancelNotificationForMailMessage(maily.Message message) {
    cancelNotificationForMail(message.mimeMessage, message.mailClient);
  }

  void cancelNotificationForMail(
      MimeMessage mimeMessage, MailClient mailClient) {
    cancelNotification(getId(mimeMessage, mailClient));
  }

  void cancelNotification(int id) {
    _flutterLocalNotificationsPlugin.cancel(id);
  }
}

class _MailNotificationPayload extends SerializableObject {
  int get uid => attributes['uid'];
  set uid(int value) => attributes['uid'] = value;
  int get id => attributes['id'];
  set id(int value) => attributes['id'] = value;
  String get accountEmail => attributes['account-email'];
  set accountEmail(String value) => attributes['account-email'] = value;
  String get subject => attributes['subject'];
  set subject(String value) => attributes['subject'] = value;
  int get size => attributes['size'];
  set size(int value) => attributes['size'] = value;

  _MailNotificationPayload();

  _MailNotificationPayload.fromMail(
      MimeMessage mimeMessage, MailClient mailClient) {
    uid = mimeMessage.uid;
    id = mimeMessage.sequenceId;
    subject = mimeMessage.decodeSubject();
    size = mimeMessage.size;
    accountEmail = mailClient.account.email;
  }
}
