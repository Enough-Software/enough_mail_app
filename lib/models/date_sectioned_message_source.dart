import 'package:enough_mail_app/locator.dart';
import 'package:enough_mail_app/models/message_source.dart';
import 'package:enough_mail_app/services/date_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'message.dart';
import 'message_date_section.dart';

class DateSectionedMessageSource extends ChangeNotifier {
  final MessageSource messageSource;
  int _numberOfSections = 0;
  int get size {
    final sourceSize = messageSource.size;
    if (sourceSize == 0) {
      return 0;
    }
    return sourceSize + _numberOfSections;
  }

  List<MessageDateSection> _sections;
  bool isInitialized = false;

  DateSectionedMessageSource(this.messageSource) {
    messageSource.addListener(_update);
  }

  Future<bool> init() async {
    bool success = await this.messageSource.init();
    if (success) {
      _sections = await getDateSections();
      _numberOfSections = _sections.length;
      isInitialized = true;
      notifyListeners();
    }
    return success;
  }

  @override
  void dispose() {
    messageSource.removeListener(_update);
    messageSource.dispose();
    super.dispose();
  }

  Future<List<MessageDateSection>> getDateSections(
      {int numberOfMessagesToBeConsidered = 40}) async {
    final sections = <MessageDateSection>[];
    DateSectionRange lastRange;
    int foundSections = 0;
    final max = messageSource.size;
    if (numberOfMessagesToBeConsidered > max) {
      numberOfMessagesToBeConsidered = max;
    }
    for (var i = 0; i < numberOfMessagesToBeConsidered; i++) {
      final message = await messageSource.waitForMessageAt(i);
      final dateTime = message.mimeMessage.decodeDate()?.toLocal();
      if (dateTime != null) {
        final range = locator<DateService>().determineDateSection(dateTime);
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

  SectionElement getElementAt(int index) {
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
    final message = messageSource.getMessageAt(messageIndex);
    return SectionElement(null, message);
  }

  void _update() {
    notifyListeners();
  }

  Future<void> deleteMessage(BuildContext context, Message message) {
    return messageSource.deleteMessage(context, message);
  }
}

class SectionElement {
  final MessageDateSection section;
  final Message message;

  SectionElement(this.section, this.message);
}
