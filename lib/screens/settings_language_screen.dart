import 'package:collection/collection.dart' show IterableExtension;
import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_mail_app/services/settings_service.dart';
import 'package:enough_mail_app/widgets/button_text.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../locator.dart';
import 'base.dart';

class SettingsLanguageScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingsLanguageScreenState();
  }
}

class _SettingsLanguageScreenState extends State<SettingsLanguageScreen> {
  _Language? selectedLanguage;
  late List<_Language> languages;
  AppLocalizations? selectedLocalizations;
  bool systemSettingApplied = false;

  @override
  void initState() {
    //TODO display names should be localized in the arb files
    final displayNames = {
      'de': 'deutsch',
      'en': 'English',
    };
    final available = AppLocalizations.supportedLocales
        .map(
            (locale) => _Language(locale, displayNames[locale.toLanguageTag()]))
        .toList();
    final systemLanguage = _Language(
        null, locator<I18nService>().localizations!.designThemeOptionSystem);
    languages = [systemLanguage, ...available];
    final languageTag = locator<SettingsService>().settings.languageTag;
    if (languageTag != null) {
      selectedLanguage = available
          .firstWhereOrNull((l) => l.locale!.toLanguageTag() == languageTag);
    } else {
      selectedLanguage = systemLanguage;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    return Base.buildAppChrome(
      context,
      title: localizations.languageSettingTitle,
      content: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(localizations.languageSettingLabel,
                    style: theme.textTheme.caption),
                PlatformDropdownButton<_Language>(
                  value: selectedLanguage,
                  onChanged: (value) async {
                    if (value!.locale == null) {
                      setState(() {
                        selectedLanguage = value;
                        this.selectedLocalizations = null;
                        systemSettingApplied = true;
                      });
                      locator<SettingsService>().settings.languageTag = null;
                      await locator<SettingsService>().save();
                      return;
                    }
                    final selectedLocalizations =
                        await AppLocalizations.delegate.load(value.locale!);
                    final confirmed = await DialogHelper.showTextDialog(
                        context,
                        selectedLocalizations.languageSettingConfirmationTitle,
                        selectedLocalizations.languageSettingConfirmationQuery,
                        actions: [
                          PlatformTextButton(
                            child:
                                ButtonText(selectedLocalizations.actionCancel),
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                          PlatformTextButton(
                            child: ButtonText(selectedLocalizations.actionOk),
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                        ]);
                    if (confirmed) {
                      setState(() {
                        selectedLanguage = value;
                        this.selectedLocalizations = selectedLocalizations;
                        systemSettingApplied = false;
                      });
                      locator<SettingsService>().settings.languageTag =
                          selectedLanguage?.locale?.toLanguageTag();
                      await locator<SettingsService>().save();
                    }
                  },
                  selectedItemBuilder: (context) => languages
                      .map((language) => Text(language.displayName!))
                      .toList(),
                  items: languages
                      .map((language) => DropdownMenuItem(
                          value: language, child: Text(language.displayName!)))
                      .toList(),
                ),
                if (selectedLocalizations != null) ...{
                  Text(selectedLocalizations!.languageSetInfo,
                      style: theme.textTheme.subtitle1),
                } else if (systemSettingApplied) ...{
                  Text(localizations.languageSystemSetInfo,
                      style: theme.textTheme.subtitle1),
                },
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Language {
  final Locale? locale;
  final String? displayName;
  _Language(this.locale, this.displayName);
}
