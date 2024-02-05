import 'dart:io';

import 'package:enough_icalendar/enough_icalendar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart' as date_intl;
import 'package:intl/date_symbols.dart';
import 'package:intl/intl.dart';

import '../util/date_helper.dart';
import 'app_localizations.g.dart';
import 'provider.dart';

// lateDateFormat _dateTimeFormatToday;
// late intl.DateFormat _dateTimeFormatLastWeek;
// late intl.DateFormat _dateTimeFormat;
// late intl.DateFormat _dateTimeFormatLong;
// late intl.DateFormat _dateFormatDayInLastWeek;
// late intl.DateFormat _dateFormatDayBeforeLastWeek;
// late intl.DateFormat _dateFormatLong;
// late intl.DateFormat _dateFormatShort;
// // late intl.DateFormat _dateFormatMonth;
// late intl.DateFormat _dateFormatWeekday;
// // late intl.DateFormat _dateFormatNoTime;

/// Allows to look up the localized strings for the current locale
extension AppLocalizationRef on Ref {
  /// Retrieves the current localizations
  AppLocalizations get text => read(currentAppLocalizationProvider);
}

/// Allows to look up the localized strings for the current locale
extension AppLocalizationWidgetRef on WidgetRef {
  /// Retrieves the current localizations
  AppLocalizations get text => read(currentAppLocalizationProvider);

  /// Retrieves the data range Name
  String getDateRangeName(
    DateSectionRange range,
  ) {
    final localizations = text;
    switch (range) {
      case DateSectionRange.future:
        return localizations.dateRangeFuture;
      case DateSectionRange.tomorrow:
        return localizations.dateRangeTomorrow;
      case DateSectionRange.today:
        return localizations.dateRangeToday;
      case DateSectionRange.yesterday:
        return localizations.dateRangeYesterday;
      case DateSectionRange.thisWeek:
        return localizations.dateRangeCurrentWeek;
      case DateSectionRange.lastWeek:
        return localizations.dateRangeLastWeek;
      case DateSectionRange.thisMonth:
        return localizations.dateRangeCurrentMonth;
      case DateSectionRange.monthOfThisYear:
        return localizations.dateRangeCurrentYear;
      case DateSectionRange.monthAndYear:
        return localizations.dateRangeLongAgo;
    }
  }

  DateFormat get _dateTimeFormatLong =>
      // cSpell: ignore yMMMMEEEEd
      DateFormat.yMMMMEEEEd(text.localeName).add_jm();
  DateFormat get _dateTimeFormatLastWeek =>
      DateFormat.E(text.localeName).add_jm();
  DateFormat get _dateFormatDayInLastWeek => DateFormat.E(text.localeName);
  DateFormat get _dateFormatDayBeforeLastWeek =>
      DateFormat.yMd(text.localeName);
  DateFormat get _dateFormatLong => DateFormat.yMMMMEEEEd(text.localeName);
  DateFormat get _dateFormatShort => DateFormat.yMd(text.localeName);
  DateFormat get _dateFormatWeekday => DateFormat.EEEE(text.localeName);
  DateFormat get _dateTimeFormatToday => DateFormat.jm(text.localeName);
  DateFormat get _dateTimeFormat => DateFormat.yMd(text.localeName).add_jm();

  String formatDateTime(
    DateTime? dateTime, {
    bool alwaysUseAbsoluteFormat = false,
    bool useLongFormat = false,
  }) {
    if (dateTime == null) {
      return text.dateUndefined;
    }
    if (alwaysUseAbsoluteFormat) {
      if (useLongFormat) {
        return _dateTimeFormatLong.format(dateTime);
      }

      return _dateTimeFormat.format(dateTime);
    }
    final nw = DateTime.now();
    final today = nw.subtract(
      Duration(
        hours: nw.hour,
        minutes: nw.minute,
        seconds: nw.second,
        milliseconds: nw.millisecond,
      ),
    );
    final lastWeek = today.subtract(const Duration(days: 7));
    String date;
    if (dateTime.isAfter(today)) {
      date = _dateTimeFormatToday.format(dateTime);
    } else if (dateTime.isAfter(lastWeek)) {
      date = _dateTimeFormatLastWeek.format(dateTime);
    } else {
      date = useLongFormat
          ? _dateTimeFormatLong.format(dateTime)
          : _dateTimeFormat.format(dateTime);
    }

    return date;
  }

