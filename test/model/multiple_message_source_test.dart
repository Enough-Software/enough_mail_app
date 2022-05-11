import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/async_mime_source.dart';
import 'package:enough_mail_app/models/message.dart';
import 'package:enough_mail_app/models/message_source.dart';
import 'package:enough_mail_app/services/notification_service.dart';
import 'package:enough_mail_app/services/scaffold_messenger_service.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/material/scaffold.dart';
import 'package:enough_mail_app/widgets/cupertino_status_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'fake_mime_source.dart';

void main() async {
  final notificationService = TestNotificationService();
  GetIt.instance.registerSingleton<NotificationService>(notificationService);
  GetIt.instance.registerLazySingleton<ScaffoldMessengerService>(
      () => TestScaffoldMessengerService());

  final firstMimeSourceStartDate = DateTime.utc(2022, 04, 16, 09, 00);
  const firstMimeSourceDifferencePerMessage = Duration(minutes: 5);
  final secondMimeSourceStartDate = DateTime.utc(2022, 04, 16, 09, 01);
  const secondMimeSourceDifferencePerMessage = Duration(minutes: 10);

  late AsyncMimeSource firstMimeSource;
  late AsyncMimeSource secondMimeSource;
  late MultipleMessageSource source;
  setUp(() {
    firstMimeSource = FakeMimeSource(
      size: 100,
      name: 'first',
      startDate: firstMimeSourceStartDate,
      differencePerMessage: firstMimeSourceDifferencePerMessage,
    );
    secondMimeSource = FakeMimeSource(
      size: 20,
      name: 'second',
      startDate: secondMimeSourceStartDate,
      differencePerMessage: secondMimeSourceDifferencePerMessage,
    );
    source = MultipleMessageSource(
        [firstMimeSource, secondMimeSource], 'multiple', MailboxFlag.inbox);
  });

  Future<void> _expectMessagesOrderedByDate({int numberToTest = 20}) async {
    var lastDate = DateTime.now();
    var lastSubject = '<no message>';
    for (int i = 0; i < numberToTest; i++) {
      final message = await source.getMessageAt(i);
      final messageDate = message.mimeMessage.decodeDate();
      final subject =
          message.mimeMessage.decodeSubject() ?? '<no subject for $i>';
      expect(
        messageDate,
        isNotNull,
        reason: 'no date for message at index $i $subject',
      );
      expect(
        messageDate!.isBefore(lastDate),
        isTrue,
        reason:
            'wrong date for message at $i: $messageDate of "$subject" should be before $lastDate of "$lastSubject"',
      );
      lastDate = messageDate;
      lastSubject = subject;
    }
  }

  group('base tests', () {
    test('size', () async {
      expect(source.size, 120);
    });

    test('load first message', () async {
      final message = await source.getMessageAt(0);
      expect(message.mimeMessage.sequenceId, 20);
      expect(message.mailClient, secondMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 20');
      expect(message.mimeMessage.decodeDate(),
          secondMimeSourceStartDate.toLocal());
    });

    test('load second message', () async {
      final message = await source.getMessageAt(1);
      expect(message.mimeMessage.sequenceId, 100);
      expect(message.mailClient, firstMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'firstSubject 100');
      expect(
          message.mimeMessage.decodeDate(), firstMimeSourceStartDate.toLocal());
    });

    test('load third message', () async {
      final message = await source.getMessageAt(2);
      expect(message.mimeMessage.sequenceId, 99);
      expect(message.mailClient, firstMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'firstSubject 99');
      expect(
          message.mimeMessage.decodeDate(),
          firstMimeSourceStartDate
              .subtract(firstMimeSourceDifferencePerMessage)
              .toLocal());
    });

    test('load fourth message', () async {
      final message = await source.getMessageAt(3);
      expect(message.mimeMessage.sequenceId, 19);
      expect(message.mailClient, secondMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 19');
      expect(
          message.mimeMessage.decodeDate(),
          secondMimeSourceStartDate
              .subtract(secondMimeSourceDifferencePerMessage)
              .toLocal());
    });

    test('ensure dates are strictly ordered', () async {
      DateTime? lastDateTime =
          (await source.getMessageAt(0)).mimeMessage.decodeDate();
      expect(lastDateTime, isNotNull);
      for (int i = 1; i < source.size; i++) {
        final nextDateTime =
            (await source.getMessageAt(i)).mimeMessage.decodeDate();
        expect(nextDateTime, isNotNull,
            reason: 'decodeDate() is null for message $i');
        expect(nextDateTime?.isBefore(lastDateTime!), isTrue,
            reason:
                '$nextDateTime should be before $lastDateTime for message $i');
        lastDateTime = nextDateTime;
      }
    });
  });

  group('incoming messages', () {
    test('simple onMessageArrived x 1', () async {
      (firstMimeSource as FakeMimeSource).addFakeMessage(101);
      final message = await source.getMessageAt(0);
      expect(message.mailClient, firstMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'firstSubject 101');
      expect(
          message.mimeMessage.decodeDate(),
          firstMimeSourceStartDate
              .add(firstMimeSourceDifferencePerMessage)
              .toLocal());
      await _expectMessagesOrderedByDate();
    });

    test('real update - onMessageArrived x 1', () async {
      var hasBeenNotified = false;
      source.addListener(() {
        hasBeenNotified = true;
      });
      var message = await source.getMessageAt(0);
      expect(message.mimeMessage.sequenceId, 20);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 20');
      expect(message.mailClient, secondMimeSource.mailClient);
      expect(message.mimeMessage.decodeDate(),
          secondMimeSourceStartDate.toLocal());
      // add new message:
      (firstMimeSource as FakeMimeSource).addFakeMessage(101);
      message = await source.getMessageAt(0);
      expect(message.mimeMessage.sequenceId, 101);
      expect(message.mimeMessage.decodeSubject(), 'firstSubject 101');
      expect(message.mailClient, firstMimeSource.mailClient);
      expect(
          message.mimeMessage.decodeDate(),
          firstMimeSourceStartDate
              .add(firstMimeSourceDifferencePerMessage)
              .toLocal());
      expect(hasBeenNotified, isTrue);
    });

    test('real update 1 x- test first 2 messages', () async {
      var hasBeenNotified = false;
      source.addListener(() {
        hasBeenNotified = true;
      });
      var message = await source.getMessageAt(0);
      expect(message.mimeMessage.sequenceId, 20);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 20');
      expect(message.mailClient, secondMimeSource.mailClient);
      expect(message.mimeMessage.decodeDate(),
          secondMimeSourceStartDate.toLocal());

      message = await source.getMessageAt(1);
      expect(message.mimeMessage.sequenceId, 100);
      expect(message.mimeMessage.decodeSubject(), 'firstSubject 100');
      expect(message.mailClient, firstMimeSource.mailClient);
      expect(
          message.mimeMessage.decodeDate(), firstMimeSourceStartDate.toLocal());
      // add new message:
      (firstMimeSource as FakeMimeSource).addFakeMessage(101);
      message = await source.getMessageAt(0);
      expect(message.mimeMessage.sequenceId, 101);
      expect(message.mimeMessage.decodeSubject(), 'firstSubject 101');
      expect(message.mailClient, firstMimeSource.mailClient);
      expect(
          message.mimeMessage.decodeDate(),
          firstMimeSourceStartDate
              .add(firstMimeSourceDifferencePerMessage)
              .toLocal());
      expect(hasBeenNotified, isTrue);

      message = await source.getMessageAt(1);
      expect(message.mimeMessage.sequenceId, 20);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 20');
      expect(message.mailClient, secondMimeSource.mailClient);
      expect(message.mimeMessage.decodeDate(),
          secondMimeSourceStartDate.toLocal());
    });

    test('onMessageArrived x 2', () async {
      var notifyCounter = 0;
      source.addListener(() {
        notifyCounter++;
      });
      var message = await source.getMessageAt(0);
      expect(message.mimeMessage.sequenceId, 20);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 20');
      expect(message.mailClient, secondMimeSource.mailClient);
      expect(message.mimeMessage.decodeDate(),
          secondMimeSourceStartDate.toLocal());
      // add new message:
      (firstMimeSource as FakeMimeSource).addFakeMessage(101);
      expect(notifyCounter, 1);
      // add new message:
      (secondMimeSource as FakeMimeSource).addFakeMessage(21);
      message = await source.getMessageAt(0);
      expect(message.mimeMessage.sequenceId, 21);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 21');
      expect(message.mailClient, secondMimeSource.mailClient);
      expect(
          message.mimeMessage.decodeDate(),
          secondMimeSourceStartDate
              .add(secondMimeSourceDifferencePerMessage)
              .toLocal());
      expect(notifyCounter, 2);
      await _expectMessagesOrderedByDate();
    });

    test('onMessageArrived - once per source ordered by data', () async {
      var notifyCounter = 0;
      source.addListener(() => notifyCounter++);
      var message = await source.getMessageAt(0);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 20');
      message = await source.getMessageAt(1);
      expect(message.mimeMessage.decodeSubject(), 'firstSubject 100');
      (firstMimeSource as FakeMimeSource).addFakeMessage(101);
      (secondMimeSource as FakeMimeSource).addFakeMessage(21);
      expect(notifyCounter, 2);
      expect(source.size, 122);
      message = await source.getMessageAt(0);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 21');
      expect(
          message.mimeMessage.decodeDate(),
          secondMimeSourceStartDate
              .add(secondMimeSourceDifferencePerMessage)
              .toLocal());
      message = await source.getMessageAt(1);
      expect(message.mimeMessage.decodeSubject(), 'firstSubject 101');
      expect(
          message.mimeMessage.decodeDate(),
          firstMimeSourceStartDate
              .add(firstMimeSourceDifferencePerMessage)
              .toLocal());
      await _expectMessagesOrderedByDate();
    });

    test('onMessageArrived - once per source out of date order', () async {
      var notifyCounter = 0;
      source.addListener(() => notifyCounter++);
      var message = await source.getMessageAt(0);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 20');
      message = await source.getMessageAt(1);
      expect(message.mimeMessage.decodeSubject(), 'firstSubject 100');
      (secondMimeSource as FakeMimeSource).addFakeMessage(21);
      (firstMimeSource as FakeMimeSource).addFakeMessage(101);
      expect(notifyCounter, 2);
      expect(source.size, 122);
      message = await source.getMessageAt(0);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 21');
      expect(
          message.mimeMessage.decodeDate(),
          secondMimeSourceStartDate
              .add(secondMimeSourceDifferencePerMessage)
              .toLocal());
      message = await source.getMessageAt(1);
      expect(message.mimeMessage.decodeSubject(), 'firstSubject 101');
      expect(
          message.mimeMessage.decodeDate(),
          firstMimeSourceStartDate
              .add(firstMimeSourceDifferencePerMessage)
              .toLocal());
      await _expectMessagesOrderedByDate();
    });
  });

  group('vanished', () {
    test('onMessagesVanished - single and first sequence ID', () async {
      var notifyCounter = 0;
      source.addListener(() {
        notifyCounter++;
      });
      var message = await source.getMessageAt(0);
      expect(message.mimeMessage.sequenceId, 20);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 20');
      expect(message.mailClient, secondMimeSource.mailClient);
      expect(message.mimeMessage.decodeDate(),
          secondMimeSourceStartDate.toLocal());
      // remove message:
      await secondMimeSource.onMessagesVanished(MessageSequence.fromIds([20]));
      expect(notifyCounter, 1);
      message = await source.getMessageAt(0);
      expect(message.mimeMessage.sequenceId, 100);
      expect(message.mailClient, firstMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'firstSubject 100');
      expect(
          message.mimeMessage.decodeDate(), firstMimeSourceStartDate.toLocal());
    });

    test('onMessagesVanished - second sequence ID', () async {
      var notifyCounter = 0;
      source.addListener(() {
        notifyCounter++;
      });
      var message = await source.getMessageAt(0);
      expect(message.mimeMessage.sequenceId, 20);
      message = await source.getMessageAt(1);
      expect(message.mimeMessage.sequenceId, 100);
      message = await source.getMessageAt(2);
      expect(message.mimeMessage.sequenceId, 99);
      message = await source.getMessageAt(3);
      expect(message.mimeMessage.sequenceId, 19);
      message = await source.getMessageAt(4);
      expect(message.mimeMessage.sequenceId, 98);
      message = await source.getMessageAt(5);
      expect(message.mimeMessage.sequenceId, 97);
      // remove message:
      await firstMimeSource.onMessagesVanished(MessageSequence.fromIds([100]));
      expect(notifyCounter, 1);
      message = await source.getMessageAt(0);
      expect(message.mimeMessage.sequenceId, 20);
      message = await source.getMessageAt(1);
      expect(message.mimeMessage.sequenceId, 99);
      message = await source.getMessageAt(2);
      expect(message.mimeMessage.sequenceId, 19);
      message = await source.getMessageAt(3);
      expect(message.mimeMessage.sequenceId, 98);
      message = await source.getMessageAt(4);
      expect(message.mimeMessage.sequenceId, 97);
      message = await source.getMessageAt(0);
    });

    test('onMessagesVanished - single and first UID', () async {
      var notifyCounter = 0;
      source.addListener(() {
        notifyCounter++;
      });
      var message = await source.getMessageAt(0);
      expect(message.mimeMessage.sequenceId, 20);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 20');
      expect(message.mailClient, secondMimeSource.mailClient);
      expect(message.mimeMessage.decodeDate(),
          secondMimeSourceStartDate.toLocal());
      // remove message:
      await secondMimeSource
          .onMessagesVanished(MessageSequence.fromIds([20], isUid: true));
      expect(notifyCounter, 1);
      message = await source.getMessageAt(0);
      expect(message.mimeMessage.sequenceId, 100);
      expect(message.mailClient, firstMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'firstSubject 100');
      expect(
          message.mimeMessage.decodeDate(), firstMimeSourceStartDate.toLocal());
    });

    test('onMessagesVanished - second UID', () async {
      var notifyCounter = 0;
      source.addListener(() {
        notifyCounter++;
      });
      var message = await source.getMessageAt(0);
      expect(message.mimeMessage.sequenceId, 20);
      message = await source.getMessageAt(1);
      expect(message.mimeMessage.sequenceId, 100);
      message = await source.getMessageAt(2);
      expect(message.mimeMessage.sequenceId, 99);
      message = await source.getMessageAt(3);
      expect(message.mimeMessage.sequenceId, 19);
      message = await source.getMessageAt(4);
      expect(message.mimeMessage.sequenceId, 98);
      message = await source.getMessageAt(5);
      expect(message.mimeMessage.sequenceId, 97);
      // remove message:
      await firstMimeSource
          .onMessagesVanished(MessageSequence.fromIds([100], isUid: true));
      expect(notifyCounter, 1);
      message = await source.getMessageAt(0);
      expect(message.mimeMessage.sequenceId, 20);
      message = await source.getMessageAt(1);
      expect(message.mimeMessage.sequenceId, 99);
      message = await source.getMessageAt(2);
      expect(message.mimeMessage.sequenceId, 19);
      message = await source.getMessageAt(3);
      expect(message.mimeMessage.sequenceId, 98);
      message = await source.getMessageAt(4);
      expect(message.mimeMessage.sequenceId, 97);
      message = await source.getMessageAt(0);
    });

    test('onMessagesVanished - 2 UIDs', () async {
      var notifyCounter = 0;
      source.addListener(() {
        notifyCounter++;
      });
      var message = await source.getMessageAt(0);
      expect(message.mimeMessage.sequenceId, 20);
      message = await source.getMessageAt(1);
      expect(message.mimeMessage.sequenceId, 100);
      message = await source.getMessageAt(2);
      expect(message.mimeMessage.sequenceId, 99);
      message = await source.getMessageAt(3);
      expect(message.mimeMessage.sequenceId, 19);
      message = await source.getMessageAt(4);
      expect(message.mimeMessage.sequenceId, 98);
      message = await source.getMessageAt(5);
      expect(message.mimeMessage.sequenceId, 97);
      // remove message:
      await firstMimeSource
          .onMessagesVanished(MessageSequence.fromIds([100, 99], isUid: true));
      expect(notifyCounter, 2);
      message = await source.getMessageAt(0);
      expect(message.mimeMessage.sequenceId, 20);
      message = await source.getMessageAt(1);
      expect(message.mimeMessage.sequenceId, 19);
      message = await source.getMessageAt(2);
      expect(message.mimeMessage.sequenceId, 98);
      message = await source.getMessageAt(3);
      expect(message.mimeMessage.sequenceId, 97);
      message = await source.getMessageAt(4);
      expect(message.mimeMessage.sequenceId, 18);
      message = await source.getMessageAt(0);
    });
  });

  group('deleteAll', () {
    test('size', () async {
      expect(source.size, 120);
      await source.deleteAllMessages();
      expect(source.size, 0);
    });
  });

  group('flags', () {
    test('notify seen', () async {
      final firstMime = await secondMimeSource.getMessage(0);
      expect(firstMime.isSeen, isFalse);
      expect(firstMime.sequenceId, isNotNull);
      final firstMessage = await source.getMessageAt(0);
      expect(firstMessage.mimeMessage.guid, firstMime.guid);
      expect(firstMessage.isSeen, isFalse);
      var notifyCounter = 0;
      firstMessage.addListener(() {
        notifyCounter++;
      });

      final updatedMime = (secondMimeSource as FakeMimeSource)
          .createMessage(firstMime.sequenceId!);
      updatedMime.setFlag(MessageFlags.seen, true);
      secondMimeSource.onMessageFlagsUpdated(updatedMime);
      expect(notifyCounter, 1);
      expect(firstMessage.isSeen, isTrue);
    });

    test('notify unseen', () async {
      final firstMime = await secondMimeSource.getMessage(0);
      firstMime.setFlag(MessageFlags.seen, true);
      expect(firstMime.isSeen, isTrue);
      expect(firstMime.sequenceId, isNotNull);
      final firstMessage = await source.getMessageAt(0);
      expect(firstMessage.mimeMessage.guid, firstMime.guid);
      expect(firstMessage.isSeen, isTrue);
      var notifyCounter = 0;
      firstMessage.addListener(() {
        notifyCounter++;
      });

      final updatedMime = (secondMimeSource as FakeMimeSource)
          .createMessage(firstMime.sequenceId!);
      updatedMime.setFlag(MessageFlags.seen, false);
      secondMimeSource.onMessageFlagsUpdated(updatedMime);
      expect(notifyCounter, 1);
      expect(firstMessage.isSeen, isFalse);
    });
  });

  group('resync manually', () {
    test('same messages after resync', () async {
      var notifyCounter = 0;
      source.addListener(() {
        notifyCounter++;
      });
      final messages = <MimeMessage>[];
      for (int i = 0; i < 20; i++) {
        final message = await firstMimeSource.getMessage(i);
        messages.add(message);
      }
      await firstMimeSource.resyncMessagesManually(messages);
      expect(source.size, 120);
      expect(notifyCounter, 0);
    });

    test('same re-created messages after resync', () async {
      var notifyCounter = 0;
      source.addListener(() {
        notifyCounter++;
      });
      await source.getMessageAt(0);
      final messages = <MimeMessage>[];
      for (int i = 0; i < 20; i++) {
        final message =
            (firstMimeSource as FakeMimeSource).createMessage(100 - i);
        messages.add(message);
      }
      await firstMimeSource.resyncMessagesManually(messages);
      expect(source.size, 120);
      expect(notifyCounter, 0);
    });

    test('1 new message after resync', () async {
      var notifyCounter = 0;
      source.addListener(() {
        notifyCounter++;
      });
      var message = await source.getMessageAt(0);
      expect(message.mimeMessage.sequenceId, 20);
      expect(message.mailClient, secondMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 20');
      expect(message.mimeMessage.decodeDate(),
          secondMimeSourceStartDate.toLocal());

      message = await source.getMessageAt(1);
      expect(message.mimeMessage.sequenceId, 100);
      expect(message.mailClient, firstMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'firstSubject 100');
      expect(
          message.mimeMessage.decodeDate(), firstMimeSourceStartDate.toLocal());

      final messages = <MimeMessage>[];
      for (int i = 0; i < 20; i++) {
        final message =
            (firstMimeSource as FakeMimeSource).createMessage(101 - i);
        messages.add(message);
      }
      await firstMimeSource.getMessage(0);
      await firstMimeSource.resyncMessagesManually(messages);
      expect(firstMimeSource.size, 101);
      expect(source.size, 121);
      expect(notifyCounter, 1);
      message = await source.getMessageAt(0);
      expect(message.mimeMessage.sequenceId, 101);
      expect(message.mailClient, firstMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'firstSubject 101');
      expect(
          message.mimeMessage.decodeDate(),
          firstMimeSourceStartDate
              .add(firstMimeSourceDifferencePerMessage)
              .toLocal());

      // previous first message should now be at the second position:
      message = await source.getMessageAt(1);
      expect(message.mimeMessage.sequenceId, 20);
      expect(message.mailClient, secondMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 20');
      expect(message.mimeMessage.decodeDate(),
          secondMimeSourceStartDate.toLocal());
    });

    test('1 removed message after resync', () async {
      var notifyCounter = 0;
      source.addListener(() {
        notifyCounter++;
      });
      var message = await source.getMessageAt(0);
      expect(message.mimeMessage.sequenceId, 20);
      expect(message.mailClient, secondMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 20');
      expect(message.mimeMessage.decodeDate(),
          secondMimeSourceStartDate.toLocal());

      message = await source.getMessageAt(1);
      expect(message.mimeMessage.sequenceId, 100);
      expect(message.mailClient, firstMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'firstSubject 100');
      expect(
          message.mimeMessage.decodeDate(), firstMimeSourceStartDate.toLocal());

      final messages = <MimeMessage>[];
      for (int i = 1; i < 21; i++) {
        final message =
            (firstMimeSource as FakeMimeSource).createMessage(100 - i);
        messages.add(message);
      }
      await firstMimeSource.getMessage(0);
      await firstMimeSource.resyncMessagesManually(messages);
      expect(firstMimeSource.size, 99);
      expect(source.size, 119);
      expect(notifyCounter, 1);
      message = await source.getMessageAt(0);
      expect(message.mimeMessage.sequenceId, 20);
      expect(message.mailClient, secondMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 20');
      expect(message.mimeMessage.decodeDate(),
          secondMimeSourceStartDate.toLocal());

      // previous first message should now be at the second position:
      message = await source.getMessageAt(1);
      expect(message.mimeMessage.sequenceId, 19);
      expect(message.mimeMessage.guid, 19);
      expect(message.mailClient, secondMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 19');
      expect(
          message.mimeMessage.decodeDate(),
          secondMimeSourceStartDate
              .subtract(secondMimeSourceDifferencePerMessage)
              .toLocal());

      await _expectMessagesOrderedByDate();
    });

    test('1 message added flag after resync', () async {
      var sourceNotifyCounter = 0;
      source.addListener(() {
        sourceNotifyCounter++;
      });

      final messages = <MimeMessage>[];
      for (int i = 0; i < 20; i++) {
        final message = await firstMimeSource.getMessage(i);
        messages.add(message);
      }
      final copy = (firstMimeSource as FakeMimeSource)
          .createMessage(messages[1].sequenceId!);
      copy.isSeen = true;
      messages[1] = copy;

      var message = await source.getMessageAt(2);
      expect(message.mimeMessage.sequenceId, copy.sequenceId);
      expect(message.isSeen, isFalse);
      var messageNotifyCounter = 0;
      message.addListener(() {
        messageNotifyCounter++;
      });

      await firstMimeSource.resyncMessagesManually(messages);
      expect(source.size, 120);
      expect(sourceNotifyCounter, 0);
      expect(messageNotifyCounter, 1);

      message = await source.getMessageAt(2);
      expect(message.mimeMessage.sequenceId, copy.sequenceId);
      expect(message.isSeen, isTrue);

      await _expectMessagesOrderedByDate();
    });

    test('1 message removed flag after resync', () async {
      var sourceNotifyCounter = 0;
      source.addListener(() {
        sourceNotifyCounter++;
      });

      final messages = <MimeMessage>[];
      for (int i = 0; i < 20; i++) {
        final message = await firstMimeSource.getMessage(i);
        messages.add(message);
      }
      messages[1].isSeen = true;
      final copy = (firstMimeSource as FakeMimeSource)
          .createMessage(messages[1].sequenceId!);
      messages[1] = copy;

      var message = await source.getMessageAt(2);
      expect(message.mimeMessage.sequenceId, copy.sequenceId);
      expect(message.isSeen, isTrue);
      var messageNotifyCounter = 0;
      message.addListener(() {
        messageNotifyCounter++;
      });

      await firstMimeSource.resyncMessagesManually(messages);
      expect(source.size, 120);
      expect(sourceNotifyCounter, 0);
      expect(messageNotifyCounter, 1);

      message = await source.getMessageAt(2);
      expect(message.mimeMessage.sequenceId, copy.sequenceId);
      expect(message.isSeen, isFalse);

      await _expectMessagesOrderedByDate();
    });

    test('1 message added, 1 removed, 1 changed flags after resync', () async {
      var notifyCounter = 0;
      source.addListener(() {
        notifyCounter++;
      });
      var message = await source.getMessageAt(0);
      expect(message.mimeMessage.sequenceId, 20);
      expect(message.mailClient, secondMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 20');
      expect(message.mimeMessage.decodeDate(),
          secondMimeSourceStartDate.toLocal());

      message = await source.getMessageAt(1);
      expect(message.mimeMessage.sequenceId, 100);
      expect(message.mailClient, firstMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'firstSubject 100');
      expect(
          message.mimeMessage.decodeDate(), firstMimeSourceStartDate.toLocal());

      message = await source.getMessageAt(2);
      expect(message.mimeMessage.decodeSubject(), 'firstSubject 99');

      final messages = <MimeMessage>[];
      for (int i = 0; i < 21; i++) {
        final message =
            (firstMimeSource as FakeMimeSource).createMessage(101 - i);
        messages.add(message);
      }

      // remove 'firstSubject 100':
      messages.removeAt(1);

      // set 'firstSubject 99' to seen:
      messages[1].isSeen = true;

      await firstMimeSource.getMessage(0);
      await firstMimeSource.resyncMessagesManually(messages);
      expect(source.size, 120);
      expect(notifyCounter, 2);
      message = await source.getMessageAt(0);
      expect(message.mimeMessage.guid, 101,
          reason: 'first message should be the 101');
      expect(message.mailClient, firstMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'firstSubject 101');
      expect(message.isSeen, isFalse);
      expect(
          message.mimeMessage.decodeDate(),
          firstMimeSourceStartDate
              .add(firstMimeSourceDifferencePerMessage)
              .toLocal());

      // previous first message should now be at the second position:
      message = await source.getMessageAt(1);
      expect(message.mimeMessage.sequenceId, 20);
      expect(message.mailClient, secondMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 20');
      expect(message.mimeMessage.decodeDate(),
          secondMimeSourceStartDate.toLocal());
      expect(message.isSeen, isFalse);

      message = await source.getMessageAt(2);
      expect(message.mimeMessage.decodeSubject(), 'firstSubject 99');
      expect(message.isSeen, isTrue);
      expect(
          message.mimeMessage.decodeDate(),
          firstMimeSourceStartDate
              .subtract(firstMimeSourceDifferencePerMessage)
              .toLocal());

      message = await source.getMessageAt(3);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 19');
      expect(message.isSeen, isFalse);

      await _expectMessagesOrderedByDate();
    });

    test('1 message added ordered by date on each source after resync',
        () async {
      var notifyCounter = 0;
      source.addListener(() {
        notifyCounter++;
      });
      var message = await source.getMessageAt(0);
      expect(message.mimeMessage.sequenceId, 20);
      expect(message.mailClient, secondMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 20');
      expect(message.mimeMessage.decodeDate(),
          secondMimeSourceStartDate.toLocal());

      message = await source.getMessageAt(1);
      expect(message.mimeMessage.sequenceId, 100);
      expect(message.mailClient, firstMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'firstSubject 100');
      expect(
          message.mimeMessage.decodeDate(), firstMimeSourceStartDate.toLocal());

      var messages = <MimeMessage>[];
      for (int i = 0; i < 20; i++) {
        final message =
            (firstMimeSource as FakeMimeSource).createMessage(101 - i);
        messages.add(message);
      }
      await firstMimeSource.resyncMessagesManually(messages);

      messages = <MimeMessage>[];
      for (int i = 0; i < 20; i++) {
        final message =
            (secondMimeSource as FakeMimeSource).createMessage(21 - i);
        messages.add(message);
      }
      await secondMimeSource.resyncMessagesManually(messages);

      expect(source.size, 122);
      expect(notifyCounter, 2);
      message = await source.getMessageAt(0);
      expect(message.mimeMessage.sequenceId, 21);
      expect(message.mailClient, secondMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 21');
      expect(
          message.mimeMessage.decodeDate(),
          secondMimeSourceStartDate
              .add(secondMimeSourceDifferencePerMessage)
              .toLocal());
      expect(message.isSeen, isFalse);

      // previous first message should now be at the second position:
      message = await source.getMessageAt(1);
      expect(message.mimeMessage.sequenceId, 101);
      expect(message.mailClient, firstMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'firstSubject 101');
      expect(
          message.mimeMessage.decodeDate(),
          firstMimeSourceStartDate
              .add(firstMimeSourceDifferencePerMessage)
              .toLocal());

      message = await source.getMessageAt(2);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 20');
      expect(message.mimeMessage.decodeDate(),
          secondMimeSourceStartDate.toLocal());
      await _expectMessagesOrderedByDate();
    });

    test('1 message added unordered by date on each source after resync',
        () async {
      var notifyCounter = 0;
      source.addListener(() {
        notifyCounter++;
      });
      var message = await source.getMessageAt(0);
      expect(message.mimeMessage.sequenceId, 20);
      expect(message.mailClient, secondMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 20');
      expect(message.mimeMessage.decodeDate(),
          secondMimeSourceStartDate.toLocal());

      message = await source.getMessageAt(1);
      expect(message.mimeMessage.sequenceId, 100);
      expect(message.mailClient, firstMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'firstSubject 100');
      expect(
          message.mimeMessage.decodeDate(), firstMimeSourceStartDate.toLocal());

      var messages = <MimeMessage>[];
      for (int i = 0; i < 20; i++) {
        final message =
            (secondMimeSource as FakeMimeSource).createMessage(21 - i);
        messages.add(message);
      }
      await secondMimeSource.resyncMessagesManually(messages);

      messages = <MimeMessage>[];
      for (int i = 0; i < 20; i++) {
        final message =
            (firstMimeSource as FakeMimeSource).createMessage(101 - i);
        messages.add(message);
      }
      await firstMimeSource.resyncMessagesManually(messages);

      expect(source.size, 122);
      expect(notifyCounter, 2);
      message = await source.getMessageAt(0);
      expect(message.mimeMessage.sequenceId, 21);
      expect(message.mailClient, secondMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 21');
      expect(
          message.mimeMessage.decodeDate(),
          secondMimeSourceStartDate
              .add(secondMimeSourceDifferencePerMessage)
              .toLocal());
      expect(message.isSeen, isFalse);

      // previous first message should now be at the second position:
      message = await source.getMessageAt(1);
      expect(message.mimeMessage.sequenceId, 101);
      expect(message.mailClient, firstMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'firstSubject 101');
      expect(
          message.mimeMessage.decodeDate(),
          firstMimeSourceStartDate
              .add(firstMimeSourceDifferencePerMessage)
              .toLocal());

      message = await source.getMessageAt(2);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 20');
      expect(message.mimeMessage.decodeDate(),
          secondMimeSourceStartDate.toLocal());
      await _expectMessagesOrderedByDate();
    });

    test(
        'out of cache: 1 message added, 2 removed, 2 changed flags after resync',
        () async {
      firstMimeSource = FakeMimeSource(
        size: 100,
        name: 'first',
        startDate: firstMimeSourceStartDate,
        differencePerMessage: firstMimeSourceDifferencePerMessage,
        maxCacheSize: 20,
      );
      secondMimeSource = FakeMimeSource(
        size: 20,
        name: 'second',
        startDate: secondMimeSourceStartDate,
        differencePerMessage: secondMimeSourceDifferencePerMessage,
      );
      source = MultipleMessageSource(
          [firstMimeSource, secondMimeSource], 'multiple', MailboxFlag.inbox);

      var notifyCounter = 0;
      source.addListener(() {
        notifyCounter++;
      });

      // ensure caches are initialized across mime and message sources:
      var message = await source.getMessageAt(0);
      message.isSeen = true;
      expect(message.mimeMessage.sequenceId, 20);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 20');
      expect(message.mimeMessage.decodeDate(),
          secondMimeSourceStartDate.toLocal());

      message = await source.getMessageAt(1);
      expect(message.mimeMessage.sequenceId, 100);
      expect(message.mimeMessage.decodeSubject(), 'firstSubject 100');
      expect(
          message.mimeMessage.decodeDate(), firstMimeSourceStartDate.toLocal());

      // create test messages:
      final messages = <MimeMessage>[];
      for (int i = 0; i < 20; i++) {
        await firstMimeSource.getMessage(i);
        final message =
            (firstMimeSource as FakeMimeSource).createMessage(100 - i);
        messages.add(message);
      }
      // as this is out of cache, simulate changes by also these changes
      // to the underlying structure:
      messages[2].isAnswered = true;
      messages.removeAt(3);
      messages.removeAt(7);
      messages.insert(
          0, (firstMimeSource as FakeMimeSource).createMessage(101));
      final serverMessages = FakeMimeSource.generateMessages(size: 99);
      for (int i = 0; i < messages.length; i++) {
        final message = messages[i];
        message.sequenceId = 99 - i;
        serverMessages[98 - i] = message;
      }
      // resync: ensure to remove first message from cache:
      await firstMimeSource.getMessage(21);
      await firstMimeSource.resyncMessagesManually(messages);
      (firstMimeSource as FakeMimeSource).messages = serverMessages;

      expect(source.size, 119);
      expect(notifyCounter, 1);
      message = await source.getMessageAt(0);
      expect(message.mimeMessage.sequenceId, 99);
      expect(message.mimeMessage.guid, 101);
      expect(message.mimeMessage.decodeSubject(), 'firstSubject 101');
      expect(message.isSeen, isFalse);
      expect(
          message.mimeMessage.decodeDate(),
          firstMimeSourceStartDate
              .add(firstMimeSourceDifferencePerMessage)
              .toLocal());

      // previous first message should now be at the second position:
      message = await source.getMessageAt(1);
      expect(message.mimeMessage.sequenceId, 20);
      expect(message.mailClient, secondMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 20');
      expect(message.mimeMessage.decodeDate(),
          secondMimeSourceStartDate.toLocal());
      expect(message.isSeen, isTrue);

      message = await source.getMessageAt(2);
      expect(message.mimeMessage.decodeSubject(), 'firstSubject 100');
      expect(message.isSeen, isFalse);
      expect(
          message.mimeMessage.decodeDate(), firstMimeSourceStartDate.toLocal());
      await _expectMessagesOrderedByDate();
    });
  });

  group('delete', () {
    test('delete 1 message', () async {
      notificationService.reset();
      var sourceNotifyCounter = 0;
      source.addListener(() {
        sourceNotifyCounter++;
      });

      var message = await source.getMessageAt(0);
      expect(message.mimeMessage.sequenceId, 20);
      expect(message.mailClient, secondMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 20');
      expect(message.mimeMessage.decodeDate(),
          secondMimeSourceStartDate.toLocal());

      message = await source.getMessageAt(1);
      expect(message.mimeMessage.sequenceId, 100);
      expect(message.mailClient, firstMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'firstSubject 100');
      expect(
          message.mimeMessage.decodeDate(), firstMimeSourceStartDate.toLocal());

      message = await source.getMessageAt(2);
      expect(message.mimeMessage.sequenceId, 99);
      expect(message.mailClient, firstMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'firstSubject 99');
      expect(
          message.mimeMessage.decodeDate(),
          firstMimeSourceStartDate
              .subtract(firstMimeSourceDifferencePerMessage)
              .toLocal());

      message = await source.getMessageAt(3);
      expect(message.mimeMessage.sequenceId, 19);
      expect(message.mailClient, secondMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 19');
      expect(
          message.mimeMessage.decodeDate(),
          secondMimeSourceStartDate
              .subtract(secondMimeSourceDifferencePerMessage)
              .toLocal());

      final messages = [await source.getMessageAt(2)];
      expect(source.size, 120);
      await source.deleteMessages(messages, 'deleted messages');
      expect(source.size, 119);
      expect(sourceNotifyCounter, 1);
      expect(notificationService.sendNotifications, 0);
      expect(notificationService.cancelledNotifications, 1);

      message = await source.getMessageAt(0);
      expect(message.mimeMessage.sequenceId, 20);
      expect(message.mailClient, secondMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 20');
      expect(message.mimeMessage.decodeDate(),
          secondMimeSourceStartDate.toLocal());

      message = await source.getMessageAt(1);
      expect(message.mimeMessage.sequenceId, 99);
      expect(message.mimeMessage.guid, 100);
      expect(message.mailClient, firstMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'firstSubject 100');
      expect(
          message.mimeMessage.decodeDate(), firstMimeSourceStartDate.toLocal());

      message = await source.getMessageAt(2);
      expect(message.mimeMessage.sequenceId, 19);
      expect(message.mailClient, secondMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 19');
      expect(
          message.mimeMessage.decodeDate(),
          secondMimeSourceStartDate
              .subtract(secondMimeSourceDifferencePerMessage)
              .toLocal());
      await _expectMessagesOrderedByDate();
    });

    test('delete 1 message and clear cache', () async {
      notificationService.reset();
      var sourceNotifyCounter = 0;
      source.addListener(() {
        sourceNotifyCounter++;
      });

      var message = await source.getMessageAt(0);
      expect(message.mimeMessage.sequenceId, 20);
      expect(message.mailClient, secondMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 20');
      expect(message.mimeMessage.decodeDate(),
          secondMimeSourceStartDate.toLocal());

      message = await source.getMessageAt(1);
      expect(message.mimeMessage.sequenceId, 100);
      expect(message.mailClient, firstMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'firstSubject 100');
      expect(
          message.mimeMessage.decodeDate(), firstMimeSourceStartDate.toLocal());

      message = await source.getMessageAt(2);
      expect(message.mimeMessage.sequenceId, 99);
      expect(message.mailClient, firstMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'firstSubject 99');
      expect(
          message.mimeMessage.decodeDate(),
          firstMimeSourceStartDate
              .subtract(firstMimeSourceDifferencePerMessage)
              .toLocal());

      message = await source.getMessageAt(3);
      expect(message.mimeMessage.sequenceId, 19);
      expect(message.mailClient, secondMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 19');
      expect(
          message.mimeMessage.decodeDate(),
          secondMimeSourceStartDate
              .subtract(secondMimeSourceDifferencePerMessage)
              .toLocal());

      final messages = [await source.getMessageAt(2)];
      expect(source.size, 120);
      await source.deleteMessages(messages, 'deleted messages');
      source.cache.clear();
      expect(source.size, 119);
      expect(sourceNotifyCounter, 1);
      expect(notificationService.sendNotifications, 0);
      expect(notificationService.cancelledNotifications, 1);

      message = await source.getMessageAt(0);
      expect(message.mimeMessage.sequenceId, 20);
      expect(message.mailClient, secondMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 20');
      expect(message.mimeMessage.decodeDate(),
          secondMimeSourceStartDate.toLocal());

      message = await source.getMessageAt(1);
      expect(message.mimeMessage.sequenceId, 99);
      expect(message.mimeMessage.guid, 100);
      expect(message.mailClient, firstMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'firstSubject 100');
      expect(
          message.mimeMessage.decodeDate(), firstMimeSourceStartDate.toLocal());

      message = await source.getMessageAt(2);
      expect(message.mimeMessage.sequenceId, 19);
      expect(message.mailClient, secondMimeSource.mailClient);
      expect(message.mimeMessage.decodeSubject(), 'secondSubject 19');
      expect(
          message.mimeMessage.decodeDate(),
          secondMimeSourceStartDate
              .subtract(secondMimeSourceDifferencePerMessage)
              .toLocal());
      await _expectMessagesOrderedByDate();
    });
  });
}

class TestScaffoldMessengerService implements ScaffoldMessengerService {
  @override
  void popStatusBarState() {
    // TODO: implement popStatusBarState
  }

  @override
  // TODO: implement scaffoldMessengerKey
  GlobalKey<ScaffoldMessengerState> get scaffoldMessengerKey =>
      throw UnimplementedError();

  @override
  void showTextSnackBar(String text, {Function()? undo}) {
    // TODO: implement showTextSnackBar
  }

  @override
  set statusBarState(CupertinoStatusBarState state) {
    // TODO: implement statusBarState
  }
}

class TestNotificationService implements NotificationService {
  int _cancelledNotifications = 0;
  int get cancelledNotifications => _cancelledNotifications;
  int _sendNotifications = 0;
  int get sendNotifications => _sendNotifications;

  void reset() {
    _sendNotifications = 0;
    _cancelledNotifications = 0;
  }

  @override
  void cancelNotification(int id) {
    _cancelledNotifications++;
  }

  @override
  void cancelNotificationForMail(MimeMessage mimeMessage) {
    _cancelledNotifications++;
  }

  @override
  void cancelNotificationForMailMessage(Message message) {
    _cancelledNotifications++;
  }

  @override
  Future<List<MailNotificationPayload>> getActiveMailNotifications() {
    // TODO: implement getActiveMailNotifications
    throw UnimplementedError();
  }

  @override
  Future<NotificationServiceInitResult> init(
      {bool checkForLaunchDetails = true}) {
    // TODO: implement init
    throw UnimplementedError();
  }

  @override
  Future sendLocalNotification(int id, String title, String? text,
      {String? payloadText, DateTime? when, bool channelShowBadge = true}) {
    _sendNotifications++;
    return Future.value();
  }

  @override
  Future sendLocalNotificationForMail(
      MimeMessage mimeMessage, MailClient mailClient) {
    _sendNotifications++;
    return Future.value();
  }

  @override
  Future sendLocalNotificationForMailLoadEvent(MailLoadEvent event) =>
      sendLocalNotificationForMail(event.message, event.mailClient);

  @override
  Future sendLocalNotificationForMailMessage(Message message) {
    _sendNotifications++;
    return Future.value();
  }
}
