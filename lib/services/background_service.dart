import 'package:background_fetch/background_fetch.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

import '../locator.dart';
import 'mail_service.dart';

class BackgroundService {
  static const String _keyInboxUids = 'nextUids';

  Future init() async {
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
        ), (String taskId) async {
      try {
        await locator<MailService>().resume();
      } catch (e, s) {
        print('Error: Unable to finish foreground background fetch: $e $s');
      }
      BackgroundFetch.finish(taskId);
    }, (String taskId) {
      BackgroundFetch.finish(taskId);
    });
    await BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  }

  static void backgroundFetchHeadlessTask(HeadlessTask task) async {
    final taskId = task.taskId;
    print(
        'backgroundFetchHeadlessTask with taskId $taskId, timeout=${task.timeout}');
    if (task.timeout) {
      BackgroundFetch.finish(taskId);
      return;
    }
    try {
      await checkForNewMail();
    } catch (e, s) {
      print('Error during backgroundFetchHeadlessTask $e $s');
    } finally {
      BackgroundFetch.finish(taskId);
    }
  }

  Future saveStateOnPause() async {
    final mailClients = locator<MailService>().getMailClients();
    final List<Future<int?>> futures = <Future<int>>[];
    for (final client in mailClients) {
      futures.add(getNextUidFor(client));
    }
    final nextUids = await Future.wait(futures);
    final stringValue = _SharedPrefsHelper.renderIntList(nextUids);
    print('nextUids: $stringValue');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyInboxUids, stringValue);
  }

  Future<int> getNextUidFor(final MailClient mailClient) async {
    try {
      var box = mailClient.selectedMailbox;
      if (box == null || !box.isInbox) {
        final connected =
            await locator<MailService>().connect(mailClient.account);
        if (connected == null) {
          return 0;
        }
        box = await connected.selectInbox();
      }
      return box.uidNext ?? 0;
    } catch (e, s) {
      print(
          'Error while getting Inbox.nextUids for ${mailClient.account.email}: $e $s');
    }
    return 0;
  }

  static Future checkForNewMail() async {
    print('background check at ${DateTime.now()}');
    final prefs = await SharedPreferences.getInstance();

    final prefsValue = prefs.getString(_keyInboxUids);
    if (prefsValue == null) {
      print('WARNING: no previous nextUid values found, exiting.');
      return;
    }
    final prevUids = _SharedPrefsHelper.parseIntList(prefsValue);
    final mailService = MailService();
    final accounts = await mailService.loadMailAccounts();
    final notificationService = NotificationService();
    await notificationService.init(checkForLaunchDetails: false);
    final activeMailNotifications =
        await notificationService.getActiveMailNotifications();
    // print('background: got activeMailNotifications=$activeMailNotifications');
    final List<Future<int?>> futures = <Future<int>>[];
    for (var index = 0;
        index < math.min(prevUids.length, accounts.length);
        index++) {
      int previousUidNext = prevUids[index];
      final account = accounts[index];
      final accountEmail = account.email;
      futures.add(loadNewMessage(
          mailService,
          account,
          previousUidNext,
          notificationService,
          activeMailNotifications
              .where((n) => n.accountEmail == accountEmail)
              .toList()));
    }
    final newUids = await Future.wait(futures);
    final newPrefsValue = _SharedPrefsHelper.renderIntList(newUids);
    if (newPrefsValue != prefsValue &&
        newUids.every((element) => element != null)) {
      await prefs.setString(_keyInboxUids, newPrefsValue);
    }
  }

  static Future<int> loadNewMessage(
      MailService mailService,
      MailAccount account,
      int previousUidNext,
      NotificationService notificationService,
      List<MailNotificationPayload> activeNotifications) async {
    try {
      final mailClient = await mailService.connect(account);
      if (mailClient == null) {
        return previousUidNext;
      }
      final inbox = await mailClient.selectInbox();
      if (inbox.uidNext == previousUidNext) {
        // print(
        //     'no change for ${account.name}, activeNotifications=$activeNotifications');
        // check outdated notifications that should be removed because the message is deleted or read elsewhere:
        if (activeNotifications.isNotEmpty) {
          final uids = activeNotifications.map((n) => n.uid).toList();
          final sequence =
              MessageSequence.fromIds(uids as List<int>, isUid: true);
          final mimeMessages = await mailClient.fetchMessageSequence(sequence,
              fetchPreference: FetchPreference.envelope);
          for (final mimeMessage in mimeMessages) {
            if (mimeMessage.isSeen) {
              notificationService.cancelNotificationForMail(
                  mimeMessage, mailClient);
            }
            uids.remove(mimeMessage.uid);
          }
          // remove notifications for messages that have been deleted:
          for (final uid in uids) {
            notificationService.cancelNotificationForUid(uid, mailClient);
          }
        }
      } else {
        print(
            'new uidNext=${inbox.uidNext}, previous=$previousUidNext for ${account.name}');
        final sequence = MessageSequence.fromRangeToLast(previousUidNext,
            isUidSequence: true);
        final mimeMessages = await mailClient.fetchMessageSequence(sequence,
            fetchPreference: FetchPreference.envelope);
        for (final mimeMessage in mimeMessages) {
          if (!mimeMessage.isSeen) {
            notificationService.sendLocalNotificationForMail(
                mimeMessage, mailClient);
          }
        }
      }

      await mailClient.disconnect();
      return inbox.uidNext ?? previousUidNext;
    } catch (e, s) {
      print(
          'Unable to process background operation for ${account.name}: $e $s');
      return previousUidNext;
    }
  }
}

class _SharedPrefsHelper {
  static String renderIntList(final List<int?> ids) {
    final buffer = StringBuffer();
    bool addComma = false;
    for (final id in ids) {
      if (addComma) {
        buffer.write(',');
      }
      buffer.write(id);
      addComma = true;
    }
    return buffer.toString();
  }

  static List<int> parseIntList(String input) {
    return input.split(',').map((s) => int.parse(s)).toList();
  }
}
