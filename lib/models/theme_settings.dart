import 'package:enough_serialization/enough_serialization.dart';
import 'package:flutter/material.dart';

enum ThemeModeSetting { light, dark, system, custom }

class ThemeSettings extends SerializableObject {
  ThemeSettings() {
    transformers['themeModeSetting'] = (value) => value is ThemeModeSetting
        ? value.index
        : ThemeModeSetting.values[value];
    transformers['themeDarkStartTime'] = _convertTimeOfDay;
    transformers['themeDarkEndTime'] = _convertTimeOfDay;
  }

  ThemeModeSetting get themeModeSetting =>
      attributes['themeModeSetting'] ?? ThemeModeSetting.system;
  set themeModeSetting(ThemeModeSetting? value) =>
      attributes['themeModeSetting'] = value;

  TimeOfDay get themeDarkStartTime =>
      attributes['themeDarkStartTime'] ?? TimeOfDay(hour: 22, minute: 0);
  set themeDarkStartTime(TimeOfDay value) =>
      attributes['themeDarkStartTime'] = value;
  TimeOfDay get themeDarkEndTime =>
      attributes['themeDarkEndTime'] ?? TimeOfDay(hour: 7, minute: 0);
  set themeDarkEndTime(TimeOfDay value) =>
      attributes['themeDarkEndTime'] = value;

  MaterialColor get primarySwatch {
    int? index = attributes['primarySwatchIndex'];
    if (index == null || index < 0) {
      return Colors.green;
    }
    return availableColors[index] as MaterialColor;
  }

  set primarySwatch(MaterialColor value) {
    final index = availableColors.indexOf(value);
    if (index != -1) {
      attributes['primarySwatchIndex'] = index;
    }
  }

  List<Color> get availableColors => const [
        Colors.red,
        Colors.green,
        Colors.yellow,
        Colors.blue,
        Colors.grey,
        Colors.blueGrey,
        Colors.lightBlue,
        Colors.cyan,
        Colors.teal,
        Colors.indigo,
        Colors.lightGreen,
        Colors.orange,
        Colors.deepOrange,
        Colors.purple,
        Colors.deepPurple,
        Colors.brown,
        Colors.amber,
        Colors.lime,
        Colors.pink,
      ];

  ThemeMode getCurrentThemeMode() {
    switch (themeModeSetting) {
      case ThemeModeSetting.light:
        return ThemeMode.light;
      case ThemeModeSetting.dark:
        return ThemeMode.dark;
      case ThemeModeSetting.system:
        return ThemeMode.system;
      case ThemeModeSetting.custom:
        final now = _convertTimeOfDayToInt(TimeOfDay.now());
        if (now > _convertTimeOfDayToInt(themeDarkStartTime) ||
            now < _convertTimeOfDayToInt(themeDarkEndTime)) {
          return ThemeMode.dark;
        } else {
          return ThemeMode.light;
        }
    }
  }

  static dynamic _convertTimeOfDay(dynamic value) {
    if (value == null) {
      return null;
    }
    return value is TimeOfDay
        ? _convertTimeOfDayToInt(value)
        : _convertIntToTimeOfDay(value);
  }

  static int _convertTimeOfDayToInt(TimeOfDay input) =>
      input.hour * 100 + input.minute;

  static TimeOfDay _convertIntToTimeOfDay(int input) =>
      TimeOfDay(hour: input ~/ 100, minute: input - ((input ~/ 100) * 100));
}
