import 'dart:convert';
import 'dart:math';

import 'package:background_fetch/background_fetch.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../account/provider.dart';
import '../account/storage.dart';
import '../app_lifecycle/provider.dart';
import '../logger.dart';
import '../mail/provider.dart';
import '../mail/service.dart';
import '../notification/service.dart';
import 'model.dart';

part 'provider.g.dart';

/// Registers the background service to check for emails regularly
@Riverpod(keepAlive: true)
class Background extends _$Background {
  var _isActive = true;

  @override
  Future<void> build() {
    _isActive = true;
    ref.onDispose(() {
      _isActive = false;
    });
    if (!_isSupported) {
      return Future.value();
    }
    final isInactive = ref.watch(appIsInactivatedProvider);
    if (isInactive) {
      return _saveStateOnPause();
    }

    return Future.value();
  }

  /// Is the background provider supported on the current platform?
  static bool get _isSupported =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  /// Configures and registers the background service
  Future<void> init() async {
    if (!_isSupported) {
      return;
    }
    await BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15,
        startOnBoot: true,
        stopOnTerminate: false,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.ANY,
      ),
      (String taskId) async {
        logger.d('running background fetch $taskId');
        try {
          //   await locator<MailService>().resume();
          await _saveStateOnPause();
        } catch (e, s) {
          logger.e(
            'Error: Unable to finish foreground background fetch: $e',
            error: e,
            stackTrace: s,
          );
        }
        BackgroundFetch.finish(taskId);
      },
    );
    await BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
    logger.d('Registered background fetch');
  }

  Future<void> _saveStateOnPause() async {
    logger.d('save state on pause: isActive=$_isActive');
    if (!_isActive) {
      return _checkForNewMail();
    }

    final accounts = ref.read(realAccountsProvider);
    final mailClients = accounts
        .map(
          (account) => ref.read(mailClientSourceProvider(account: account)),
        )
        .toList();
    final futures = <Future>[];
    final preferences = await SharedPreferences.getInstance();
    final jsonText = preferences.getString(_keyInboxUids);
    final info = BackgroundUpdateInfo.fromJsonText(jsonText);
    for (final client in mailClients) {
      futures.add(_addNextUidFor(client, info));
    }
    await Future.wait(futures);
    logger.d('Updated UIDs, new UIDs found: ${info.containsUpdatedEntries}');
    if (info.containsUpdatedEntries) {
      final stringValue = jsonEncode(info.toJson());
      logger.d('nextUids: $stringValue');
      await preferences.setString(_keyInboxUids, stringValue);
    }
  }

  Future<void> _addNextUidFor(
    final MailClient mailClient,
    final BackgroundUpdateInfo info,
  ) async {
    try {
      var box = mailClient.selectedMailbox;
      if (box == null || !box.isInbox) {
        await mailClient.connect();
        box = await mailClient.selectInbox();
      }
      final uidNext = box.uidNext;
      if (uidNext != null) {
        info.updateForEmail(mailClient.account.email, uidNext);
      }
    } catch (e, s) {
      logger.e(
        'Error while getting Inbox.nextUids '
        'for ${mailClient.account.email}: $e',
        error: e,
        stackTrace: s,
      );
    }
  }
}

const String _keyInboxUids = 'nextUidsInfo';

/// Fetches data in the background when the app is not running
Future<void> backgroundFetchHeadlessTask(HeadlessTask task) async {
  final taskId = task.taskId;
  logger.d(
    'backgroundFetchHeadlessTask with '
    'taskId $taskId, timeout=${task.timeout}',
  );
  if (task.timeout) {
    BackgroundFetch.finish(taskId);

    return;
  }
  try {
    await _checkForNewMail();
  } catch (e, s) {
    if (kDebugMode) {
      print('Error during backgroundFetchHeadlessTask $e $s');
    }
  } finally {
    BackgroundFetch.finish(taskId);
  }
}

