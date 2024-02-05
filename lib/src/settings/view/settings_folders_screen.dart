import 'package:enough_mail/enough_mail.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../account/model.dart';
import '../../account/provider.dart';
import '../../localization/extension.dart';
import '../../mail/provider.dart';
import '../../models/models.dart';
import '../../scaffold_messenger/service.dart';
import '../../screens/base.dart';
import '../../util/localized_dialog_helper.dart';
import '../../widgets/account_selector.dart';
import '../../widgets/mailbox_selector.dart';
import '../model.dart';
import '../provider.dart';
import '../theme/icon_service.dart';

class SettingsFoldersScreen extends ConsumerWidget {
  const SettingsFoldersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final localizations = ref.text;
    final settings = ref.watch(settingsProvider);
    final folderNameSetting = settings.folderNameSetting;

    void onFolderNameSettingChanged(FolderNameSetting? value) =>
        _onFolderNameSettingChanged(context, value, ref);

    return BasePage(
      title: localizations.settingsFolders,
      content: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.folderNamesIntroduction,
                  style: theme.textTheme.bodySmall,
                ),
                PlatformRadioListTile<FolderNameSetting>(
                  value: FolderNameSetting.localized,
                  groupValue: folderNameSetting,
                  onChanged: onFolderNameSettingChanged,
                  title: Text(localizations.folderNamesSettingLocalized),
                ),
                PlatformRadioListTile<FolderNameSetting>(
                  value: FolderNameSetting.server,
                  groupValue: folderNameSetting,
                  onChanged: onFolderNameSettingChanged,
                  title: Text(localizations.folderNamesSettingServer),
                ),
                PlatformRadioListTile<FolderNameSetting>(
                  value: FolderNameSetting.custom,
                  groupValue: folderNameSetting,
                  onChanged: onFolderNameSettingChanged,
                  title: Text(localizations.folderNamesSettingCustom),
                ),
                if (folderNameSetting == FolderNameSetting.custom) ...[
                  const Divider(),
                  PlatformTextButtonIcon(
                    icon: Icon(CommonPlatformIcons.edit),
                    label: Text(localizations.folderNamesEditAction),
                    onPressed: () => _editFolderNames(context, settings, ref),
                  ),
                ],
                const Divider(
                  height: 8,
                ),
                const FolderManagement(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _editFolderNames(
    BuildContext context,
    Settings settings,
    WidgetRef ref,
  ) async {
    final localizations = ref.text;
    var customNames = settings.customFolderNames;
    if (customNames == null) {
      final l = ref.text;
      customNames = [
        l.folderInbox,
        l.folderDrafts,
        l.folderSent,
        l.folderTrash,
        l.folderArchive,
        l.folderJunk,
      ];
    }
    final result = await LocalizedDialogHelper.showWidgetDialog(
      ref,
      CustomFolderNamesEditor(customNames: customNames),
      title: localizations.folderNamesCustomTitle,
      defaultActions: DialogActions.okAndCancel,
    );
    if (result == true) {
      await ref.read(settingsProvider.notifier).update(
            settings.copyWith(customFolderNames: customNames),
          );
    }
  }

  Future<void> _onFolderNameSettingChanged(
    BuildContext context,
    FolderNameSetting? value,
    WidgetRef ref,
  ) async {
    final settings = ref.read(settingsProvider);

    await ref.read(settingsProvider.notifier).update(
          settings.copyWith(folderNameSetting: value),
        );
  }
}

class CustomFolderNamesEditor extends HookConsumerWidget {
  const CustomFolderNamesEditor({super.key, required this.customNames});

  final List<String> customNames;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = ref.text;
    final iconService = IconService.instance;

    final inboxController = useTextEditingController(text: customNames[0]);
    final draftsController = useTextEditingController(text: customNames[1]);
    final sentController = useTextEditingController(text: customNames[2]);
    final trashController = useTextEditingController(text: customNames[3]);
    final archiveController = useTextEditingController(text: customNames[4]);
    final junkController = useTextEditingController(text: customNames[5]);

