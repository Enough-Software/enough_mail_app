import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/models.dart';
import 'package:enough_mail_app/services/icon_service.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/services/scaffold_messenger_service.dart';
import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_mail_app/services/settings_service.dart';
import 'package:enough_mail_app/util/localized_dialog_helper.dart';
import 'package:enough_mail_app/widgets/account_selector.dart';
import 'package:enough_mail_app/widgets/button_text.dart';
import 'package:enough_mail_app/widgets/mailbox_selector.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.g.dart';
import '../locator.dart';
import 'base.dart';

class SettingsFoldersScreen extends StatefulWidget {
  const SettingsFoldersScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SettingsFoldersScreenState();
  }
}

class _SettingsFoldersScreenState extends State<SettingsFoldersScreen> {
  FolderNameSetting? folderNameSetting;

  @override
  void initState() {
    final settings = locator<SettingsService>().settings;
    folderNameSetting = settings.folderNameSetting;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    return Base.buildAppChrome(
      context,
      title: localizations.settingsFolders,
      content: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(localizations.folderNamesIntroduction,
                    style: theme.textTheme.caption),
                PlatformRadioListTile<FolderNameSetting>(
                  value: FolderNameSetting.localized,
                  groupValue: folderNameSetting,
                  onChanged: _onFolderNameSettingChanged,
                  title: Text(localizations.folderNamesSettingLocalized),
                ),
                PlatformRadioListTile<FolderNameSetting>(
                  value: FolderNameSetting.server,
                  groupValue: folderNameSetting,
                  onChanged: _onFolderNameSettingChanged,
                  title: Text(localizations.folderNamesSettingServer),
                ),
                PlatformRadioListTile<FolderNameSetting>(
                  value: FolderNameSetting.custom,
                  groupValue: folderNameSetting,
                  onChanged: _onFolderNameSettingChanged,
                  title: Text(localizations.folderNamesSettingCustom),
                ),
                if (folderNameSetting == FolderNameSetting.custom) ...[
                  const Divider(),
                  PlatformTextButtonIcon(
                    icon: Icon(CommonPlatformIcons.edit),
                    label: ButtonText(localizations.folderNamesEditAction),
                    onPressed: _editFolderNames,
                  ),
                ],
                const Divider(
                  height: 8.0,
                ),
                const FolderManagement(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _editFolderNames() async {
    final localizations = AppLocalizations.of(context)!;
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
    final result = await LocalizedDialogHelper.showWidgetDialog(
        context, CustomFolderNamesEditor(customNames: customNames),
        title: localizations.folderNamesCustomTitle,
        defaultActions: DialogActions.okAndCancel);
    if (result == true) {
      service.settings =
          service.settings.copyWith(customFolderNames: customNames);
      locator<MailService>().applyFolderNameSettings(service.settings);
      await service.save();
    }
  }

  void _onFolderNameSettingChanged(FolderNameSetting? value) async {
    setState(() {
      folderNameSetting = value;
    });
    final service = locator<SettingsService>();
    service.settings = service.settings.copyWith(folderNameSetting: value);
    locator<MailService>().applyFolderNameSettings(service.settings);
    await service.save();
  }
}

class CustomFolderNamesEditor extends StatefulWidget {
  const CustomFolderNamesEditor({Key? key, required this.customNames})
      : super(key: key);

  final List<String> customNames;

  @override
  State<CustomFolderNamesEditor> createState() =>
      _CustomFolderNamesEditorState();
}

class _CustomFolderNamesEditorState extends State<CustomFolderNamesEditor> {
  TextEditingController? _inboxController;
  TextEditingController? _draftsController;
  TextEditingController? _sentController;
  TextEditingController? _trashController;
  TextEditingController? _archiveController;
  TextEditingController? _junkController;

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
    _inboxController!.dispose();
    _draftsController!.dispose();
    _sentController!.dispose();
    _trashController!.dispose();
    _archiveController!.dispose();
    _junkController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final iconService = locator<IconService>();
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          children: [
            DecoratedPlatformTextField(
              controller: _inboxController,
              decoration: InputDecoration(
                labelText: localizations.folderInbox,
                prefixIcon: Icon(iconService.folderInbox),
              ),
              onChanged: (value) => widget.customNames[0] = value,
              cupertinoAlignLabelOnTop: true,
            ),
            DecoratedPlatformTextField(
              controller: _draftsController,
              decoration: InputDecoration(
                labelText: localizations.folderDrafts,
                prefixIcon: Icon(iconService.folderDrafts),
              ),
              onChanged: (value) => widget.customNames[1] = value,
              cupertinoAlignLabelOnTop: true,
            ),
            DecoratedPlatformTextField(
              controller: _sentController,
              decoration: InputDecoration(
                labelText: localizations.folderSent,
                prefixIcon: Icon(iconService.folderSent),
              ),
              onChanged: (value) => widget.customNames[2] = value,
              cupertinoAlignLabelOnTop: true,
            ),
            DecoratedPlatformTextField(
              controller: _trashController,
              decoration: InputDecoration(
                labelText: localizations.folderTrash,
                prefixIcon: Icon(iconService.folderTrash),
              ),
              onChanged: (value) => widget.customNames[3] = value,
              cupertinoAlignLabelOnTop: true,
            ),
            DecoratedPlatformTextField(
              controller: _archiveController,
              decoration: InputDecoration(
                labelText: localizations.folderArchive,
                prefixIcon: Icon(iconService.folderArchive),
              ),
              onChanged: (value) => widget.customNames[4] = value,
              cupertinoAlignLabelOnTop: true,
            ),
            DecoratedPlatformTextField(
              controller: _junkController,
              decoration: InputDecoration(
                labelText: localizations.folderJunk,
                prefixIcon: Icon(iconService.folderJunk),
              ),
              onChanged: (value) => widget.customNames[5] = value,
              cupertinoAlignLabelOnTop: true,
            ),
          ],
        ),
      ),
    );
  }
}

