import 'package:enough_mail_app/routes.dart';
import 'package:enough_mail_app/screens/base.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/widgets/action_page_view.dart';
import 'package:flutter/material.dart';

import '../locator.dart';

class WelcomeScreen extends StatefulWidget {
  WelcomeScreen({Key key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  //final PageController _pageController = PageController(initialPage: 0);
  @override
  Widget build(BuildContext context) {
    return Base.buildAppChrome(
      context,
      title: 'Welcome',
      content: ActionPageView(
        children: [
          Text(
            'Welcome to Maily, your fast and no-fuss email app.',
            style: TextStyle(color: Colors.white),
          ),
          Text(
            'You can define and use aliases and even let Maily generate + aliases, when your provider supports them.',
            style: TextStyle(color: Colors.white),
          ),
          Text(
            'Add an account to start.\n\nYou can also add several accounts.',
            style: TextStyle(color: Colors.white),
          )
        ],
        action: ElevatedButton(
          onPressed: () {
            locator<NavigationService>().push(Routes.accountAdd);
          },
          child: Row(
              children: [Icon(Icons.add), Text('Sign into your mail account')]),
        ),
        gradients: [
          [Colors.green[700], Colors.green[900]],
          [Colors.orange[700], Colors.orange[900]],
          [Colors.blue, Colors.blue[800]]
        ],
      ),
      //  Column(
      //   children: [
      //     Expanded(
      //       child: PageView(
      //         controller: _pageController,
      //         children: [
      //           Text('It\'s email!'),
      //           Text('Let\'s get personal.'),
      //           Text('Hey, add an account to start...please!')
      //         ],
      //       ),
      //     ),
      //     ElevatedButton(
      //       onPressed: () {
      //         locator<NavigationService>().push(Routes.accountAdd);
      //       },
      //       child: Row(children: [
      //         Icon(Icons.add),
      //         Text('Sign into your mail account')
      //       ]),
      //     )
      //   ],
      // ),
    );
  }
}
