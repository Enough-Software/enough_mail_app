import 'dart:io';

import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/models.dart';
import 'package:enough_mail_app/screens/all_screens.dart';
import 'package:enough_mail_app/widgets/app_drawer.dart';
import 'package:enough_media/enough_media.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Routes {
  static const String home = '/';
  static const String accountAdd = '/accountAdd';
  static const String accountEdit = '/accountEdit';
  static const String accountServerDetails = '/accountServerDetails';
  static const String settings = '/settings';
  static const String settingsSecurity = '/settings/security';
  static const String settingsAccounts = '/settings/accounts';
  static const String settingsDesign = '/settings/design';
  static const String settingsFeedback = '/settings/feedback';
  static const String settingsLanguage = '/settings/language';
  static const String settingsFolders = '/settings/folders';
  static const String settingsReadReceipts = '/settings/readReceipts';
  static const String settingsDevelopment = '/settings/developerMode';
  static const String settingsSwipe = '/settings/swipe';
  static const String settingsSignature = '/settingsSignature';
  static const String settingsDefaultSender = '/settingsDefaultSender';
  static const String settingsReplyFormat = '/settingsReplyFormat';
  static const String messageSource = '/messageSource';
  static const String messageSourceFuture = '/messageSource/future';
  static const String mailDetails = '/mailDetails';
  static const String mailContents = '/mailContents';
  static const String mailCompose = '/mailCompose';
  static const String welcome = '/welcome';
  static const String splash = '/';
  static const String interactiveMedia = '/interactiveMedia';
  static const String locationPicker = '/locationPicker';
  static const String sourceCode = '/sourceCode';
  static const String webview = '/webview';
  static const String appDrawer = '/appDrawer';
  static const String lockScreen = '/lock';
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
        page = AccountServerDetailsScreen(account: arguments as RealAccount);
        break;
      case Routes.accountEdit:
        page = AccountEditScreen(account: arguments as RealAccount);
        break;
      case Routes.settings:
        page = const SettingsScreen();
        break;
      case Routes.settingsSecurity:
        page = const SettingsSecurityScreen();
        break;
      case Routes.settingsAccounts:
        page = const SettingsAccountsScreen();
        break;
      case Routes.settingsDesign:
        page = const SettingsThemeScreen();
        break;
      case Routes.settingsFeedback:
        page = const SettingsFeedbackScreen();
        break;
      case Routes.settingsLanguage:
        page = const SettingsLanguageScreen();
        break;
      case Routes.settingsFolders:
        page = const SettingsFoldersScreen();
        break;
      case Routes.settingsReadReceipts:
        page = const SettingsReadReceiptsScreen();
        break;
      case Routes.settingsDevelopment:
        page = const SettingsDeveloperModeScreen();
        break;
      case Routes.settingsSwipe:
        page = const SettingsSwipeScreen();
        break;
      case Routes.settingsSignature:
        page = const SettingsSignatureScreen();
        break;
      case Routes.settingsDefaultSender:
        page = const SettingsDefaultSenderScreen();
        break;
      case Routes.settingsReplyFormat:
        page = const SettingsReplyScreen();
        break;
      case Routes.messageSourceFuture:
        page = AsyncMessageSourceScreen(
            messageSourceFuture: arguments as Future<MessageSource>);
        break;
      case Routes.messageSource:
        page = MessageSourceScreen(messageSource: arguments as MessageSource);
        break;
      case Routes.mailDetails:
        if (arguments is Message) {
          page = MessageDetailsScreen(message: arguments);
        } else if (arguments is DisplayMessageArguments) {
          page = MessageDetailsScreen(
            message: arguments.message,
            blockExternalContents: arguments.blockExternalContent,
          );
        } else {
          page = const WelcomeScreen();
        }
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
        page = const LocationScreen();
        break;
      case Routes.splash:
        page = const SplashScreen();
        break;
      case Routes.welcome:
        page = const WelcomeScreen();
        break;
      case Routes.sourceCode:
        page = SourceCodeScreen(mimeMessage: arguments as MimeMessage);
        break;
      case Routes.webview:
        page = WebViewScreen(configuration: arguments as WebViewConfiguration);
        break;
      case Routes.appDrawer:
        page = const AppDrawer();
        break;
      case Routes.lockScreen:
        page = const LockScreen();
        break;
      default:
        if (kDebugMode) {
          print('Unknown route: $name');
        }
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
