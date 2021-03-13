import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import 'package:enough_mail_app/events/accounts_changed_event.dart';
import 'package:enough_mail_app/events/app_event_bus.dart';
import 'package:enough_mail_app/models/settings.dart';
import 'package:enough_mail_app/services/alert_service.dart';
import 'package:enough_mail_app/services/mail_service.dart';
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
  StreamSubscription eventsSubscription;

  @override
  void initState() {
    settings = locator<SettingsService>().settings;
    blockExternalImages = settings.blockExternalImages;
    eventsSubscription =
        AppEventBus.eventBus.on<AccountsChangedEvent>().listen((event) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    eventsSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = locator<MailService>().accounts;
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
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(color: Colors.grey, width: 1),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Accounts:'),
                    for (final account in accounts) ...{
                      ListTile(
                        leading: Icon(Icons.account_circle),
                        title: Text(account.name),
                        onTap: () => locator<NavigationService>()
                            .push(Routes.accountEdit, arguments: account),
                      ),
                    },
                    ListTile(
                      leading: Icon(Icons.add),
                      title: Text('Add account'),
                      onTap: () =>
                          locator<NavigationService>().push(Routes.accountAdd),
                    ),
                    if (accounts.length > 1) ...{
                      ElevatedButton(
                        onPressed: () {
                          locator<NavigationService>()
                              .push(Routes.accountsReorder);
                        },
                        child: Text('Reorder accounts'),
                      ),
                    },
                  ],
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    locator<AlertService>().showAbout(context);
                  },
                  child: Text('About Maily'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  child: Text('Suggest a feature'),
                  onPressed: () async {
                    await launcher.launch('https://maily.userecho.com/');
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  child: Text('Report a problem'),
                  onPressed: () async {
                    await launcher.launch('https://maily.userecho.com/');
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  child: Text('Help developing Maily'),
                  onPressed: () async {
                    await launcher.launch(
                        'https://github.com/Enough-Software/enough_mail_app');
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    locator<NavigationService>().push(Routes.welcome);
                  },
                  child: Text('Show welcome'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
