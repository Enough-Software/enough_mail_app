import 'dart:io';

import 'package:badges/badges.dart' as badges;
import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/extensions/extension_action_tile.dart';
import 'package:enough_mail_app/locator.dart';
import 'package:enough_mail_app/models/account.dart';
import 'package:enough_mail_app/services/icon_service.dart';
import 'package:enough_mail_app/util/localized_dialog_helper.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/widgets/inherited_widgets.dart';
import 'package:enough_mail_app/widgets/mailbox_tree.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.g.dart';

import '../routes.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mailService = locator<MailService>();
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final iconService = locator<IconService>();
    final mailState = MailServiceWidget.of(context)!;
    final currentAccount = mailState.account ?? mailService.currentAccount;
    var accounts = mailState.accounts ?? mailService.accounts;
    if (mailService.hasUnifiedAccount) {
      accounts = accounts.toList();
      accounts.insert(0, mailService.unifiedAccount!);
    }
    return PlatformDrawer(
      child: SafeArea(
        child: Column(
          children: [
            Material(
              elevation: 18,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildAccountHeader(
                    currentAccount, mailService.accounts, theme),
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
                      _buildFolderTree(currentAccount),
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
                  final navService = locator<NavigationService>();
                  navService.push(Routes.settings);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAccountHeader(
    Account? currentAccount,
    List<Account> accounts,
    ThemeData theme,
  ) {
    if (currentAccount == null) {
      return Container();
    }
    final avatarAccount = currentAccount is RealAccount
        ? currentAccount
        : accounts.first as RealAccount;
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
        final NavigationService navService = locator<NavigationService>();
        if (currentAccount is UnifiedAccount) {
          navService.push(Routes.settingsAccounts, fade: true);
        } else {
          navService.push(Routes.accountEdit,
              arguments: currentAccount, fade: true);
        }
      },
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.secondaryHeaderColor,
            backgroundImage: NetworkImage(
              avatarAccount.imageUrlGravatar!,
            ),
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
                        fontStyle: FontStyle.italic, fontSize: 14),
                  ),
                Text(
                  currentAccount is UnifiedAccount
                      ? currentAccount.accounts.map((a) => a.name).join(', ')
                      : (currentAccount as RealAccount).email,
                  style: const TextStyle(
                      fontStyle: FontStyle.italic, fontSize: 14),
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
      AppLocalizations localizations) {
    if (accounts.length > 1) {
      return ExpansionTile(
        leading: mailService.hasAccountsWithErrors() ? Badge() : null,
        title: Text(localizations
            .drawerAccountsSectionTitle(mailService.accounts.length)),
        children: [
          for (final account in accounts)
            SelectablePlatformListTile(
              leading: mailService.hasError(account)
                  ? const Icon(Icons.error_outline)
                  : null,
              tileColor: mailService.hasError(account) ? Colors.red : null,
              title: Text(account.name),
              selected: account == currentAccount,
              onTap: () async {
                final navService = locator<NavigationService>();
                if (!Platform.isIOS) {
                  // close drawer
                  navService.pop();
                }
                if (mailService.hasError(account)) {
                  navService.push(Routes.accountEdit, arguments: account);
                } else {
                  final accountWidgetState = MailServiceWidget.of(context);
                  if (accountWidgetState != null) {
                    accountWidgetState.account = account;
                  }
                  final messageSource = locator<MailService>()
                      .getMessageSourceFor(account, switchToAccount: true);
                  navService.push(Routes.messageSourceFuture,
                      arguments: messageSource,
                      replace: !Platform.isIOS,
                      fade: true);
                }
              },
              onLongPress: () {
                final navService = locator<NavigationService>();
                if (account is UnifiedAccount) {
                  navService.push(Routes.settingsAccounts, fade: true);
                } else {
                  navService.push(Routes.accountEdit,
                      arguments: account, fade: true);
                }
              },
            ),
          _buildAddAccountTile(localizations),
        ],
      );
    } else {
      return _buildAddAccountTile(localizations);
    }
  }

  Widget _buildAddAccountTile(AppLocalizations localizations) {
    return PlatformListTile(
      leading: const Icon(Icons.add),
      title: Text(localizations.drawerEntryAddAccount),
      onTap: () {
        final navService = locator<NavigationService>();
        if (!Platform.isIOS) {
          navService.pop();
        }
        navService.push(Routes.accountAdd);
      },
    );
  }

  Widget _buildFolderTree(Account? account) {
    if (account == null) {
      return Container();
    }
    return MailboxTree(account: account, onSelected: _navigateToMailbox);
  }

  void _navigateToMailbox(Mailbox mailbox) async {
    final mailService = locator<MailService>();
    final account = mailService.currentAccount!;
    final messageSourceFuture =
        mailService.getMessageSourceFor(account, mailbox: mailbox);
    locator<NavigationService>().push(
      Routes.messageSourceFuture,
      arguments: messageSourceFuture,
      replace: !Platform.isIOS,
      fade: true,
    );
  }
}