class FolderManagement extends StatefulWidget {
  const FolderManagement({Key? key}) : super(key: key);

  @override
  State<FolderManagement> createState() => _FolderManagementState();
}

class _FolderManagementState extends State<FolderManagement> {
  late RealAccount _account;
  Mailbox? _mailbox;
  late TextEditingController _folderNameController;

  @override
  void initState() {
    _account = locator<MailService>()
        .accounts
        .firstWhere((account) => account is RealAccount) as RealAccount;
    _folderNameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _folderNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(localizations.folderAccountLabel),
            AccountSelector(
              account: _account,
              onChanged: (account) {
                setState(() {
                  _mailbox = null;
                  _account = account!;
                });
              },
            ),
            const Divider(),
            Text(localizations.folderMailboxLabel),
            MailboxSelector(
              account: _account,
              mailbox: _mailbox,
              onChanged: (mailbox) {
                setState(() {
                  _mailbox = mailbox;
                });
              },
            ),
            const Divider(),
            MailboxWidget(
              mailbox: _mailbox,
              account: _account,
              onMailboxAdded: () {
                setState(() {});
              },
              onMailboxDeleted: () {
                setState(() {
                  _mailbox = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MailboxWidget extends StatelessWidget {
  final RealAccount account;
  final Mailbox? mailbox;
  final void Function() onMailboxAdded;
  final void Function() onMailboxDeleted;

  const MailboxWidget(
      {Key? key,
      required this.mailbox,
      required this.account,
      required this.onMailboxAdded,
      required this.onMailboxDeleted})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PlatformTextButtonIcon(
          onPressed: () => _createFolder(context),
          icon: Icon(CommonPlatformIcons.add),
          label: ButtonText(localizations.folderAddAction),
        ),
        if (mailbox != null)
          PlatformTextButtonIcon(
            onPressed: () => _deleteFolder(context),
            backgroundColor: Colors.red,
            style: TextButton.styleFrom(backgroundColor: Colors.red),
            icon: Icon(
              CommonPlatformIcons.delete,
              color: Colors.white,
            ),
            label: ButtonText(
              localizations.folderDeleteAction,
              style: Theme.of(context)
                  .textTheme
                  .button!
                  .copyWith(color: Colors.white),
            ),
          ),
      ],
    );
  }

  void _createFolder(context) async {
    final localizations = AppLocalizations.of(context)!;
    final folderNameController = TextEditingController();
    final result = await LocalizedDialogHelper.showWidgetDialog(
      context,
      DecoratedPlatformTextField(
        controller: folderNameController,
        decoration: InputDecoration(
          labelText: localizations.folderAddNameLabel,
          hintText: localizations.folderAddNameHint,
        ),
        textInputAction: TextInputAction.done,
      ),
      title: localizations.folderAddTitle,
      defaultActions: DialogActions.okAndCancel,
    );
    if (result == true) {
      try {
        await locator<MailService>().createMailbox(
          account,
          folderNameController.text,
          mailbox,
        );
        locator<ScaffoldMessengerService>()
            .showTextSnackBar(localizations.folderAddResultSuccess);
        onMailboxAdded();
      } on MailException catch (e) {
        await LocalizedDialogHelper.showTextDialog(
          context,
          localizations.errorTitle,
          localizations.folderAddResultFailure(e.message!),
        );
      }
    }
  }

  void _deleteFolder(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final confirmed = await LocalizedDialogHelper.askForConfirmation(
      context,
      title: localizations.folderDeleteConfirmTitle,
      query: localizations.folderDeleteConfirmText(mailbox!.path),
    );
    if (confirmed == true) {
      try {
        await locator<MailService>().deleteMailbox(account, mailbox!);
        locator<ScaffoldMessengerService>()
            .showTextSnackBar(localizations.folderDeleteResultSuccess);
        onMailboxDeleted();
      } on MailException catch (e) {
        await LocalizedDialogHelper.showTextDialog(
          context,
          localizations.errorTitle,
          localizations.folderDeleteResultFailure(e.message!),
        );
      }
    }
  }
}
