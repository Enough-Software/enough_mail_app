import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum DialogActions { ok, cancel, okAndCancel }

class DialogHelper {
  static Future<bool> askForConfirmation(
    BuildContext context, {
    @required String title,
    @required String query,
    String action,
    bool isDangerousAction,
  }) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    var actionButtonStyle = theme.textButtonTheme.style;
    var actionTextStyle = theme.textTheme.button;
    if (isDangerousAction == true) {
      actionButtonStyle = TextButton.styleFrom(
          backgroundColor: Colors.red, onSurface: Colors.white);
      actionTextStyle = actionTextStyle.copyWith(color: Colors.white);
    }

    return showDialog<bool>(
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(query),
        actions: [
          TextButton(
            child: Text(localizations.actionCancel),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text(action ?? title, style: actionTextStyle),
            onPressed: () => Navigator.of(context).pop(true),
            style: actionButtonStyle,
          ),
        ],
      ),
      context: context,
    );
  }

  static Future showTextDialog(BuildContext context, String title, String text,
      {List<Widget> actions}) {
    return showWidgetDialog(context, title, Text(text), actions: actions);
  }

  static Future showWidgetDialog(
      BuildContext context, String title, Widget content,
      {List<Widget> actions, DialogActions defaultActions = DialogActions.ok}) {
    final localizations = AppLocalizations.of(context);
    actions ??= [
      if (defaultActions == DialogActions.cancel ||
          defaultActions == DialogActions.okAndCancel) ...{
        TextButton(
          child: Text(localizations.actionCancel),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      },
      if (defaultActions == DialogActions.ok ||
          defaultActions == DialogActions.okAndCancel) ...{
        TextButton(
          child: Text(localizations.actionOk),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      },
    ];

    return showDialog(
      builder: (context) => AlertDialog(
        title: title == null ? null : Text(title),
        content: content,
        actions: actions,
      ),
      context: context,
    );
  }

  static void showAbout(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    final packageInfo = await PackageInfo.fromPlatform();
    var version = 'v${packageInfo.version}+${packageInfo.buildNumber}';
    showAboutDialog(
      context: context,
      applicationName: 'Maily',
      applicationVersion: version,
      applicationIcon: Icon(Icons.email),
      applicationLegalese: localizations.aboutApplicationLegalese,
      children: [
        ElevatedButton(
          child: Text(localizations.feedbackActionSuggestFeature),
          onPressed: () async {
            await launcher.launch('https://maily.userecho.com/');
          },
        ),
        ElevatedButton(
          child: Text(localizations.feedbackActionReportProblem),
          onPressed: () async {
            await launcher.launch('https://maily.userecho.com/');
          },
        ),
        ElevatedButton(
          child: Text(localizations.feedbackActionHelpDeveloping),
          onPressed: () async {
            await launcher
                .launch('https://github.com/Enough-Software/enough_mail_app');
          },
        ),
      ],
    );
  }
}
