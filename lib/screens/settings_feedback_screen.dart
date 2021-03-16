import 'dart:async';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
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

class SettingsFeedbackScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingsFeedbackScreenState();
  }
}

class _SettingsFeedbackScreenState extends State<SettingsFeedbackScreen> {
  String info;

  @override
  void initState() {
    super.initState();
    loadAppInformation();
  }

  Future<void> loadAppInformation() async {
    final packageInfo = await PackageInfo.fromPlatform();
    var textualInfo =
        'Maily v${packageInfo.version}+${packageInfo.buildNumber}\n'
        'Platform ${Platform.operatingSystem} ${Platform.operatingSystemVersion}\n';
    if (Platform.isAndroid || Platform.isIOS) {
      final deviceInfoPlugin = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        textualInfo +=
            '${androidInfo.manufacturer}/${androidInfo.model} (${androidInfo.device})\nAndroid ${androidInfo.version.release} with API level ${androidInfo.version.sdkInt}';
      } else {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        textualInfo +=
            '${iosInfo.localizedModel}\n${iosInfo.systemName}/${iosInfo.systemVersion}\n';
      }
    }
    setState(() {
      info = textualInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Base.buildAppChrome(
      context,
      title: 'Feedback',
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Thank you for testing Maily!',
                    style: theme.textTheme.subtitle1),
              ),
              if (info == null) ...{
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              } else ...{
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Please provide this information when you report a problem:',
                    style: theme.textTheme.caption,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(info),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: info));
                    },
                  ),
                ),
              },
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
            ],
          ),
        ),
      ),
    );
  }
}
