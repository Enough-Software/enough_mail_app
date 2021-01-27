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
      title: 'Maily',
      includeDrawer: false,
      content: ActionPageView(
        children: [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to Maily, your fast and no-fuss email app.',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: Image(
                      image: AssetImage('assets/images/maily.png'),
                      fit: BoxFit.contain),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: Text(
                'You can define and use aliases and even let Maily generate + aliases, when your provider supports them.'
                '\n\nFor example: "your-mail+shopping@domain.com"',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: Text(
                'Add an account to start.\n\nYou can also add several accounts.'
                '\n\n\nYou can also search across all your accounts at the same time.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ),
          )
        ],
        action: ElevatedButton.icon(
          icon: Icon(Icons.add),
          label: Text('Sign into your mail account'),
          onPressed: () {
            locator<NavigationService>().push(Routes.accountAdd);
          },
        ),
        gradients: [
          [Color(0xff99cc00), Color(0xff669900)],
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
