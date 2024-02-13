import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../localization/extension.dart';
import '../../screens/base.dart';
import '../../util/localized_dialog_helper.dart';
import '../provider.dart';
import '../theme/model.dart';
import '../theme/provider.dart';

class SettingsDesignScreen extends HookConsumerWidget {
  const SettingsDesignScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = ref.text;
    final theme = Theme.of(context);

    final themeSettings = ref.watch(
      settingsProvider.select(
        (value) => value.themeSettings,
      ),
    );
    final darkThemeStartTime = themeSettings.themeDarkStartTime;
    final darkThemeEndTime = themeSettings.themeDarkEndTime;
    final availableColors = ThemeSettings.availableColors;
    final defaultColor = ref.watch(defaultColorSeedProvider);

    void updateThemeSettings(ThemeSettings value) {
      final settings = ref.read(settingsProvider);
      ref.read(settingsProvider.notifier).update(
            settings.copyWith(
              themeSettings: value,
            ),
          );
    }

    void updateThemeModeSettings(ThemeModeSetting? value) =>
        updateThemeSettings(
          themeSettings.copyWith(themeModeSetting: value),
        );

    return BasePage(
      title: localizations.designTitle,
      content: SingleChildScrollView(
        child: Material(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.designSectionThemeTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                  PlatformRadioListTile<ThemeModeSetting>(
                    title: Text(localizations.designThemeOptionLight),
                    value: ThemeModeSetting.light,
                    groupValue: themeSettings.themeModeSetting,
                    onChanged: updateThemeModeSettings,
                  ),
                  PlatformRadioListTile<ThemeModeSetting>(
                    title: Text(localizations.designThemeOptionDark),
                    value: ThemeModeSetting.dark,
                    groupValue: themeSettings.themeModeSetting,
                    onChanged: updateThemeModeSettings,
                  ),
                  PlatformRadioListTile<ThemeModeSetting>(
                    title: Text(localizations.designThemeOptionSystem),
                    value: ThemeModeSetting.system,
                    groupValue: themeSettings.themeModeSetting,
                    onChanged: updateThemeModeSettings,
                  ),
                  PlatformRadioListTile<ThemeModeSetting>(
                    title: Text(localizations.designThemeOptionCustom),
                    value: ThemeModeSetting.custom,
                    groupValue: themeSettings.themeModeSetting,
                    onChanged: updateThemeModeSettings,
                  ),
                  if (themeSettings.themeModeSetting ==
                      ThemeModeSetting.custom) ...[
                    Text(
                      localizations.designSectionCustomTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                    Row(
                      children: [
                        PlatformTextButton(
                          child: Text(
                            localizations.designThemeCustomStart(
                              darkThemeStartTime.format(context),
                            ),
                          ),
                          onPressed: () async {
                            final pickedTime = await showPlatformTimePicker(
                              context: context,
                              initialTime: darkThemeStartTime,
                            );
                            if (pickedTime != null) {
                              updateThemeSettings(
                                themeSettings.copyWith(
                                  themeDarkStartTime: pickedTime,
                                  themeModeSetting: ThemeModeSetting.custom,
                                ),
                              );
                            }
                          },
                        ),
                        PlatformTextButton(
                          child: Text(
                            localizations.designThemeCustomEnd(
                              darkThemeEndTime.format(context),
                            ),
                          ),
                          onPressed: () async {
                            final pickedTime = await showPlatformTimePicker(
                              context: context,
                              initialTime: darkThemeEndTime,
                            );
                            if (pickedTime != null) {
                              updateThemeSettings(
                                themeSettings.copyWith(
                                  themeDarkEndTime: pickedTime,
                                  themeModeSetting: ThemeModeSetting.custom,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                  const Divider(),
                  Text(
                    localizations.designSectionColorTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                  GridView.count(
                    crossAxisCount: 4,
                    primary: false,
                    shrinkWrap: true,
                    children: [
                      PlatformListTile(
                        title: CircleAvatar(
                          backgroundColor: themeSettings.colorSchemeSeed,
                          child: Icon(PlatformInfo.isCupertino
                              ? CupertinoIcons.color_filter
                              : Icons.colorize),
                        ),
                        onTap: () async {
                          Color selectedColor =
                              themeSettings.colorSchemeSeed ?? defaultColor;
                          final result =
                              await LocalizedDialogHelper.showWidgetDialog(
                            ref,
                            ColorPicker(
                              pickerColor:
                                  themeSettings.colorSchemeSeed ?? defaultColor,
                              onColorChanged: (value) => selectedColor = value,
                            ),
                            defaultActions: DialogActions.okAndCancel,
                          );
                          if (result == true) {
                            updateThemeSettings(
                              themeSettings.copyWith(
                                colorSchemeSeed: selectedColor,
                              ),
                            );
                          }
                        },
                      ),
                      for (final color in availableColors)
                        PlatformListTile(
                          title: CircleAvatar(
                            backgroundColor: color,
                            child: (color == themeSettings.colorSchemeSeed)
                                ? Icon(CommonPlatformIcons.ok)
                                : null,
                          ),
                          onTap: () {
                            updateThemeSettings(
                              themeSettings.copyWith(
                                colorSchemeSeed: color,
                              ),
                            );
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
