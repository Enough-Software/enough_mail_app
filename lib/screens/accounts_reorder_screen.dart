import 'package:enough_mail_app/models/account.dart';
import 'package:enough_mail_app/screens/base.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:flutter/material.dart';

import '../locator.dart';

class AccountsReorderScreen extends StatefulWidget {
  AccountsReorderScreen({Key key}) : super(key: key);

  @override
  _AccountsReorderScreenState createState() => _AccountsReorderScreenState();
}

class _AccountsReorderScreenState extends State<AccountsReorderScreen> {
  List<Account> accounts;

  @override
  void initState() {
    accounts = locator<MailService>().accounts.toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Base.buildAppChrome(
      context,
      title: 'Accounts',
      content: ReorderableListView(
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
