import 'dart:io';

import 'package:badges/badges.dart' as badges;
import 'package:enough_mail/enough_mail.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../account/model.dart';
import '../account/providers.dart';
import '../extensions/extension_action_tile.dart';
import '../localization/app_localizations.g.dart';
import '../localization/extension.dart';
import '../locator.dart';
import '../routes.dart';
import '../services/icon_service.dart';
import '../services/mail_service.dart';
import '../util/localized_dialog_helper.dart';
import 'mailbox_tree.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key, this.currentAccount});

  final Account? currentAccount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(allAccountsProvider);
    final mailService = locator<MailService>();
    final theme = Theme.of(context);
    final localizations = context.text;
    final iconService = locator<IconService>();
    final currentAccount = this.currentAccount;

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
                  mailService.accounts,
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
                        mailService,
                        accounts,
                        currentAccount,
                        localizations,
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
                          LocalizedDialogHelper.showAbout(context);
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
      return Container();
    }
    final avatarAccount = currentAccount is RealAccount
        ? currentAccount
        : accounts.isNotEmpty
            ? accounts.first as RealAccount
            : null;
    final avatarImageUrl = avatarAccount?.imageUrlGravatar;

    final userName =
        currentAccount is RealAccount ? currentAccount.userName : null;
    final accountName = Text(
      currentAccount.name,
      style: const TextStyle(fontWeight: FontWeight.bold),
    );
    final accountNameWithBadge = locator<MailService>().hasError(currentAccount)
        ? badges.Badge(child: accountName)
        : accountName;

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
                            : (currentAccount as RealAccount).email,
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
    MailService mailService,
    List<Account> accounts,
    Account? currentAccount,
    AppLocalizations localizations,
  ) =>
      accounts.length > 1
          ? ExpansionTile(
              leading:
                  mailService.hasAccountsWithErrors() ? const Badge() : null,
              title: Text(
                localizations.drawerAccountsSectionTitle(accounts.length),
              ),
              children: [
                for (final account in accounts)
                  SelectablePlatformListTile(
                    leading: mailService.hasError(account)
                        ? const Icon(Icons.error_outline)
                        : null,
                    tileColor:
                        mailService.hasError(account) ? Colors.red : null,
                    title: Text(
                      account is UnifiedAccount
                          ? localizations.unifiedAccountName
                          : account.name,
                    ),
                    selected: account == currentAccount,
                    onTap: () {
                      if (!Platform.isIOS) {
                        context.pop();
                      }
                      if (mailService.hasError(account)) {
                        context.pushNamed(
                          Routes.accountEdit,
                          pathParameters: {
                            Routes.pathParameterEmail: account.email,
                          },
                        );
                      } else {
                        context.pushNamed(
                          Routes.mail,
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
          if (!Platform.isIOS) {
            context.pop();
          }
          context.pushNamed(Routes.accountAdd);
        },
      );

  Widget _buildFolderTree(BuildContext context, Account? account) {
    if (account == null) {
      return const SizedBox.shrink();
    }

    return MailboxTree(
      account: account,
      onSelected: (mailbox) => _navigateToMailbox(context, mailbox),
    );
  }

  Future<void> _navigateToMailbox(BuildContext context, Mailbox mailbox) async {
    final account = currentAccount;
    if (account == null) {
      return;
    }
    await context.pushNamed(
      Routes.mail,
      pathParameters: {
        Routes.pathParameterEmail: account.email,
      },
      queryParameters: {
        Routes.queryParameterEncodedMailboxPath: mailbox.encodedPath,
      },
    );
  }
}
