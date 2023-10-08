import 'dart:async';

import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../account/model.dart';
import '../../account/providers.dart';
import '../../l10n/app_localizations.g.dart';
import '../../l10n/extension.dart';
import '../../locator.dart';
import '../../routes.dart';
import '../../screens/base.dart';
import '../../services/navigation_service.dart';
import '../../widgets/button_text.dart';

/// Allows to select an account for editing and to re-order the accounts
class SettingsAccountsScreen extends HookConsumerWidget {
  /// Creates a [SettingsAccountsScreen]
  const SettingsAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reorderAccountsState = useState(false);
    final accounts = ref.watch(realAccountsProvider);
    final localizations = context.text;

    return BasePage(
      title: localizations.accountsTitle,
      content: reorderAccountsState.value
          ? _buildReorderableListView(
              context,
              localizations,
              ref,
              reorderAccountsState,
              accounts,
            )
          : _buildAccountSettings(
              context,
              localizations,
              ref,
              reorderAccountsState,
              accounts,
            ),
    );
  }

  Widget _buildAccountSettings(
    BuildContext context,
    AppLocalizations localizations,
    WidgetRef ref,
    ValueNotifier<bool> reorderAccountsState,
    List<RealAccount> accounts,
  ) =>
      SingleChildScrollView(
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
                onTap: () =>
                    locator<NavigationService>().push(Routes.accountAdd),
              ),
              if (accounts.length > 1)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: PlatformElevatedButton(
                    onPressed: () => reorderAccountsState.value = true,
                    child: ButtonText(localizations.accountsActionReorder),
                  ),
                ),
            ],
          ),
        ),
      );

  Widget _buildReorderableListView(
    BuildContext context,
    AppLocalizations localizations,
    WidgetRef ref,
    ValueNotifier<bool> reorderAccountsState,
    List<RealAccount> accounts,
  ) =>
      WillPopScope(
        onWillPop: () {
          reorderAccountsState.value = false;

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
                ref
                    .read(realAccountsProvider.notifier)
                    .reorderAccounts(accounts);
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
