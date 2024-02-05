import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../enough_mail_app.dart';

part 'provider.g.dart';

@Riverpod(keepAlive: true)
class SettingsUiElements extends _$SettingsUiElements {
  @override
  void build() {}

  /// Generates the shown setting entries
  List<UiSettingsElement> generate(
    WidgetRef ref,
  ) =>
      buildStandardElements(ref);

  static List<UiSettingsElement> buildStandardElements(
    WidgetRef ref,
  ) {
    final text = ref.text;
    final context = ref.context;

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
        onTap: () => LocalizedDialogHelper.showAbout(ref),
      ),
      UiSettingsElement(
        type: UiSettingsType.welcome,
        title: text.settingsActionWelcome,
        onTap: () => context.pushNamed(Routes.welcome),
      ),
    ];
  }
}
