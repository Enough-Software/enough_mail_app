import 'package:enough_mail_app/locator.dart';

import 'i18n_service.dart';

enum DateSectionRange {
  future,
  tomorrow,
  today,
  yesterday,
  thisWeek,
  lastWeek,
  thisMonth,
  monthOfThisYear,
  monthAndYear
}

class DateService {
  DateTime? _today;
  late DateTime _tomorrow;
  late DateTime _dayAfterTomorrow;
  DateTime? _yesterday;
  DateTime? _thisWeek;
  late DateTime _lastWeek;

  void _setupDates() {
    final nw = DateTime.now();
    _today = DateTime(nw.year, nw.month, nw.day);
    _tomorrow = _today!.add(const Duration(days: 1));
    _dayAfterTomorrow = _tomorrow.add(const Duration(days: 1));
    _yesterday = _today!.subtract(const Duration(days: 1));
    final firstDayOfWeek = locator<I18nService>().firstDayOfWeek;
    if (_today!.weekday == firstDayOfWeek) {
      _thisWeek = _today;
    } else if (_yesterday!.weekday == firstDayOfWeek) {
      _thisWeek = _yesterday;
    } else {
      if (_today!.weekday > firstDayOfWeek) {
        _thisWeek =
            _today!.subtract(Duration(days: _today!.weekday - firstDayOfWeek));
      } else {
        _thisWeek = _today!
            .subtract(Duration(days: (_today!.weekday + 7 - firstDayOfWeek)));
      }
    }
    _lastWeek = _thisWeek!.subtract(const Duration(days: 7));
  }

  DateSectionRange determineDateSection(DateTime localTime) {
    if (_today == null || _today!.weekday != DateTime.now().weekday) {
      _setupDates();
    }
    if (localTime.isAfter(_today!)) {
      if (localTime.isBefore(_tomorrow)) {
        return DateSectionRange.today;
      } else {
        if (localTime.isBefore(_dayAfterTomorrow)) {
          return DateSectionRange.tomorrow;
        } else {
          return DateSectionRange.future;
        }
      }
    }
    if (localTime.isAfter(_yesterday!)) {
      return DateSectionRange.yesterday;
    } else if (localTime.isAfter(_thisWeek!)) {
      return DateSectionRange.thisWeek;
    } else if (localTime.isAfter(_lastWeek)) {
      return DateSectionRange.lastWeek;
    } else if (localTime.year == _today!.year) {
      if (localTime.month == _today!.month) {
        return DateSectionRange.thisMonth;
      } else {
        return DateSectionRange.monthOfThisYear;
      }
    }
    return DateSectionRange.monthAndYear;
  }
}
