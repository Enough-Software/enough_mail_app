import 'dart:math';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.g.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final texts = [
      localizations.splashLoading1,
      localizations.splashLoading2,
      localizations.splashLoading3
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
