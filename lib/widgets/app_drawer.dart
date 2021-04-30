import 'dart:async';

import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/events/accounts_changed_event.dart';
import 'package:enough_mail_app/events/app_event_bus.dart';
import 'package:enough_mail_app/locator.dart';
import 'package:enough_mail_app/models/account.dart';
import 'package:enough_mail_app/services/icon_service.dart';
import 'package:enough_mail_app/util/dialog_helper.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/widgets/mailbox_tree.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../routes.dart';

class AppDrawer extends StatefulWidget {
  AppDrawer({Key key}) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  StreamSubscription eventSubscription;

  @override
  void initState() {
    eventSubscription =
        AppEventBus.eventBus.on<AccountsChangedEvent>().listen((event) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    eventSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mailService = locator<MailService>();
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final currentAccount = mailService.currentAccount;
    var accounts = mailService.accounts;
    if (mailService.hasUnifiedAccount) {
      accounts = accounts.toList();
      accounts.insert(0, mailService.unifiedAccount);
    }
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Material(
              elevation: 18,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildAccountHeader(
                    currentAccount, mailService.accounts, theme),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                //physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildAccountSelection(
                        mailService, accounts, currentAccount, localizations),
                    buildFolderTree(currentAccount),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.info),
                      title: Text(localizations.drawerEntryAbout),
                      onTap: () {
                        DialogHelper.showAbout(context);
                      },
                    )
                  ],
                ),
              ),
            ),
            Material(
              elevation: 18,
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text(localizations.drawerEntrySettings),
                onTap: () {
                  final navService = locator<NavigationService>();
                  navService.pop();
                  navService.push(Routes.settings);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildAccountHeader(
      Account currentAccount, List<Account> accounts, ThemeData theme) {
    final avatarAccount =
        currentAccount.isVirtual ? accounts.first : currentAccount;
    return ListTile(
      onTap: () {
        final navService = locator<NavigationService>();
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
              avatarAccount.imageUrlGravator,
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
              children: <Widget>[
                Text(
                  currentAccount.name ?? '',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  currentAccount.userName ?? '',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
                ),
                Text(
                  currentAccount.email ?? '',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAccountSelection(MailService mailService, List<Account> accounts,
      Account currentAccount, AppLocalizations localizations) {
    if (accounts.length > 1) {
      return ExpansionTile(
        title: Text(localizations
            .drawerAccountsSectionTitle(mailService.accounts.length)),
        children: [
          for (final account in accounts) ...{
            ListTile(
              title: Text(account.name),
              selected: account == currentAccount,
              onTap: () async {
                final navService = locator<NavigationService>();
                navService.pop();
                final messageSource = await locator<MailService>()
                    .getMessageSourceFor(account, switchToAccount: true);
                navService.push(Routes.messageSource,
                    arguments: messageSource, replace: true, fade: true);
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
          buildAddAccountTile(localizations),
        ],
      );
    } else {
      return buildAddAccountTile(localizations);
    }
  }

  Widget buildAddAccountTile(AppLocalizations localizations) {
    return ListTile(
      leading: Icon(Icons.add),
      title: Text(localizations.drawerEntryAddAccount),
      onTap: () {
        final navService = locator<NavigationService>();
        navService.pop();
        navService.push(Routes.accountAdd);
      },
    );
  }

  Widget buildFolderTree(Account account) {
    return MailboxTree(account: account, onSelected: navigateToMailbox);
  }

  void navigateToMailbox(Mailbox mailbox) async {
    final mailService = locator<MailService>();
    final account = mailService.currentAccount;
    final messageSource =
        await mailService.getMessageSourceFor(account, mailbox: mailbox);
    locator<NavigationService>().push(Routes.messageSource,
        arguments: messageSource, replace: true, fade: true);
  }
}
