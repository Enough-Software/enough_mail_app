import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'theme_settings.g.dart';

enum ThemeModeSetting { light, dark, system, custom }

@JsonSerializable()
class ThemeSettings {
  const ThemeSettings({
    this.themeModeSetting = ThemeModeSetting.system,
    this.themeDarkStartTime = const TimeOfDay(hour: 22, minute: 0),
    this.themeDarkEndTime = const TimeOfDay(hour: 7, minute: 0),
    this.colorSchemeSeed = Colors.green,
  });

  /// Creates settings from the given [json]
  factory ThemeSettings.fromJson(Map<String, dynamic> json) =>
      _$ThemeSettingsFromJson(json);

  /// Converts these settings to JSON
  Map<String, dynamic> toJson() => _$ThemeSettingsToJson(this);

  final ThemeModeSetting themeModeSetting;

  @JsonKey(fromJson: _timeOfDayFromJson, toJson: _timeOfDayToJson)
  final TimeOfDay themeDarkStartTime;
  @JsonKey(fromJson: _timeOfDayFromJson, toJson: _timeOfDayToJson)
  final TimeOfDay themeDarkEndTime;
  @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
  final Color colorSchemeSeed;

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

Map<String, dynamic> _colorToJson(Color value) {
  final index = ThemeSettings.availableColors.indexOf(value);
  return {
    'index': index,
    'color': value.value,
  };
}

Color _colorFromJson(Map<String, dynamic> json) {
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
  return Colors.green;
}
