import 'package:enough_mail_app/models/settings.dart';
import 'package:enough_mail_app/services/settings_service.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.g.dart';
import '../locator.dart';
import 'base.dart';

class SettingsReadReceiptsScreen extends StatefulWidget {
  const SettingsReadReceiptsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SettingsFoldersScreenState();
  }
}

class _SettingsFoldersScreenState extends State<SettingsReadReceiptsScreen> {
  ReadReceiptDisplaySetting? _readReceiptDisplaySetting;

  @override
  void initState() {
    final settings = locator<SettingsService>().settings;
    _readReceiptDisplaySetting = settings.readReceiptDisplaySetting;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    return Base.buildAppChrome(
      context,
      title: localizations.settingsReadReceipts,
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(localizations.readReceiptsSettingsIntroduction,
                    style: theme.textTheme.caption),
                PlatformRadioListTile<ReadReceiptDisplaySetting>(
                  value: ReadReceiptDisplaySetting.always,
                  groupValue: _readReceiptDisplaySetting,
                  onChanged: _onReadReceiptDisplaySettingChanged,
                  title: Text(localizations.readReceiptOptionAlways),
                ),
                PlatformRadioListTile<ReadReceiptDisplaySetting>(
                  value: ReadReceiptDisplaySetting.never,
                  groupValue: _readReceiptDisplaySetting,
                  onChanged: _onReadReceiptDisplaySettingChanged,
                  title: Text(localizations.readReceiptOptionNever),
                ),
                // PlatformRadioListTile<ReadReceiptDisplaySetting>(
                //   value: ReadReceiptDisplaySetting.forContacts,
                //   groupValue: _readReceiptDisplaySetting,
                //   onChanged: _onReadReceiptDisplaySettingChanged,
                //   title: Text(localizations.readReceiptOptionForContacts),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _onReadReceiptDisplaySettingChanged(ReadReceiptDisplaySetting? value) async {
    setState(() {
      _readReceiptDisplaySetting = value;
    });
    final service = locator<SettingsService>();
    service.settings = service.settings
        .copyWith(readReceiptDisplaySetting: _readReceiptDisplaySetting);
    await service.save();
  }
}
