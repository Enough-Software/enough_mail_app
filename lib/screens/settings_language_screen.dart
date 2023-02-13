import 'package:collection/collection.dart' show IterableExtension;
import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_mail_app/services/settings_service.dart';
import 'package:enough_mail_app/util/localized_dialog_helper.dart';
import 'package:enough_mail_app/widgets/button_text.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.g.dart';
import '../locator.dart';
import 'base.dart';

class SettingsLanguageScreen extends StatefulWidget {
  const SettingsLanguageScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SettingsLanguageScreenState();
  }
}

class _SettingsLanguageScreenState extends State<SettingsLanguageScreen> {
  _Language? _selectedLanguage;
  late List<_Language> _languages;
  AppLocalizations? _selectedLocalizations;
  bool _systemSettingApplied = false;

  @override
  void initState() {
    final displayNames = {
      'de': 'deutsch',
      'en': 'English',
    };
    final available = AppLocalizations.supportedLocales
        .map(
            (locale) => _Language(locale, displayNames[locale.toLanguageTag()]))
        .toList();
    final systemLanguage = _Language(
        null, locator<I18nService>().localizations.designThemeOptionSystem);
    _languages = [systemLanguage, ...available];
    final languageTag = locator<SettingsService>().settings.languageTag;
    if (languageTag != null) {
      _selectedLanguage = available
          .firstWhereOrNull((l) => l.locale!.toLanguageTag() == languageTag);
    } else {
      _selectedLanguage = systemLanguage;
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
                  value: _selectedLanguage,
                  onChanged: (value) async {
                    if (value!.locale == null) {
                      setState(() {
                        _selectedLanguage = value;
                        _selectedLocalizations = null;
                        _systemSettingApplied = true;
                      });
                      final service = locator<SettingsService>();
                      service.settings = service.settings.removeLanguageTag();
                      await service.save();
                      return;
                    }
                    final selectedLocalizations =
                        await AppLocalizations.delegate.load(value.locale!);
                    if (mounted) {
                      final confirmed =
                          await LocalizedDialogHelper.showTextDialog(
                              context,
                              selectedLocalizations
                                  .languageSettingConfirmationTitle,
                              selectedLocalizations
                                  .languageSettingConfirmationQuery,
                              actions: [
                            PlatformTextButton(
                              child: ButtonText(
                                  selectedLocalizations.actionCancel),
                              onPressed: () => Navigator.of(context).pop(false),
                            ),
                            PlatformTextButton(
                              child: ButtonText(selectedLocalizations.actionOk),
                              onPressed: () => Navigator.of(context).pop(true),
                            ),
                          ]);
                      if (confirmed) {
                        setState(() {
                          _selectedLanguage = value;
                          _selectedLocalizations = selectedLocalizations;
                          _systemSettingApplied = false;
                        });
                        final service = locator<SettingsService>();
                        service.settings = service.settings.copyWith(
                          languageTag:
                              _selectedLanguage?.locale?.toLanguageTag(),
                        );
                        await service.save();
                      }
                    }
                  },
                  selectedItemBuilder: (context) => _languages
                      .map((language) => Text(language.displayName!))
                      .toList(),
                  items: _languages
                      .map((language) => DropdownMenuItem(
                          value: language, child: Text(language.displayName!)))
                      .toList(),
                ),
                if (_selectedLocalizations != null)
                  Text(_selectedLocalizations!.languageSetInfo,
                      style: theme.textTheme.subtitle1)
                else if (_systemSettingApplied)
                  Text(localizations.languageSystemSetInfo,
                      style: theme.textTheme.subtitle1),
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
