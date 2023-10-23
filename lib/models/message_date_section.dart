import '../util/date_helper.dart';

class MessageDateSection {
  MessageDateSection(this.range, this.date, this.sourceStartIndex);
  final DateSectionRange range;
  final DateTime date;
  final int sourceStartIndex;
}
