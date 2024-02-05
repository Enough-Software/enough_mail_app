import 'package:collection/collection.dart' show IterableExtension;
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../localization/app_localizations.g.dart';
import '../../localization/extension.dart';
import '../../screens/base.dart';
import '../../util/localized_dialog_helper.dart';
import '../provider.dart';

class SettingsLanguageScreen extends HookConsumerWidget {
  const SettingsLanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayNames = {
      'de': 'deutsch',
      'en': 'English',
      'es': 'español',
    };
    final available = AppLocalizations.supportedLocales
        .map(
          (locale) => _Language(locale, displayNames[locale.toLanguageTag()]),
        )
        .toList();
    final systemLanguage = _Language(
      null,
      ref.text.designThemeOptionSystem,
    );

    final languages = [systemLanguage, ...available];
    final languageTag = ref.watch(
      settingsProvider.select((value) => value.languageTag),
    );
    final _Language? selectedLanguage;
    selectedLanguage = languageTag != null
        ? available
            .firstWhereOrNull((l) => l.locale?.toLanguageTag() == languageTag)
        : systemLanguage;

    final theme = Theme.of(context);
    final localizations = ref.text;
    final systemSettingApplied = useState(false);
    final selectedLanguageState = useState(selectedLanguage);
    final selectedLocalizationsState = useState<AppLocalizations?>(null);

    return BasePage(
      title: localizations.languageSettingTitle,
      content: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.languageSettingLabel,
                  style: theme.textTheme.bodySmall,
                ),
                PlatformDropdownButton<_Language>(
                  value: selectedLanguage,
                  onChanged: (value) async {
                    final locale = value?.locale;
                    final settings = ref.read(settingsProvider);

                    if (locale == null) {
                      systemSettingApplied.value = true;
                      await ref
                          .read(settingsProvider.notifier)
                          .update(settings.removeLanguageTag());

                      return;
                    }

                    final selectedLocalizations =
                        await AppLocalizations.delegate.load(locale);
                    selectedLocalizationsState.value = selectedLocalizations;
                    if (context.mounted) {
                      final confirmed =
                          await LocalizedDialogHelper.showTextDialog(
                        ref,
                        selectedLocalizations.languageSettingConfirmationTitle,
                        selectedLocalizations.languageSettingConfirmationQuery,
                        actions: [
                          PlatformTextButton(
                            child: Text(
                              selectedLocalizations.actionCancel,
                            ),
                            onPressed: () => context.pop(false),
                          ),
                          PlatformTextButton(
                            child: Text(selectedLocalizations.actionOk),
                            onPressed: () => context.pop(true),
                          ),
                        ],
                      );
                      if (confirmed) {
                        selectedLanguageState.value = value;

                        await ref.read(settingsProvider.notifier).update(
                              settings.copyWith(
                                languageTag: locale.toLanguageTag(),
                              ),
                            );
                      }
                    }
                  },
                  selectedItemBuilder: (context) => languages
                      .map((language) => Text(language.displayName ?? ''))
                      .toList(),
                  items: languages
                      .map((language) => DropdownMenuItem(
                            value: language,
                            child: Text(language.displayName ?? ''),
                          ))
                      .toList(),
                ),
                if (selectedLocalizationsState.value != null)
                  Text(
                    selectedLocalizationsState.value?.languageSetInfo ?? '',
                    style: theme.textTheme.titleMedium,
                  )
                else if (systemSettingApplied.value)
                  Text(
                    localizations.languageSystemSetInfo,
                    style: theme.textTheme.titleMedium,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Language {
  _Language(this.locale, this.displayName);
  final Locale? locale;
  final String? displayName;
}
