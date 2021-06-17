import 'dart:io';

import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/models.dart';
import 'package:enough_mail_app/screens/all_screens.dart';
import 'package:enough_mail_app/widgets/app_drawer.dart';
import 'package:enough_media/enough_media.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Routes {
  static const String home = '/';
  static const String accountAdd = 'accountAdd';
  static const String accountEdit = 'accountEdit';
  static const String accountServerDetails = 'accountServerDetails';
  static const String settings = 'settings';
  static const String settingsAccounts = 'settingsAccounts';
  static const String settingsDesign = 'settingsDesign';
  static const String settingsFeedback = 'settingsFeedback';
  static const String settingsLanguage = 'settingsLanguage';
  static const String settingsFolders = 'settingsFolders';
  static const String settingsReadReceipts = 'settingsReadReceipts';
  static const String settingsDevelopment = 'settingsDeveloperMode';
  static const String settingsSwipe = 'settingsSwipe';
  static const String settingsSignature = 'settingsSignature';
  static const String messageSource = 'messageSource';
  static const String mailDetails = 'mailDetails';
  static const String mailContents = 'mailContents';
  static const String mailCompose = 'mailCompose';
  static const String welcome = 'welcome';
  static const String splash = 'splash';
  static const String interactiveMedia = 'interactiveMedia';
  static const String locationPicker = 'locationPicker';
  static const String sourceCode = 'sourceCode';
  static const String webview = 'webview';
  static const String appDrawer = 'appDrawer';
  static const String search = 'search';
}

class AppRouter {
  static Widget generatePage(String? name, Object? arguments) {
    Widget page;
    switch (name) {
      case Routes.accountAdd:
        page = AccountAddScreen(
          launchedFromWelcome: (arguments == true),
        );
        break;
      case Routes.accountServerDetails:
        page = AccountServerDetailsScreen(account: arguments as Account);
        break;
      case Routes.accountEdit:
        page = AccountEditScreen(account: arguments as Account);
        break;
      case Routes.settings:
        page = SettingsScreen();
        break;
      case Routes.settingsAccounts:
        page = SettingsAccountsScreen();
        break;
      case Routes.settingsDesign:
        page = SettingsThemeScreen();
        break;
      case Routes.settingsFeedback:
        page = SettingsFeedbackScreen();
        break;
      case Routes.settingsLanguage:
        page = SettingsLanguageScreen();
        break;
      case Routes.settingsFolders:
        page = SettingsFoldersScreen();
        break;
      case Routes.settingsReadReceipts:
        page = SettingsReadReceiptsScreen();
        break;
      case Routes.settingsDevelopment:
        page = SettingsDeveloperModeScreen();
        break;
      case Routes.settingsSwipe:
        page = SettingsSwipeScreen();
        break;
      case Routes.settingsSignature:
        page = SettingsSignatureScreen();
        break;
      case Routes.messageSource:
        page = MessageSourceScreen(messageSource: arguments as MessageSource);
        break;
      case Routes.mailDetails:
        page = MessageDetailsScreen(message: arguments as Message);
        break;
      case Routes.mailContents:
        page = MessageContentsScreen(message: arguments as Message);
        break;
      case Routes.mailCompose:
        page = ComposeScreen(data: arguments as ComposeData);
        break;
      case Routes.interactiveMedia:
        page = InteractiveMediaScreen(
            mediaWidget: arguments as InteractiveMediaWidget);
        break;
      case Routes.locationPicker:
        page = LocationScreen();
        break;
      case Routes.splash:
        page = SplashScreen();
        break;
      case Routes.welcome:
        page = WelcomeScreen();
        break;
      case Routes.sourceCode:
        page = SourceCodeScreen(mimeMessage: arguments as MimeMessage);
        break;
      case Routes.webview:
        page = WebViewScreen(configuration: arguments as WebViewConfiguration);
        break;
      case Routes.appDrawer:
        page = AppDrawer();
        break;
      case Routes.search:
        page = SearchScreen(
          messageSource: arguments as MessageSource,
        );
        break;
      default:
        print('Unknown route: $name');
        page = Scaffold(
          body: Center(child: Text('No route defined for $name')),
        );
    }
    return page;
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final page = generatePage(settings.name, settings.arguments);
    return Platform.isAndroid
        ? MaterialPageRoute(builder: (_) => page)
        : CupertinoPageRoute(builder: (_) => page);
  }
}
