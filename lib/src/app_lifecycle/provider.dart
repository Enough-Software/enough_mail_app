import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../logger.dart';

part 'provider.g.dart';

/// Allows to retrieve the current (raw) app life cycle
final rawAppLifecycleStateProvider =
    StateProvider<AppLifecycleState>((ref) => AppLifecycleState.resumed);

/// Allows to retrieve the current (filtered) app life cycle
@Riverpod(keepAlive: true)
class AppLifecycle extends _$AppLifecycle {
  /// Should the next resume event be ignored?
  var _ignoreNextInActivationCycle = false;
  var _ignoreTimestamp = DateTime.now();
  var _ignoreDuration = const Duration(seconds: 30);

  @override
  AppLifecycleState build() {
    final state = ref.watch(rawAppLifecycleStateProvider);
    if (_ignoreNextInActivationCycle) {
      final difference = DateTime.now().difference(_ignoreTimestamp);
      if (difference > _ignoreDuration) {
        _ignoreNextInActivationCycle = false;
        logger.d('too long pause for ignoring next inactivation cycle');

        return state;
      }

      if (state == AppLifecycleState.resumed) {
        logger.d('ignored inactivation cycle completed');
        _ignoreNextInActivationCycle = false;
      }

      return AppLifecycleState.resumed;
    }
    logger.d('emitting non-ignored state: $state');

    return state;
  }

  /// Ignores the next inactivation -> resume event
  void ignoreNextInactivationCycle({
    Duration timeout = const Duration(seconds: 30),
  }) {
    _ignoreNextInActivationCycle = true;
    _ignoreTimestamp = DateTime.now();
    _ignoreDuration = timeout;
  }
}

/// Easy access to be notified when the app is resumed
@Riverpod(keepAlive: true)
bool appIsResumed(AppIsResumedRef ref) => ref.watch(
      appLifecycleProvider
          .select((value) => value == AppLifecycleState.resumed),
    );

/// Easy access to be notified when the app is put to the background
@Riverpod(keepAlive: true)
bool appIsInactivated(AppIsInactivatedRef ref) => ref.watch(
      appLifecycleProvider
          .select((value) => value == AppLifecycleState.inactive),
    );
