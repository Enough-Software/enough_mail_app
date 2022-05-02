import 'package:enough_mail_app/widgets/button_text.dart';
import 'package:enough_mail_app/widgets/legalese.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import '../l10n/app_localizations.g.dart';

class LocalizedDialogHelper {
  LocalizedDialogHelper._();

  static void showAbout(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final packageInfo = await PackageInfo.fromPlatform();
    var version = 'v${packageInfo.version}+${packageInfo.buildNumber}';
    showAboutDialog(
      context: context,
      applicationName: 'Maily',
      applicationVersion: version,
      applicationIcon: Icon(CommonPlatformIcons.mailRead),
      applicationLegalese: localizations.aboutApplicationLegalese,
      children: [
        TextButton(
          child: ButtonText(localizations.feedbackActionSuggestFeature),
          onPressed: () async {
            await launcher.launchUrl(Uri.parse('https://maily.userecho.com/'));
          },
        ),
        TextButton(
          child: ButtonText(localizations.feedbackActionReportProblem),
          onPressed: () async {
            await launcher.launchUrl(Uri.parse('https://maily.userecho.com/'));
          },
        ),
        TextButton(
          child: ButtonText(localizations.feedbackActionHelpDeveloping),
          onPressed: () async {
            await launcher.launchUrl(Uri.parse(
                'https://github.com/Enough-Software/enough_mail_app'));
          },
        ),
        const Legalese(),
      ],
    );
  }

  /// Asks the user for confirmation with the given [title] and [query].
  ///
  /// Specify the [action] in case it's different from the title.
  /// Set [isDangerousAction] to `true` for marking the action as dangerous on Cupertino
  static Future<bool?> askForConfirmation(
    BuildContext context, {
    required String title,
    required String query,
    String? action,
    bool isDangerousAction = false,
  }) {
    final localizations = AppLocalizations.of(context)!;
    return DialogHelper.askForConfirmation(
      context,
      title: title,
      query: query,
      action: action,
      isDangerousAction: isDangerousAction,
      cancelActionText: localizations.actionCancel,
    );
  }

  /// Shows a simple text dialog with the given [title] and [text].
  ///
  /// Compare [showWidgetDialog] for parameter details.
  static Future showTextDialog(
    BuildContext context,
    String title,
    String text, {
    List<Widget>? actions,
  }) {
    final localizations = AppLocalizations.of(context)!;
    return DialogHelper.showTextDialog(
      context,
      title,
      text,
      actions: actions,
      okActionText: localizations.actionOk,
      cancelActionText: localizations.actionCancel,
    );
  }

  /// Shows a dialog with the given [content].
  ///
  /// Set the [title] to display the title on top
  /// Specify custom [actions] to provide dialog specific actions, alternatively specify the [defaultActions]. Without [actions] or [defaultActions] only and OK button is shown.
  /// When default actions are used, this method will return `true` when the user pressed `ok` and `false` after selecting `cancel`.
  static Future showWidgetDialog(
    BuildContext context,
    Widget content, {
    String? title,
    List<Widget>? actions,
    DialogActions defaultActions = DialogActions.ok,
  }) {
    final localizations = AppLocalizations.of(context)!;
    return DialogHelper.showWidgetDialog(
      context,
      content,
      title: title,
      actions: actions,
      defaultActions: defaultActions,
      okActionText: localizations.actionOk,
      cancelActionText: localizations.actionCancel,
    );
  }
}
