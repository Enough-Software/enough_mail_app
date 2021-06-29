import 'dart:io';

import 'package:badges/badges.dart';
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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../routes.dart';

class AppDrawer extends StatelessWidget {
  AppDrawer({Key? key}) : super(key: key);

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
                      _buildAccountSelection(context, mailService, accounts,
                          currentAccount, localizations),
                      _buildFolderTree(currentAccount),
                      ExtensionActionTile.buildSideMenuForAccount(
                          context, currentAccount),
                      Divider(),
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
    final avatarAccount =
        currentAccount.isVirtual ? accounts.first : currentAccount;
    final userName = currentAccount.userName;
    final accountName = Text(
      currentAccount.name,
      style: TextStyle(fontWeight: FontWeight.bold),
    );
    final accountNameWithBadge = locator<MailService>().hasError(currentAccount)
        ? Badge(child: accountName)
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
              avatarAccount.imageUrlGravator!,
            ),
            radius: 30,
          ),
          Padding(
            padding: EdgeInsets.only(left: 8),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                accountNameWithBadge,
                if (userName != null) ...{
                  Text(
                    userName,
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
                  ),
                },
                Text(
                  currentAccount is UnifiedAccount
                      ? currentAccount.accounts.map((a) => a.name).join(', ')
                      : currentAccount.email,
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
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
          for (final account in accounts) ...{
            PlatformListTile(
              leading: mailService.hasError(account)
                  ? Icon(Icons.error_outline)
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
                  final messageSource = await locator<MailService>()
                      .getMessageSourceFor(account, switchToAccount: true);
                  navService.push(Routes.messageSource,
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
          },
          _buildAddAccountTile(localizations),
        ],
      );
    } else {
      return _buildAddAccountTile(localizations);
    }
  }

  Widget _buildAddAccountTile(AppLocalizations localizations) {
    return PlatformListTile(
      leading: Icon(Icons.add),
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
    final messageSource =
        await mailService.getMessageSourceFor(account, mailbox: mailbox);
    locator<NavigationService>().push(Routes.messageSource,
        arguments: messageSource, replace: !Platform.isIOS, fade: true);
  }
}
