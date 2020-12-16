import 'package:enough_mail_app/routes.dart';
import 'package:enough_mail_app/screens/base.dart';
// import 'package:enough_style/enough_style.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Base.buildAppChrome(
      context,
      title: 'Enough Mail',
      content: Center(
        child: Column(
          children: <Widget>[
            Text('Home sweet home'),
            ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, Routes.settings),
                child: Text('Settings')),
            ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, Routes.accountAdd),
                child: Text('Add Account'))
          ],
        ),
      ),
    );
  }
}
