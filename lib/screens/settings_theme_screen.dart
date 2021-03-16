import 'package:enough_mail_app/models/theme_settings.dart';
import 'package:enough_mail_app/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:enough_mail_app/services/settings_service.dart';

import '../locator.dart';
import 'base.dart';

class SettingsThemeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingsThemeScreenState();
  }
}

class _SettingsThemeScreenState extends State<SettingsThemeScreen> {
  ThemeSettings themeSettings;

  ThemeModeSetting _themeModeSetting;
  set themeModeSetting(ThemeModeSetting value) {
    _themeModeSetting = value;
    themeSettings.themeModeSetting = value;
    locator<ThemeService>().checkForChangedTheme();
    locator<SettingsService>().save();
  }

  MaterialColor primarySwatch;

  @override
  void initState() {
    themeSettings = locator<SettingsService>().settings.themeSettings;
    _themeModeSetting = themeSettings.themeModeSetting;
    primarySwatch = themeSettings.primarySwatch;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final darkThemeStartTime = themeSettings.themeDarkStartTime;
    final darkThemeEndTime = themeSettings.themeDarkEndTime;
    final availableColors = themeSettings.availableColors;
    final theme = Theme.of(context);
    return Base.buildAppChrome(
      context,
      title: 'Design Settings',
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Theme', style: theme.textTheme.subtitle1),
              ListTile(
                title: const Text('Light'),
                leading: Radio<ThemeModeSetting>(
                  value: ThemeModeSetting.light,
                  groupValue: _themeModeSetting,
                  onChanged: (ThemeModeSetting value) {
                    setState(() {
                      themeModeSetting = value;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Dark'),
                leading: Radio<ThemeModeSetting>(
                  value: ThemeModeSetting.dark,
                  groupValue: _themeModeSetting,
                  onChanged: (ThemeModeSetting value) {
                    setState(() {
                      themeModeSetting = value;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('System'),
                leading: Radio<ThemeModeSetting>(
                  value: ThemeModeSetting.system,
                  groupValue: _themeModeSetting,
                  onChanged: (ThemeModeSetting value) {
                    setState(() {
                      themeModeSetting = value;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Custom'),
                leading: Radio<ThemeModeSetting>(
                  value: ThemeModeSetting.custom,
                  groupValue: _themeModeSetting,
                  onChanged: (ThemeModeSetting value) {
                    setState(() {
                      themeModeSetting = value;
                    });
                  },
                ),
              ),
              if (_themeModeSetting == ThemeModeSetting.custom) ...{
                Text('Enable dark theme', style: theme.textTheme.subtitle1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                      child: Text('From ${darkThemeStartTime.format(context)}'),
                      onPressed: () async {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: darkThemeStartTime,
                          initialEntryMode: TimePickerEntryMode.dial,
                        );
                        if (pickedTime != null) {
                          themeSettings.themeDarkStartTime = pickedTime;
                          // indirectly set theme again:
                          themeModeSetting = ThemeModeSetting.custom;
                          setState(() {});
                          await locator<SettingsService>().save();
                        }
                      },
                    ),
                    TextButton(
                      child: Text('until ${darkThemeEndTime.format(context)}'),
                      onPressed: () async {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: darkThemeEndTime,
                          initialEntryMode: TimePickerEntryMode.dial,
                        );
                        if (pickedTime != null) {
                          themeSettings.themeDarkEndTime = pickedTime;
                          // indirectly set theme again:
                          themeModeSetting = ThemeModeSetting.custom;
                          setState(() {});
                          await locator<SettingsService>().save();
                        }
                      },
                    ),
                  ],
                ),
              },
              Divider(),
              Text('Color scheme', style: theme.textTheme.subtitle1),
              GridView.count(
                crossAxisCount: 4,
                primary: false,
                shrinkWrap: true,
                children: [
                  for (final color in availableColors) ...{
                    ListTile(
                        title: CircleAvatar(
                          backgroundColor: color,
                          child: (color == primarySwatch)
                              ? Icon(Icons.check)
                              : null,
                        ),
                        onTap: () async {
                          primarySwatch = color;
                          setState(() {});
                          themeSettings.primarySwatch = color;
                          locator<ThemeService>().checkForChangedTheme();
                          await locator<SettingsService>().save();
                        }),
                  },
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
