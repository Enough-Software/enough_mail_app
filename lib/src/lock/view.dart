import 'package:enough_platform_widgets/platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../localization/app_localizations.g.dart';
import '../localization/extension.dart';
import '../screens/base.dart';
import 'service.dart';

/// Displays a lock screen
class LockScreen extends StatefulHookConsumerWidget {
  /// Creates a new [LockScreen]
  const LockScreen({super.key});

  static var _isShown = false;

  /// Is the lock screen currently shown?
  static bool get isShown => _isShown;

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  @override
  void initState() {
    super.initState();
    LockScreen._isShown = true;
  }

  @override
  void dispose() {
    LockScreen._isShown = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = ref.text;

    return BasePage(
      includeDrawer: false,
      title: localizations.lockScreenTitle,
      content: _buildContent(context, localizations),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations localizations) =>
      WillPopScope(
        onWillPop: () => Future.value(false),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(PlatformInfo.isCupertino ? CupertinoIcons.lock : Icons.lock),
              Padding(
                padding: const EdgeInsets.all(32),
                child: Text(localizations.lockScreenIntro),
              ),
              PlatformTextButton(
                child: Text(localizations.lockScreenUnlockAction),
                onPressed: () => _authenticate(context),
              ),
            ],
          ),
        ),
      );

  Future<void> _authenticate(BuildContext context) async {
    final didAuthenticate =
        await BiometricsService.instance.authenticate(ref.text);
    if (didAuthenticate && context.mounted) {
      context.pop();
    }
  }
}
