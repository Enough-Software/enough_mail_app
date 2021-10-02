import 'package:enough_mail_app/models/settings.dart';
import 'package:enough_mail_app/services/settings_service.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../locator.dart';
import 'base.dart';

class SettingsReplyScreen extends StatefulWidget {
  @override
  _SettingsReplyScreenState createState() => _SettingsReplyScreenState();
}

class _SettingsReplyScreenState extends State<SettingsReplyScreen> {
  late ReplyFormatPreference _preference;

  @override
  void initState() {
    super.initState();
    _preference = locator<SettingsService>().settings.replyFormatPreference;
  }

  String _getFormatPreferenceName(
      ReplyFormatPreference preference, AppLocalizations localizations) {
    switch (preference) {
      case ReplyFormatPreference.alwaysHtml:
        return localizations.replySettingsFormatHtml;
      case ReplyFormatPreference.sameFormat:
        return localizations.replySettingsFormatSameAsOriginal;
      case ReplyFormatPreference.alwaysPlainText:
        return localizations.replySettingsFormatPlainText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    return Base.buildAppChrome(
      context,
      title: localizations.replySettingsTitle,
      content: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(localizations.replySettingsIntro),
                for (final preference in ReplyFormatPreference.values) ...{
                  PlatformRadioListTile<ReplyFormatPreference>(
                    value: preference,
                    groupValue: _preference,
                    onChanged: (value) async {
                      if (value != null) {
                        setState(() {
                          _preference = value;
                        });
                        final service = locator<SettingsService>();
                        service.settings.replyFormatPreference = value;
                        await service.save();
                      }
                    },
                    title: Text(
                        _getFormatPreferenceName(preference, localizations)),
                  ),
                },
              ],
            ),
          ),
        ),
      ),
    );
  }
}
