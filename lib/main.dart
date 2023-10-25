import 'dart:async';

import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'account/provider.dart';
import 'app_lifecycle/provider.dart';
import 'background/provider.dart';
import 'keys/service.dart';
import 'localization/app_localizations.g.dart';
import 'lock/provider.dart';
import 'logger.dart';
import 'notification/service.dart';
import 'routes.dart';
import 'scaffold_messenger/service.dart';
import 'screens/screens.dart';
import 'settings/provider.dart';
import 'settings/theme/provider.dart';
import 'share/provider.dart';
// AppStyles appStyles = AppStyles.instance;

void main() {
  runApp(
    const ProviderScope(
      child: MailyApp(),
    ),
  );
}

/// Runs the app
class MailyApp extends HookConsumerWidget {
  /// Creates a new app
  const MailyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useOnAppLifecycleStateChange((previous, current) {
      logger.d('raw AppLifecycleState changed from $previous to $current');
      ref.read(rawAppLifecycleStateProvider.notifier).state = current;
    });

    final themeSettingsData = ref.watch(themeFinderProvider(context: context));
    final languageTag =
        ref.watch(settingsProvider.select((settings) => settings.languageTag));
    ref
      ..watch(incomingShareProvider)
      ..watch(backgroundProvider)
      ..watch(appLockProvider);

    final app = PlatformSnackApp.router(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      debugShowCheckedModeBanner: false,
      title: 'Maily',
      routerConfig: Routes.routerConfig,
      scaffoldMessengerKey:
          ScaffoldMessengerService.instance.scaffoldMessengerKey,
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

/// Initializes the app
class InitializationScreen extends ConsumerStatefulWidget {
  /// Creates a new [InitializationScreen]
  const InitializationScreen({super.key});

  @override
  ConsumerState<InitializationScreen> createState() =>
      _InitializationScreenState();
}

class _InitializationScreenState extends ConsumerState<InitializationScreen> {
  late Future<void> _appInitialization;

  @override
  void initState() {
    _appInitialization = _initApp();
    super.initState();
  }

  Future<void> _initApp() async {
    await ref.read(settingsProvider.notifier).init();
    await ref.read(realAccountsProvider.notifier).init();
    await ref.read(backgroundProvider.notifier).init();
    if (context.mounted) {
      await NotificationService.instance.init(context: context);
    }
    await KeyService.instance.init();
    if (PlatformInfo.isCupertino &&
        ref.read(realAccountsProvider).isNotEmpty &&
        context.mounted) {
      context.goNamed(Routes.appDrawer);
      unawaited(context.pushNamed(Routes.home));
    }

    logger.d('App initialized');
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
