import 'package:flutter/cupertino.dart';

import 'app_localizations.g.dart';
import 'app_localizations_en.g.dart';

extension AppLocalizationBuildContext on BuildContext {
  /// Retrieves the current localizations
  AppLocalizations get text =>
      AppLocalizations.of(this) ?? AppLocalizationsEn();
}
