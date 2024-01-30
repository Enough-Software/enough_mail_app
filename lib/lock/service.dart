import 'dart:async';

import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

import '../localization/app_localizations.g.dart';

/// Handles biometrics
class BiometricsService {
  /// Creates a new [BiometricsService]
  BiometricsService._();

  static final _instance = BiometricsService._();

  /// The instance of the [BiometricsService]
  static BiometricsService get instance => _instance;

  bool _isResolved = false;
  bool _isSupported = false;
  final _localAuth = LocalAuthentication();

  /// Checks if the device supports biometrics
  Future<bool> isDeviceSupported() async {
    if (_isResolved) {
      return _isSupported;
    }
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      _isSupported = canCheck && isDeviceSupported;
    } catch (e, s) {
      if (kDebugMode) {
        print('Unable to check local auth for biometrics support: $e $s');
        _isSupported = false;
      }
    }
    _isResolved = true;

    return _isSupported;
  }

  /// Authenticates the user with biometrics
  Future<bool> authenticate(
    AppLocalizations localizations, {
    String? reason,
  }) async {
    if (!_isResolved) {
      await isDeviceSupported();
    }
    if (!_isSupported) {
      return false;
    }
    // AppService.instance.ignoreBiometricsCheckAtNextResume = true;
    try {
      final result = await _localAuth.authenticate(
        localizedReason:
            reason ?? await _getLocalizedUnlockReason(localizations),
        options: const AuthenticationOptions(
          sensitiveTransaction: false,
        ),
      );
      // unawaited(Future.delayed(const Duration(seconds: 2)).then(
      //   (_) => AppService.instance.ignoreBiometricsCheckAtNextResume = false,
      // ));

      return result;
    } catch (e, s) {
      if (kDebugMode) {
        print('Authentication failed with $e $s');
      }
    }

    return false;
  }

  Future<String> _getLocalizedUnlockReason(
    AppLocalizations localizations,
  ) async {
    if (PlatformInfo.isCupertino) {
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      if (availableBiometrics.contains(BiometricType.face)) {
        return localizations.securityUnlockWithFaceId;
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return localizations.securityUnlockWithTouchId;
      }
    }

    return localizations.securityUnlockReason;
  }
}
