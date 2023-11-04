import 'package:enough_mail/enough_mail.dart';
import 'package:enough_media/enough_media.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../account/model.dart';
import '../models/models.dart';
import '../notification/model.dart';

/// Should the app drawer be used as root?
///
/// This is `true` on Cupertino platforms.
final useAppDrawerAsRoot = PlatformInfo.isCupertino;

/// Defines app navigation routes
class Routes {
  Routes._();

  /// The root route
  static const String root = '/';

  /// Displays the welcome screen
  static const String welcome = '/welcome';

  /// Creates a new account
  static const String accountAdd = 'accountAdd';

  /// Allows to edit a single account
  ///
  /// pathParameters: [pathParameterEmail]
  static const String accountEdit = 'edit';

  /// Allows to edit a the account server settings
  ///
  /// pathParameters: [pathParameterEmail] or
  ///
  /// extra: [RealAccount]
  ///
  static const String accountServerDetails = 'serverDetails';

  /// Displays inbox messages of the default account
  ///
  static const String mail = 'mail';

  /// Displays inbox messages of the given account
  ///
  /// pathParameters: [pathParameterEmail]
  ///
  static const String mailForAccount = 'account';

  /// Displays messages of the given account and mailbox
  ///
  /// pathParameters: [pathParameterEmail] and [pathParameterEncodedMailboxPath]
  ///
  static const String mailForMailbox = 'box';

  /// Displays the settings
  static const String settings = 'settings';

  /// Displays security settings
  static const String settingsSecurity = 'security';

  /// Displays the settings for all accounts
  static const String settingsAccounts = 'accounts';

  /// Displays theme settings
  static const String settingsDesign = 'design';

  /// Displays feedback options
  static const String settingsFeedback = 'feedback';

  /// Displays language settings
  static const String settingsLanguage = 'language';

  /// Displays folder naming settings
  static const String settingsFolders = 'folders';

  /// Displays read receipts settings
  static const String settingsReadReceipts = 'readReceipts';

  /// Displays developer settings
  static const String settingsDevelopment = 'developerMode';

  /// Displays swipe settings
  static const String settingsSwipe = 'swipe';

  /// Displays signature settings
  static const String settingsSignature = 'signature';

  /// Displays default sender settings
  static const String settingsDefaultSender = 'defaultSender';

  /// Displays reply settings
  static const String settingsReplyFormat = 'replyFormat';

  /// Displays a message source directly
  ///
  /// extra: [MessageSource]
  ///
  static const String messageSource = 'messageSource';

  /// Displays a mail search
  ///
  /// extra: [MailSearch]
  ///
  static const String mailSearch = 'mailSearch';

  /// Shows message details
  ///
  /// extra: [Message]
  ///
  /// queryParameters: [queryParameterBlockExternalContent]
  ///
  static const String mailDetails = 'mailDetails';

  /// Loads message details from notification data
  ///
  /// extra: [MailNotificationPayload]
  ///
  /// queryParameters: [queryParameterBlockExternalContent]
  ///
  static const String mailDetailsForNotification = 'mailNotification';

  /// Shows all message contents
  ///
  /// extra: [Message]
  ///
  static const String mailContents = 'mailContents';

  /// Composes a new message
  ///
  /// extra: [ComposeData]
  ///
  static const String mailCompose = 'mailCompose';

  /// Allows to pick a location
  ///
  /// Pops the [Uint8List] after selecting a location
  ///
  static const String locationPicker = 'locationPicker';

  /// Displays interactive media
  ///
  /// extra: [InteractiveMediaWidget]
  ///
  static const String interactiveMedia = 'interactiveMedia';

  /// Displays the source code of a message
  ///
  /// extra: [MimeMessage]
  ///
  static const String sourceCode = 'sourceCode';

  /// Displays the web view based on the given configuration
  ///
  /// extra: [WebViewConfiguration]
  ///
  static const String webview = 'webview';

  /// Displays the account and mailbox switcher on a separate screen.
  ///
  /// This is only applicable on iOS.
  static const String appDrawer = '/appDrawer';

  /// Displays the lock screen
  static const String lockScreen = '/lock';

  /// Path parameter name for an email address
  static const String pathParameterEmail = 'email';

  /// Query parameter name for an encoded mailbox path
  static const String pathParameterEncodedMailboxPath = 'mailbox';

  /// Query parameter to signal external images should be blocked
  static const String queryParameterBlockExternalContent = 'blockExternal';

  /// The navigator key to use for routing when a widget's context is not
  /// mounted anymore
  static final navigatorKey = GlobalKey<NavigatorState>();
}
