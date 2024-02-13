import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

/// Defines the current theme mode
enum ThemeModeSetting {
  /// always use a light theme
  light,

  /// always use a dark theme
  dark,

  /// use the system theme
  system,

  /// use a custom theme in which you switch between dark and light depending
  /// on the time of day
  custom,
}

//// Contains the settings for the theme
@JsonSerializable()
class ThemeSettings {
  /// Creates settings for the theme
  const ThemeSettings({
    this.themeModeSetting = ThemeModeSetting.system,
    this.themeDarkStartTime = const TimeOfDay(hour: 22, minute: 0),
    this.themeDarkEndTime = const TimeOfDay(hour: 7, minute: 0),
    this.colorSchemeSeed,
  });

  /// Creates settings from the given [json]
  factory ThemeSettings.fromJson(Map<String, dynamic> json) =>
      _$ThemeSettingsFromJson(json);

  /// Converts these settings to JSON
  Map<String, dynamic> toJson() => _$ThemeSettingsToJson(this);

  /// The current theme mode
  final ThemeModeSetting themeModeSetting;

  /// The time of day when the dark theme should be active
  @JsonKey(fromJson: _timeOfDayFromJson, toJson: _timeOfDayToJson)
  final TimeOfDay themeDarkStartTime;

  /// The time of day when the dark theme should be inactive
  @JsonKey(fromJson: _timeOfDayFromJson, toJson: _timeOfDayToJson)
  final TimeOfDay themeDarkEndTime;

  /// The color scheme seed
  @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
  final Color? colorSchemeSeed;

  /// Standard colors
  static List<Color> get availableColors => const [
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

  /// Returns the current theme mode
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
        return now > _convertTimeOfDayToInt(themeDarkStartTime) ||
                now < _convertTimeOfDayToInt(themeDarkEndTime)
            ? ThemeMode.dark
            : ThemeMode.light;
    }
  }

  /// Returns a copy of these settings with the given properties
  ThemeSettings copyWith({
    Color? colorSchemeSeed,
    TimeOfDay? themeDarkStartTime,
    TimeOfDay? themeDarkEndTime,
    ThemeModeSetting? themeModeSetting,
  }) =>
      ThemeSettings(
        colorSchemeSeed: colorSchemeSeed ?? this.colorSchemeSeed,
        themeDarkStartTime: themeDarkStartTime ?? this.themeDarkStartTime,
        themeDarkEndTime: themeDarkEndTime ?? this.themeDarkEndTime,
        themeModeSetting: themeModeSetting ?? this.themeModeSetting,
      );
}

Map<String, dynamic> _timeOfDayToJson(TimeOfDay value) => {
      'hour': value.hour,
      'minute': value.minute,
    };

TimeOfDay _timeOfDayFromJson(Map<String, dynamic> json) => TimeOfDay(
      hour: json['hour'],
      minute: json['minute'],
    );

int _convertTimeOfDayToInt(TimeOfDay input) => input.hour * 100 + input.minute;

Map<String, dynamic> _colorToJson(Color? value) {
  if (value == null) {
    return {};
  }
  final index = ThemeSettings.availableColors.indexOf(value);

  return {
    'index': index,
    'color': value.value,
  };
}

Color? _colorFromJson(Map<String, dynamic> json) {
  final index = json['index'] as int?;
  if (index != null &&
      index > 0 &&
      index < ThemeSettings.availableColors.length) {
    return ThemeSettings.availableColors[index];
  }
  final color = json['color'] as int?;
  if (color != null) {
    return Color(color);
  }

  return null;
}

//// The actually applied theme data
@immutable
class ThemeSettingsData {
  /// Creates the theme data
  const ThemeSettingsData({
    required this.brightness,
    required this.darkTheme,
    required this.lightTheme,
    required this.themeMode,
    required this.cupertinoTheme,
  });

  /// The current brightness
  final Brightness brightness;

  /// The current dark theme data
  final ThemeData darkTheme;

  /// The current bright theme data
  final ThemeData lightTheme;

  /// The (material) theme mode
  final ThemeMode themeMode;

  /// The cupertino theme data
  final CupertinoThemeData cupertinoTheme;

  @override
  int get hashCode =>
      darkTheme.hashCode ^ lightTheme.hashCode ^ themeMode.hashCode;

  @override
  bool operator ==(Object other) =>
      other is ThemeSettingsData &&
      other.darkTheme == darkTheme &&
      other.lightTheme == lightTheme &&
      other.themeMode == themeMode;
}
