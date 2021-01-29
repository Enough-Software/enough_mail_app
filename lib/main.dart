import 'dart:async';
import 'dart:io';

import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/routes.dart';
import 'package:enough_mail_app/services/background_service.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/services/notification_service.dart';
import 'package:enough_mail_app/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:enough_style/enough_style.dart';
// import 'app_styles.dart';
import 'locator.dart';
import 'models/compose_data.dart';

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
  static const platform = const MethodChannel('app.channel.shared.data');

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
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print('state = $state');
    switch (state) {
      case AppLifecycleState.resumed:
        await checkForShare();
        break;
      case AppLifecycleState.inactive:
        // TODO: Check if AppLifecycleState.inactive needs to be handled
        break;
      case AppLifecycleState.paused:
        await locator<BackgroundService>().saveStateOnPause();
        break;
      case AppLifecycleState.detached:
        // TODO: Check if AppLifecycleState.detached needs to be handled
        break;
    }
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
        await checkForShare();
      }
    } else {
      // this app has no mail accounts yet, so switch to welcome screen:
      locator<NavigationService>()
          .push(Routes.welcome, fade: true, replace: true);
    }
    await locator<BackgroundService>().init();
  }

  Future checkForShare() async {
    final shared = await platform.invokeMethod("getSharedData");
    print('checkForShare: received data: $shared');
    if (shared != null) {
      composeWithSharedData(shared);
    }
  }

  Future composeWithSharedData(String shared) async {
    // structure is:
    // mimetype:[<<uri>>,<<uri>>]:text
    final uriStartIndex = shared.indexOf(':[<<');
    final uriEndIndex = shared.indexOf('>>]:');
    if (uriStartIndex == -1 || uriEndIndex <= uriStartIndex) {
      print('invalid share: "$shared"');
      return Future.value();
    }
    final urls = shared
        .substring(uriStartIndex + ':[<<'.length, uriEndIndex)
        .split('>>, <<');
    print(urls);
    MessageBuilder builder;
    if (urls.first.startsWith('mailto:')) {
      builder = MessageBuilder.prepareMailtoBasedMessage(Uri.parse(urls.first),
          locator<MailService>().currentAccount.fromAddress);
    } else {
      final mediaTypeText = shared.substring(0, uriStartIndex);
      final mediaType = (mediaTypeText != 'null' &&
              mediaTypeText != null &&
              !mediaTypeText.contains('*'))
          ? MediaType.fromText(mediaTypeText)
          : null;
      builder = MessageBuilder();
      for (final url in urls) {
        final filePath = await FlutterAbsolutePath.getAbsolutePath(url);
        final file = File(filePath);
        //final file = File.fromUri(Uri.parse(url));
        MediaType fileMediaType = mediaType ?? _guessMediaTypeFromFile(file);
        await builder.addFile(file, fileMediaType);
      }
    }
    var sharedText = uriEndIndex < (shared.length - '>>]:'.length)
        ? shared.substring(uriEndIndex + '>>]:'.length)
        : null;
    if (sharedText != null && sharedText != 'null') {
      builder.text = sharedText;
    }

    final composeData = ComposeData(null, builder, ComposeAction.newMessage);
    return locator<NavigationService>()
        .push(Routes.mailCompose, arguments: composeData, fade: true);
  }

  MediaType _guessMediaTypeFromFile(File file) {
    print('guess media type for "${file.path}"...');
    final extIndex = file.path.lastIndexOf('.');
    if (extIndex != -1) {
      final ext = file.path.substring(extIndex + 1);
      return MediaType.guessFromFileExtension(ext);
    }
    return MediaType.fromSubtype(MediaSubtype.applicationOctetStream);
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