  String formatDate(DateTime? dateTime, {bool useLongFormat = false}) {
    if (dateTime == null) {
      return text.dateUndefined;
    }

    return useLongFormat
        ? _dateFormatLong.format(dateTime)
        : _dateFormatShort.format(dateTime);
  }

  String formatDay(DateTime dateTime) {
    final messageDate = dateTime;
    final nw = DateTime.now();
    final today = nw.subtract(
      Duration(
        hours: nw.hour,
        minutes: nw.minute,
        seconds: nw.second,
        milliseconds: nw.millisecond,
      ),
    );
    if (messageDate.isAfter(today)) {
      return text.dateDayToday;
    } else if (messageDate.isAfter(today.subtract(const Duration(days: 1)))) {
      return text.dateDayYesterday;
    } else if (messageDate.isAfter(today.subtract(const Duration(days: 7)))) {
      return text
          .dateDayLastWeekday(_dateFormatDayInLastWeek.format(messageDate));
    } else {
      return _dateFormatDayBeforeLastWeek.format(messageDate);
    }
  }

  String formatWeekDay(DateTime dateTime) =>
      _dateFormatWeekday.format(dateTime);

  List<WeekDay> formatWeekDays({int? startOfWeekDay, bool abbreviate = false}) {
    final dateSymbols = date_intl.dateTimeSymbolMap()[text.localeName];
    final weekdays = (dateSymbols is DateSymbols)
        ? (abbreviate
            // cSpell: ignore STANDALONESHORTWEEKDAYS, STANDALONEWEEKDAYS
            ? dateSymbols.STANDALONESHORTWEEKDAYS
            : dateSymbols.STANDALONEWEEKDAYS)
        : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    final usedStartOfWeekDay = startOfWeekDay ?? firstDayOfWeek;
    final result = <WeekDay>[];
    for (int i = 0; i < 7; i++) {
      final day = ((usedStartOfWeekDay + i) <= 7)
          ? (usedStartOfWeekDay + i)
          : ((usedStartOfWeekDay + i) - 7);
      final nameIndex = day == DateTime.sunday ? 0 : day;
      final name = weekdays[nameIndex];
      result.add(WeekDay(day, name));
    }

    return result;
  }

  Locale _getPlatformLocale() {
    final localeName = Platform.localeName;
    final parts = localeName.split('_');
    final languageCode = parts.first;
    final countryCode = parts.length > 1 ? parts[1].split('.').first : null;

    return Locale(languageCode, countryCode);
  }

  static int? _firstDayOfWeek;
  int get firstDayOfWeek {
    final value = _firstDayOfWeek;
    if (value != null) {
      return value;
    }
    final locale = _getPlatformLocale();
    final firstDay =
        _firstDayOfWeekPerCountryCode[locale.countryCode] ?? DateTime.monday;
    _firstDayOfWeek = firstDay;

    return firstDay;
  }

  String? formatMemory(int? size) {
    if (size == null) {
      return null;
    }
    double sizeD = size + 0.0;
    final units = ['gb', 'mb', 'kb', 'bytes'];
    var unitIndex = units.length - 1;
    while ((sizeD / 1024) > 1.0 && unitIndex > 0) {
      sizeD = sizeD / 1024;
      unitIndex--;
    }
    final sizeFormat = NumberFormat('###.0#', text.localeName);

    return '${sizeFormat.format(sizeD)} ${units[unitIndex]}';
  }