Future<void> _checkForNewMail() async {
  logger.d('background check at ${DateTime.now()}');
  final preferences = await SharedPreferences.getInstance();

  final inboxUidsText = preferences.getString(_keyInboxUids);
  if (inboxUidsText == null || inboxUidsText.isEmpty) {
    logger.w('WARNING: no previous UID infos found, exiting.');

    return;
  }

  final info = BackgroundUpdateInfo.fromJsonText(inboxUidsText);
  const storage = AccountStorage();
  final accounts = await storage.loadAccounts();
  final mailClients = accounts.map(
    (account) => EmailService.instance
        .createMailClient(account.mailAccount, account.name, null),
  );
  final notificationService = NotificationService.instance;
  await notificationService.init(checkForLaunchDetails: false);
  // final activeMailNotifications =
  //     await notificationService.getActiveMailNotifications();
  // print('background: got '
  // 'activeMailNotifications=$activeMailNotifications');
  final futures = <Future>[];
  for (final mailClient in mailClients) {
    final previousUidNext =
        info.nextExpectedUidForEmail(mailClient.account.email) ?? 0;
    futures.add(
      _loadNewMessage(
        mailClient,
        previousUidNext,
        notificationService,
        info,
        // activeMailNotifications
        //     .where((n) => n.accountEmail == accountEmail)
        //     .toList()),
      ),
    );
  }
  await Future.wait(futures);
  if (info.containsUpdatedEntries) {
    final serialized = jsonEncode(info.toJson());
    await preferences.setString(_keyInboxUids, serialized);
  }
}

Future<void> _loadNewMessage(
  MailClient mailClient,
  int previousUidNext,
  NotificationService notificationService,
  BackgroundUpdateInfo info,
  // List<MailNotificationPayload> activeNotifications,
) async {
  try {
    // ignore: avoid_print
    print('${mailClient.account.name} A: background fetch connecting');
    await mailClient.connect();
    final inbox = await mailClient.selectInbox();
    final uidNext = inbox.uidNext;
    if (uidNext == previousUidNext || uidNext == null) {
      // print(
      //     'no change for ${account.name}, activeNotifications=$activeNotifications');
      // check outdated notifications that should be removed because the message is deleted or read elsewhere:
      // if (activeNotifications.isNotEmpty) {
      //   final uids = activeNotifications.map((n) => n.uid).toList();
      //   final sequence =
      //       MessageSequence.fromIds(uids as List<int>, isUid: true);
      //   final mimeMessages = await mailClient.fetchMessageSequence(sequence,
      //       fetchPreference: FetchPreference.envelope);
      //   for (final mimeMessage in mimeMessages) {
      //     if (mimeMessage.isSeen) {
      //       notificationService.cancelNotificationForMail(
      //           mimeMessage, mailClient);
      //     }
      //     uids.remove(mimeMessage.uid);
      //   }
      //   // remove notifications for messages that have been deleted:
      //   final email = mailClient.account.email ?? '';
      //   final mailboxName = mailClient.selectedMailbox?.name ?? '';
      //   final mailboxValidity = mailClient.selectedMailbox?.uidValidity ?? 0;
      //   for (final uid in uids) {
      //     final guid = MimeMessage.calculateGuid(
      //       email: email,
      //       mailboxName: mailboxName,
      //       mailboxUidValidity: mailboxValidity,
      //       messageUid: uid,
      //     );
      //     notificationService.cancelNotification(guid);
      //   }
      // }
    } else {
      if (kDebugMode) {
        print(
          'new uidNext=$uidNext, previous=$previousUidNext '
          'for ${mailClient.account.name} uidValidity=${inbox.uidValidity}',
        );
      }
      final sequence = MessageSequence.fromRangeToLast(
        // special care when uidnext of the account was not known before:
        // do not load _all_ messages
        previousUidNext == 0
            ? max(previousUidNext, uidNext - 10)
            : previousUidNext,
        isUidSequence: true,
      );
      info.updateForEmail(mailClient.account.email, uidNext);
      final mimeMessages = await mailClient.fetchMessageSequence(
        sequence,
        fetchPreference: FetchPreference.envelope,
      );
      for (final mimeMessage in mimeMessages) {
        if (!mimeMessage.isSeen) {
          await notificationService.sendLocalNotificationForMail(
            mimeMessage,
            mailClient.account.email,
          );
        }
      }
    }

    await mailClient.disconnect();
  } catch (e, s) {
    logger.e(
      'Unable to process background operation '
      'for ${mailClient.account.name}: $e',
      error: e,
      stackTrace: s,
    );
  }
}
