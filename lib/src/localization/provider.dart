import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../settings/provider.dart';
import 'app_localizations.g.dart';
import 'app_localizations_en.g.dart';

part 'provider.g.dart';

@Riverpod(keepAlive: true)
class CurrentAppLocalization extends _$CurrentAppLocalization {
  static _LocaleObserver? _observer;
  @override
  AppLocalizations build() {
    final languageTag =
        ref.watch(settingsProvider.select((settings) => settings.languageTag));
    final locale = languageTag != null
        ? Locale(languageTag)
        : PlatformDispatcher.instance.locale;
    state = resolve(locale);
    final binding = WidgetsBinding.instance;
    final existingObserver = _observer;
    if (languageTag != null) {
      if (existingObserver != null) {
        binding.removeObserver(existingObserver);
        _observer = null;
      }
    } else {
      if (existingObserver == null) {
        final newObserver = _LocaleObserver((locales) {
          state = resolve(PlatformDispatcher.instance.locale);
        });
        _observer = newObserver;
        binding.addObserver(newObserver);
      }
    }
    ref.onDispose(() {
      final observer = _observer;
      if (observer != null) {
        binding.removeObserver(observer);
      }
    });

    return state;
  }

  /// Finds the localizations for the given [locale]
  AppLocalizations resolve(Locale locale) {
    try {
      return lookupAppLocalizations(locale);
      // ignore: avoid_catching_errors
    } on FlutterError {
      return AppLocalizationsEn();
    }
  }
}

/// observed used to notify the caller when the locale changes
class _LocaleObserver extends WidgetsBindingObserver {
  _LocaleObserver(this._didChangeLocales);

  final void Function(List<Locale>? locales) _didChangeLocales;

  @override
  void didChangeLocales(List<Locale>? locales) => _didChangeLocales(locales);
}
