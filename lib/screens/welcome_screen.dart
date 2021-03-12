import 'package:enough_mail_app/routes.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:flutter/material.dart';

import '../locator.dart';

import 'dart:math';
import 'package:liquid_swipe/liquid_swipe.dart';

class WelcomeScreen extends StatefulWidget {
  static final style = TextStyle(
    fontSize: 30,
    fontFamily: "Billy",
    fontWeight: FontWeight.w600,
  );

  WelcomeScreen({Key key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int page = 0;
  LiquidController liquidController;
  UpdateType updateType;

  @override
  void initState() {
    liquidController = LiquidController();
    super.initState();
  }

  Widget _buildDot(int index) {
    final selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - (page - index).abs(),
      ),
    );
    final zoom = 1.0 + (2.0 - 1.0) * selectedness;
    return new Container(
      width: 25.0,
      child: new Center(
        child: new Material(
          color: Colors.white,
          type: MaterialType.circle,
          child: new Container(
            width: 8.0 * zoom,
            height: 8.0 * zoom,
          ),
        ),
      ),
    );
  }

  //final PageController _pageController = PageController(initialPage: 0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildOnboardingArea(),
    );
  }

  Widget _buildOnboardingArea() {
    final pages = buildPages();
    return Stack(
      children: [
        LiquidSwipe(
          pages: pages,
          positionSlideIcon: 0.8,
          slideIconWidget: Icon(Icons.arrow_back_ios),
          onPageChangeCallback: (value) {
            setState(() {
              page = value;
            });
          },
          waveType: WaveType.liquidReveal,
          liquidController: liquidController,
          ignoreUserGestureWhileAnimating: true,
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            children: [
              Expanded(child: SizedBox()),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(pages.length, _buildDot),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  icon: Icon(Icons.email),
                  label: Text('Sign into your mail account'),
                  onPressed: () {
                    locator<NavigationService>().push(Routes.accountAdd);
                  },
                ),
              ),
            ],
          ),
        ),

      ],
    );
  }

  List<Widget> buildPages() {
    return [
      Container(
        color: Colors.green[700],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Center(
              child: Image.asset(
                'assets/images/maily.png',
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            Column(
              children: [
                Text(
                  'Welcome',
                  style: WelcomeScreen.style,
                ),
                Text(
                  'to Maily!',
                  style: WelcomeScreen.style,
                ),
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 20.0)),
          ],
        ),
      ),
      Container(
        color: Colors.deepPurpleAccent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(
              'assets/images/counting.png',
              fit: BoxFit.cover,
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
            ),
            Column(
              children: [
                Text(
                  "Add",
                  style: WelcomeScreen.style,
                ),
                Text(
                  "unlimited",
                  style: WelcomeScreen.style,
                ),
                Text(
                  "accounts.",
                  style: WelcomeScreen.style,
                ),
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 20.0)),
          ],
        ),
      ),
      Container(
        color: Colors.pink,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(
              'assets/images/letterboxes.jpg',
              fit: BoxFit.cover,
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
            ),
            Column(
              children: [
                Text(
                  "Manage your email",
                  style: WelcomeScreen.style,
                ),
                Text(
                  "efficiently.",
                  style: WelcomeScreen.style,
                ),
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 20.0)),
          ],
        ),
      ),
      Container(
        color: Colors.yellowAccent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(
              'assets/images/drawing.jpg',
              fit: BoxFit.cover,
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
            ),
            Column(
              children: [
                Text(
                  'Unsubcribe newsletters',
                  style: WelcomeScreen.style,
                ),
                Text(
                  'with just one',
                  style: WelcomeScreen.style,
                ),
                Text(
                  'tap.',
                  style: WelcomeScreen.style,
                ),
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 20.0)),
          ],
        ),
      ),
    ];
  }
}
