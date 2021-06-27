import 'package:enough_mail_app/routes.dart';
import 'package:enough_mail_app/services/icon_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/widgets/button_text.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../locator.dart';

import 'dart:math';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WelcomeScreen extends StatefulWidget {
  static final textStyleLight = TextStyle(
    fontSize: 26,
    fontFamily: "Billy",
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  static final textStyleDark = TextStyle(
    fontSize: 26,
    fontFamily: "Billy",
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );
  WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int page = 0;
  LiquidController? liquidController;
  UpdateType? updateType;

  @override
  void initState() {
    liquidController = LiquidController();
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final localizations = AppLocalizations.of(context)!;
      DialogHelper.showTextDialog(context, localizations.welcomeBetaTitle,
          localizations.welcomeBetaText);
    });
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
    return PlatformScaffold(
      body: _buildOnboardingArea(),
    );
  }

  Widget _buildOnboardingArea() {
    final localizations = AppLocalizations.of(context)!;
    final pages = buildPages(localizations);
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
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(pages.length, _buildDot),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Shimmer(
                    duration: const Duration(seconds: 4),
                    interval: const Duration(seconds: 6),
                    child: PlatformFilledButtonIcon(
                      icon: Icon(locator<IconService>().email),
                      label: ButtonText(localizations.welcomeActionSignIn),
                      onPressed: () {
                        locator<NavigationService>()
                            .push(Routes.accountAdd, arguments: true);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> buildPages(AppLocalizations localizations) {
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
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 24.0, 8.0),
              child: Text(
                localizations.welcomePanel1,
                style: WelcomeScreen.textStyleLight,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 20.0)),
          ],
        ),
      ),
      Container(
        color: Color(0xff543226),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 24.0, 8.0),
              child: Text(
                localizations.welcomePanel2,
                style: WelcomeScreen.textStyleLight,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 20.0)),
          ],
        ),
      ),
      Container(
        color: Color(0xff761711),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 24.0, 8.0),
              child: Text(
                localizations.welcomePanel3,
                style: WelcomeScreen.textStyleLight,
                textAlign: TextAlign.center,
              ),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 24.0, 8.0),
              child: Text(
                localizations.welcomePanel4,
                style: WelcomeScreen.textStyleDark,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 20.0)),
          ],
        ),
      ),
    ];
  }
}
