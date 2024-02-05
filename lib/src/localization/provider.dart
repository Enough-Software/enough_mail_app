import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_localizations.g.dart';

part 'provider.g.dart';

@Riverpod(keepAlive: true)
AppLocalizations currentAppLocalization(CurrentAppLocalizationRef ref) {
  ref.state = lookupAppLocalizations(PlatformDispatcher.instance.locale);
  final observer = _LocaleObserver((locales) {
    ref.state = lookupAppLocalizations(PlatformDispatcher.instance.locale);
  });
  final binding = WidgetsBinding.instance..addObserver(observer);
  ref.onDispose(() => binding.removeObserver(observer));

  return ref.state;
}

/// observed used to notify the caller when the locale changes
class _LocaleObserver extends WidgetsBindingObserver {
  _LocaleObserver(this._didChangeLocales);
  final void Function(List<Locale>? locales) _didChangeLocales;
  @override
  void didChangeLocales(List<Locale>? locales) {
    _didChangeLocales(locales);
  }
}
