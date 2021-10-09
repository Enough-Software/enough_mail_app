import 'package:enough_mail_app/locator.dart';
import 'package:enough_mail_app/screens/base.dart';
import 'package:enough_mail_app/services/biometrics_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_platform_widgets/platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LockScreen extends StatelessWidget {
  const LockScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Base.buildAppChrome(
      context,
      includeDrawer: false,
      title: localizations.lockScreenTitle,
      content: _buildContent(context, localizations),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations localizations) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(PlatformInfo.isCupertino ? CupertinoIcons.lock : Icons.lock),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(localizations.lockScreenIntro),
            ),
            PlatformButton(
              child: PlatformText(localizations.lockScreenUnlockAction),
              onPressed: () => _authenticate(context),
            )
          ],
        ),
      ),
    );
  }

  void _authenticate(BuildContext context) async {
    final didAuthencate = await locator<BiometricsService>().authenticate();
    if (didAuthencate) {
      locator<NavigationService>().pop();
    }
  }
}
