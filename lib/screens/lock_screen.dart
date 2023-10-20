import 'package:enough_platform_widgets/platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../localization/app_localizations.g.dart';
import '../localization/extension.dart';
import '../locator.dart';
import '../services/biometrics_service.dart';
import 'base.dart';

class LockScreen extends StatelessWidget {
  const LockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = context.text;

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
                child: PlatformText(localizations.lockScreenUnlockAction),
                onPressed: () => _authenticate(context),
              ),
            ],
          ),
        ),
      );

  Future<void> _authenticate(BuildContext context) async {
    final didAuthenticate = await locator<BiometricsService>().authenticate();
    if (didAuthenticate && context.mounted) {
      context.pop();
    }
  }
}
