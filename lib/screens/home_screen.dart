import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../account/provider.dart';
import '../settings/provider.dart';
import 'screens.dart';

/// Screen shown after accounts have been loaded:
/// Either the welcome content or the first account's inbox is shown
class HomeScreen extends ConsumerWidget {
  /// Creates a [HomeScreen]
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(allAccountsProvider);
    if (accounts.isEmpty) {
      return const WelcomeScreen();
    }
    final enableBiometricLock = ref.read(settingsProvider).enableBiometricLock;
    if (enableBiometricLock) {
      return const LockScreen();
    }

    return MailScreen(
      account: accounts.first,
    );
  }
}
