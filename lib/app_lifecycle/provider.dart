import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Allows to retrieve the current app life cycle
final appLifecycleStateProvider =
    StateProvider<AppLifecycleState>((ref) => AppLifecycleState.resumed);
