import 'package:enough_mail/enough_mail.dart';
import 'package:enough_media/enough_media.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'account/model.dart';
import 'main.dart';
import 'models/models.dart';
import 'notification/model.dart';
import 'screens/screens.dart';
import 'settings/view/view.dart';

/// Defines app navigation routes
class Routes {
  Routes._();

  /// The root route
  static const String _root = '/';

  /// Displays either the welcome screen or the mail screen
  /// for the default account
  static const String home = '/home';

  /// Creates a new account
  static const String accountAdd = '/accountAdd';

  /// Allows to edit a single account
  ///
  /// pathParameters: [pathParameterEmail]
  static const String accountEdit = '/accountEdit';

  /// Allows to edit a the account server settings
  ///
  /// pathParameters: [pathParameterEmail] or
  /// extra: [RealAccount]
  static const String accountServerDetails = '/accountServerDetails';

  /// Displays messages of the given account
  ///
  /// pathParameters: [pathParameterEmail]
  /// queryParameters: [queryParameterEncodedMailboxPath]
  static const String mail = '/mail';

  /// Displays the settings
  static const String settings = '/settings';
  static const String settingsSecurity = '/settings/security';

  /// Displays the settings for all accounts
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

  /// Displays a message source directly
  ///
  /// extra: [MessageSource]
  static const String messageSource = '/messageSource';
  static const String messageSourceFuture = '/messageSource/future';

  /// Displays a mail search
  ///
  /// extra: [MailSearch]
  static const String mailSearch = '/mailSearch';

  /// Shows message details
  ///
  /// extra: [Message]
  /// queryParameters: [queryParameterBlockExternalContent]
  static const String mailDetails = '/mailDetails';

  /// Loads message details from notification data
  ///
  /// extra: [MailNotificationPayload]
  /// queryParameters: [queryParameterBlockExternalContent]
  static const String mailDetailsForNotification =
      '/mailDetailsForNotification';

  /// Shows all message contents
  ///
  /// extra: [Message]
  static const String mailContents = '/mailContents';

  /// Composes a new message
  ///
  /// extra: [ComposeData]
  static const String mailCompose = '/mailCompose';

  /// Displays the welcome screen
  static const String welcome = '/welcome';

  /// Displays the splash screen
  static const String splash = '/splash';

  /// Displays interactive media
  ///
  /// extra: [InteractiveMediaWidget]
  static const String interactiveMedia = '/interactiveMedia';

  /// Allows to pick a location
  ///
  /// Pops the [Uint8List] after selecting a location
  static const String locationPicker = '/locationPicker';

  /// Displays the source code of a message
  ///
  /// extra: [MimeMessage]
  static const String sourceCode = '/sourceCode';

  /// Displays the web view based on the given configuration
  ///
  /// extra: [WebViewConfiguration]
  static const String webview = '/webview';
  static const String appDrawer = '/appDrawer';

  /// Displays the lock screen
  static const String lockScreen = '/lock';

  /// Path parameter name for an email address
  static const String pathParameterEmail = 'email';

  /// Query parameter name for an encoded mailbox path
  static const String queryParameterEncodedMailboxPath = 'mailbox';

  /// Query parameter to signal external images should be blocked
  static const String queryParameterBlockExternalContent = 'blockExternal';

  /// The navigator key to use for routing when a widget's context is not
  /// mounted anymore
  static final navigatorKey = GlobalKey<NavigatorState>();

