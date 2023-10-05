import 'dart:async';

import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.g.dart';
import '../../l10n/extension.dart';
import '../../locator.dart';
import '../../models/account.dart';
import '../../routes.dart';
import '../../screens/base.dart';
import '../../services/mail_service.dart';
import '../../services/navigation_service.dart';
import '../../widgets/button_text.dart';
import '../../widgets/inherited_widgets.dart';

class SettingsAccountsScreen extends StatefulWidget {
  const SettingsAccountsScreen({super.key});

  @override
  State<SettingsAccountsScreen> createState() => _SettingsAccountsScreenState();
}

class _SettingsAccountsScreenState extends State<SettingsAccountsScreen> {
  bool _reorderAccounts = false;

  @override
  Widget build(BuildContext context) {
    final localizations = context.text;

    return BasePage(
      title: localizations.accountsTitle,
      content: _reorderAccounts
          ? _buildReorderableListView(context)
          : _buildAccountSettings(context, localizations),
    );
  }

  Widget _buildAccountSettings(
      BuildContext context, AppLocalizations localizations) {
    final accounts = MailServiceWidget.of(context)?.accounts ?? [];
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final account in accounts)
              PlatformListTile(
                leading: Icon(CommonPlatformIcons.account),
                title: Text(account.name),
                onTap: () => locator<NavigationService>()
                    .push(Routes.accountEdit, arguments: account),
              ),
            PlatformListTile(
              leading: Icon(CommonPlatformIcons.add),
              title: Text(localizations.drawerEntryAddAccount),
              onTap: () => locator<NavigationService>().push(Routes.accountAdd),
            ),
            if (accounts.length > 1)
              Padding(
                padding: const EdgeInsets.all(8),
                child: PlatformElevatedButton(
                  onPressed: () {
                    setState(() {
                      _reorderAccounts = true;
                    });
                  },
                  child: ButtonText(localizations.accountsActionReorder),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReorderableListView(BuildContext context) {
    final accounts = List<RealAccount>.from(
        MailServiceWidget.of(context)?.accounts?.whereType<RealAccount>() ??
            <RealAccount>[]);
    return WillPopScope(
      onWillPop: () {
        setState(() {
          _reorderAccounts = false;
        });
        return Future.value(false);
      },
      child: SafeArea(
        child: Material(
          child: ReorderableListView(
            onReorder: (oldIndex, newIndex) async {
              // print('moved $oldIndex to $newIndex');
              final account = accounts.removeAt(oldIndex);
              if (newIndex > accounts.length) {
                accounts.add(account);
              } else {
                accounts.insert(newIndex, account);
              }
              setState(() {});
              await locator<MailService>().reorderAccounts(accounts);
            },
            children: [
              for (final account in accounts)
                ListTile(
                  key: ValueKey(account),
                  leading: const Icon(Icons.account_circle),
                  title: Text(account.name),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
