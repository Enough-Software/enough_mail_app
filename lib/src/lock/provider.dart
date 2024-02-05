import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../app_lifecycle/provider.dart';
import '../localization/extension.dart';
import '../logger.dart';
import '../routes/routes.dart';
import '../screens/screens.dart';
import '../settings/model.dart';
import '../settings/provider.dart';
import 'service.dart';

part 'provider.g.dart';

/// Checks the app life cycle and displays the lock screen if needed
@Riverpod(keepAlive: true)
class AppLock extends _$AppLock {
  var _lockTime = DateTime.now();
  static var _ignoreNextSettingsChange = false;

  /// Allows to ignore the next settings change
  // ignore: avoid_setters_without_getters
  static set ignoreNextSettingsChange(bool value) =>
      _ignoreNextSettingsChange = value;

  @override
  void build() {
    final enableBiometricLock = ref.watch(
      settingsProvider.select((value) => value.enableBiometricLock),
    );
    final lockTimePreference = ref.watch(
      settingsProvider.select((value) => value.lockTimePreference),
    );
    final isResumed = ref.watch(appIsResumedProvider);
    if (!enableBiometricLock) {
      return;
    }
    if (_ignoreNextSettingsChange) {
      _ignoreNextSettingsChange = false;
      logger.d('ignoring settings change');

      return;
    }
    final context = Routes.navigatorKey.currentContext;
    if (context == null) {
      return;
    }
    if (!isResumed) {
      _lockTime = DateTime.now();
      logger.d(
        'setting lock time: $_lockTime',
      );
      if (lockTimePreference == LockTimePreference.immediately &&
          !LockScreen.isShown) {
        logger.d('pushing lock screen (immediately + !isResumed)');
        unawaited(context.pushNamed(Routes.lockScreen));
      }
    } else {
      final difference = DateTime.now().difference(_lockTime);
      switch (lockTimePreference) {
        case LockTimePreference.immediately:
          if (!LockScreen.isShown) {
            logger.d('pushing lock screen (immediately + isResumed)');
            unawaited(context.pushNamed(Routes.lockScreen));
          }
          _unlock(context, ref);
          break;
        case LockTimePreference.after5minutes:
          if (difference.inMinutes >= 5) {
            if (!LockScreen.isShown) {
              logger.d('pushing lock screen 5min');
              unawaited(context.pushNamed(Routes.lockScreen));
            }
            _unlock(context, ref);
          }
          break;
        case LockTimePreference.after30minutes:
          if (difference.inMinutes >= 30) {
            if (!LockScreen.isShown) {
              logger.d('pushing lock screen 30min');
              unawaited(context.pushNamed(Routes.lockScreen));
            }
            _unlock(context, ref);
          }
          break;
      }
    }
  }

  Future<void> _unlock(BuildContext context, Ref ref) async {
    final localizations = ref.text;
    var isUnlocked = false;
    while (!isUnlocked) {
      ref.read(appLifecycleProvider.notifier).ignoreNextInactivationCycle();
      isUnlocked = await BiometricsService.instance.authenticate(localizations);
    }
    if (isUnlocked && LockScreen.isShown) {
      if (context.mounted) {
        context.pop();
      }
    }
  }
}
