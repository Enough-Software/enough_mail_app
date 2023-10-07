import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app_lifecycle/provider.dart';
import '../provider.dart';
import 'model.dart';

/// Provides the settings
final themeProvider =
    NotifierProvider<ThemeNotifier, ThemeSettingsData>(ThemeNotifier.new);

/// Provides the settings
class ThemeNotifier extends Notifier<ThemeSettingsData> {
  /// Creates a [ThemeNotifier]
  ThemeNotifier();

  @override
  ThemeSettingsData build() {
    final themeSettings = ref.watch(
      settingsProvider.select((value) => value.themeSettings),
    );
    final isResumed = ref.watch(
      appLifecycleStateProvider
          .select((value) => value == AppLifecycleState.resumed),
    );
    if (!isResumed) {
      return state;
    }

    return _fromThemeSettings(
      themeSettings,
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
  ThemeData _lightTheme = defaultLightTheme;
  ThemeData get lightTheme => _lightTheme;
  ThemeData _darkTheme = defaultDarkTheme;
  ThemeData get darkTheme => _darkTheme;
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;
  Color _colorSchemeSeed = Colors.green;

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

  /// Initializes this theme notifier
  void init(BuildContext context) {
    final themeSettings = ref.read(settingsProvider).themeSettings;
    state = _fromThemeSettings(themeSettings, context: context);
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

  void checkForChangedTheme(ThemeSettings settings) {
    var isChanged = false;
    final mode = settings.getCurrentThemeMode();
    if (mode != _themeMode) {
      _themeMode = mode;
      isChanged = true;
    }
    final colorSchemeSeed = settings.colorSchemeSeed;
    if (colorSchemeSeed != _colorSchemeSeed) {
      _colorSchemeSeed = colorSchemeSeed;
      _lightTheme = _generateTheme(Brightness.light, colorSchemeSeed);
      _darkTheme = _generateTheme(Brightness.dark, colorSchemeSeed);
      isChanged = true;
    }
    if (isChanged) {}
  }
}
