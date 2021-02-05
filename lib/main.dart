import 'dart:async';
import 'package:enough_mail_app/routes.dart';
import 'package:enough_mail_app/services/app_service.dart';
import 'package:enough_mail_app/services/background_service.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/services/notification_service.dart';
import 'package:enough_mail_app/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:enough_style/enough_style.dart';
// import 'app_styles.dart';
import 'locator.dart';

// AppStyles appStyles = AppStyles.instance;

void main() {
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Future<void> _appInitialization;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _appInitialization = initApp();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    locator<AppService>().didChangeAppLifecycleState(state);
  }

  Future<void> initApp() async {
    await locator<SettingsService>().init();
    final mailService = locator<MailService>();
    await mailService.init();

    if (mailService.messageSource != null) {
      /// the app has at least one configured account
      locator<NavigationService>().push(Routes.messageSource,
          arguments: mailService.messageSource, fade: true, replace: true);
      // check for a tapped notification that started the app:
      final notificationInitResult =
          await locator<NotificationService>().init();
      if (notificationInitResult !=
          NotificationServiceInitResult.appLaunchedByNotification) {
        // the app has not been launched by a notification
        await locator<AppService>().checkForShare();
      }
    } else {
      // this app has no mail accounts yet, so switch to welcome screen:
      locator<NavigationService>()
          .push(Routes.welcome, fade: true, replace: true);
    }
    await locator<BackgroundService>().init();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _appInitialization,
      builder: (context, snapshot) {
        return buildApp(context);
        // if (snapshot.connectionState == ConnectionState.done) {
        //   return buildApp(context);
        // } else {
        //   return Splash();
        // }
      },
    );
  }

  Widget buildApp(BuildContext context) {
    //final mailService = locator<MailService>();
    // return StreamBuilder<StyleSheet>(
    //     stream: appStyles.styleSheetManager.streamController.stream,
    //     initialData: appStyles.styleSheetManager.current,
    //     builder: (context, snapshot) {
    //       print('switching to theme/stylesheet ${snapshot.data?.name}');
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        const Locale('en', ''),
        const Locale('de', ''),
      ],
      // localeResolutionCallback: (deviceLocale, supportedLocales) {
      //   print('new locale: $deviceLocale');
      //   if (!supportedLocales.contains(deviceLocale)) {
      //     deviceLocale = supportedLocales.firstWhere(
      //         (l) => l.languageCode == deviceLocale.languageCode,
      //         orElse: () => supportedLocales.first);
      //     print('adjusted locale to $deviceLocale');
      //   }
      //   intl.initializeDateFormatting(deviceLocale.toString());
      //   return deviceLocale;
      // },
      debugShowCheckedModeBanner: false,
      title: 'Enough Mail',
      // theme: snapshot.data.themeData,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: Routes.splash,
      //mailService.current == null ? Routes.welcome : Routes.mailbox,
      navigatorKey: locator<NavigationService>().navigatorKey,
    );
    // });
  }
}
