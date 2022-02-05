import 'package:enough_serialization/enough_serialization.dart';
import 'package:flutter/material.dart';

enum ThemeModeSetting { light, dark, system, custom }

class ThemeSettings extends SerializableObject {
  static const _keyColorSchemeSeed = 'colorSchemeSeed';
  static const _keyPrimaryColorSwatchIndex = 'primarySwatchIndex';
  static const _keyThemeModeSetting = 'themeModeSetting';
  static const _keyThemeDarkStartTime = 'themeDarkEndTime';
  static const _keyThemeDarkEndTime = 'themeDarkStartTime';
  ThemeSettings() {
    transformers[_keyThemeModeSetting] = (value) => value is ThemeModeSetting
        ? value.index
        : ThemeModeSetting.values[value];
    transformers[_keyThemeDarkEndTime] = _convertTimeOfDay;
    transformers[_keyThemeDarkStartTime] = _convertTimeOfDay;
    transformers[_keyColorSchemeSeed] = _convertColor;
  }

  ThemeModeSetting get themeModeSetting =>
      attributes[_keyThemeModeSetting] ?? ThemeModeSetting.system;
  set themeModeSetting(ThemeModeSetting? value) =>
      attributes[_keyThemeModeSetting] = value;

  TimeOfDay get themeDarkStartTime =>
      attributes[_keyThemeDarkEndTime] ?? const TimeOfDay(hour: 22, minute: 0);
  set themeDarkStartTime(TimeOfDay value) =>
      attributes[_keyThemeDarkEndTime] = value;
  TimeOfDay get themeDarkEndTime =>
      attributes[_keyThemeDarkStartTime] ?? const TimeOfDay(hour: 7, minute: 0);
  set themeDarkEndTime(TimeOfDay value) =>
      attributes[_keyThemeDarkStartTime] = value;

  Color get colorSchemeSeed {
    Color? color = attributes[_keyColorSchemeSeed];
    if (color == null) {
      int? index = attributes[_keyPrimaryColorSwatchIndex];
      if (index != null && index >= 0 && index < availableColors.length) {
        color = availableColors[index];
      }
    }
    return color ?? Colors.green;
  }

  set colorSchemeSeed(Color value) {
    if (value is MaterialColor) {
      final index = availableColors.indexOf(value);
      if (index != -1) {
        attributes[_keyPrimaryColorSwatchIndex] = index;
        attributes[_keyColorSchemeSeed] = null;
        return;
      }
    }
    attributes[_keyColorSchemeSeed] = value;
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

  static dynamic _convertColor(dynamic value) {
    if (value == null) {
      return null;
    }
    return value is Color ? value.value : Color(value);
  }

  static int _convertTimeOfDayToInt(TimeOfDay input) =>
      input.hour * 100 + input.minute;

  static TimeOfDay _convertIntToTimeOfDay(int input) =>
      TimeOfDay(hour: input ~/ 100, minute: input - ((input ~/ 100) * 100));
}
