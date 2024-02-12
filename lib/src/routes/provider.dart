import 'package:enough_mail/enough_mail.dart';
import 'package:enough_media/enough_media.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../account/model.dart';
import '../app.dart';
import '../models/compose_data.dart';
import '../models/message.dart';
import '../models/message_source.dart';
import '../models/web_view_configuration.dart';
import '../notification/model.dart';
import '../screens/screens.dart';
import '../settings/view/view.dart';
import '../widgets/app_drawer.dart';
import 'routes.dart';

part 'provider.g.dart';

/// Provides the [GoRouter] configuration
@Riverpod(keepAlive: true)
GoRouter routerConfig(RouterConfigRef ref) => standardRouterConfig;

/// The standard [GoRouter] configuration
GoRouter get standardRouterConfig => GoRouter(
      navigatorKey: Routes.navigatorKey,
      // redirect: (context, state) {
      //   logger.d('redirect for ${state.uri}');

      //   return null;
      // },
      routes: [
        if (useAppDrawerAsRoot) ...[
          _rootRoute,
          _appDrawerRoute,
          _lockRoute,
          _welcomeRoute,
        ] else ...[
          _rootRoute,
          _accountAddRoute,
          _welcomeRoute,
          _mailRoute,
          _mailDetailsRoute,
          _mailDetailsForNotificationRoute,
          _mailContentsRoute,
          _sourceCodeRoute,
          _mailComposeRoute,
          _interactiveMediaRoute,
          _settingsRoute,
          _webviewRoute,
          _lockRoute,
        ],
      ],
    );

String _path(String routeName) =>
    useAppDrawerAsRoot ? routeName : '/$routeName';

GoRoute get _rootRoute => GoRoute(
      path: Routes.root,
      builder: (context, state) => const InitializationScreen(),
    );

GoRoute get _appDrawerRoute => GoRoute(
      name: Routes.appDrawer,
      path: Routes.appDrawer,
      builder: (context, state) => const AppDrawer(),
      routes: [
        _accountAddRoute,
        _mailRoute,
        _mailForAccountRoute,
        _mailDetailsRoute,
        _mailDetailsForNotificationRoute,
        _mailContentsRoute,
        _sourceCodeRoute,
        _mailComposeRoute,
        _interactiveMediaRoute,
        _settingsRoute,
        _webviewRoute,
      ],
    );

GoRoute get _accountAddRoute => GoRoute(
      name: Routes.accountAdd,
      path: _path(Routes.accountAdd),
      builder: (context, state) => const AccountAddScreen(),
    );
GoRoute get _welcomeRoute => GoRoute(
      name: Routes.welcome,
      path: Routes.welcome,
      builder: (context, state) => const WelcomeScreen(),
    );

GoRoute get _mailRoute => GoRoute(
      name: Routes.mail,
      path: _path(Routes.mail),
      builder: (context, state) => const MailScreenForDefaultAccount(),
      routes: [
        if (!useAppDrawerAsRoot) _mailForAccountRoute,
      ],
    );

GoRoute get _mailForAccountRoute => GoRoute(
      name: Routes.mailForAccount,
      path: '${Routes.mailForAccount}/:${Routes.pathParameterEmail}',
      builder: (context, state) {
        final email = state.pathParameters[Routes.pathParameterEmail] ?? '';

        return EMailScreen(key: ValueKey(email), email: email);
      },
      routes: [
        GoRoute(
          name: Routes.mailForMailbox,
          path: '${Routes.mailForMailbox}/'
              ':${Routes.pathParameterEncodedMailboxPath}',
          builder: (context, state) {
            final email = state.pathParameters[Routes.pathParameterEmail] ?? '';
            final encodedMailboxPath =
                state.pathParameters[Routes.pathParameterEncodedMailboxPath] ??
                    '';

            return EMailScreen(
              key: ValueKey('$email/$encodedMailboxPath'),
              email: email,
              encodedMailboxPath: encodedMailboxPath,
            );
          },
        ),
        GoRoute(
          name: Routes.messageSource,
          path: Routes.messageSource,
          builder: (context, state) {
            final extra = state.extra;

            return extra is MessageSource
                ? MessageSourceScreen(messageSource: extra)
                : const MailScreenForDefaultAccount();
          },
        ),
        GoRoute(
          name: Routes.mailSearch,
          path: Routes.mailSearch,
          builder: (context, state) {
            final extra = state.extra;

            return extra is MailSearch
                ? MailSearchScreen(search: extra)
                : const MailScreenForDefaultAccount();
          },
        ),
        GoRoute(
          name: Routes.accountEdit,
          path: Routes.accountEdit,
          builder: (context, state) => AccountEditScreen(
            accountEmail: state.pathParameters[Routes.pathParameterEmail] ?? '',
          ),
        ),
        GoRoute(
          name: Routes.accountServerDetails,
          path: Routes.accountServerDetails,
          builder: (context, state) {
            final email = state.pathParameters[Routes.pathParameterEmail];
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

            return const MailScreenForDefaultAccount();
          },
        ),
      ],
    );

