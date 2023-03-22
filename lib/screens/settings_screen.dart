import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:enough_mail_app/util/localized_dialog_helper.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import '../l10n/app_localizations.g.dart';
import '../locator.dart';
import '../routes.dart';
import 'base.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Base.buildAppChrome(
      context,
      title: localizations.settingsTitle,
      content: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlatformListTile(
                  title: Text(localizations.securitySettingsTitle),
                  onTap: () {
                    locator<NavigationService>().push(Routes.settingsSecurity);
                  },
                ),
                PlatformListTile(
                  title: Text(localizations.settingsActionAccounts),
                  onTap: () {
                    locator<NavigationService>().push(Routes.settingsAccounts);
                  },
                ),
                PlatformListTile(
                  title: Text(localizations.swipeSettingTitle),
                  onTap: () {
                    locator<NavigationService>().push(Routes.settingsSwipe);
                  },
                ),
                PlatformListTile(
                  title: Text(localizations.signatureSettingsTitle),
                  onTap: () {
                    locator<NavigationService>()
                        .push(Routes.settingsSignature, containsModals: true);
                  },
                ),
                PlatformListTile(
                  title: Text(localizations.defaultSenderSettingsTitle),
                  onTap: () {
                    locator<NavigationService>()
                        .push(Routes.settingsDefaultSender);
                  },
                ),
                if (!PlatformInfo.isCupertino)
                  PlatformListTile(
                    title: Text(localizations.settingsActionDesign),
                    onTap: () {
                      locator<NavigationService>().push(Routes.settingsDesign);
                    },
                  ),
                PlatformListTile(
                  title: Text(localizations.languageSettingTitle),
                  onTap: () {
                    locator<NavigationService>().push(Routes.settingsLanguage);
                  },
                ),
                PlatformListTile(
                  title: Text(localizations.settingsFolders),
                  onTap: () {
                    locator<NavigationService>().push(Routes.settingsFolders);
                  },
                ),
                PlatformListTile(
                  title: Text(localizations.settingsReadReceipts),
                  onTap: () {
                    locator<NavigationService>()
                        .push(Routes.settingsReadReceipts);
                  },
                ),
                PlatformListTile(
                  title: Text(localizations.replySettingsTitle),
                  onTap: () {
                    locator<NavigationService>()
                        .push(Routes.settingsReplyFormat);
                  },
                ),
                const Divider(),
                PlatformListTile(
                  title: Text(localizations.settingsActionFeedback),
                  onTap: () {
                    locator<NavigationService>().push(Routes.settingsFeedback);
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
                    locator<NavigationService>().push(Routes.welcome);
                  },
                  title: Text(localizations.settingsActionWelcome),
                ),
                const Divider(),
                PlatformListTile(
                  title: Text(localizations.settingsDevelopment),
                  onTap: () {
                    locator<NavigationService>()
                        .push(Routes.settingsDevelopment);
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
