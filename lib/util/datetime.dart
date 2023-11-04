import 'package:flutter/material.dart';

extension DateTimeExtension on DateTime {
  TimeOfDay toTimeOfDay() => TimeOfDay.fromDateTime(this);

  DateTime withTimeOfDay(TimeOfDay timeOfDay) =>
      DateTime(year, month, day, timeOfDay.hour, timeOfDay.minute);
}
