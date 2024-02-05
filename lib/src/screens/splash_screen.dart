import 'dart:math';

import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../localization/extension.dart';

/// Displays a splash screen
class SplashScreen extends StatefulHookConsumerWidget {
  /// Creates a new [SplashScreen]
  const SplashScreen({super.key});

  static var _isShown = false;

  /// Is the splash screen shown?
  static bool get isShown => _isShown;

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SplashScreen._isShown = true;
  }

  @override
  void dispose() {
    SplashScreen._isShown = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
    final splashColor = isNight ? Colors.black87 : const Color(0xff99cc00);
    final textColor = isNight ? Colors.white : Colors.black87;

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
