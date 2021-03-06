import 'package:enough_mail_app/routes.dart';
import 'package:enough_mail_app/services/icon_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/util/localized_dialog_helper.dart';
import 'package:enough_mail_app/widgets/button_text.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import '../locator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WelcomeScreen extends StatefulWidget {
  WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final localizations = AppLocalizations.of(context)!;
      LocalizedDialogHelper.showTextDialog(context,
          localizations.welcomeBetaTitle, localizations.welcomeBetaText);
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final pages = _buildPages(localizations);
    return Theme(
      data: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
      ),
      child: PlatformScaffold(
        body: IntroductionScreen(
          pages: pages,
          done: ButtonText(localizations.actionDone),
          onDone: () {
            locator<NavigationService>()
                .push(Routes.accountAdd, arguments: true);
          },
          showDoneButton: true,
          next: ButtonText(localizations.actionNext),
          showNextButton: true,
          skip: ButtonText(localizations.actionSkip),
          showSkipButton: true,
        ),
      ),
    ); //Material App
  }

  List<PageViewModel> _buildPages(AppLocalizations localizations) {
    return [
      PageViewModel(
        title: localizations.welcomePanel1Title,
        body: localizations.welcomePanel1Text,
        image: Image.asset(
          'assets/images/maily.png',
          height: 200,
          fit: BoxFit.cover,
        ),
        decoration: PageDecoration(pageColor: Colors.green[700]),
        footer: Padding(
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
      ),
      PageViewModel(
        title: localizations.welcomePanel2Title,
        body: localizations.welcomePanel2Text,
        image: Image.asset(
          'assets/images/mailboxes.png',
          height: 200,
          fit: BoxFit.cover,
        ),
        decoration: PageDecoration(pageColor: Color(0xff543226)),
        footer: Padding(
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
      ),
      PageViewModel(
        title: localizations.welcomePanel3Title,
        body: localizations.welcomePanel3Text,
        image: Image.asset(
          'assets/images/swipe_press.png',
          height: 200,
          fit: BoxFit.cover,
        ),
        decoration: PageDecoration(pageColor: Color(0xff761711)),
        footer: Padding(
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
      ),
      PageViewModel(
        title: localizations.welcomePanel4Title,
        body: localizations.welcomePanel4Text,
        image: Image.asset(
          'assets/images/drawing.jpg',
          height: 200,
          fit: BoxFit.cover,
        ),
        footer: Padding(
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
      ),
    ];
  }
}