  /// The routing configuration
  static GoRouter routerConfig = GoRouter(
    navigatorKey: navigatorKey,
    routes: [
      GoRoute(
        path: _root,
        builder: (context, state) => const InitializationScreen(),
      ),
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        name: accountAdd,
        path: accountAdd,
        builder: (context, state) => AccountAddScreen(
          launchedFromWelcome: state.uri.queryParameters['welcome'] == 'true',
        ),
      ),
      GoRoute(
        path: home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        name: mail,
        path: '$mail/:$pathParameterEmail',
        builder: (context, state) => EMailScreen(
          email: state.pathParameters[pathParameterEmail] ?? '',
          encodedMailboxPath:
              state.uri.queryParameters[queryParameterEncodedMailboxPath],
        ),
      ),
      GoRoute(
        name: mailSearch,
        path: mailSearch,
        builder: (context, state) {
          final extra = state.extra;

          return extra is MailSearch
              ? MailSearchScreen(search: extra)
              : const HomeScreen();
        },
      ),
      GoRoute(
        name: messageSource,
        path: messageSource,
        builder: (context, state) {
          final extra = state.extra;

          return extra is MessageSource
              ? MessageSourceScreen(messageSource: extra)
              : const HomeScreen();
        },
      ),
      GoRoute(
        name: mailDetails,
        path: mailDetails,
        builder: (context, state) {
          final extra = state.extra;
          final blockExternalContent =
              state.uri.queryParameters[queryParameterBlockExternalContent] ==
                  'true';

          return extra is Message
              ? MessageDetailsScreen(
                  message: extra,
                  blockExternalContent: blockExternalContent,
                )
              : const HomeScreen();
        },
      ),
      GoRoute(
        name: mailDetailsForNotification,
        path: mailDetailsForNotification,
        builder: (context, state) {
          final extra = state.extra;
          final blockExternalContent =
              state.uri.queryParameters[queryParameterBlockExternalContent] ==
                  'true';

          return extra is MailNotificationPayload
              ? MessageDetailsForNotificationScreen(
                  payload: extra,
                  blockExternalContent: blockExternalContent,
                )
              : const HomeScreen();
        },
      ),
      GoRoute(
        name: mailContents,
        path: mailContents,
        builder: (context, state) {
          final extra = state.extra;

          return extra is Message
              ? MessageContentsScreen(
                  message: extra,
                )
              : const HomeScreen();
        },
      ),
      GoRoute(
        name: accountEdit,
        path: '$accountEdit/:$pathParameterEmail',
        builder: (context, state) => AccountEditScreen(
          accountEmail: state.pathParameters[pathParameterEmail] ?? '',
        ),
      ),
      GoRoute(
        name: accountServerDetails,
        path: '$accountServerDetails/:$pathParameterEmail',
        builder: (context, state) {
          final email = state.pathParameters[pathParameterEmail];
          if (email != null) {
            return AccountServerDetailsScreen(
              accountEmail: email,
            );
          }
          final account = state.extra;
          if (account is RealAccount) {
            return AccountServerDetailsScreen(
              account: account,
            );
          }

          return const HomeScreen();
        },
      ),
      GoRoute(
        name: mailCompose,
        path: mailCompose,
        builder: (context, state) {
          final data = state.extra;

          return data is ComposeData
              ? ComposeScreen(data: data)
              : const HomeScreen();
        },
      ),
      GoRoute(
        name: interactiveMedia,
        path: interactiveMedia,
        builder: (context, state) {
          final widget = state.extra;

          return widget is InteractiveMediaWidget
              ? InteractiveMediaScreen(mediaWidget: widget)
              : const HomeScreen();
        },
      ),
      GoRoute(
        path: settings,
        name: settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        name: settingsAccounts,
        path: settingsAccounts,
        builder: (context, state) => const SettingsAccountsScreen(),
      ),
      GoRoute(
        name: settingsDefaultSender,
        path: settingsDefaultSender,
        builder: (context, state) => const SettingsDefaultSenderScreen(),
      ),
      GoRoute(
        name: settingsDesign,
        path: settingsDesign,
        builder: (context, state) => const SettingsDesignScreen(),
      ),
      GoRoute(
        name: settingsDevelopment,
        path: settingsDevelopment,
        builder: (context, state) => const SettingsDeveloperModeScreen(),
      ),
      GoRoute(
        name: settingsFeedback,
        path: settingsFeedback,
        builder: (context, state) => const SettingsFeedbackScreen(),
      ),
      GoRoute(
        name: settingsFolders,
        path: settingsFolders,
        builder: (context, state) => const SettingsFoldersScreen(),
      ),
      GoRoute(
        name: settingsLanguage,
        path: settingsLanguage,
        builder: (context, state) => const SettingsLanguageScreen(),
      ),
      GoRoute(
        name: settingsReadReceipts,
        path: settingsReadReceipts,
        builder: (context, state) => const SettingsReadReceiptsScreen(),
      ),
      GoRoute(
        name: settingsReplyFormat,
        path: settingsReplyFormat,
        builder: (context, state) => const SettingsReplyScreen(),
      ),
      GoRoute(
        name: settingsSecurity,
        path: settingsSecurity,
        builder: (context, state) => const SettingsSecurityScreen(),
      ),
      GoRoute(
        name: settingsSignature,
        path: settingsSignature,
        builder: (context, state) => const SettingsSignatureScreen(),
      ),
      GoRoute(
        name: settingsSwipe,
        path: settingsSwipe,
        builder: (context, state) => const SettingsSwipeScreen(),
      ),
      GoRoute(
        name: sourceCode,
        path: sourceCode,
        builder: (context, state) {
          final mimeMessage = state.extra;

          return mimeMessage is MimeMessage
              ? SourceCodeScreen(mimeMessage: mimeMessage)
              : const HomeScreen();
        },
      ),
      GoRoute(
        name: webview,
        path: webview,
        builder: (context, state) {
          final configuration = state.extra;

          return configuration is WebViewConfiguration
              ? WebViewScreen(configuration: configuration)
              : const HomeScreen();
        },
      ),
      GoRoute(
        name: locationPicker,
        path: locationPicker,
        builder: (context, state) => const LocationScreen(),
      ),
      GoRoute(
        path: lockScreen,
        name: lockScreen,
        builder: (context, state) => const LockScreen(),
      ),
    ],
  );
}
