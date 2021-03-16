import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import 'package:enough_mail_app/models/settings.dart';
import 'package:enough_mail_app/services/alert_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/services/settings_service.dart';

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
  Settings settings;
  bool blockExternalImages;

  @override
  void initState() {
    settings = locator<SettingsService>().settings;
    blockExternalImages = settings.blockExternalImages;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Base.buildAppChrome(
      context,
      title: 'Settings',
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: blockExternalImages,
                    onChanged: (value) async {
                      setState(() {
                        blockExternalImages = value;
                      });
                      settings.blockExternalImages = value;
                      await locator<SettingsService>().save();
                    },
                  ),
                  Text('Block external images'),
                ],
              ),
              Divider(),
              ListTile(
                title: const Text('Manage accounts'),
                onTap: () {
                  locator<NavigationService>().push(Routes.settingsAccounts);
                },
              ),
              ListTile(
                title: const Text('Design'),
                onTap: () {
                  locator<NavigationService>().push(Routes.settingsDesign);
                },
              ),
              Divider(),
              ListTile(
                title: const Text('Feedback'),
                onTap: () {
                  locator<NavigationService>().push(Routes.settingsFeedback);
                },
              ),
              ListTile(
                onTap: () {
                  locator<AlertService>().showAbout(context);
                },
                title: const Text('About Maily'),
              ),
              ListTile(
                onTap: () {
                  locator<NavigationService>().push(Routes.welcome);
                },
                title: const Text('Show welcome'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
