import 'package:enough_platform_widgets/platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.g.dart';
import '../l10n/extension.dart';
import '../locator.dart';
import '../services/biometrics_service.dart';
import '../services/navigation_service.dart';
import 'base.dart';

class LockScreen extends StatelessWidget {
  const LockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = context.text;

    return Base.buildAppChrome(
      context,
      includeDrawer: false,
      title: localizations.lockScreenTitle,
      content: _buildContent(context, localizations),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations localizations) => WillPopScope(
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
              child: PlatformText(localizations.lockScreenUnlockAction),
              onPressed: () => _authenticate(context),
            )
          ],
        ),
      ),
    );

  Future<void> _authenticate(BuildContext context) async {
    final didAuthencate = await locator<BiometricsService>().authenticate();
    if (didAuthencate) {
      locator<NavigationService>().pop();
    }
  }
}
