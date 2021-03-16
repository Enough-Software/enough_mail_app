import 'package:enough_mail_app/services/date_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class I18nService {
  /// Day of week for countries (in two letter code) for which the week does not start on Monday
  /// Source: http://chartsbin.com/view/41671
  static const firstDayOfWeekPerCountryCode = const <String, int>{
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
  Locale _locale;
  Locale get locale => _locale;
  set locale(Locale value) {
    _locale = value;
    var countryCode = value?.countryCode?.toLowerCase();
    firstDayOfWeek =
        firstDayOfWeekPerCountryCode[countryCode] ?? DateTime.monday;
    var localeText = value.toString();
    _dateFormatToday = intl.DateFormat.jm(localeText);
    _dateFormatLastWeek = intl.DateFormat.E(localeText).add_jm();
    _dateFormat = intl.DateFormat.yMd(localeText).add_jm();
    _dateFormatDayInLastWeek = intl.DateFormat.E(localeText);
    _dateFormatDayBeforeLastWeek = intl.DateFormat.yMd(localeText);
    _dateFormatMonth = intl.DateFormat.MMMM(localeText);
  }

  Map<DateSectionRange, intl.DateFormat> _messageListFormats = {};
  Map<DateSectionRange, intl.DateFormat> _messageSectionHeaderFormats = {};

  intl.DateFormat _dateFormatToday;
  intl.DateFormat _dateFormatLastWeek;
  intl.DateFormat _dateFormat;
  intl.DateFormat _dateFormatDayInLastWeek;
  intl.DateFormat _dateFormatDayBeforeLastWeek;
  intl.DateFormat _dateFormatMonth;

  String formatDate(DateTime dateTime, BuildContext context) {
    if (_locale == null) {
      locale = Localizations.localeOf(context);
    }
    if (dateTime == null) {
      return 'undefined'; //TODO
    }
    //TODO use DateService
    final messageDate = dateTime.toLocal();
    final nw = DateTime.now();
    final today = nw.subtract(Duration(
        hours: nw.hour,
        minutes: nw.minute,
        seconds: nw.second,
        milliseconds: nw.millisecond));
    final lastWeek = today.subtract(Duration(days: 7));
    String date;
    if (messageDate.isAfter(today)) {
      date = _dateFormatToday.format(messageDate);
    } else if (messageDate.isAfter(lastWeek)) {
      date = _dateFormatLastWeek.format(messageDate);
    } else {
      date = _dateFormat.format(messageDate);
    }
    return date;
  }

  String formatDay(DateTime dateTime, BuildContext context) {
    if (_locale == null) {
      locale = Localizations.localeOf(context);
    }
    final messageDate = dateTime.toLocal();
    final nw = DateTime.now();
    final today = nw.subtract(Duration(
        hours: nw.hour,
        minutes: nw.minute,
        seconds: nw.second,
        milliseconds: nw.millisecond));
    if (messageDate.isAfter(today)) {
      return 'today';
    } else if (messageDate.isAfter(today.subtract(Duration(days: 1)))) {
      return 'yesterday';
    } else if (messageDate.isAfter(today.subtract(Duration(days: 7)))) {
      return 'last ${_dateFormatDayInLastWeek.format(messageDate)}';
    } else {
      return _dateFormatDayBeforeLastWeek.format(messageDate);
    }
  }

  String formatDateRange(DateSectionRange range, DateTime dateTime) {
    switch (range) {
      case DateSectionRange.future:
        return 'future';
      case DateSectionRange.tomorrow:
        return 'tomorrow';
      case DateSectionRange.today:
        return 'today';
      case DateSectionRange.yesterday:
        return 'yesterday';
      case DateSectionRange.thisWeek:
        return 'this week';
      case DateSectionRange.lastWeek:
        return 'last week';
      case DateSectionRange.thisMonth:
        return 'this month';
      case DateSectionRange.monthOfThisYear:
        return 'this year';
      case DateSectionRange.monthAndYear:
        return 'long ago';
    }
    return '<uncategorized>';
  }

  String formatTimeOfDay(TimeOfDay timeOfDay, BuildContext context) {
    if (timeOfDay == null) {
      return 'undefined'; //TODO
    }
    return timeOfDay.format(context);
  }
}
