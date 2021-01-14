import 'package:enough_mail_app/models/account.dart';
import 'package:enough_mail_app/models/compose_data.dart';
import 'package:enough_mail_app/models/message.dart';
import 'package:enough_mail_app/models/message_source.dart';
import 'package:enough_mail_app/screens/all_screens.dart';
import 'package:enough_mail_flutter/enough_mail_flutter.dart';
import 'package:flutter/material.dart';

class Routes {
  static const String home = '/';
  static const String accountAdd = 'accountAdd';
  static const String accountEdit = 'accountEdit';
  static const String accountServerDetails = 'accountServerDetails';
  static const String settings = 'settings';
  static const String messageSource = 'messageSource';
  static const String mailDetails = 'mailDetails';
  static const String mailCompose = 'mailCompose';
  static const String welcome = 'welcome';
  static const String splash = 'splash';

  static const String mediaViewer = 'mediaViewer';
}

class AppRouter {
  static Widget generatePage(String name, Object arguments) {
    Widget page;
    switch (name) {
      case Routes.home:
        page = HomeScreen();
        break;
      case Routes.settings:
        page = SettingsScreen();
        break;
      case Routes.accountAdd:
        page = AccountAddScreen();
        break;
      case Routes.accountServerDetails:
        page = AccountServerDetailsScreen(account: arguments as Account);
        break;
      case Routes.accountEdit:
        page = AccountEditScreen(account: arguments as Account);
        break;
      case Routes.messageSource:
        page = MessageSourceScreen(arguments as MessageSource);
        break;
      case Routes.mailDetails:
        var message = arguments as Message;
        page = MessageDetailsScreen(message: message);
        break;
      case Routes.mailCompose:
        var composeData = arguments as ComposeData;
        page = ComposeScreen(data: composeData);
        break;
      case Routes.mediaViewer:
        final mediaViewer = arguments as MediaViewer;
        page = MediaScreen(mediaViewer: mediaViewer);
        break;
      case Routes.splash:
        page = SplashScreen();
        break;
      case Routes.welcome:
        page = WelcomeScreen();
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
