/// The date section of a given date
enum DateSectionRange {
  /// The date is in the future, more distant than tomorrow
  future,

  /// The date is tomorrow
  tomorrow,

  /// The date is today
  today,

  /// The date is yesterday
  yesterday,

  /// The date is in the current week
  thisWeek,

  /// The date is in the last week
  lastWeek,

  /// The date is in the current month
  thisMonth,

  /// The date is in the current year
  monthOfThisYear,

  /// The date is in a different year
  monthAndYear,
}

/// Allows to determine the date section of a given date
class DateHelper {
  /// Creates a new [DateHelper]
  DateHelper(this.firstDayOfWeek) {
    _setupDates();
  }

  /// The first weekday of the week
  final int firstDayOfWeek;

  late DateTime _today;
  late DateTime _tomorrow;
  late DateTime _dayAfterTomorrow;
  late DateTime _yesterday;
  late DateTime _thisWeek;
  late DateTime _lastWeek;

  void _setupDates() {
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _tomorrow = _today.add(const Duration(days: 1));
    _dayAfterTomorrow = _tomorrow.add(const Duration(days: 1));
    _yesterday = _today.subtract(const Duration(days: 1));
    if (_today.weekday == firstDayOfWeek) {
      _thisWeek = _today;
    } else if (_yesterday.weekday == firstDayOfWeek) {
      _thisWeek = _yesterday;
    } else {
      _thisWeek = _today.weekday > firstDayOfWeek
          ? _today.subtract(Duration(days: _today.weekday - firstDayOfWeek))
          : _today
              .subtract(Duration(days: _today.weekday + 7 - firstDayOfWeek));
    }
    _lastWeek = _thisWeek.subtract(const Duration(days: 7));
  }

  /// Determines the date section of the given [localTime]
  DateSectionRange determineDateSection(
    DateTime localTime,
  ) {
    if (_today.weekday != DateTime.now().weekday) {
      _setupDates();
    }
    if (localTime.isAfter(_today)) {
      return localTime.isBefore(_tomorrow)
          ? DateSectionRange.today
          : localTime.isBefore(_dayAfterTomorrow)
              ? DateSectionRange.tomorrow
              : DateSectionRange.future;
    }
    if (localTime.isAfter(_yesterday)) {
      return DateSectionRange.yesterday;
    } else if (localTime.isAfter(_thisWeek)) {
      return DateSectionRange.thisWeek;
    } else if (localTime.isAfter(_lastWeek)) {
      return DateSectionRange.lastWeek;
    } else if (localTime.year == _today.year) {
      return localTime.month == _today.month
          ? DateSectionRange.thisMonth
          : DateSectionRange.monthOfThisYear;
    }

    return DateSectionRange.monthAndYear;
  }
}
