import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../localization/extension.dart';
import '../../routes.dart';
import '../../screens/base.dart';
import '../../util/localized_dialog_helper.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = context.text;

    return BasePage(
      title: localizations.settingsTitle,
      content: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlatformListTile(
                  title: Text(localizations.securitySettingsTitle),
                  onTap: () {
                    context.pushNamed(Routes.settingsSecurity);
                  },
                ),
                PlatformListTile(
                  title: Text(localizations.settingsActionAccounts),
                  onTap: () {
                    context.pushNamed(Routes.settingsAccounts);
                  },
                ),
                PlatformListTile(
                  title: Text(localizations.swipeSettingTitle),
                  onTap: () {
                    context.pushNamed(Routes.settingsSwipe);
                  },
                ),
                PlatformListTile(
                  title: Text(localizations.signatureSettingsTitle),
                  onTap: () {
                    context.pushNamed(Routes.settingsSignature);
                  },
                ),
                PlatformListTile(
                  title: Text(localizations.defaultSenderSettingsTitle),
                  onTap: () {
                    context.pushNamed(Routes.settingsDefaultSender);
                  },
                ),
                if (!PlatformInfo.isCupertino)
                  PlatformListTile(
                    title: Text(localizations.settingsActionDesign),
                    onTap: () {
                      context.pushNamed(Routes.settingsDesign);
                    },
                  ),
                PlatformListTile(
                  title: Text(localizations.languageSettingTitle),
                  onTap: () {
                    context.pushNamed(Routes.settingsLanguage);
                  },
                ),
                PlatformListTile(
                  title: Text(localizations.settingsFolders),
                  onTap: () {
                    context.pushNamed(Routes.settingsFolders);
                  },
                ),
                PlatformListTile(
                  title: Text(localizations.settingsReadReceipts),
                  onTap: () {
                    context.pushNamed(Routes.settingsReadReceipts);
                  },
                ),
                PlatformListTile(
                  title: Text(localizations.replySettingsTitle),
                  onTap: () {
                    context.pushNamed(Routes.settingsReplyFormat);
                  },
                ),
                const Divider(),
                PlatformListTile(
                  title: Text(localizations.settingsActionFeedback),
                  onTap: () {
                    context.pushNamed(Routes.settingsFeedback);
                  },
                ),
                PlatformListTile(
                  onTap: () {
                    LocalizedDialogHelper.showAbout(context);
                  },
                  title: Text(localizations.drawerEntryAbout),
                ),
                PlatformListTile(
                  onTap: () {
                    context.pushNamed(Routes.welcome);
                  },
                  title: Text(localizations.settingsActionWelcome),
                ),
                const Divider(),
                PlatformListTile(
                  title: Text(localizations.settingsDevelopment),
                  onTap: () {
                    context.pushNamed(Routes.settingsDevelopment);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
