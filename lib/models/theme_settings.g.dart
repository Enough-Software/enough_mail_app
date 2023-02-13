// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThemeSettings _$ThemeSettingsFromJson(Map<String, dynamic> json) =>
    ThemeSettings(
      themeModeSetting: $enumDecodeNullable(
              _$ThemeModeSettingEnumMap, json['themeModeSetting']) ??
          ThemeModeSetting.system,
      themeDarkStartTime: json['themeDarkStartTime'] == null
          ? const TimeOfDay(hour: 22, minute: 0)
          : _timeOfDayFromJson(
              json['themeDarkStartTime'] as Map<String, dynamic>),
      themeDarkEndTime: json['themeDarkEndTime'] == null
          ? const TimeOfDay(hour: 7, minute: 0)
          : _timeOfDayFromJson(
              json['themeDarkEndTime'] as Map<String, dynamic>),
      colorSchemeSeed: json['colorSchemeSeed'] == null
          ? Colors.green
          : _colorFromJson(json['colorSchemeSeed'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ThemeSettingsToJson(ThemeSettings instance) =>
    <String, dynamic>{
      'themeModeSetting': _$ThemeModeSettingEnumMap[instance.themeModeSetting]!,
      'themeDarkStartTime': _timeOfDayToJson(instance.themeDarkStartTime),
      'themeDarkEndTime': _timeOfDayToJson(instance.themeDarkEndTime),
      'colorSchemeSeed': _colorToJson(instance.colorSchemeSeed),
    };

const _$ThemeModeSettingEnumMap = {
  ThemeModeSetting.light: 'light',
  ThemeModeSetting.dark: 'dark',
  ThemeModeSetting.system: 'system',
  ThemeModeSetting.custom: 'custom',
};
