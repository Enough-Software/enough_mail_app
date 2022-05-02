import 'package:enough_icalendar/enough_icalendar.dart';
import 'package:enough_mail_app/services/date_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbols.dart';
import 'package:intl/intl.dart' as intl;
import 'package:intl/date_symbol_data_local.dart' as date_intl;
import '../l10n/app_localizations.g.dart';
import 'package:intl/intl.dart';

class I18nService {
  /// Day of week for countries (in two letter code) for which the week does not start on Monday
  /// Source: http://chartsbin.com/view/41671
  static const firstDayOfWeekPerCountryCode = <String, int>{
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
  int firstDayOfWeek = DateTime.monday;
  Locale? _locale;
  Locale? get locale => _locale;

  late AppLocalizations _localizations;
  AppLocalizations get localizations => _localizations;

  late intl.DateFormat _dateTimeFormatToday;
  late intl.DateFormat _dateTimeFormatLastWeek;
  late intl.DateFormat _dateTimeFormat;
  late intl.DateFormat _dateTimeFormatLong;
  late intl.DateFormat _dateFormatDayInLastWeek;
  late intl.DateFormat _dateFormatDayBeforeLastWeek;
  late intl.DateFormat _dateFormatLong;
  late intl.DateFormat _dateFormatShort;
  // late intl.DateFormat _dateFormatMonth;
  late intl.DateFormat _dateFormatWeekday;
  // late intl.DateFormat _dateFormatNoTime;

  void init(AppLocalizations localizations, Locale locale) {
    _localizations = localizations;
    _locale = locale;
    final countryCode = locale.countryCode?.toLowerCase();
    if (countryCode == null) {
      firstDayOfWeek = DateTime.monday;
    } else {
      firstDayOfWeek =
          firstDayOfWeekPerCountryCode[countryCode] ?? DateTime.monday;
    }
    final localeText = locale.toString();
    date_intl.initializeDateFormatting(localeText).then((value) {
      _dateTimeFormatToday = intl.DateFormat.jm(localeText);
      _dateTimeFormatLastWeek = intl.DateFormat.E(localeText).add_jm();
      _dateTimeFormat = intl.DateFormat.yMd(localeText).add_jm();
      _dateTimeFormatLong = intl.DateFormat.yMMMMEEEEd(localeText).add_jm();
      _dateFormatDayInLastWeek = intl.DateFormat.E(localeText);
      _dateFormatDayBeforeLastWeek = intl.DateFormat.yMd(localeText);
      _dateFormatLong = intl.DateFormat.yMMMMEEEEd(localeText);
      _dateFormatShort = intl.DateFormat.yMd(localeText);
      _dateFormatWeekday = intl.DateFormat.EEEE(localeText);
      // _dateFormatMonth = intl.DateFormat.MMMM(localeText);
      // _dateFormatNoTime = intl.DateFormat.yMEd(localeText);
    });
  }

  String formatDateTime(DateTime? dateTime,
      {bool alwaysUseAbsoluteFormat = false, useLongFormat = false}) {
    if (dateTime == null) {
      return _localizations.dateUndefined;
    }
    if (alwaysUseAbsoluteFormat) {
      if (useLongFormat) {
        return _dateTimeFormatLong.format(dateTime);
      }
      return _dateTimeFormat.format(dateTime);
    }
    final nw = DateTime.now();
    final today = nw.subtract(Duration(
        hours: nw.hour,
        minutes: nw.minute,
        seconds: nw.second,
        milliseconds: nw.millisecond));
    final lastWeek = today.subtract(const Duration(days: 7));
    String date;
    if (dateTime.isAfter(today)) {
      date = _dateTimeFormatToday.format(dateTime);
    } else if (dateTime.isAfter(lastWeek)) {
      date = _dateTimeFormatLastWeek.format(dateTime);
    } else {
      if (useLongFormat) {
        date = _dateTimeFormatLong.format(dateTime);
      } else {
        date = _dateTimeFormat.format(dateTime);
      }
    }
    return date;
  }

  String formatDate(DateTime? dateTime, {bool useLongFormat = false}) {
    if (dateTime == null) {
      return _localizations.dateUndefined;
    }

    if (useLongFormat) {
      return _dateFormatLong.format(dateTime);
    } else {
      return _dateFormatShort.format(dateTime);
    }
  }

  String formatDay(DateTime dateTime) {
    final messageDate = dateTime;
    final nw = DateTime.now();
    final today = nw.subtract(Duration(
        hours: nw.hour,
        minutes: nw.minute,
        seconds: nw.second,
        milliseconds: nw.millisecond));
    if (messageDate.isAfter(today)) {
      return localizations.dateDayToday;
    } else if (messageDate.isAfter(today.subtract(const Duration(days: 1)))) {
      return localizations.dateDayYesterday;
    } else if (messageDate.isAfter(today.subtract(const Duration(days: 7)))) {
      return localizations
          .dateDayLastWeekday(_dateFormatDayInLastWeek.format(messageDate));
    } else {
      return _dateFormatDayBeforeLastWeek.format(messageDate);
    }
  }

  String formatWeekDay(DateTime dateTime) {
    return _dateFormatWeekday.format(dateTime);
  }

  List<WeekDay> formatWeekDays({int? startOfWeekDay, bool abbreviate = false}) {
    startOfWeekDay ??= firstDayOfWeek;
    final dateSymbols =
        (date_intl.dateTimeSymbolMap()[_locale.toString()] as DateSymbols);
    final weekdays = abbreviate
        ? dateSymbols.STANDALONESHORTWEEKDAYS
        : dateSymbols.STANDALONEWEEKDAYS;
    final result = <WeekDay>[];
    for (int i = 0; i < 7; i++) {
      final day = ((startOfWeekDay + i) <= 7)
          ? (startOfWeekDay + i)
          : ((startOfWeekDay + i) - 7);
      final nameIndex = day == DateTime.sunday ? 0 : day;
      final name = weekdays[nameIndex];
      result.add(WeekDay(day, name));
    }
    return result;
  }

  String formatDateRange(DateSectionRange range, DateTime dateTime) {
    switch (range) {
      case DateSectionRange.future:
        return _localizations.dateRangeFuture;
      case DateSectionRange.tomorrow:
        return _localizations.dateRangeTomorrow;
      case DateSectionRange.today:
        return _localizations.dateRangeToday;
      case DateSectionRange.yesterday:
        return _localizations.dateRangeYesterday;
      case DateSectionRange.thisWeek:
        return _localizations.dateRangeCurrentWeek;
      case DateSectionRange.lastWeek:
        return _localizations.dateRangeLastWeek;
      case DateSectionRange.thisMonth:
        return _localizations.dateRangeCurrentMonth;
      case DateSectionRange.monthOfThisYear:
        return _localizations.dateRangeCurrentYear;
      case DateSectionRange.monthAndYear:
        return _localizations.dateRangeLongAgo;
    }
  }

  String formatTimeOfDay(TimeOfDay timeOfDay, BuildContext context) {
    return timeOfDay.format(context);
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
    final sizeFormat = NumberFormat('###.0#');
    return '${sizeFormat.format(sizeD)} ${units[unitIndex]}';
  }

  String formatIsoDuration(IsoDuration duration) {
    final localizations = _localizations;
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

class WeekDay {
  final int day;
  final String name;

  const WeekDay(this.day, this.name);
}