  String formatIsoDuration(IsoDuration duration) {
    final localizations = text;
    final buffer = StringBuffer();
    if (duration.isNegativeDuration) {
      buffer.write('-');
    }
    if (duration.years > 0) {
      buffer.write(localizations.durationYears(duration.years));
    }
    if (duration.months > 0) {
      if (buffer.isNotEmpty) buffer.write(', ');
      buffer.write(localizations.durationMonths(duration.months));
    }
    if (duration.weeks > 0) {
      if (buffer.isNotEmpty) buffer.write(', ');
      buffer.write(localizations.durationWeeks(duration.weeks));
    }
    if (duration.days > 0) {
      if (buffer.isNotEmpty) buffer.write(', ');
      buffer.write(localizations.durationDays(duration.days));
    }
    if (duration.hours > 0) {
      if (buffer.isNotEmpty) buffer.write(', ');
      buffer.write(localizations.durationHours(duration.hours));
    }
    if (duration.minutes > 0) {
      if (buffer.isNotEmpty) buffer.write(', ');
      buffer.write(localizations.durationHours(duration.minutes));
    }
    if (buffer.isEmpty) {
      buffer.write(localizations.durationEmpty);
    }

    return buffer.toString();
  }
}

extension AppLocalizationExtension on BuildContext {
  String formatTimeOfDay(TimeOfDay timeOfDay) => timeOfDay.format(this);
}

class WeekDay {
  const WeekDay(this.day, this.name);
  final int day;
  final String name;
}

/// Day of week for countries (in two letter code) for
/// which the week does not start on Monday
///
/// Source: http://chartsbin.com/view/41671
const _firstDayOfWeekPerCountryCode = <String, int>{
  'ae': DateTime.saturday, // United Arab Emirates
  'af': DateTime.saturday, // Afghanistan
  'ar': DateTime.sunday, // Argentina
  'bh': DateTime.saturday, // Bahrain
  'br': DateTime.sunday, // Brazil
  'bz': DateTime.sunday, // Belize
  'bo': DateTime.sunday, // Bolivia
  'ca': DateTime.sunday, // Canada
  'cl': DateTime.sunday, // Chile
  'cn': DateTime.sunday, // China
  'co': DateTime.sunday, // Colombia
  // cSpell: ignore Rica
  'cr': DateTime.sunday, // Costa Rica
  'do': DateTime.sunday, // Dominican Republic
  'dz': DateTime.saturday, // Algeria
  'ec': DateTime.sunday, // Ecuador
  'eg': DateTime.saturday, // Egypt
  'gt': DateTime.sunday, // Guatemala
  'hk': DateTime.sunday, // Hong Kong
  'hn': DateTime.sunday, // Honduras
  'il': DateTime.sunday, // Israel
  'iq': DateTime.saturday, // Iraq
  'ir': DateTime.saturday, // Iran
  'jm': DateTime.sunday, // Jamaica
  'io': DateTime.saturday, // Jordan
  'jp': DateTime.sunday, // Japan
  'ke': DateTime.sunday, // Kenya
  'kr': DateTime.sunday, // South Korea
  'kw': DateTime.saturday, // Kuwait
  'ly': DateTime.saturday, // Libya
  'mo': DateTime.sunday, // Macao
  'mx': DateTime.sunday, // Mexico
  'ni': DateTime.sunday, // Nicaragua
  'om': DateTime.saturday, // Oman
  'pa': DateTime.sunday, // Panama
  'pe': DateTime.sunday, // Peru
  'ph': DateTime.sunday, // Philippines
  'pr': DateTime.sunday, // Puerto Rico
  'qa': DateTime.saturday, // Qatar
  'sa': DateTime.saturday, // Saudi Arabia
  'sv': DateTime.sunday, // El Salvador
  'sy': DateTime.saturday, // Syria
  'tw': DateTime.sunday, // Taiwan
  'us': DateTime.sunday, // USA
  've': DateTime.sunday, // Venezuela
  'ye': DateTime.saturday, // Yemen
  'za': DateTime.sunday, // South Africa
  'zw': DateTime.sunday, // Zimbabwe
};
