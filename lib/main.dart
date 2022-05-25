import 'dart:async';
import 'dart:io';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:enough_mail_app/routes.dart';
import 'package:enough_mail_app/screens/all_screens.dart';
import 'package:enough_mail_app/services/app_service.dart';
import 'package:enough_mail_app/services/background_service.dart';
import 'package:enough_mail_app/services/biometrics_service.dart';
import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_mail_app/services/key_service.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/services/notification_service.dart';
import 'package:enough_mail_app/services/scaffold_messenger_service.dart';
import 'package:enough_mail_app/services/settings_service.dart';
import 'package:enough_mail_app/services/theme_service.dart';
import 'package:enough_mail_app/widgets/inherited_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'locator.dart';
import '../l10n/app_localizations.g.dart';
// AppStyles appStyles = AppStyles.instance;

void main() {
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late Future<MailService> _appInitialization;
  ThemeMode _themeMode = ThemeMode.system;
  ThemeService? _themeService;
  Locale? _locale;
  bool _isInitialized = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _appInitialization = _initApp();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isInitialized) {
      locator<AppService>().didChangeAppLifecycleState(state);
    }
  }

  Future<MailService> _initApp() async {
    final settings = await locator<SettingsService>().init();
    final themeService = locator<ThemeService>();
    _themeService = themeService;
    themeService.addListener(() => setState(() {
          _themeMode = themeService.themeMode;
        }));
    themeService.init(settings);
    final i18nService = locator<I18nService>();
    final languageTag = settings.languageTag;
    if (languageTag != null) {
      final settingsLocale = AppLocalizations.supportedLocales
          .firstWhereOrNull((l) => l.toLanguageTag() == languageTag);
      if (settingsLocale != null) {
        final settingsLocalizations =
            await AppLocalizations.delegate.load(settingsLocale);
        i18nService.init(settingsLocalizations, settingsLocale);
        setState(() {
          _locale = settingsLocale;
        });
      }
    }
    final mailService = locator<MailService>();
    // key service is required before mail service due to Oauth configs
    await locator<KeyService>().init();
    await mailService.init(i18nService.localizations);

    if (mailService.messageSource != null) {
      final state = MailServiceWidget.of(context);
      if (state != null) {
        state.account = mailService.currentAccount;
        state.accounts = mailService.accounts;
      }
      // on ios show the app drawer:
      if (Platform.isIOS) {
        locator<NavigationService>().push(Routes.appDrawer, replace: true);
      }

      /// the app has at least one configured account
      locator<NavigationService>().push(Routes.messageSource,
          arguments: mailService.messageSource,
          fade: true,
          replace: !Platform.isIOS);
      // check for a tapped notification that started the app:
      final notificationInitResult =
          await locator<NotificationService>().init();
      if (notificationInitResult !=
          NotificationServiceInitResult.appLaunchedByNotification) {
        // the app has not been launched by a notification
        await locator<AppService>().checkForShare();
      }
      if (settings.enableBiometricLock) {
        locator<NavigationService>().push(Routes.lockScreen);
        final didAuthenticate =
            await locator<BiometricsService>().authenticate();
        if (didAuthenticate) {
          locator<NavigationService>().pop();
        }
      }
    } else {
      // this app has no mail accounts yet, so switch to welcome screen:
      locator<NavigationService>()
          .push(Routes.welcome, fade: true, replace: true);
    }
    if (BackgroundService.isSupported) {
      await locator<BackgroundService>().init();
    }
    _isInitialized = true;
    return mailService;
  }

  @override
  Widget build(BuildContext context) {
    return PlatformSnackApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: _locale,
      debugShowCheckedModeBanner: false,
      title: 'Maily',
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: Routes.splash,
      navigatorKey: locator<NavigationService>().navigatorKey,
      scaffoldMessengerKey:
          locator<ScaffoldMessengerService>().scaffoldMessengerKey,
      builder: (context, child) {
        locator<I18nService>().init(
            AppLocalizations.of(context)!, Localizations.localeOf(context));
        child ??= FutureBuilder<MailService>(
          future: _appInitialization,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
              case ConnectionState.active:
                return const SplashScreen();
              case ConnectionState.done:
                // in the meantime the app has navigated away
                break;
            }
            return Container();
          },
        );
        final mailService = locator<MailService>();
        return MailServiceWidget(
          account: mailService.currentAccount,
          accounts: mailService.accounts,
          messageSource: mailService.messageSource,
          child: child,
        );
      },
      // home: Builder(
      //   builder: (context) {
      //     locator<I18nService>().init(
      //         AppLocalizations.of(context)!, Localizations.localeOf(context));
      //     return FutureBuilder<MailService>(
      //       future: _appInitialization,
      //       builder: (context, snapshot) {
      //         switch (snapshot.connectionState) {
      //           case ConnectionState.none:
      //           case ConnectionState.waiting:
      //           case ConnectionState.active:
      //             return SplashScreen();
      //           case ConnectionState.done:
      //             // in the meantime the app has navigated away
      //             break;
      //         }
      //         return Container();
      //       },
      //     );
      //   },
      // ),
      materialTheme:
          _themeService?.lightTheme ?? ThemeService.defaultLightTheme,
      materialDarkTheme:
          _themeService?.darkTheme ?? ThemeService.defaultDarkTheme,
      materialThemeMode: _themeMode,
      cupertinoTheme: const CupertinoThemeData(
        brightness: Brightness.light,
        //TODO support theming on Cupertino
      ),
    );
  }
}
