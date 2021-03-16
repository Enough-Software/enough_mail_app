import 'dart:async';

import 'package:enough_mail_app/events/accounts_changed_event.dart';
import 'package:enough_mail_app/events/app_event_bus.dart';
import 'package:enough_mail_app/models/account.dart';
import 'package:enough_mail_app/screens/base.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:flutter/material.dart';

import '../locator.dart';
import '../routes.dart';

class SettingsAccountsScreen extends StatefulWidget {
  SettingsAccountsScreen({Key key}) : super(key: key);

  @override
  _SettingsAccountsScreenState createState() => _SettingsAccountsScreenState();
}

class _SettingsAccountsScreenState extends State<SettingsAccountsScreen> {
  List<Account> accounts;
  bool reorderAccounts = false;
  StreamSubscription eventsSubscription;

  @override
  void initState() {
    accounts = locator<MailService>().accounts.toList();
    eventsSubscription =
        AppEventBus.eventBus.on<AccountsChangedEvent>().listen((event) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    eventsSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Base.buildAppChrome(
      context,
      title: 'Accounts',
      content:
          reorderAccounts ? buildReorderableListView() : buildAccountSettings(),
    );
  }

  Widget buildAccountSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final account in accounts) ...{
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text(account.name),
            onTap: () => locator<NavigationService>()
                .push(Routes.accountEdit, arguments: account),
          ),
        },
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add account'),
          onTap: () => locator<NavigationService>().push(Routes.accountAdd),
        ),
        if (accounts.length > 1) ...{
          Padding(
            padding: EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  reorderAccounts = true;
                });
              },
              child: Text('Reorder accounts'),
            ),
          ),
        },
      ],
    );
  }

  Widget buildReorderableListView() {
    return WillPopScope(
      onWillPop: () {
        setState(() {
          reorderAccounts = false;
        });
        return Future.value(false);
      },
      child: ReorderableListView(
        onReorder: (oldIndex, newIndex) async {
          print('moved $oldIndex to $newIndex');
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
          for (final account in accounts) ...{
            ListTile(
              key: ValueKey(account),
              leading: Icon(Icons.account_circle),
              title: Text(account.name),
            ),
          },
        ],
      ),
    );
  }
}
