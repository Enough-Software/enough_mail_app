import 'dart:async';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'account/providers.dart';
import 'app_lifecycle/provider.dart';
import 'l10n/app_localizations.g.dart';
import 'locator.dart';
import 'logger.dart';
import 'routes.dart';
import 'screens/screens.dart';
import 'services/background_service.dart';
import 'services/i18n_service.dart';
import 'services/scaffold_messenger_service.dart';
import 'settings/provider.dart';
import 'settings/theme/provider.dart';
// AppStyles appStyles = AppStyles.instance;

void main() {
  setupLocator();
  runApp(
    const ProviderScope(
      child: MailyApp(),
    ),
  );
}

class MailyApp extends HookConsumerWidget {
  const MailyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useOnAppLifecycleStateChange((previous, current) {
      logger.d('AppLifecycleState changed from $previous to $current');
      ref.read(appLifecycleStateProvider.notifier).state = current;
    });

    final themeSettingsData = ref.watch(themeProvider);
    final languageTag =
        ref.watch(settingsProvider.select((settings) => settings.languageTag));

    final app = PlatformSnackApp.router(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      debugShowCheckedModeBanner: false,
      title: 'Maily',
      routerConfig: Routes.routerConfig,
      scaffoldMessengerKey:
          locator<ScaffoldMessengerService>().scaffoldMessengerKey,
      // builder: (context, child) => Consumer(
      //   builder: (context, ref, child) {
      //     final languageTag =
      //         ref.watch(settingsProvider.select((value) => value.languageTag));
      //     final usedChild = child ?? const SplashScreen();

      //     return languageTag == null
      //         ? usedChild
      //         : Localizations.override(
      //             context: context,
      //             locale: Locale(languageTag),
      //             child: usedChild,
      //           );
      //   },
      // ),
      materialTheme: themeSettingsData.lightTheme,
      materialDarkTheme: themeSettingsData.darkTheme,
      materialThemeMode: themeSettingsData.themeMode,
      cupertinoTheme: CupertinoThemeData(
        brightness: themeSettingsData.brightness,
        applyThemeToAll: true,
        //TODO support theming on Cupertino
      ),
    );
    if (languageTag == null) {
      return app;
    }

    return Localizations.override(
      context: context,
      locale: Locale(languageTag),
      child: app,
    );
  }
}

class InitializationScreen extends ConsumerStatefulWidget {
  const InitializationScreen({super.key});

  @override
  ConsumerState<InitializationScreen> createState() => _InitializationScreen();
}

class _InitializationScreen extends ConsumerState<InitializationScreen> {
  late Future<void> _appInitialization;
  bool _isInitialized = false;

  @override
  void initState() {
    _appInitialization = _initApp();
    super.initState();
  }

  Future<void> _initApp() async {
    await ref.read(settingsProvider.notifier).init();
    if (context.mounted) {
      ref.read(themeProvider.notifier).init(context);
    }
    await ref.read(realAccountsProvider.notifier).init();

    final settings = ref.read(settingsProvider);

    final i18nService = locator<I18nService>();
    final languageTag = settings.languageTag ?? 'en';
    final settingsLocale = AppLocalizations.supportedLocales
        .firstWhereOrNull((l) => l.toLanguageTag() == languageTag);
    if (settingsLocale != null) {
      final settingsLocalizations =
          await AppLocalizations.delegate.load(settingsLocale);
      i18nService.init(settingsLocalizations, settingsLocale);
    }
    // final mailService = locator<MailService>();
    // // key service is required before mail service due to Oauth configs
    // await locator<KeyService>().init();
    // await mailService.init(i18nService.localizations, settings);

    // if (mailService.messageSource != null) {
    //   // on ios show the app drawer:
    //   if (Platform.isIOS) {
    //     await locator<NavigationService>()
    //         .push(Routes.appDrawer, replace: true);
    //   }

    //   /// the app has at least one configured account
    //   unawaited(locator<NavigationService>().push(
    //     Routes.messageSource,
    //     arguments: mailService.messageSource,
    //     fade: true,
    //     replace: !Platform.isIOS,
    //   ));
    //   // check for a tapped notification that started the app:
    //   final notificationInitResult =
    //       await locator<NotificationService>().init();
    //   if (notificationInitResult !=
    //       NotificationServiceInitResult.appLaunchedByNotification) {
    //     // the app has not been launched by a notification
    //     await locator<AppService>().checkForShare();
    //   }
    //   if (settings.enableBiometricLock) {
    //     unawaited(locator<NavigationService>().push(Routes.lockScreen));
    //     final didAuthenticate =
    //         await locator<BiometricsService>().authenticate();
    //     if (didAuthenticate) {
    //       locator<NavigationService>().pop();
    //     }
    //   }
    // } else {
    //   // this app has no mail accounts yet, so switch to welcome screen:
    //   unawaited(locator<NavigationService>()
    //       .push(Routes.welcome, fade: true, replace: true));
    // }
    if (BackgroundService.isSupported) {
      await locator<BackgroundService>().init();
    }
    // final usedContext = Routes.navigatorKey.currentContext ?? context;
    // if (usedContext.mounted) {
    //   usedContext.pushReplacement(Routes.home);
    // }

    logger.d('App initialized');
    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: _appInitialization,
        builder: (context, snapshot) {
          final done = snapshot.connectionState == ConnectionState.done;
          if (!done) {
            return const SplashScreen();
          }

          return const HomeScreen();
        },
      );
}
