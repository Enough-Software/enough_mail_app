import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app_lifecycle/provider.dart';
import '../provider.dart';
import 'model.dart';

part 'provider.g.dart';

/// The default color provider
@Riverpod(keepAlive: true)
Color defaultColorSeed(DefaultColorSeedRef ref) => Colors.green;

/// Provides the settings
@Riverpod(keepAlive: true)
class ThemeFinder extends _$ThemeFinder {
  @override
  ThemeSettingsData build({required BuildContext context}) {
    final themeSettings = ref.watch(
      settingsProvider.select((value) => value.themeSettings),
    );
    ref.watch(appIsResumedProvider);
    final defaultColor = ref.watch(defaultColorSeedProvider);

    return _fromThemeSettings(
      themeSettings,
      defaultColor,
      context: context,
    );
  }

  static ThemeSettingsData _fromThemeSettings(
    ThemeSettings settings,
    Color defaultColor, {
    BuildContext? context,
  }) {
    final mode = settings.getCurrentThemeMode();
    final brightness = _resolveBrightness(mode, context);
    final dark = _generateMaterialTheme(
      Brightness.dark,
      settings.colorSchemeSeed ?? defaultColor,
    );
    final light = _generateMaterialTheme(
      Brightness.light,
      settings.colorSchemeSeed ?? defaultColor,
    );
    final cupertino = _generateCupertinoTheme(
      brightness,
      settings.colorSchemeSeed ?? defaultColor,
    );

    return ThemeSettingsData(
      brightness: brightness,
      lightTheme: light,
      darkTheme: dark,
      themeMode: mode,
      cupertinoTheme: cupertino,
    );
  }

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

  static ThemeData _generateMaterialTheme(Brightness brightness, Color color) =>
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

  static CupertinoThemeData _generateCupertinoTheme(
    Brightness brightness,
    Color color,
  ) =>
      CupertinoThemeData(
        brightness: brightness,
        primaryColor: color,
      );
}
