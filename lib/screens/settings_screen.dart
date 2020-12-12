import 'package:enough_mail_app/app_styles.dart';
import 'package:enough_mail_app/models/account.dart';
import 'package:enough_mail_app/models/settings.dart';
import 'package:enough_mail_app/screens/account_edit_screen.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/services/settings_service.dart';
// import 'package:enough_style/enough_style.dart';
import 'package:flutter/material.dart';

import '../locator.dart';
import '../routes.dart';
import 'base.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingsScreenState();
  }
}

class _SettingsScreenState extends State<SettingsScreen> {
  Settings settings;
  bool blockExternalImages;

  @override
  void initState() {
    settings = locator<SettingsService>().settings;
    blockExternalImages = settings.blockExternalImages;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Base.buildAppChrome(
      context,
      title: 'Settings',
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: blockExternalImages,
                    onChanged: (value) async {
                      setState(() {
                        blockExternalImages = value;
                      });
                      settings.blockExternalImages = value;
                      await locator<SettingsService>().save();
                    },
                  ),
                  Text('Block external images'),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Accounts:'),
                    AccountList(),
                  ],
                ),
              ),
              // Stack(
              //   children: <Widget>[
              //     StyledContainer(
              //       styleName: 'page',
              //       child: _createStylesSection(),
              //     ),
              //     RaisedButton(
              //       onPressed: () => Navigator.pop(context),
              //       child: Text('Done'),
              //     )
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _createStylesSection() {
  //   var appStyles = AppStyles.instance;
  //   return Stack(
  //     children: <Widget>[
  //       Base.onCenter(
  //         StyledContainer(
  //           styleName: 'settings',
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: <Widget>[
  //               StyledText(
  //                 'Welcome',
  //                 //textAlign: TextAlign.center,
  //                 styleName: 'settingsOption',
  //               ),
  //               for (final sheet
  //                   in appStyles.styleSheetManager.styleSheets) ...[
  //                 RaisedButton(
  //                   child: Text(sheet.name),
  //                   onPressed: () {
  //                     appStyles.styleSheetManager.current = sheet;
  //                     setState(() {});
  //                   },
  //                 )
  //               ],
  //             ],
  //           ),
  //         ),
  //       )
  //     ],
  //   );
  // }
}

class AccountList extends StatefulWidget {
  AccountList({Key key}) : super(key: key);

  @override
  _AccountListState createState() => _AccountListState();
}

class _AccountListState extends State<AccountList> {
  @override
  Widget build(BuildContext context) {
    final accounts = locator<MailService>().accounts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final account in accounts) ...{
          _AccountOverview(
            account: account,
          ),
        },
        FlatButton(
          child: ListTile(
            leading: Icon(Icons.add),
            title: Text('Add account'),
          ),
          onPressed: () async =>
              await locator<NavigationService>().push(Routes.accountAdd),
        ),
      ],
    );
  }
}

class _AccountOverview extends StatefulWidget {
  final Account account;
  _AccountOverview({Key key, @required this.account}) : super(key: key);

  _AccountOverviewState createState() => _AccountOverviewState();
}

class _AccountOverviewState extends State<_AccountOverview> {
  void _update() {
    setState(() {});
  }

  @override
  void initState() {
    widget.account.addListener(_update);
    super.initState();
  }

  @override
  void dispose() {
    widget.account.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.account_circle),
      title: Text(widget.account.name),
      onTap: () => locator<NavigationService>()
          .push(Routes.accountEdit, arguments: widget.account),
    );
  }
}
