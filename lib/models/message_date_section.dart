import 'package:enough_mail_app/services/date_service.dart';

class MessageDateSection {
  final DateSectionRange range;
  final DateTime date;
  final int sourceStartIndex;

  MessageDateSection(this.range, this.date, this.sourceStartIndex);
}
