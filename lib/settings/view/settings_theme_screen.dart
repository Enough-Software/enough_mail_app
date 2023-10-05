import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../l10n/extension.dart';
import '../../locator.dart';
import '../../models/theme_settings.dart';
import '../../screens/base.dart';
import '../../services/theme_service.dart';
import '../../util/localized_dialog_helper.dart';
import '../../widgets/button_text.dart';
import '../provider.dart';

class SettingsThemeScreen extends HookConsumerWidget {
  const SettingsThemeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = context.text;
    final theme = Theme.of(context);

    final themeSettings = ref.watch(
      settingsProvider.select(
        (value) => value.themeSettings,
      ),
    );
    final darkThemeStartTime = themeSettings.themeDarkStartTime;
    final darkThemeEndTime = themeSettings.themeDarkEndTime;
    final availableColors = ThemeSettings.availableColors;

    void updateThemeSettings(ThemeSettings value) {
      final settings = ref.read(settingsProvider);
      ref.read(settingsProvider.notifier).update(
            settings.copyWith(
              themeSettings: value,
            ),
          );
      locator<ThemeService>().checkForChangedTheme();
    }

    void updateThemeModeSettings(ThemeModeSetting? value) =>
        updateThemeSettings(
          themeSettings.copyWith(themeModeSetting: value),
        );

    return Base.buildAppChrome(
      context,
      title: localizations.designTitle,
      content: SingleChildScrollView(
        child: Material(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(localizations.designSectionThemeTitle,
                      style: theme.textTheme.titleMedium),
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
                          child: ButtonText(
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
                          child: ButtonText(localizations.designThemeCustomEnd(
                              darkThemeEndTime.format(context))),
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
                          Color selectedColor = themeSettings.colorSchemeSeed;
                          final result =
                              await LocalizedDialogHelper.showWidgetDialog(
                            context,
                            ColorPicker(
                              pickerColor: themeSettings.colorSchemeSeed,
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