    // TODO(RV): support to save these values

    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          children: [
            DecoratedPlatformTextField(
              controller: inboxController,
              decoration: InputDecoration(
                labelText: localizations.folderInbox,
                prefixIcon: Icon(iconService.folderInbox),
              ),
              onChanged: (value) => customNames[0] = value,
              cupertinoAlignLabelOnTop: true,
            ),
            DecoratedPlatformTextField(
              controller: draftsController,
              decoration: InputDecoration(
                labelText: localizations.folderDrafts,
                prefixIcon: Icon(iconService.folderDrafts),
              ),
              onChanged: (value) => customNames[1] = value,
              cupertinoAlignLabelOnTop: true,
            ),
            DecoratedPlatformTextField(
              controller: sentController,
              decoration: InputDecoration(
                labelText: localizations.folderSent,
                prefixIcon: Icon(iconService.folderSent),
              ),
              onChanged: (value) => customNames[2] = value,
              cupertinoAlignLabelOnTop: true,
            ),
            DecoratedPlatformTextField(
              controller: trashController,
              decoration: InputDecoration(
                labelText: localizations.folderTrash,
                prefixIcon: Icon(iconService.folderTrash),
              ),
              onChanged: (value) => customNames[3] = value,
              cupertinoAlignLabelOnTop: true,
            ),
            DecoratedPlatformTextField(
              controller: archiveController,
              decoration: InputDecoration(
                labelText: localizations.folderArchive,
                prefixIcon: Icon(iconService.folderArchive),
              ),
              onChanged: (value) => customNames[4] = value,
              cupertinoAlignLabelOnTop: true,
            ),
            DecoratedPlatformTextField(
              controller: junkController,
              decoration: InputDecoration(
                labelText: localizations.folderJunk,
                prefixIcon: Icon(iconService.folderJunk),
              ),
              onChanged: (value) => customNames[5] = value,
              cupertinoAlignLabelOnTop: true,
            ),
          ],
        ),
      ),
    );
  }
}

class FolderManagement extends StatefulHookConsumerWidget {
  const FolderManagement({super.key});

  @override
  ConsumerState<FolderManagement> createState() => _FolderManagementState();
}

class _FolderManagementState extends ConsumerState<FolderManagement> {
  late RealAccount _account;
  Mailbox? _mailbox;
  late TextEditingController _folderNameController;

  @override
  void initState() {
    final account = ref.read(currentAccountProvider);
    _account =
        account is RealAccount ? account : ref.read(realAccountsProvider).first;
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
    final localizations = ref.text;

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
                  _account = account;
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

class MailboxWidget extends ConsumerWidget {
  const MailboxWidget({
    super.key,
    required this.mailbox,
    required this.account,
    required this.onMailboxAdded,
    required this.onMailboxDeleted,
  });

  final RealAccount account;
  final Mailbox? mailbox;
  final void Function() onMailboxAdded;
  final void Function() onMailboxDeleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = ref.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PlatformTextButtonIcon(
          onPressed: () => _createFolder(context, ref),
          icon: Icon(CommonPlatformIcons.add),
          label: Text(localizations.folderAddAction),
        ),
        if (mailbox != null)
          PlatformTextButtonIcon(
            onPressed: () => _deleteFolder(context, ref),
            backgroundColor: Colors.red,
            style: TextButton.styleFrom(backgroundColor: Colors.red),
            icon: Icon(
              CommonPlatformIcons.delete,
              color: Colors.white,
            ),
            label: Text(
              localizations.folderDeleteAction,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
      ],
    );
  }

  Future<void> _createFolder(BuildContext context, WidgetRef ref) async {
    final localizations = ref.text;
    final folderNameController = TextEditingController();
    final result = await LocalizedDialogHelper.showWidgetDialog(
      ref,
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
        await ref
            .read(mailClientSourceProvider(account: account).notifier)
            .createMailbox(
              folderNameController.text,
              mailbox,
            );
        ScaffoldMessengerService.instance.showTextSnackBar(
          localizations,
          localizations.folderAddResultSuccess,
        );
        onMailboxAdded();
      } on MailException catch (e) {
        if (context.mounted) {
          await LocalizedDialogHelper.showTextDialog(
            ref,
            localizations.errorTitle,
            localizations.folderAddResultFailure(e.message ?? e.toString()),
          );
        }
      }
    }
  }

  Future<void> _deleteFolder(BuildContext context, WidgetRef ref) async {
    final localizations = ref.text;
    final mailbox = this.mailbox;
    if (mailbox == null) {
      return;
    }

    final confirmed = await LocalizedDialogHelper.askForConfirmation(
      ref,
      title: localizations.folderDeleteConfirmTitle,
      query: localizations.folderDeleteConfirmText(mailbox.path),
    );
    if (confirmed ?? false) {
      try {
        await ref
            .read(mailClientSourceProvider(account: account).notifier)
            .deleteMailbox(mailbox);
        ScaffoldMessengerService.instance.showTextSnackBar(
          localizations,
          localizations.folderDeleteResultSuccess,
        );
        onMailboxDeleted();
      } on MailException catch (e) {
        if (context.mounted) {
          await LocalizedDialogHelper.showTextDialog(
            ref,
            localizations.errorTitle,
            localizations.folderDeleteResultFailure(e.message ?? e.toString()),
          );
        }
      }
    }
  }
}
