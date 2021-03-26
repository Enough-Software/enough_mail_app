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
        print('Error: Unable to finish foreground backkground fetch: $e $s');
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
    final futures = <Future<int>>[];
    for (final client in mailClients) {
      futures.add(getNextUidFor(client));
    }
    final nextUids = await Future.wait(futures);
    final stringValue = _SharedPrefsHelper.renderIntList(nextUids);
    print('nextUids: $stringValue');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyInboxUids, stringValue);
  }

  Future<int> getNextUidFor(MailClient mailClient) async {
    try {
      if (mailClient.selectedMailbox == null) {
        await mailClient.connect();
        await mailClient.selectInbox();
      } else if (!mailClient.selectedMailbox.isInbox) {
        // do not interfere with other operations
        mailClient = MailClient(mailClient.account);
        await mailClient.connect();
        await mailClient.selectInbox();
      }
      return mailClient.selectedMailbox.uidNext;
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
    final futures = <Future<int>>[];
    for (var index = 0;
        index < math.min(prevUids.length, accounts.length);
        index++) {
      int previousUidNext = prevUids[index];
      final account = accounts[index];
      futures
          .add(loadNewMessage(account, previousUidNext, notificationService));
    }
    final newUids = await Future.wait(futures);
    final newPrefsValue = _SharedPrefsHelper.renderIntList(newUids);
    if (newPrefsValue != prefsValue &&
        newUids.every((element) => element != null)) {
      await prefs.setString(_keyInboxUids, newPrefsValue);
    }
  }

  static Future<int> loadNewMessage(MailAccount account, int previousUidNext,
      NotificationService notificationService) async {
    final mailClient =
        MailClient(account, isLogEnabled: true, logName: account.name);
    await mailClient.connect();
    final inbox = await mailClient.selectInbox();
    if (inbox.uidNext == previousUidNext) {
      print('no change for ${account.name}');
    } else {
      print(
          'new uidNext=${inbox.uidNext}, previous=$previousUidNext for ${account.name}');
      final sequence =
          MessageSequence.fromRangeToLast(previousUidNext, isUidSequence: true);
      final mimeMessages = await mailClient.fetchMessageSequence(sequence,
          fetchPreference: FetchPreference.envelope);
      for (final mimeMessage in mimeMessages) {
        notificationService.sendLocalNotificationForMail(
            mimeMessage, mailClient);
      }
    }

    await mailClient.disconnect();
    return inbox.uidNext;
  }
}

class _SharedPrefsHelper {
  static String renderIntList(final List<int> ids) {
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
