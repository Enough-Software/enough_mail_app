import 'dart:io';

import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:enough_platform_widgets/platform.dart';
import 'package:flutter/material.dart';
import 'package:enough_mail_app/models/settings.dart';
import 'package:enough_mail_app/util/localized_dialog_helper.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/services/settings_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../locator.dart';
import '../routes.dart';
import 'base.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingsScreenState();
  }
}

class _SettingsScreenState extends State<SettingsScreen> {
  Settings? settings;
  bool? blockExternalImages;

  @override
  void initState() {
    settings = locator<SettingsService>().settings;
    blockExternalImages = settings!.blockExternalImages;
    super.initState();
  }

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
                PlatformCheckboxListTile(
                  value: blockExternalImages,
                  onChanged: (value) async {
                    setState(() {
                      blockExternalImages = value;
                    });
                    settings!.blockExternalImages = value;
                    await locator<SettingsService>().save();
                  },
                  title:
                      Text(localizations.settingsSecurityBlockExternalImages),
                ),
                Divider(),
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
                if (!CommonPlatformIcons.isCupertino) ...{
                  PlatformListTile(
                    title: Text(localizations.settingsActionDesign),
                    onTap: () {
                      locator<NavigationService>().push(Routes.settingsDesign);
                    },
                  ),
                },
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
                Divider(),
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
                Divider(),
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
