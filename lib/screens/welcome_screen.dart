import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../localization/app_localizations.g.dart';
import '../localization/extension.dart';
import '../routes.dart';
import '../settings/theme/icon_service.dart';
import '../widgets/button_text.dart';
import '../widgets/legalese.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = context.text;
    final pages = _buildPages(context, localizations);

    return Theme(
      data: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
      ),
      child: SafeArea(
        child: PlatformScaffold(
          body: IntroductionScreen(
            pages: pages,
            done: ButtonText(localizations.actionDone),
            onDone: () {
              context.goNamed(
                Routes.accountAdd,
                queryParameters: {'welcome': 'true'},
              );
            },
            next: ButtonText(localizations.actionNext),
            skip: ButtonText(localizations.actionSkip),
            showSkipButton: true,
          ),
        ),
      ),
    ); //Material App
  }

  List<PageViewModel> _buildPages(
    BuildContext context,
    AppLocalizations localizations,
  ) =>
      [
        PageViewModel(
          title: localizations.welcomePanel1Title,
          body: localizations.welcomePanel1Text,
          image: Image.asset(
            'assets/images/maily.png',
            height: 200,
            fit: BoxFit.cover,
          ),
          decoration: PageDecoration(pageColor: Colors.green[700]),
          footer: _buildFooter(context, localizations),
        ),
        PageViewModel(
          title: localizations.welcomePanel2Title,
          body: localizations.welcomePanel2Text,
          image: Image.asset(
            'assets/images/mailboxes.png',
            height: 200,
            fit: BoxFit.cover,
          ),
          decoration: const PageDecoration(pageColor: Color(0xff543226)),
          footer: _buildFooter(context, localizations),
        ),
        PageViewModel(
          title: localizations.welcomePanel3Title,
          body: localizations.welcomePanel3Text,
          image: Image.asset(
            'assets/images/swipe_press.png',
            height: 200,
            fit: BoxFit.cover,
          ),
          decoration: const PageDecoration(pageColor: Color(0xff761711)),
          footer: _buildFooter(context, localizations),
        ),
        PageViewModel(
          title: localizations.welcomePanel4Title,
          body: localizations.welcomePanel4Text,
          image: Image.asset(
            'assets/images/drawing.jpg',
            height: 200,
            fit: BoxFit.cover,
          ),
          footer: _buildFooter(context, localizations),
        ),
      ];

  Widget _buildFooter(BuildContext context, AppLocalizations localizations) =>
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Shimmer(
              duration: const Duration(seconds: 4),
              interval: const Duration(seconds: 6),
              child: PlatformFilledButtonIcon(
                icon: Icon(IconService.instance.email),
                label: Center(
                  child: PlatformText(localizations.welcomeActionSignIn),
                ),
                onPressed: () {
                  context.goNamed(
                    Routes.accountAdd,
                    queryParameters: {'welcome': 'true'},
                  );
                },
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Legalese(),
          ),
        ],
      );
}
