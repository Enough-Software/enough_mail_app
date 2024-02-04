import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../localization/extension.dart';
import '../../routes/routes.dart';
import '../../util/localized_dialog_helper.dart';
import 'model.dart';

part 'provider.g.dart';

@Riverpod(keepAlive: true)
class SettingsUiElements extends _$SettingsUiElements {
  @override
  void build() {}

  /// Generates the shown setting entries
  List<UiSettingsElement> generate(
    BuildContext context,
  ) =>
      buildStandardElements(context);

  static List<UiSettingsElement> buildStandardElements(BuildContext context) {
    final text = context.text;

    return [
      UiSettingsElement(
        type: UiSettingsType.security,
        title: text.securitySettingsTitle,
        onTap: () => context.pushNamed(Routes.settingsSecurity),
      ),
      UiSettingsElement(
        type: UiSettingsType.accounts,
        title: text.settingsActionAccounts,
        onTap: () => context.pushNamed(Routes.settingsAccounts),
      ),
      UiSettingsElement(
        type: UiSettingsType.swipe,
        title: text.swipeSettingTitle,
        onTap: () => context.pushNamed(Routes.settingsSwipe),
      ),
      UiSettingsElement(
        type: UiSettingsType.signature,
        title: text.signatureSettingsTitle,
        onTap: () => context.pushNamed(Routes.settingsSignature),
      ),
      UiSettingsElement(
        type: UiSettingsType.defaultSender,
        title: text.defaultSenderSettingsTitle,
        onTap: () => context.pushNamed(Routes.settingsDefaultSender),
      ),
      UiSettingsElement(
        type: UiSettingsType.design,
        title: text.settingsActionDesign,
        onTap: () => context.pushNamed(Routes.settingsDesign),
      ),
      UiSettingsElement(
        type: UiSettingsType.language,
        title: text.languageSettingTitle,
        onTap: () => context.pushNamed(Routes.settingsLanguage),
      ),
      UiSettingsElement(
        type: UiSettingsType.folders,
        title: text.settingsFolders,
        onTap: () => context.pushNamed(Routes.settingsFolders),
      ),
      UiSettingsElement(
        type: UiSettingsType.readReceipts,
        title: text.settingsReadReceipts,
        onTap: () => context.pushNamed(Routes.settingsReadReceipts),
      ),
      UiSettingsElement(
        type: UiSettingsType.reply,
        title: text.replySettingsTitle,
        onTap: () => context.pushNamed(Routes.settingsReplyFormat),
      ),
      UiSettingsElement.divider(),
      UiSettingsElement(
        type: UiSettingsType.feedback,
        title: text.settingsActionFeedback,
        onTap: () => context.pushNamed(Routes.settingsFeedback),
      ),
      UiSettingsElement(
        type: UiSettingsType.about,
        title: text.drawerEntryAbout,
        onTap: () => LocalizedDialogHelper.showAbout(context),
      ),
      UiSettingsElement(
        type: UiSettingsType.welcome,
        title: text.settingsActionWelcome,
        onTap: () => context.pushNamed(Routes.welcome),
      ),
    ];
  }
}
