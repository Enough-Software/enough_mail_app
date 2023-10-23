import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app_lifecycle/provider.dart';
import '../provider.dart';
import 'model.dart';

part 'provider.g.dart';

/// Provides the settings
@Riverpod(keepAlive: true)
class ThemeFinder extends _$ThemeFinder {
  @override
  ThemeSettingsData build({required BuildContext context}) {
    final themeSettings = ref.watch(
      settingsProvider.select((value) => value.themeSettings),
    );
    ref.watch(appIsResumedProvider);

    return _fromThemeSettings(
      themeSettings,
      context: context,
    );
  }

  static ThemeSettingsData _fromThemeSettings(
    ThemeSettings settings, {
    BuildContext? context,
  }) {
    final mode = settings.getCurrentThemeMode();
    final brightness = _resolveBrightness(mode, context);
    final dark = _generateTheme(Brightness.dark, settings.colorSchemeSeed);
    final light = _generateTheme(Brightness.light, settings.colorSchemeSeed);

    return ThemeSettingsData(
      brightness: brightness,
      lightTheme: light,
      darkTheme: dark,
      themeMode: mode,
    );
  }

  /// The default light theme
  static final ThemeData defaultLightTheme =
      _generateTheme(Brightness.light, Colors.green);

  /// The default dark theme
  static final ThemeData defaultDarkTheme =
      _generateTheme(Brightness.dark, Colors.green);

  static Brightness _resolveBrightness(
    ThemeMode mode,
    BuildContext? context,
  ) {
    switch (mode) {
      case ThemeMode.system:
        return context != null
            ? MediaQuery.platformBrightnessOf(context)
            : Brightness.light;
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
    }
  }

  static ThemeData _generateTheme(Brightness brightness, Color color) =>
      color is MaterialColor
          ? ThemeData(
              brightness: brightness,
              primarySwatch: color,
              useMaterial3: false,
            )
          : ThemeData(
              brightness: brightness,
              colorSchemeSeed: color,
              useMaterial3: true,
            );
}