GoRoute get _mailComposeRoute => GoRoute(
      name: Routes.mailCompose,
      path: _path(Routes.mailCompose),
      builder: (context, state) {
        final data = state.extra;

        return data is ComposeData
            ? ComposeScreen(data: data)
            : const MailScreenForDefaultAccount();
      },
      routes: [
        GoRoute(
          name: Routes.locationPicker,
          path: Routes.locationPicker,
          builder: (context, state) => const LocationScreen(),
        ),
      ],
    );

GoRoute get _mailDetailsRoute => GoRoute(
      name: Routes.mailDetails,
      path: _path(Routes.mailDetails),
      builder: (context, state) {
        final extra = state.extra;
        final blockExternalContent = state.uri
                .queryParameters[Routes.queryParameterBlockExternalContent] ==
            'true';

        return extra is Message
            ? MessageDetailsScreen(
                message: extra,
                blockExternalContent: blockExternalContent,
              )
            : const MailScreenForDefaultAccount();
      },
    );
GoRoute get _mailDetailsForNotificationRoute => GoRoute(
      name: Routes.mailDetailsForNotification,
      path: _path(Routes.mailDetailsForNotification),
      builder: (context, state) {
        final extra = state.extra;
        final blockExternalContent = state.uri
                .queryParameters[Routes.queryParameterBlockExternalContent] ==
            'true';

        return extra is MailNotificationPayload
            ? MessageDetailsForNotificationScreen(
                payload: extra,
                blockExternalContent: blockExternalContent,
              )
            : const MailScreenForDefaultAccount();
      },
    );

GoRoute get _mailContentsRoute => GoRoute(
      name: Routes.mailContents,
      path: _path(Routes.mailContents),
      builder: (context, state) {
        final extra = state.extra;

        return extra is Message
            ? MessageContentsScreen(
                message: extra,
              )
            : const MailScreenForDefaultAccount();
      },
    );
GoRoute get _sourceCodeRoute => GoRoute(
      name: Routes.sourceCode,
      path: _path(Routes.sourceCode),
      builder: (context, state) {
        final mimeMessage = state.extra;

        return mimeMessage is MimeMessage
            ? SourceCodeScreen(mimeMessage: mimeMessage)
            : const MailScreenForDefaultAccount();
      },
    );

GoRoute get _interactiveMediaRoute => GoRoute(
      name: Routes.interactiveMedia,
      path: _path(Routes.interactiveMedia),
      builder: (context, state) {
        final widget = state.extra;

        return widget is InteractiveMediaWidget
            ? InteractiveMediaScreen(mediaWidget: widget)
            : const MailScreenForDefaultAccount();
      },
    );

GoRoute get _settingsRoute => GoRoute(
      name: Routes.settings,
      path: _path(Routes.settings),
      builder: (context, state) => const SettingsScreen(),
      routes: [
        GoRoute(
          name: Routes.settingsAccounts,
          path: Routes.settingsAccounts,
          builder: (context, state) => const SettingsAccountsScreen(),
        ),
        GoRoute(
          name: Routes.settingsDefaultSender,
          path: Routes.settingsDefaultSender,
          builder: (context, state) => const SettingsDefaultSenderScreen(),
        ),
        GoRoute(
          name: Routes.settingsDesign,
          path: Routes.settingsDesign,
          builder: (context, state) => const SettingsDesignScreen(),
        ),
        GoRoute(
          name: Routes.settingsDevelopment,
          path: Routes.settingsDevelopment,
          builder: (context, state) => const SettingsDeveloperModeScreen(),
        ),
        GoRoute(
          name: Routes.settingsFeedback,
          path: Routes.settingsFeedback,
          builder: (context, state) => const SettingsFeedbackScreen(),
        ),
        GoRoute(
          name: Routes.settingsFolders,
          path: Routes.settingsFolders,
          builder: (context, state) => const SettingsFoldersScreen(),
        ),
        GoRoute(
          name: Routes.settingsLanguage,
          path: Routes.settingsLanguage,
          builder: (context, state) => const SettingsLanguageScreen(),
        ),
        GoRoute(
          name: Routes.settingsReadReceipts,
          path: Routes.settingsReadReceipts,
          builder: (context, state) => const SettingsReadReceiptsScreen(),
        ),
        GoRoute(
          name: Routes.settingsReplyFormat,
          path: Routes.settingsReplyFormat,
          builder: (context, state) => const SettingsReplyScreen(),
        ),
        GoRoute(
          name: Routes.settingsSecurity,
          path: Routes.settingsSecurity,
          builder: (context, state) => const SettingsSecurityScreen(),
        ),
        GoRoute(
          name: Routes.settingsSignature,
          path: Routes.settingsSignature,
          builder: (context, state) => const SettingsSignatureScreen(),
        ),
        GoRoute(
          name: Routes.settingsSwipe,
          path: Routes.settingsSwipe,
          builder: (context, state) => const SettingsSwipeScreen(),
        ),
      ],
    );

GoRoute get _lockRoute => GoRoute(
      name: Routes.lockScreen,
      path: Routes.lockScreen,
      builder: (context, state) => const LockScreen(),
    );

GoRoute _webviewRoute = GoRoute(
  name: Routes.webview,
  path: _path(Routes.webview),
  builder: (context, state) {
    final configuration = state.extra;

    return configuration is WebViewConfiguration
        ? WebViewScreen(configuration: configuration)
        : const MailScreenForDefaultAccount();
  },
);
