import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/events/account_change_event.dart';
import 'package:enough_mail_app/events/app_event_bus.dart';
import 'package:enough_mail_app/locator.dart';
import 'package:enough_mail_app/models/account.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import '../routes.dart';

class AppDrawer extends StatefulWidget {
  AppDrawer({Key key}) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  void initState() {
    AppEventBus.eventBus.on<AccountChangeEvent>().listen((event) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mailService = locator<MailService>();
    final theme = Theme.of(context);
    final currentAccount = mailService.currentAccount;
    final accounts = mailService.accounts;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Material(
              elevation: 18,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildAccountHeader(currentAccount, theme),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                //physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildAccountSelection(accounts, currentAccount),
                    buildFolderTree(mailService, currentAccount),
                  ],
                ),
              ),
            ),
            Material(
              elevation: 18,
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
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

  Widget buildAccountHeader(Account currentAccount, ThemeData theme) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: theme.secondaryHeaderColor,
          backgroundImage: currentAccount.isVirtual
              ? null
              : NetworkImage(
                  currentAccount.imageUrlGravator,
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
    );
  }

  Widget buildAccountSelection(List<Account> accounts, Account currentAccount) {
    if (accounts.length > 1) {
      return ExpansionTile(
        title: Text('${accounts.length} accounts'),
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
            ),
          },
          buildAddAccountTile(),
        ],
      );
    } else {
      return buildAddAccountTile();
    }
  }

  Widget buildAddAccountTile() {
    return ListTile(
      leading: Icon(Icons.add),
      title: Text('Add account'),
      onTap: () {
        final navService = locator<NavigationService>();
        navService.pop();
        navService.push(Routes.accountAdd);
      },
    );
  }

  Widget buildFolderTree(MailService mailService, Account account) {
    final mailboxTreeData = mailService.getMailboxTreeFor(account);
    final mailboxTreeElements = mailboxTreeData.root.children;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final element in mailboxTreeElements) ...{
          buildMailboxElement(element, 0),
        },
      ],
    );
  }

  Widget buildMailboxElement(TreeElement<Mailbox> element, final int level) {
    final title = Padding(
      padding: EdgeInsets.only(left: level * 8.0),
      child: Text(element.value.name),
    );
    if (element.children == null) {
      var iconData = MaterialCommunityIcons.folder_outline;
      if (element.value.isInbox) {
        iconData = MaterialCommunityIcons.inbox;
      } else if (element.value.isDrafts) {
        iconData = MaterialCommunityIcons.email_edit_outline;
      } else if (element.value.isTrash) {
        iconData = MaterialCommunityIcons.trash_can_outline;
      } else if (element.value.isSent) {
        iconData = MaterialCommunityIcons.inbox_arrow_up;
      } else if (element.value.isArchive) {
        iconData = MaterialCommunityIcons.archive;
      } else if (element.value.isJunk) {
        iconData = MaterialCommunityIcons.emoticon_angry_outline;
      }
      return ListTile(
        leading: Icon(iconData),
        title: title,
        onTap: () async => navigateToMailbox(element.value),
      );
    }
    return ExpansionTile(
      title: title,
      children: [
        for (final childElement in element.children) ...{
          buildMailboxElement(childElement, level + 1),
        },
      ],
    );
  }

  void navigateToMailbox(Mailbox mailbox) async {
    final navService = locator<NavigationService>();
    final mailService = locator<MailService>();
    navService.pop();
    final account = mailService.currentAccount;
    final messageSource =
        await mailService.getMessageSourceFor(account, mailbox: mailbox);
    navService.push(Routes.messageSource,
        arguments: messageSource, replace: true, fade: true);
  }
}
