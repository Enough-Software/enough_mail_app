import 'package:enough_mail_app/models/theme_settings.dart';
import 'package:enough_mail_app/services/theme_service.dart';
import 'package:enough_mail_app/util/localized_dialog_helper.dart';
import 'package:enough_mail_app/widgets/button_text.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:enough_mail_app/services/settings_service.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../l10n/app_localizations.g.dart';
import '../locator.dart';
import 'base.dart';

class SettingsThemeScreen extends StatefulWidget {
  const SettingsThemeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SettingsThemeScreenState();
  }
}

class _SettingsThemeScreenState extends State<SettingsThemeScreen> {
  late ThemeSettings _themeSettings;

  ThemeModeSetting? _themeModeSetting;
  set themeModeSetting(ThemeModeSetting? value) {
    _themeModeSetting = value;
    _themeSettings = _themeSettings.copyWith(themeModeSetting: value);
    locator<ThemeService>().checkForChangedTheme();
    locator<SettingsService>().save();
  }

  late Color _colorSchemeSeed;

  @override
  void initState() {
    _themeSettings = locator<SettingsService>().settings.themeSettings;
    _themeModeSetting = _themeSettings.themeModeSetting;
    _colorSchemeSeed = _themeSettings.colorSchemeSeed;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final darkThemeStartTime = _themeSettings.themeDarkStartTime;
    final darkThemeEndTime = _themeSettings.themeDarkEndTime;
    final availableColors = ThemeSettings.availableColors;
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
                  if (_themeModeSetting == ThemeModeSetting.custom) ...[
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
                              _themeSettings = _themeSettings.copyWith(
                                  themeDarkStartTime: pickedTime);
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
                              _themeSettings = _themeSettings.copyWith(
                                  themeDarkEndTime: pickedTime);
                              // indirectly set theme again:
                              themeModeSetting = ThemeModeSetting.custom;
                              setState(() {});
                              await locator<SettingsService>().save();
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                  const Divider(),
                  Text(
                    localizations.designSectionColorTitle,
                    style: theme.textTheme.subtitle1,
                  ),
                  GridView.count(
                    crossAxisCount: 4,
                    primary: false,
                    shrinkWrap: true,
                    children: [
                      PlatformListTile(
                        title: CircleAvatar(
                          backgroundColor: _colorSchemeSeed,
                          child: Icon(PlatformInfo.isCupertino
                              ? CupertinoIcons.color_filter
                              : Icons.colorize),
                        ),
                        onTap: () async {
                          Color selectedColor = _colorSchemeSeed;
                          final result =
                              await LocalizedDialogHelper.showWidgetDialog(
                                  context,
                                  ColorPicker(
                                    pickerColor: _colorSchemeSeed,
                                    onColorChanged: (value) =>
                                        selectedColor = value,
                                  ),
                                  defaultActions: DialogActions.okAndCancel);
                          if (result == true) {
                            _colorSchemeSeed = selectedColor;
                            setState(() {});
                            _themeSettings = _themeSettings.copyWith(
                                colorSchemeSeed: selectedColor);
                            locator<ThemeService>().checkForChangedTheme();
                            await locator<SettingsService>().save();
                          }
                        },
                      ),
                      for (final color in availableColors)
                        PlatformListTile(
                          title: CircleAvatar(
                            backgroundColor: color,
                            child: (color == _colorSchemeSeed)
                                ? Icon(CommonPlatformIcons.ok)
                                : null,
                          ),
                          onTap: () async {
                            _colorSchemeSeed = color;
                            setState(() {});
                            _themeSettings =
                                _themeSettings.copyWith(colorSchemeSeed: color);
                            locator<ThemeService>().checkForChangedTheme();
                            await locator<SettingsService>().save();
                          },
                        ),
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
