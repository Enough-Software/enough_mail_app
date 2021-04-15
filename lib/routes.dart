import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/account.dart';
import 'package:enough_mail_app/models/compose_data.dart';
import 'package:enough_mail_app/models/message.dart';
import 'package:enough_mail_app/models/message_source.dart';
import 'package:enough_mail_app/screens/all_screens.dart';
import 'package:enough_media/enough_media.dart';
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
  static const String settingsDeveloperMode = 'settingsDeveloperMode';
  static const String settingsSwipe = 'settingsSwipe';
  static const String messageSource = 'messageSource';
  static const String mailDetails = 'mailDetails';
  static const String mailContents = 'mailContents';
  static const String mailCompose = 'mailCompose';
  static const String welcome = 'welcome';
  static const String splash = 'splash';
  static const String interactiveMedia = 'interactiveMedia';
  static const String locationPicker = 'locationPicker';
  static const String sourceCode = 'sourceCode';
}

class AppRouter {
  static Widget generatePage(String name, Object arguments) {
    Widget page;
    switch (name) {
      case Routes.accountAdd:
        page = AccountAddScreen();
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
      case Routes.settingsDeveloperMode:
        page = SettingsDeveloperModeScreen();
        break;
      case Routes.settingsSwipe:
        page = SettingsSwipeScreen();
        break;
      case Routes.messageSource:
        page = MessageSourceScreen(arguments as MessageSource);
        break;
      case Routes.mailDetails:
        final message = arguments as Message;
        page = MessageDetailsScreen(message: message);
        break;
      case Routes.mailContents:
        final message = arguments as Message;
        page = MessageContentsScreen(message: message);
        break;
      case Routes.mailCompose:
        final composeData = arguments as ComposeData;
        page = ComposeScreen(data: composeData);
        break;
      case Routes.interactiveMedia:
        final mediaViewer = arguments as InteractiveMediaWidget;
        page = InteractiveMediaScreen(mediaWidget: mediaViewer);
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
        final mime = arguments as MimeMessage;
        page = SourceCodeScreen(mimeMessage: mime);
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
    return MaterialPageRoute(builder: (_) => page);
  }
}
