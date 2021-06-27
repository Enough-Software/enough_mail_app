import 'package:enough_mail_app/widgets/button_text.dart';
// import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AboutHelper {
  AboutHelper._();

  static void showAbout(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final packageInfo = await PackageInfo.fromPlatform();
    var version = 'v${packageInfo.version}+${packageInfo.buildNumber}';
    showAboutDialog(
      context: context,
      applicationName: 'Maily',
      applicationVersion: version,
      applicationIcon: Icon(Icons.email),
      applicationLegalese: localizations.aboutApplicationLegalese,
      children: [
        TextButton(
          child: ButtonText(localizations.feedbackActionSuggestFeature),
          onPressed: () async {
            await launcher.launch('https://maily.userecho.com/');
          },
        ),
        TextButton(
          child: ButtonText(localizations.feedbackActionReportProblem),
          onPressed: () async {
            await launcher.launch('https://maily.userecho.com/');
          },
        ),
        TextButton(
          child: ButtonText(localizations.feedbackActionHelpDeveloping),
          onPressed: () async {
            await launcher
                .launch('https://github.com/Enough-Software/enough_mail_app');
          },
        ),
      ],
    );
  }
}
