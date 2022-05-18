import 'package:enough_mail_app/locator.dart';
import 'package:enough_mail_app/services/app_service.dart';
import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class BiometricsService {
  bool _isResolved = false;
  bool _isSupported = false;
  final _localAuth = LocalAuthentication();

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

  Future<bool> authenticate({String? reason}) async {
    if (!_isResolved) {
      await isDeviceSupported();
    }
    if (!_isSupported) {
      return false;
    }
    reason ??= await _getLocalizedUnlockReason();
    locator<AppService>().ignoreBiometricsCheckAtNextResume = true;
    try {
      final result = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: false,
          sensitiveTransaction: false,
        ),
      );
      Future.delayed(const Duration(seconds: 2)).then(
        (value) =>
            locator<AppService>().ignoreBiometricsCheckAtNextResume = false,
      );
      return result;
    } catch (e, s) {
      if (kDebugMode) {
        print('Authentication failed with $e $s');
      }
    }
    return false;
  }

  Future<String> _getLocalizedUnlockReason() async {
    final localizations = locator<I18nService>().localizations;
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
