import 'dart:convert';
import 'dart:io';

import 'package:enough_mail/enough_mail.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import '../logger.dart';
import '../models/message.dart' as maily;
import '../routes/routes.dart';
import 'model.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService _instance = NotificationService._();

  /// Retrieves the instance of the notification service
  static NotificationService get instance => _instance;

  static const String _messagePayloadStart = 'msg:';
  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<NotificationServiceInitResult> init({
    BuildContext? context,
    bool checkForLaunchDetails = true,
  }) async {
    // print('init notification service...');
    // set up local notifications:
    // initialize the plugin. app_icon needs to be a added as a drawable
    // resource to the Android head project
    if (defaultTargetPlatform == TargetPlatform.windows) {
      // Windows is not yet supported:
      return NotificationServiceInitResult.normal;
    }
    const android = AndroidInitializationSettings('ic_stat_notification');
    final ios = DarwinInitializationSettings(
      // onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );
    const macos = DarwinInitializationSettings();
    final initSettings = InitializationSettings(
      android: android,
      iOS: ios,
      macOS: macos,
    );
    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _selectNotification,
    );
    if (Platform.isAndroid) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
    if (checkForLaunchDetails) {
      final launchDetails =
          await _flutterLocalNotificationsPlugin
              .getNotificationAppLaunchDetails();
      if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
        final response = launchDetails.notificationResponse;
        if (response != null) {
          // print(
          //     'got notification launched details: $launchDetails
          // with payload ${response.payload}');
          if (context != null && context.mounted) {
            _selectNotification(response, context: context);
          }

          return NotificationServiceInitResult.appLaunchedByNotification;
        }
      }
    }

    return NotificationServiceInitResult.normal;
  }

  Future _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) async {
    if (kDebugMode) {
      print('iOS onDidReceiveLocalNotification $id $title $body $payload');
    }
  }

  Future<List<MailNotificationPayload>> getActiveMailNotifications() {
    /// wait until active notification also return the payload
    return Future.value([]);
    // if (!Platform.isAndroid) {
    //   return [];
    // }
    // final activeNotifications = await _flutterLocalNotificationsPlugin
    //     .resolvePlatformSpecificImplementation<
    //         AndroidFlutterLocalNotificationsPlugin>()
    //     .getActiveNotifications();
    // if (activeNotifications == null || activeNotifications.isEmpty) {
    //   return [];
    // }
    // print('active Notifications:');
    // for (final n in activeNotifications) {
    //   print(
    //       'body=${n.body}, title=${n.title}, id=${n.id}, channel=${n.channelId}');
    // }
    // return activeNotifications
    //     .where((notification) =>
    //         notification.body.startsWith(_messagePayloadStart))
    //     .map((notification) => _deserialize(notification.body))
    //     .toList();
  }

  MailNotificationPayload _deserialize(String payloadText) {
    final json = jsonDecode(payloadText.substring(_messagePayloadStart.length));

    return MailNotificationPayload.fromJson(json);
  }

  void _selectNotification(
    NotificationResponse response, {
    BuildContext? context,
  }) {
    final payloadText = response.payload;
    if (kDebugMode) {
      print('select notification: $payloadText');
    }
    final usedContext = context ?? Routes.navigatorKey.currentContext;
    if (usedContext == null) {
      logger.e('Unable to show notification: no context found');

      return;
    }

    if (payloadText != null && payloadText.startsWith(_messagePayloadStart)) {
      final payload = _deserialize(payloadText);
      usedContext.pushNamed(Routes.mailDetailsForNotification, extra: payload);
    }
  }

  Future sendLocalNotificationForMailMessage(maily.Message message) =>
      sendLocalNotificationForMail(
        message.mimeMessage,
        message.source.getMimeSource(message)?.mailClient.account.email ??
            message.account.email,
      );

  Future sendLocalNotificationForMail(
    MimeMessage mimeMessage,
    String accountEmail,
  ) {
    String retrieveFromName() {
      final mimeFrom = mimeMessage.from;
      final personalName =
          mimeFrom != null && mimeFrom.isNotEmpty
              ? mimeFrom.first.personalName
              : mimeMessage.sender?.personalName;
      if (personalName != null && personalName.isNotEmpty) {
        return personalName;
      }
      final email =
          mimeFrom != null && mimeFrom.isNotEmpty
              ? mimeFrom.first.email
              : mimeMessage.sender?.email;
      if (email != null && email.isNotEmpty) {
        return email;
      }

      return '';
    }

    final notificationId = mimeMessage.guid ?? 0;
    final from = retrieveFromName();

    final subject = mimeMessage.decodeSubject();
    final payload = MailNotificationPayload.fromMail(mimeMessage, accountEmail);
    final payloadText = _messagePayloadStart + jsonEncode(payload.toJson());

    return _sendLocalNotification(
      notificationId,
      from,
      subject,
      payloadText: payloadText,
      when: mimeMessage.decodeDate(),
    );
  }

  // int getNotificationIdForMail(MimeMessage mimeMessage, MailClient mailClient) {
  //   return getNotificationIdForUid(mimeMessage.uid!, mailClient.account.email);
  // }

  // int getNotificationIdForUid(int uid, String? email) {
  //   return (email?.hashCode ?? 0) + uid;
  // }

  Future<void> _sendLocalNotification(
    int id,
    String title,
    String? text, {
    String? payloadText,
    DateTime? when,
    bool channelShowBadge = true,
  }) async {
    logger.d('sendLocalNotification: $id: $title $text');
    AndroidNotificationDetails? androidPlatformChannelSpecifics;
    DarwinNotificationDetails? iosPlatformChannelSpecifics;
    if (Platform.isAndroid) {
      androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'maily',
        'Mail',
        channelDescription: 'Maily',
        importance: Importance.max,
        priority: Priority.high,
        channelShowBadge: channelShowBadge,
        showWhen: when != null,
        when: when?.millisecondsSinceEpoch,
        sound: const RawResourceAndroidNotificationSound('pop'),
      );
    } else if (PlatformInfo.isCupertino) {
      iosPlatformChannelSpecifics = const DarwinNotificationDetails(
        presentSound: true,
        presentBadge: true,
      );
    }
    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      text,
      platformChannelSpecifics,
      payload: payloadText,
    );
  }

  void cancelNotificationForMessage(maily.Message message) =>
      cancelNotificationForMime(message.mimeMessage);

  void cancelNotificationForMime(MimeMessage mimeMessage) {
    final guid = mimeMessage.guid;
    if (guid != null) {
      cancelNotification(guid);
    }
  }

  // void cancelNotificationForUid(int uid, MailClient mailClient) {
  //   cancelNotification(getNotificationIdForUid(uid, mailClient.account.email));
  // }

  void cancelNotification(int id) {
    if (defaultTargetPlatform != TargetPlatform.windows) {
      _flutterLocalNotificationsPlugin.cancel(id);
    }
  }
}
