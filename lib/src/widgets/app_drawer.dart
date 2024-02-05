import 'package:badges/badges.dart' as badges;
import 'package:collection/collection.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../account/model.dart';
import '../account/provider.dart';
import '../extensions/extension_action_tile.dart';
import '../localization/app_localizations.g.dart';
import '../localization/extension.dart';
import '../routes/routes.dart';
import '../settings/theme/icon_service.dart';
import '../util/localized_dialog_helper.dart';
import 'mailbox_tree.dart';

/// Displays the base navigation drawer with all accounts
class AppDrawer extends ConsumerWidget {
  /// Creates a new [AppDrawer]
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(allAccountsProvider);
    final theme = Theme.of(context);
    final localizations = ref.text;
    final iconService = IconService.instance;
    final currentAccount = ref.watch(currentAccountProvider);
    final hasAccountsWithErrors = ref.watch(hasAccountWithErrorProvider);

    return PlatformDrawer(
      child: SafeArea(
        child: Column(
          children: [
            Material(
              elevation: 18,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: _buildAccountHeader(
                  context,
                  currentAccount,
                  accounts,
                  theme,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Material(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAccountSelection(
                        context,
                        accounts,
                        currentAccount,
                        localizations,
                        hasAccountsWithErrors: hasAccountsWithErrors,
                      ),
                      _buildFolderTree(context, currentAccount),
                      if (currentAccount is RealAccount)
                        ExtensionActionTile.buildSideMenuForAccount(
                          context,
                          currentAccount,
                        ),
                      const Divider(),
                      PlatformListTile(
                        leading: Icon(iconService.about),
                        title: Text(localizations.drawerEntryAbout),
                        onTap: () {
                          LocalizedDialogHelper.showAbout(
                            ref,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Material(
              elevation: 18,
              child: PlatformListTile(
                leading: Icon(iconService.settings),
                title: Text(localizations.drawerEntrySettings),
                onTap: () {
                  context.pushNamed(Routes.settings);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountHeader(
    BuildContext context,
    Account? currentAccount,
    List<Account> accounts,
    ThemeData theme,
  ) {
    if (currentAccount == null) {
      return const SizedBox.shrink();
    }
    final avatarAccount = currentAccount is RealAccount
        ? currentAccount
        : (currentAccount is UnifiedAccount
            ? currentAccount.accounts.first
            : accounts.firstWhereOrNull((a) => a is RealAccount)
                as RealAccount?);
    final avatarImageUrl = avatarAccount?.imageUrlGravatar;
    final hasError = currentAccount is RealAccount && currentAccount.hasError;

    final userName =
        currentAccount is RealAccount ? currentAccount.userName : null;
    final accountName = Text(
      currentAccount.name,
      style: const TextStyle(fontWeight: FontWeight.bold),
    );
    final accountNameWithBadge =
        hasError ? badges.Badge(child: accountName) : accountName;

    return PlatformListTile(
      onTap: () {
        if (currentAccount is UnifiedAccount) {
          context.pushNamed(Routes.settingsAccounts);
        } else {
          context.pushNamed(
            Routes.accountEdit,
            pathParameters: {
              Routes.pathParameterEmail: currentAccount.email,
            },
          );
        }
      },
      title: avatarAccount == null
          ? const SizedBox.shrink()
          : Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.secondaryHeaderColor,
                  backgroundImage: avatarImageUrl == null
                      ? null
                      : NetworkImage(avatarImageUrl),
                  radius: 30,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      accountNameWithBadge,
                      if (userName != null)
                        Text(
                          userName,
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 14,
                          ),
                        ),
                      Text(
                        currentAccount is UnifiedAccount
                            ? currentAccount.accounts
                                .map((a) => a.name)
                                .join(', ')
                            : currentAccount.email,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAccountSelection(
    BuildContext context,
    List<Account> accounts,
    Account? currentAccount,
    AppLocalizations localizations, {
    required bool hasAccountsWithErrors,
  }) =>
      accounts.length > 1
          ? ExpansionTile(
              leading: hasAccountsWithErrors ? const Badge() : null,
              title: Text(
                localizations.drawerAccountsSectionTitle(accounts.length),
              ),
              children: [
                for (final account in accounts)
                  _SelectableAccountTile(
                    account: account,
                    currentAccount: currentAccount,
                  ),
                _buildAddAccountTile(context, localizations),
              ],
            )
          : _buildAddAccountTile(context, localizations);

  Widget _buildAddAccountTile(
    BuildContext context,
    AppLocalizations localizations,
  ) =>
      PlatformListTile(
        leading: const Icon(Icons.add),
        title: Text(localizations.drawerEntryAddAccount),
        onTap: () {
          if (!useAppDrawerAsRoot) {
            context.pop();
          }
          context.pushNamed(Routes.accountAdd);
        },
      );

  Widget _buildFolderTree(
    BuildContext context,
    Account? account,
  ) {
    if (account == null) {
      return const SizedBox.shrink();
    }

    return MailboxTree(
      account: account,
      onSelected: (mailbox) => _navigateToMailbox(context, account, mailbox),
      isReselectPossible: true,
    );
  }

  void _navigateToMailbox(
    BuildContext context,
    Account account,
    Mailbox mailbox,
  ) {
    if (!useAppDrawerAsRoot) {
      while (context.canPop()) {
        context.pop();
      }
    }
    if (mailbox.isInbox) {
      context.goNamed(
        Routes.mailForAccount,
        pathParameters: {
          Routes.pathParameterEmail: account.email,
        },
      );
    } else {
      context.pushNamed(
        Routes.mailForMailbox,
        pathParameters: {
          Routes.pathParameterEmail: account.email,
          Routes.pathParameterEncodedMailboxPath: mailbox.encodedPath,
        },
      );
    }
  }
}

class _SelectableAccountTile extends ConsumerWidget {
  const _SelectableAccountTile({
    required this.account,
    required this.currentAccount,
  });

  final Account account;
  final Account? currentAccount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = this.account;
    final hasError = account is RealAccount && account.hasError;
    final localizations = ref.text;

    return SelectablePlatformListTile(
      leading: hasError ? const Icon(Icons.error_outline) : null,
      tileColor: hasError ? Colors.red : null,
      title: Text(
        account is UnifiedAccount
            ? localizations.unifiedAccountName
            : account.name,
      ),
      selected: account == currentAccount,
      onTap: () {
        if (!useAppDrawerAsRoot) {
          context.pop();
        }
        if (hasError) {
          context.pushNamed(
            Routes.accountEdit,
            pathParameters: {
              Routes.pathParameterEmail: account.email,
            },
          );
        } else {
          context.goNamed(
            Routes.mailForAccount,
            pathParameters: {
              Routes.pathParameterEmail: account.email,
            },
          );
        }
      },
      onLongPress: () {
        if (account is UnifiedAccount) {
          context.pushNamed(
            Routes.settingsAccounts,
            pathParameters: {
              Routes.pathParameterEmail: account.email,
            },
          );
        } else {
          context.pushNamed(
            Routes.accountEdit,
            pathParameters: {
              Routes.pathParameterEmail: account.email,
            },
          );
        }
      },
    );
  }
}
