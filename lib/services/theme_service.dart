import 'package:enough_mail_app/models/settings.dart';
import 'package:enough_mail_app/models/theme_settings.dart';
import 'package:flutter/material.dart';

class ThemeService with ChangeNotifier {
  late ThemeSettings _themeSettings;
  static final ThemeData defaultLightTheme =
      ThemeData(primarySwatch: Colors.green);
  static final ThemeData defaultDarkTheme =
      ThemeData(brightness: Brightness.dark, primarySwatch: Colors.green);
  ThemeData _lightTheme = defaultLightTheme;
  ThemeData get lightTheme => _lightTheme;
  ThemeData _darkTheme = defaultDarkTheme;
  ThemeData get darkTheme => _darkTheme;
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;
  MaterialColor _primarySwatch = Colors.green;

  Brightness brightness(BuildContext context) {
    final mode = _themeSettings.getCurrentThemeMode();
    switch (mode) {
      case ThemeMode.system:
        return MediaQuery.platformBrightnessOf(context);
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
    }
  }

  void init(Settings settings) {
    _themeSettings = settings.themeSettings;
    checkForChangedTheme();
  }

  void checkForChangedTheme() {
    var isChanged = false;
    final mode = _themeSettings.getCurrentThemeMode();
    if (mode != _themeMode) {
      _themeMode = mode;
      isChanged = true;
    }
    final primarySwatch = _themeSettings.primarySwatch;
    if (primarySwatch != _primarySwatch) {
      _primarySwatch = primarySwatch;
      _lightTheme = ThemeData(primarySwatch: primarySwatch);
      _darkTheme =
          ThemeData(brightness: Brightness.dark, primarySwatch: primarySwatch);
      isChanged = true;
    }
    if (isChanged) {
      notifyListeners();
    }
  }
}
