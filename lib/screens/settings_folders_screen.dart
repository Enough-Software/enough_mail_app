import 'package:enough_mail_app/models/settings.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/util/dialog_helper.dart';
import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_mail_app/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_icons/flutter_icons.dart';
import '../locator.dart';
import 'base.dart';

class SettingsFoldersScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingsFoldersScreenState();
  }
}

class _SettingsFoldersScreenState extends State<SettingsFoldersScreen> {
  FolderNameSetting folderNameSetting;

  @override
  void initState() {
    final settings = locator<SettingsService>().settings;
    folderNameSetting = settings.folderNameSetting;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    return Base.buildAppChrome(
      context,
      title: localizations.settingsFolders,
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(localizations.folderNamesIntroduction,
                  style: theme.textTheme.caption),
              RadioListTile<FolderNameSetting>(
                value: FolderNameSetting.localized,
                groupValue: folderNameSetting,
                onChanged: _onFolderNameSettingChanged,
                title: Text(localizations.folderNamesSettingLocalized),
              ),
              RadioListTile<FolderNameSetting>(
                value: FolderNameSetting.server,
                groupValue: folderNameSetting,
                onChanged: _onFolderNameSettingChanged,
                title: Text(localizations.folderNamesSettingServer),
              ),
              RadioListTile<FolderNameSetting>(
                value: FolderNameSetting.custom,
                groupValue: folderNameSetting,
                onChanged: _onFolderNameSettingChanged,
                title: Text(localizations.folderNamesSettingCustom),
              ),
              if (folderNameSetting == FolderNameSetting.custom) ...{
                Divider(),
                TextButton.icon(
                  icon: Icon(Icons.edit),
                  label: Text(localizations.folderNamesEditAction),
                  onPressed: () async {
                    final service = locator<SettingsService>();
                    var customNames = service.settings.customFolderNames;
                    if (customNames == null) {
                      final l = locator<I18nService>().localizations;
                      customNames = [
                        l.folderInbox,
                        l.folderDrafts,
                        l.folderSent,
                        l.folderTrash,
                        l.folderArchive,
                        l.folderJunk
                      ];
                    }
                    final result = await DialogHelper.showWidgetDialog(
                        context,
                        localizations.folderNamesCustomTitle,
                        CustomFolderNamesEditor(customNames: customNames),
                        defaultActions: DialogActions.okAndCancel);
                    if (result == true) {
                      service.settings.customFolderNames = customNames;
                      locator<MailService>()
                          .applyFolderNameSettings(service.settings);
                      await service.save();
                    }
                  },
                ),
              },
            ],
          ),
        ),
      ),
    );
  }

  _onFolderNameSettingChanged(FolderNameSetting value) async {
    setState(() {
      folderNameSetting = value;
    });
    final service = locator<SettingsService>();
    service.settings.folderNameSetting = value;
    locator<MailService>().applyFolderNameSettings(service.settings);
    await service.save();
  }
}

class CustomFolderNamesEditor extends StatefulWidget {
  final List<String> customNames;
  CustomFolderNamesEditor({Key key, @required this.customNames})
      : super(key: key);

  @override
  _CustomFolderNamesEditorState createState() =>
      _CustomFolderNamesEditorState();
}

class _CustomFolderNamesEditorState extends State<CustomFolderNamesEditor> {
  TextEditingController _inboxController;
  TextEditingController _draftsController;
  TextEditingController _sentController;
  TextEditingController _trashController;
  TextEditingController _archiveController;
  TextEditingController _junkController;

  @override
  void initState() {
    super.initState();
    final customNames = widget.customNames;
    _inboxController = TextEditingController(text: customNames[0]);
    _draftsController = TextEditingController(text: customNames[1]);
    _sentController = TextEditingController(text: customNames[2]);
    _trashController = TextEditingController(text: customNames[3]);
    _archiveController = TextEditingController(text: customNames[4]);
    _junkController = TextEditingController(text: customNames[5]);
  }

  @override
  void dispose() {
    _inboxController.dispose();
    _draftsController.dispose();
    _sentController.dispose();
    _trashController.dispose();
    _archiveController.dispose();
    _junkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          TextField(
            controller: _inboxController,
            decoration: InputDecoration(
              labelText: localizations.folderInbox,
              prefixIcon: Icon(MaterialCommunityIcons.inbox),
            ),
            onChanged: (value) => widget.customNames[0] = value,
          ),
          TextField(
            controller: _draftsController,
            decoration: InputDecoration(
              labelText: localizations.folderDrafts,
              prefixIcon: Icon(MaterialCommunityIcons.email_edit_outline),
            ),
            onChanged: (value) => widget.customNames[1] = value,
          ),
          TextField(
            controller: _sentController,
            decoration: InputDecoration(
              labelText: localizations.folderSent,
              prefixIcon: Icon(MaterialCommunityIcons.inbox_arrow_up),
            ),
            onChanged: (value) => widget.customNames[2] = value,
          ),
          TextField(
            controller: _trashController,
            decoration: InputDecoration(
              labelText: localizations.folderTrash,
              prefixIcon: Icon(MaterialCommunityIcons.trash_can_outline),
            ),
            onChanged: (value) => widget.customNames[3] = value,
          ),
          TextField(
            controller: _archiveController,
            decoration: InputDecoration(
              labelText: localizations.folderArchive,
              prefixIcon: Icon(MaterialCommunityIcons.archive),
            ),
            onChanged: (value) => widget.customNames[4] = value,
          ),
          TextField(
            controller: _junkController,
            decoration: InputDecoration(
              labelText: localizations.folderJunk,
              prefixIcon: Icon(Entypo.bug),
            ),
            onChanged: (value) => widget.customNames[5] = value,
          ),
        ],
      ),
    );
  }
}
