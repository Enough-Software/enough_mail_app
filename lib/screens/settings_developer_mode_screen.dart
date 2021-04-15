import 'package:enough_mail_app/util/dialog_helper.dart';
import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_mail_app/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../locator.dart';
import 'base.dart';

class SettingsDeveloperModeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingsDeveloperModeScreenState();
  }
}

class _SettingsDeveloperModeScreenState
    extends State<SettingsDeveloperModeScreen> {
  bool isDeveloperModeEnabled = false;

  @override
  void initState() {
    isDeveloperModeEnabled =
        locator<SettingsService>().settings.enableDeveloperMode;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    return Base.buildAppChrome(
      context,
      title: localizations.settingsDeveloperMode,
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(localizations.developerModeIntroduction),
              CheckboxListTile(
                value: isDeveloperModeEnabled,
                onChanged: (value) async {
                  setState(() {
                    isDeveloperModeEnabled = value;
                  });
                  final service = locator<SettingsService>();
                  service.settings.enableDeveloperMode = value;
                  await service.save();
                },
                title: Text(localizations.developerModeEnable),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Language {
  final Locale locale;
  final String displayName;
  _Language(this.locale, this.displayName);
}
