import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/async_mime_source.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_mime_source.dart';

void main() async {
  test('load first message size 100', () async {
    final AsyncMimeSource source = FakeMimeSource(size: 100);
    expect(source.size, 100);
    final message = await source.getMessage(0);
    expect(message.sequenceId, 100);
    expect(message.decodeSubject(), 'Subject 100');
  });

  test('load first message size 101', () async {
    final AsyncMimeSource source = FakeMimeSource(size: 101);
    expect(source.size, 101);
    final message = await source.getMessage(0);
    expect(message.sequenceId, 101);
    expect(message.decodeSubject(), 'Subject 101');
  });

  test('load first message from cache size 101', () async {
    final source = FakeMimeSource(size: 101);
    expect(source.size, 101);
    await source.getMessage(0);
    final message = source.cache[0];
    expect(message, isNotNull);
    expect(message!.sequenceId, 101);
    expect(message.decodeSubject(), 'Subject 101');
  });

  test('load second message size 101', () async {
    final AsyncMimeSource source = FakeMimeSource(size: 101);
    expect(source.size, 101);
    final message = await source.getMessage(1);
    expect(message.sequenceId, 100);
    expect(message.decodeSubject(), 'Subject 100');
  });

  test('load several messages at once', () async {
    final CachedMimeSource source = FakeMimeSource(size: 101);
    expect(source.size, 101);
    final futures = <Future<MimeMessage>>[];
    for (int i = 0; i < 101; i += 15) {
      final future = source.getMessage(i);
      futures.add(future);
    }
    await Future.wait(futures);
    final cache = source.cache;
    for (int i = 0; i < 101; i += 15) {
      final message = cache[i];
      expect(message, isNotNull);
      expect(message!.sequenceId, 101 - i);
    }
  });

  test('load messages with small cache', () async {
    final CachedMimeSource source = FakeMimeSource(size: 100, maxCacheSize: 10);
    expect(source.size, 100);
    for (int i = 0; i < 100; i += 7) {
      final message = await source.getMessage(i);
      expect(message.sequenceId, 100 - i);
    }
  });

  test('load messages with small cache at cache border', () async {
    final CachedMimeSource source = FakeMimeSource(size: 100, maxCacheSize: 10);
    expect(source.size, 100);
    for (int i = 1; i < 99; i += 10) {
      var message = await source.getMessage(i - 1);
      expect(message.sequenceId, 100 - (i - 1));
      message = await source.getMessage(i);
      expect(message.sequenceId, 100 - i);
      message = await source.getMessage(i + 1);
      expect(message.sequenceId, 100 - (i + 1));
    }
  });

  test('load several messages at once with small cache', () async {
    final CachedMimeSource source = FakeMimeSource(size: 101, maxCacheSize: 10);
    expect(source.size, 101);
    final futures = <Future<MimeMessage>>[];
    final expectedSequenceIds = <int>[];
    for (int i = 0; i < 101; i += 7) {
      final future = source.getMessage(i);
      futures.add(future);
      expectedSequenceIds.add(101 - i);
    }
    final messages = await Future.wait(futures);
    for (int i = 0; i < messages.length; i++) {
      expect(messages[i].sequenceId, expectedSequenceIds[i],
          reason: 'failed for index $i');
    }
  });

  test('onMessageArrived', () async {
    final source = FakeMimeSource(size: 101);
    expect(source.size, 101);
    await source.addFakeMessage(102);
    expect(source.size, 102);
    for (int i = 0; i < 102; i += 13) {
      final message = await source.getMessage(i);
      expect(message, isNotNull);
      expect(message.sequenceId, 102 - i);
    }
  });

  test('2 x onMessageArrived', () async {
    final source = FakeMimeSource(size: 101);
    expect(source.size, 101);
    await source.addFakeMessage(102);
    await source.addFakeMessage(103);
    expect(source.size, 103);
    for (int i = 0; i < 103; i += 13) {
      final message = await source.getMessage(i);
      expect(message, isNotNull);
      expect(message.sequenceId, 103 - i);
    }
  });

  test('onMessageArrived with old message', () async {
    final source = FakeMimeSource(size: 100);
    expect(source.size, 100);
    final firstMessage = await source.getMessage(0);
    final newMessage = source.createMessage(101);
    final oldDate =
        firstMessage.decodeDate()!.subtract(const Duration(seconds: 30));
    newMessage.setHeader(
        MailConventions.headerDate, DateCodec.encodeDate(oldDate));
    await source.onMessageArrived(newMessage);
    expect(source.size, 101);
    var message = await source.getMessage(0);
    expect(message.sequenceId, 100,
        reason: 'first message should stay the same');
    message = await source.getMessage(1);
    expect(message.sequenceId, 101,
        reason: 'second message should be the new message');
  });

  Future<void> _expectMessagesOrderedByDate(AsyncMimeSource source,
      {int? numberToTest}) async {
    var lastDate = DateTime.now();
    var lastSubject = '<no message>';
    final length = numberToTest ?? source.size;
    for (int i = 0; i < length; i++) {
      final message = await source.getMessage(i);
      final messageDate = message.decodeDate();
      final subject = message.decodeSubject() ?? '<no subject for $i>';
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

  test('init with old message in first result', () async {
    final source = FakeMimeSource(size: 100);
    expect(source.size, 100);
    final firstMessage = source.messages[0];
    final oldDate = firstMessage
        .decodeDate()!
        .subtract(const Duration(days: 120, seconds: 30));
    source.messages[97]
        .setHeader(MailConventions.headerDate, DateCodec.encodeDate(oldDate));
    // first page should be sorted:
    await _expectMessagesOrderedByDate(source, numberToTest: 20);
  });

  test('onMessagesVanished - sequence IDs', () async {
    final AsyncMimeSource source = FakeMimeSource(size: 101);
    Future<void> expectMessage(int index, int expectedGuid,
        [String? reason]) async {
      final message = await source.getMessage(index);
      expect(message.guid, expectedGuid, reason: reason);
    }

    expect(source.size, 101);
    // cache all messages:
    for (int i = 0; i < 101; i += 3) {
      final message = await source.getMessage(i);
      expect(message, isNotNull);
      expect(message.sequenceId, 101 - i);
    }
    await source.onMessagesVanished(MessageSequence.fromIds([101, 99, 98]));
    expect(source.size, 98, reason: '3 messages should be removed');
    await expectMessage(0, 100, 'first message expected to be 100');
    await expectMessage(1, 97, 'second message should be 97');

    for (int i = 2; i < 98; i += 7) {
      final message = await source.getMessage(i);
      expect(message, isNotNull);
      expect(message.sequenceId, 98 - i);
    }
  });

  test('onMessagesVanished - latest message', () async {
    final AsyncMimeSource source = FakeMimeSource(size: 101);
    Future<void> expectMessage(int index, int expectedSequenceId) async {
      final message = await source.getMessage(index);
      expect(message.sequenceId, expectedSequenceId);
    }

    expect(source.size, 101);
    // cache all messages:
    for (int i = 0; i < 101; i += 3) {
      final message = await source.getMessage(i);
      expect(message, isNotNull);
      expect(message.sequenceId, 101 - i);
    }
    await source.onMessagesVanished(MessageSequence.fromIds([101]));
    expect(source.size, 100);
    await expectMessage(0, 100);
    await expectMessage(1, 99);

    for (int i = 2; i < 100; i += 7) {
      final message = await source.getMessage(i);
      expect(message, isNotNull);
      expect(message.sequenceId, 100 - i);
    }
  });

  test('onMessagesVanished - same valid sequence ID twice', () async {
    final AsyncMimeSource source = FakeMimeSource(size: 101);
    Future<void> expectMessage(int index, int expectedSequenceId,
        [String? reason]) async {
      final message = await source.getMessage(index);
      expect(message.sequenceId, expectedSequenceId, reason: reason);
    }

    expect(source.size, 101);
    // cache all messages:
    for (int i = 0; i < 101; i += 3) {
      final message = await source.getMessage(i);
      expect(message, isNotNull);
      expect(message.sequenceId, 101 - i);
    }
    await source.onMessagesVanished(MessageSequence.fromIds([100]));
    expect(source.size, 100);
    await expectMessage(
        0, 100, 'first message\'s sequence ID should be adapted');
    await expectMessage(1, 99);

    await source.onMessagesVanished(MessageSequence.fromIds([100]));
    expect(source.size, 99);
    await expectMessage(0, 99);
    await expectMessage(1, 98);

    for (int i = 2; i < 99; i += 7) {
      final message = await source.getMessage(i);
      expect(message, isNotNull);
      expect(message.sequenceId, 99 - i);
    }
  });

  test('onMessagesVanished - sequence IDs reverse', () async {
    final AsyncMimeSource source = FakeMimeSource(size: 101);
    Future<void> expectMessage(int index, int expectedGuid,
        [String? reason]) async {
      final message = await source.getMessage(index);
      expect(message.guid, expectedGuid, reason: reason);
    }

    expect(source.size, 101);
    // cache all messages:
    for (int i = 0; i < 101; i += 3) {
      final message = await source.getMessage(i);
      expect(message, isNotNull);
      expect(message.sequenceId, 101 - i);
    }
    await source.onMessagesVanished(MessageSequence.fromIds([98, 99, 101]));
    expect(source.size, 98);
    await expectMessage(0, 100, 'first message should be 100');
    await expectMessage(1, 97, 'second message should be 97');

    for (int i = 2; i < 98; i += 7) {
      final message = await source.getMessage(i);
      expect(message, isNotNull);
      expect(message.sequenceId, 98 - i);
    }
  });

  test('onMessagesVanished - UIDs', () async {
    final AsyncMimeSource source = FakeMimeSource(size: 101);
    Future<void> expectMessage(int index, int expectedGuid,
        [String? reason]) async {
      final message = await source.getMessage(index);
      expect(message.guid, expectedGuid, reason: reason);
    }

    expect(source.size, 101);
    // cache all messages:
    for (int i = 0; i < 101; i += 3) {
      final message = await source.getMessage(i);
      expect(message, isNotNull);
      expect(message.sequenceId, 101 - i);
    }
    await source.onMessagesVanished(
        MessageSequence.fromIds([101, 99, 98], isUid: true));
    expect(source.size, 98);
    await expectMessage(0, 100, 'first should be 100');
    await expectMessage(1, 97, 'second should be 97');

    for (int i = 2; i < 98; i += 7) {
      final message = await source.getMessage(i);
      expect(message, isNotNull);
      expect(message.sequenceId, 98 - i);
    }
  });

  test('onMessagesVanished - UIDs reversed', () async {
    final AsyncMimeSource source = FakeMimeSource(size: 101);
    Future<void> expectMessage(int index, int expectedGuid,
        [String? reason]) async {
      final message = await source.getMessage(index);
      expect(message.guid, expectedGuid, reason: reason);
    }

    expect(source.size, 101);
    // cache all messages:
    for (int i = 0; i < 101; i += 3) {
      final message = await source.getMessage(i);
      expect(message, isNotNull);
      expect(message.sequenceId, 101 - i);
    }
    await source.onMessagesVanished(
        MessageSequence.fromIds([98, 99, 101], isUid: true));
    expect(source.size, 98);
    await expectMessage(0, 100, 'first should be 100');
    await expectMessage(1, 97, 'second should be 97');

    for (int i = 2; i < 98; i += 7) {
      final message = await source.getMessage(i);
      expect(message, isNotNull);
      expect(message.sequenceId, 98 - i);
    }
  });

  group('resync manually', () {
    test('same messages after resync', () async {
      final AsyncMimeSource source = FakeMimeSource(size: 100);
      final messages = <MimeMessage>[];
      for (int i = 0; i < 20; i++) {
        final message = await source.getMessage(i);
        messages.add(message);
      }
      expect(source.size, 100);
      await source.resyncMessagesManually(messages);
      expect(source.size, 100);
      for (int i = 0; i < 20; i++) {
        final message = await source.getMessage(i);
        expect(message.guid, messages[i].guid,
            reason: 'invalid message ${message.guid} at $i');
      }
    });

    test('same re-created messages after resync', () async {
      final source = FakeMimeSource(size: 100);
      final messages = <MimeMessage>[];
      for (int i = 0; i < 20; i++) {
        final message = source.createMessage(100 - i);
        messages.add(message);
      }
      expect(source.size, 100);
      await source.resyncMessagesManually(messages);
      expect(source.size, 100);
      for (int i = 0; i < 20; i++) {
        final message = await source.getMessage(i);
        expect(message.guid, messages[i].guid,
            reason: 'invalid message ${message.guid} at $i');
      }
    });

    test('1 new message after resync', () async {
      final source = FakeMimeSource(size: 100);
      expect(source.size, 100);
      final messages = <MimeMessage>[];
      for (int i = 0; i < 20; i++) {
        final message = await source.getMessage(i);
        messages.add(message);
      }
      expect(source.size, 100);
      messages.insert(0, source.createMessage(101));
      await source.resyncMessagesManually(messages);
      expect(source.size, 101);
      for (int i = 0; i < 21; i++) {
        final message = await source.getMessage(i);
        expect(message.guid, messages[i].guid,
            reason: 'invalid message ${message.guid} at $i');
      }
    });

    test('1 removed message after resync', () async {
      final source = FakeMimeSource(size: 100);
      expect(source.size, 100);
      final messages = <MimeMessage>[];
      for (int i = 0; i < 20; i++) {
        final message = await source.getMessage(i);
        messages.add(message);
      }
      messages.removeAt(1);
      await source.resyncMessagesManually(messages);
      expect(source.size, 99);
      for (int i = 0; i < 19; i++) {
        final message = await source.getMessage(i);
        expect(message.guid, messages[i].guid,
            reason: 'invalid message ${message.guid} at $i');
      }
    });

    test('1 message added flag after resync', () async {
      final source = FakeMimeSource(size: 100);
      expect(source.size, 100);
      final messages = <MimeMessage>[];
      for (int i = 0; i < 20; i++) {
        final message = await source.getMessage(i);
        messages.add(message);
      }
      final copy = source.createMessage(messages[1].sequenceId!);
      copy.isSeen = true;
      messages[1] = copy;
      await source.resyncMessagesManually(messages);
      expect(source.size, 100);
      for (int i = 0; i < messages.length; i++) {
        final message = await source.getMessage(i);
        expect(message.flags, messages[i].flags,
            reason: 'flags differ for message ${message.guid} at $i');
      }
    });

    test('1 message removed flag after resync', () async {
      final source = FakeMimeSource(size: 100);
      expect(source.size, 100);
      final messages = <MimeMessage>[];
      for (int i = 0; i < 20; i++) {
        final message = await source.getMessage(i);
        if (i == 1) {
          message.isSeen = true;
        }
        messages.add(message);
      }
      final copy = source.createMessage(messages[1].sequenceId!);
      messages[1] = copy;
      await source.resyncMessagesManually(messages);
      expect(source.size, 100);
      for (int i = 0; i < messages.length; i++) {
        final message = await source.getMessage(i);
        expect(message.flags, messages[i].flags,
            reason: 'flags differ for message ${message.guid} at $i');
      }
    });

    test('1 message added, 1 removed, 1 changed flags after resync', () async {
      final source = FakeMimeSource(size: 100);
      expect(source.size, 100);
      final messages = <MimeMessage>[];
      for (int i = 0; i < 20; i++) {
        final message = await source.getMessage(i);
        messages.add(message);
      }

      final copy = source.createMessage(messages[1].sequenceId!);
      copy.isSeen = true;
      messages[1] = copy;
      messages.removeAt(2);
      final newMessage = source.createMessage(101);
      messages.insert(0, newMessage);
      await source.resyncMessagesManually(messages);
      expect(source.size, 100);
      for (int i = 0; i < messages.length; i++) {
        final message = await source.getMessage(i);
        expect(message.guid, messages[i].guid,
            reason: 'invalid message ${message.guid} at $i');
        expect(message.flags, messages[i].flags,
            reason: 'flags differ for message ${message.guid} at $i');
      }
    });

    test('2 new message after resync', () async {
      final source = FakeMimeSource(size: 100);
      expect(source.size, 100);
      // ensure first message is loaded and cached:
      await source.getMessage(0);
      final messages = <MimeMessage>[];
      for (int i = 0; i < 20; i++) {
        final message = source.createMessage(102 - i);
        messages.add(message);
      }
      await source.resyncMessagesManually(messages);
      expect(source.size, 102);
      for (int i = 0; i < 20; i++) {
        final message = await source.getMessage(i);
        expect(message.guid, messages[i].guid,
            reason: 'invalid message ${message.guid} at $i');
      }
    });

    test('2 removed messages after resync', () async {
      final source = FakeMimeSource(size: 100);
      expect(source.size, 100);
      // ensure first message is loaded and cached:
      await source.getMessage(0);
      final messages = <MimeMessage>[];
      for (int i = 0; i < 20; i++) {
        final message = source.createMessage(100 - i);
        messages.add(message);
      }
      messages.removeAt(1);
      messages.removeAt(2);
      await source.resyncMessagesManually(messages);
      expect(source.size, 98);
      for (int i = 0; i < 18; i++) {
        final message = await source.getMessage(i);
        expect(message.guid, messages[i].guid,
            reason: 'invalid message ${message.guid} at $i');
      }
    });

    test('2 messages changed flags after resync', () async {
      final source = FakeMimeSource(size: 100);
      expect(source.size, 100);
      final seen = await source.getMessage(1);
      seen.isSeen = true;
      final messages = <MimeMessage>[];
      for (int i = 0; i < 20; i++) {
        final message = source.createMessage(100 - i);
        messages.add(message);
      }
      messages[2].isAnswered = true;
      await source.resyncMessagesManually(messages);
      expect(source.size, 100);
      for (int i = 0; i < messages.length; i++) {
        final message = await source.getMessage(i);
        expect(message.flags, messages[i].flags,
            reason: 'flags differ for message ${message.guid} at $i');
      }
    });

    test('2 message added, 2 removed, 2 changed flags after resync', () async {
      final source = FakeMimeSource(size: 100);
      expect(source.size, 100);
      final seen = await source.getMessage(1);
      seen.isSeen = true;
      final messages = <MimeMessage>[];
      for (int i = 0; i < 20; i++) {
        final message = source.createMessage(100 - i);
        messages.add(message);
      }
      messages[2].isAnswered = true;
      messages.removeAt(3);
      messages.removeAt(7);
      messages.insert(0, source.createMessage(101));
      messages.insert(0, source.createMessage(102));
      await source.resyncMessagesManually(messages);
      expect(source.size, 100);
      for (int i = 0; i < messages.length; i++) {
        final message = await source.getMessage(i);
        expect(message.guid, messages[i].guid,
            reason: 'invalid message ${message.guid} at $i');
        expect(message.flags, messages[i].flags,
            reason: 'flags differ for message ${message.guid} at $i');
      }
    });

    test('1 message added, 2 removed, 2 changed flags after resync', () async {
      final source = FakeMimeSource(size: 100);
      expect(source.size, 100);
      final seen = await source.getMessage(1);
      seen.isSeen = true;
      final messages = <MimeMessage>[];
      for (int i = 0; i < 20; i++) {
        final message = source.createMessage(100 - i);
        messages.add(message);
      }
      messages[2].isAnswered = true;
      messages.removeAt(3);
      messages.removeAt(7);
      messages.insert(0, source.createMessage(101));
      await source.resyncMessagesManually(messages);
      expect(source.size, 99);
      for (int i = 0; i < messages.length; i++) {
        final message = await source.getMessage(i);
        expect(message.guid, messages[i].guid,
            reason: 'invalid message ${message.guid} at $i');
        expect(message.flags, messages[i].flags,
            reason: 'flags differ for message ${message.guid} at $i');
      }
    });

    test(
        'out of cache: 1 message added, 2 removed, 2 changed flags after resync',
        () async {
      final source = FakeMimeSource(size: 100, maxCacheSize: 20);
      expect(source.size, 100);
      final seen = await source.getMessage(1);
      seen.isSeen = true;
      final messages = <MimeMessage>[];
      for (int i = 0; i < 20; i++) {
        await source.getMessage(i);
        final message = source.createMessage(100 - i);
        messages.add(message);
      }
      // as this is out of cache, simulate changes by also these changes
      // to the underlying structure:
      messages[2].isAnswered = true;
      messages.removeAt(3);
      messages.removeAt(7);
      messages.insert(0, source.createMessage(101));
      final serverMessages = FakeMimeSource.generateMessages(size: 99);
      for (int i = 0; i < messages.length; i++) {
        final message = messages[i];
        message.sequenceId = 99 - i;
        serverMessages[98 - i] = message;
      }
      // resync: ensure to remove first message from cache:
      await source.getMessage(21);
      await source.resyncMessagesManually(messages);
      source.messages = serverMessages;
      expect(source.size, 99);

      for (int i = 0; i < messages.length; i++) {
        final message = await source.getMessage(i);
        expect(message.guid, messages[i].guid,
            reason: 'invalid GUID ${message.guid} at $i');
        expect(message.flags, messages[i].flags,
            reason: 'flags differ for message ${message.guid} at $i');
      }
    });

    test(
        'delete 1 message, then 1 message added, 2 removed, 2 changed flags after resync',
        () async {
      final source = FakeMimeSource(size: 100);
      expect(source.size, 100);
      final seenMessage = await source.getMessage(1);
      seenMessage.isSeen = true;
      final deleteMessage = await source.getMessage(2);
      source.deleteMessages([deleteMessage]);
      expect(source.size, 99);
      final firstMessage = await source.getMessage(0);
      expect(firstMessage.sequenceId, 99);
      final messages = <MimeMessage>[];
      for (int i = 0; i < 20; i++) {
        final message = source.createMessage(100 - i);
        message.sequenceId = 99 - i;
        messages.add(message);
      }
      messages[2].isAnswered = true;
      messages.removeAt(3);
      messages.removeAt(7);
      messages.insert(0, source.createMessage(101));
      await source.resyncMessagesManually(messages);
      expect(source.size, 98);
      for (int i = 0; i < messages.length; i++) {
        final message = await source.getMessage(i);
        expect(message.guid, messages[i].guid,
            reason: 'invalid message ${message.guid} at $i');
        expect(message.flags, messages[i].flags,
            reason: 'flags differ for message ${message.guid} at $i');
      }
    });
  });
}
