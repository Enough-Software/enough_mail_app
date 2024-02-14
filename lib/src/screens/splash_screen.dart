import 'dart:math';

import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../localization/extension.dart';
import '../settings/theme/provider.dart';

/// Displays a splash screen
class SplashScreen extends ConsumerWidget {
  /// Creates a new [SplashScreen]
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = ref.text;
    final texts = [
      localizations.splashLoading1,
      localizations.splashLoading2,
      localizations.splashLoading3,
    ];

    final index = Random().nextInt(texts.length);
    final text = texts[index];
    final timeOfDay = TimeOfDay.now();
    final isNight = timeOfDay.hour >= 22 || timeOfDay.hour <= 6;
    final splashColor =
        isNight ? Colors.black87 : ref.watch(defaultColorSeedProvider);
    final textColor = isNight
        ? Colors.white
        : ThemeData.estimateBrightnessForColor(splashColor) == Brightness.dark
            ? Colors.white
            : Colors.black87;

    return PlatformScaffold(
      body: Container(
        color: splashColor,
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
