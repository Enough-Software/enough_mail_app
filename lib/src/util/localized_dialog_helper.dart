import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import '../localization/extension.dart';
import '../widgets/legalese.dart';

/// Helps to display localized dialogs
class LocalizedDialogHelper {
  LocalizedDialogHelper._();

  /// Shows the about dialog
  static Future<void> showAbout(WidgetRef ref) async {
    final localizations = ref.text;
    final packageInfo = await PackageInfo.fromPlatform();
    final version = 'v${packageInfo.version}+${packageInfo.buildNumber}';
    final context = ref.context;
    if (context.mounted) {
      showAboutDialog(
        context: context,
        applicationName: 'Maily',
        applicationVersion: version,
        applicationIcon: Icon(CommonPlatformIcons.mailRead),
        applicationLegalese: localizations.aboutApplicationLegalese,
        children: [
          TextButton(
            child: Text(localizations.feedbackActionSuggestFeature),
            onPressed: () async {
              await launcher
                  .launchUrl(Uri.parse('https://maily.userecho.com/'));
            },
          ),
          TextButton(
            child: Text(localizations.feedbackActionReportProblem),
            onPressed: () async {
              await launcher
                  .launchUrl(Uri.parse('https://maily.userecho.com/'));
            },
          ),
          TextButton(
            child: Text(localizations.feedbackActionHelpDeveloping),
            onPressed: () async {
              await launcher.launchUrl(Uri.parse(
                'https://github.com/Enough-Software/enough_mail_app',
              ));
            },
          ),
          const Legalese(),
        ],
      );
    }
  }

  /// Asks the user for confirmation with the given [title] and [query].
  ///
  /// Specify the [action] in case it's different from the title.
  /// Set [isDangerousAction] to `true` for marking the action as
  /// dangerous on Cupertino
  static Future<bool?> askForConfirmation(
    WidgetRef ref, {
    required String title,
    required String query,
    String? action,
    bool isDangerousAction = false,
  }) {
    final localizations = ref.text;

    return DialogHelper.askForConfirmation(
      ref.context,
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
  static Future<T?> showTextDialog<T>(
    WidgetRef ref,
    String title,
    String text, {
    List<Widget>? actions,
  }) {
    final localizations = ref.text;

    return DialogHelper.showTextDialog<T>(
      ref.context,
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
  ///
  /// Specify custom [actions] to provide dialog specific actions, alternatively
  ///
  /// specify the [defaultActions]. Without [actions] or [defaultActions] only
  /// and OK button is shown.
  ///
  /// When default actions are used, this method will return `true` when the
  /// user pressed `ok` and `false` after selecting `cancel`.
  static Future<T?> showWidgetDialog<T>(
    WidgetRef ref,
    Widget content, {
    String? title,
    List<Widget>? actions,
    DialogActions defaultActions = DialogActions.ok,
  }) {
    final localizations = ref.text;

    return DialogHelper.showWidgetDialog<T>(
      ref.context,
      content,
      title: title,
      actions: actions,
      defaultActions: defaultActions,
      okActionText: localizations.actionOk,
      cancelActionText: localizations.actionCancel,
    );
  }
}
