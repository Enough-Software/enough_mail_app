import 'dart:math';

import 'package:flutter/foundation.dart';

import '../localization/app_localizations.g.dart';
import '../util/date_helper.dart';
import 'message.dart';
import 'message_date_section.dart';
import 'message_source.dart';

class DateSectionedMessageSource extends ChangeNotifier {
  DateSectionedMessageSource(
    this.messageSource, {
    required this.firstDayOfWeek,
  }) {
    messageSource.addListener(_update);
  }
  final int firstDayOfWeek;
  final MessageSource messageSource;
  int _numberOfSections = 0;
  int get size {
    final sourceSize = messageSource.size;
    if (sourceSize == 0) {
      return 0;
    }

    return sourceSize + _numberOfSections;
  }

  late List<MessageDateSection> _sections;
  bool isInitialized = false;
  var _isDisposed = false;

  Future<void> init() async {
    try {
      await messageSource.init();
      _sections = await downloadDateSections();
      _numberOfSections = _sections.length;
      isInitialized = true;
      if (!_isDisposed) {
        notifyListeners();
      }
    } catch (e, s) {
      if (kDebugMode) {
        print('unexpected error $e at $s');
      }
    }
  }

  Future<void> refresh() async {
    try {
      _numberOfSections = 0;
      await messageSource.refresh();
      _sections = await downloadDateSections();
      _numberOfSections = _sections.length;
      isInitialized = true;
      if (!_isDisposed) {
        notifyListeners();
      }
    } catch (e, s) {
      if (kDebugMode) {
        print('unexpected error $e at $s');
      }
    }
  }

  @override
  void dispose() {
    messageSource.removeListener(_update);
    _isDisposed = true;
    super.dispose();
  }

  Future<List<MessageDateSection>> downloadDateSections({
    int numberOfMessagesToBeConsidered = 40,
  }) async {
    final max = messageSource.size;
    final usedNumberOfMessagesToBeConsidered =
        (numberOfMessagesToBeConsidered > max)
            ? max
            : numberOfMessagesToBeConsidered;

    final messages = <Message>[];
    for (var i = 0; i < usedNumberOfMessagesToBeConsidered; i++) {
      final message = await messageSource.getMessageAt(i);
      messages.add(message);
    }

    return getDateSections(messages);
  }

  List<MessageDateSection> getDateSections(
    List<Message> messages,
  ) {
    final sections = <MessageDateSection>[];
    DateSectionRange? lastRange;
    int foundSections = 0;
    for (var i = 0; i < messages.length; i++) {
      final message = messages[i];
      final dateTime = message.mimeMessage.decodeDate();
      if (dateTime != null) {
        final range = DateHelper(firstDayOfWeek).determineDateSection(dateTime);
        if (range != lastRange) {
          final index = (lastRange == null) ? 0 : i + foundSections;
          sections.add(MessageDateSection(range, dateTime, index));
          foundSections++;
        }
        lastRange = range;
      }
    }

    return sections;
  }

  SectionElement? getCachedElementAt(int index) {
    var messageIndex = index;
    if (_numberOfSections >= 0) {
      for (var i = 0; i < _numberOfSections; i++) {
        final section = _sections[i];
        if (section.sourceStartIndex == index) {
          return SectionElement(section, null);
        }
        if (section.sourceStartIndex > index) {
          break;
        }
        messageIndex--;
      }
    }
    final message = messageSource.cache[messageIndex];
    if (message != null) {
      return SectionElement(null, message);
    }

    return null;
  }

  Future<SectionElement> getElementAt(int index) async {
    var messageIndex = index;
    if (_numberOfSections >= 0) {
      for (var i = 0; i < _numberOfSections; i++) {
        final section = _sections[i];
        if (section.sourceStartIndex == index) {
          return SectionElement(section, null);
        }
        if (section.sourceStartIndex > index) {
          break;
        }
        messageIndex--;
      }
    }
    final message = await messageSource.getMessageAt(messageIndex);

    return SectionElement(null, message);
  }

  Future<List<Message>> getMessagesForSection(
    MessageDateSection section,
  ) async {
    final index = _sections.indexOf(section);
    if (index == -1) {
      return [];
    }
    final startIndex = section.sourceStartIndex - index;
    final endIndex = (index < _sections.length - 1)
        ? _sections[index + 1].sourceStartIndex - index - 1
        : min(startIndex + 5, messageSource.size);
    final futures = <Future<Message>>[];
    for (var i = startIndex; i < endIndex; i++) {
      futures.add(messageSource.getMessageAt(i));
    }
    final messages = await Future.wait(futures);

    return messages;
  }

  List<Message> _getTopMessages(int length) {
    final max = messageSource.size;
    final usedLength = (length > max) ? max : length;
    final messages = <Message>[];
    for (int i = 0; i < usedLength; i++) {
      final message = messageSource.cache[i];
      if (message != null) {
        messages.add(message);
      }
    }

    return messages;
  }

  void _update() {
    _sections = getDateSections(_getTopMessages(40));
    _numberOfSections = _sections.length;
    notifyListeners();
  }

  Future<void> deleteMessage(AppLocalizations localizations, Message message) =>
      messageSource.deleteMessages(
        localizations,
        [message],
        localizations.resultDeleted,
      );
}

class SectionElement {
  SectionElement(this.section, this.message);
  final MessageDateSection? section;
  final Message? message;
}
