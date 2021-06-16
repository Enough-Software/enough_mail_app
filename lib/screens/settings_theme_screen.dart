import 'package:enough_mail_app/models/theme_settings.dart';
import 'package:enough_mail_app/services/theme_service.dart';
import 'package:enough_mail_app/widgets/button_text.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:enough_mail_app/services/settings_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../locator.dart';
import 'base.dart';

class SettingsThemeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingsThemeScreenState();
  }
}

class _SettingsThemeScreenState extends State<SettingsThemeScreen> {
  late ThemeSettings themeSettings;

  ThemeModeSetting? _themeModeSetting;
  set themeModeSetting(ThemeModeSetting? value) {
    _themeModeSetting = value;
    themeSettings.themeModeSetting = value;
    locator<ThemeService>().checkForChangedTheme();
    locator<SettingsService>().save();
  }

  MaterialColor? primarySwatch;

  @override
  void initState() {
    themeSettings = locator<SettingsService>().settings.themeSettings;
    _themeModeSetting = themeSettings.themeModeSetting;
    primarySwatch = themeSettings.primarySwatch;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final darkThemeStartTime = themeSettings.themeDarkStartTime;
    final darkThemeEndTime = themeSettings.themeDarkEndTime;
    final availableColors = themeSettings.availableColors;
    final theme = Theme.of(context);
    return Base.buildAppChrome(
      context,
      title: localizations.designTitle,
      content: SingleChildScrollView(
        child: Material(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(localizations.designSectionThemeTitle,
                      style: theme.textTheme.subtitle1),
                  PlatformRadioListTile<ThemeModeSetting>(
                    title: Text(localizations.designThemeOptionLight),
                    value: ThemeModeSetting.light,
                    groupValue: _themeModeSetting,
                    onChanged: (ThemeModeSetting? value) {
                      setState(() {
                        themeModeSetting = value;
                      });
                    },
                  ),
                  PlatformRadioListTile<ThemeModeSetting>(
                    title: Text(localizations.designThemeOptionDark),
                    value: ThemeModeSetting.dark,
                    groupValue: _themeModeSetting,
                    onChanged: (ThemeModeSetting? value) {
                      setState(() {
                        themeModeSetting = value;
                      });
                    },
                  ),
                  PlatformRadioListTile<ThemeModeSetting>(
                    title: Text(localizations.designThemeOptionSystem),
                    value: ThemeModeSetting.system,
                    groupValue: _themeModeSetting,
                    onChanged: (ThemeModeSetting? value) {
                      setState(() {
                        themeModeSetting = value;
                      });
                    },
                  ),
                  PlatformRadioListTile<ThemeModeSetting>(
                    title: Text(localizations.designThemeOptionCustom),
                    value: ThemeModeSetting.custom,
                    groupValue: _themeModeSetting,
                    onChanged: (ThemeModeSetting? value) {
                      setState(() {
                        themeModeSetting = value;
                      });
                    },
                  ),
                  if (_themeModeSetting == ThemeModeSetting.custom) ...{
                    Text(localizations.designSectionCustomTitle,
                        style: theme.textTheme.subtitle1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        PlatformTextButton(
                          child: ButtonText(
                              localizations.designThemeCustomStart(
                                  darkThemeStartTime.format(context))),
                          onPressed: () async {
                            final pickedTime = await showPlatformTimePicker(
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
                        PlatformTextButton(
                          child: ButtonText(localizations.designThemeCustomEnd(
                              darkThemeEndTime.format(context))),
                          onPressed: () async {
                            final pickedTime = await showPlatformTimePicker(
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
                  Text(localizations.designSectionColorTitle,
                      style: theme.textTheme.subtitle1),
                  GridView.count(
                    crossAxisCount: 4,
                    primary: false,
                    shrinkWrap: true,
                    children: [
                      for (final color in availableColors) ...{
                        PlatformListTile(
                            title: CircleAvatar(
                              backgroundColor: color,
                              child: (color == primarySwatch)
                                  ? Icon(Icons.check)
                                  : null,
                            ),
                            onTap: () async {
                              primarySwatch = color as MaterialColor?;
                              setState(() {});
                              themeSettings.primarySwatch =
                                  color as MaterialColor;
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
        ),
      ),
    );
  }
}
