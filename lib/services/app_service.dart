import 'dart:ui';

import '../locator.dart';
import '../logger.dart';
import '../settings/model.dart';
import 'biometrics_service.dart';

/// Handles app life cycle events
class AppService {
  /// Creates a new [AppService]
  AppService();

  /// The current [AppLifecycleState]
  AppLifecycleState appLifecycleState = AppLifecycleState.resumed;

  var _ignoreBiometricsCheckAtNextResume = false;
  var _ignoreBiometricsCheckAtNextResumeTS = DateTime.now();
  set ignoreBiometricsCheckAtNextResume(bool value) {
    _ignoreBiometricsCheckAtNextResume = value;
    if (value) {
      _ignoreBiometricsCheckAtNextResumeTS = DateTime.now();
    }
  }

  bool get isInBackground => appLifecycleState != AppLifecycleState.resumed;
  DateTime? _lastPausedTimeStamp;

  /// Handles when app life cycle has changed
  Future<void> didChangeAppLifecycleState(
    AppLifecycleState state,
    Settings settings,
  ) async {
    logger.d('didChangeAppLifecycleState: $state');
    appLifecycleState = state;
    switch (state) {
      case AppLifecycleState.resumed:
        //locator<ThemeService>().checkForChangedTheme();
        if (settings.enableBiometricLock) {
          if (_ignoreBiometricsCheckAtNextResume) {
            _ignoreBiometricsCheckAtNextResume = false;
            // double check time stamp,
            // everything more than a minute requires a check
            if (_ignoreBiometricsCheckAtNextResumeTS.isAfter(
              DateTime.now().subtract(
                const Duration(minutes: 1),
              ),
            )) {
              return;
            }
          }
          if (settings.lockTimePreference
              .requiresAuthorization(_lastPausedTimeStamp)) {
            // final navService = locator<NavigationService>();
            // if (navService.currentRouteName != Routes.lockScreen) {
            //   await navService.push(Routes.lockScreen);
            // }
            final bool didAuthenticate =
                await locator<BiometricsService>().authenticate();
            // if (!didAuthenticate) {
            //   if (navService.currentRouteName != Routes.lockScreen) {
            //     await navService.push(Routes.lockScreen);
            //   }

            //   return;
            // } else if (navService.currentRouteName == Routes.lockScreen) {
            //   navService.pop();
            // }
          }
        }
        break;
      case AppLifecycleState.inactive:
        // TODO: Check if AppLifecycleState.inactive needs to be handled
        break;
      case AppLifecycleState.paused:
        _lastPausedTimeStamp = DateTime.now();
        //await locator<BackgroundService>().saveStateOnPause();
        break;
      case AppLifecycleState.detached:
        // TODO: Check if AppLifecycleState.detached needs to be handled
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
        break;
    }
  }
}
