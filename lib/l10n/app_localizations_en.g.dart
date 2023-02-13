import 'package:intl/intl.dart' as intl;

import 'app_localizations.g.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get signature => 'Sent with Maily';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionOk => 'OK';

  @override
  String get actionDone => 'Done';

  @override
  String get actionNext => 'Next';

  @override
  String get actionSkip => 'Skip';

  @override
  String get actionUndo => 'Undo';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionAccept => 'Accept';

  @override
  String get actionDecline => 'Decline';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionAddressCopy => 'Copy';

  @override
  String get actionAddressCompose => 'New message';

  @override
  String get actionAddressSearch => 'Search';

  @override
  String get splashLoading1 => 'Maily starting...';

  @override
  String get splashLoading2 => 'Getting your Maily engine ready...';

  @override
  String get splashLoading3 => 'Launching Maily in 10, 9, 8...';

  @override
  String get welcomePanel1Title => 'Maily';

  @override
  String get welcomePanel1Text => 'Welcome to Maily, your friendly and fast email helper!';

  @override
  String get welcomePanel2Title => 'Accounts';

  @override
  String get welcomePanel2Text => 'Manage unlimited email accounts. Read and search for mails in all your accounts at once.';

  @override
  String get welcomePanel3Title => 'Swipe & Long-Press';

  @override
  String get welcomePanel3Text => 'Swipe your mails to delete them or to mark them read. Long-press a message to select and manage several messages.';

  @override
  String get welcomePanel4Title => 'Keep your Inbox clean';

  @override
  String get welcomePanel4Text => 'Unsubscribe newsletters with just one tap.';

  @override
  String get welcomeActionSignIn => 'Sign in to your mail account';

  @override
  String get homeSearchHint => 'Your search';

  @override
  String get homeActionsShowAsStack => 'Show as stack';

  @override
  String get homeActionsShowAsList => 'Show as list';

  @override
  String get homeEmptyFolderMessage => 'All done!\n\nThere are no messages in this folder.';

  @override
  String get homeEmptySearchMessage => 'No messages found.';

  @override
  String get homeDeleteAllTitle => 'Confirm';

  @override
  String get homeDeleteAllQuestion => 'Really delete all messages?';

  @override
  String get homeDeleteAllAction => 'Delete all';

  @override
  String get homeDeleteAllScrubOption => 'Scrub messages';

  @override
  String get homeDeleteAllSuccess => 'All messages deleted.';

  @override
  String get homeMarkAllSeenAction => 'All read';

  @override
  String get homeMarkAllUnseenAction => 'All unread';

  @override
  String get homeFabTooltip => 'New message';

  @override
  String get homeLoadingMessageSourceTitle => 'Loading...';

  @override
  String homeLoading(String name) {
    return 'loading $name...';
  }

  @override
  String get swipeActionToggleRead => 'Mark as read/unread';

  @override
  String get swipeActionDelete => 'Delete';

  @override
  String get swipeActionMarkJunk => 'Mark as junk';

  @override
  String get swipeActionArchive => 'Archive';

  @override
  String get swipeActionFlag => 'Toggle flag';

  @override
  String multipleMovedToJunk(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
      
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: 'Marked $numberString messages as junk',
      one: 'One message marked as junk',
    );
    return '$_temp0';
  }

  @override
  String multipleMovedToInbox(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
      
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: 'Moved $numberString messages to inbox',
      one: 'Moved one message to inbox',
    );
    return '$_temp0';
  }

  @override
  String multipleMovedToArchive(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
      
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: 'Archived $numberString messages',
      one: 'Archived one message',
    );
    return '$_temp0';
  }

  @override
  String multipleMovedToTrash(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
      
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: 'Deleted $numberString messages',
      one: 'Deleted one message',
    );
    return '$_temp0';
  }

  @override
  String get multipleSelectionNeededInfo => 'Please select messages first.';

  @override
  String multipleMoveTitle(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
      
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: 'Move $numberString messages',
      one: 'Move message',
    );
    return '$_temp0';
  }

  @override
  String get messageActionMultipleMarkSeen => 'Mark as read';

  @override
  String get messageActionMultipleMarkUnseen => 'Mark as unread';

  @override
  String get messageActionMultipleMarkFlagged => 'Flag messages';

  @override
  String get messageActionMultipleMarkUnflagged => 'Unflag messages';

  @override
  String get messageActionViewInSafeMode => 'View without external content';

  @override
  String get emailSenderUnknown => '<no sender>';

  @override
  String get dateRangeFuture => 'future';

  @override
  String get dateRangeTomorrow => 'tomorrow';

  @override
  String get dateRangeToday => 'today';

  @override
  String get dateRangeYesterday => 'yesterday';

  @override
  String get dateRangeCurrentWeek => 'this week';

  @override
  String get dateRangeLastWeek => 'last week';

  @override
  String get dateRangeCurrentMonth => 'this month';

  @override
  String get dateRangeLastMonth => 'last month';

  @override
  String get dateRangeCurrentYear => 'this year';

  @override
  String get dateRangeLongAgo => 'long ago';

  @override
  String get dateUndefined => 'undefined';

  @override
  String get dateDayToday => 'today';

  @override
  String get dateDayYesterday => 'yesterday';

  @override
  String dateDayLastWeekday(String day) {
    return 'last $day';
  }

  @override
  String get drawerEntryAbout => 'About Maily';

  @override
  String get drawerEntrySettings => 'Settings';

  @override
  String drawerAccountsSectionTitle(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
      
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$numberString accounts',
      one: 'One account',
    );
    return '$_temp0';
  }

  @override
  String get drawerEntryAddAccount => 'Add account';

  @override
  String get unifiedAccountName => 'Unified account';

  @override
  String get unifiedFolderInbox => 'Unified Inbox';

  @override
  String get unifiedFolderSent => 'Unified Sent';

  @override
  String get unifiedFolderDrafts => 'Unified Drafts';

  @override
  String get unifiedFolderTrash => 'Unified Trash';

  @override
  String get unifiedFolderArchive => 'Unified Archive';

  @override
  String get unifiedFolderJunk => 'Unified Junk';

  @override
  String get folderInbox => 'Inbox';

  @override
  String get folderSent => 'Sent';

  @override
  String get folderDrafts => 'Drafts';

  @override
  String get folderTrash => 'Trash';

  @override
  String get folderArchive => 'Archive';

  @override
  String get folderJunk => 'Junk';

  @override
  String get viewContentsAction => 'View contents';

  @override
  String get viewSourceAction => 'View source';

  @override
  String get detailsErrorDownloadInfo => 'Message could not be downloaded.';

  @override
  String get detailsErrorDownloadRetry => 'Retry';

  @override
  String get detailsHeaderFrom => 'From';

  @override
  String get detailsHeaderTo => 'To';

  @override
  String get detailsHeaderCc => 'CC';

  @override
  String get detailsHeaderBcc => 'BCC';

  @override
  String get detailsHeaderDate => 'Date';

  @override
  String get subjectUndefined => '<without subject>';

  @override
  String get detailsActionShowImages => 'Show images';

  @override
  String get detailsNewsletterActionUnsubscribe => 'Unsubscribe';

  @override
  String get detailsNewsletterActionResubscribe => 'Re-subscribe';

  @override
  String get detailsNewsletterStatusUnsubscribed => 'Unsubscribed';

  @override
  String get detailsNewsletterUnsubscribeDialogTitle => 'Unsubscribe';

  @override
  String detailsNewsletterUnsubscribeDialogQuestion(String listName) {
    return 'Do you want to unsubscribe from the mailing list $listName?';
  }

  @override
  String get detailsNewsletterUnsubscribeDialogAction => 'Unsubscribe';

  @override
  String get detailsNewsletterUnsubscribeSuccessTitle => 'Unsubscribed';

  @override
  String detailsNewsletterUnsubscribeSuccessMessage(String listName) {
    return 'You are now unsubscribed from the mailing list $listName.';
  }

  @override
  String get detailsNewsletterUnsubscribeFailureTitle => 'Not unsubscribed';

  @override
  String detailsNewsletterUnsubscribeFailureMessage(String listName) {
    return 'Sorry, but I was unable to unsubscribe you from $listName automatically.';
  }

  @override
  String get detailsNewsletterResubscribeDialogTitle => 'Re-subscribe';

  @override
  String detailsNewsletterResubscribeDialogQuestion(String listName) {
    return 'Do you want to subscribe to this mailing list $listName again?';
  }

  @override
  String get detailsNewsletterResubscribeDialogAction => 'Subscribe';

  @override
  String get detailsNewsletterResubscribeSuccessTitle => 'Subscribed';

  @override
  String detailsNewsletterResubscribeSuccessMessage(String listName) {
    return 'You are now subscribed to the mailing list $listName again.';
  }

  @override
  String get detailsNewsletterResubscribeFailureTitle => 'Not subscribed';

  @override
  String detailsNewsletterResubscribeFailureMessage(String listName) {
    return 'Sorry, but the subscribe request has failed for mailing list $listName.';
  }

  @override
  String get detailsSendReadReceiptAction => 'Send read receipt';

  @override
  String get detailsReadReceiptSentStatus => 'Read receipt sent ✔';

  @override
  String get detailsReadReceiptSubject => 'Read receipt';

  @override
  String get attachmentActionOpen => 'Open';

  @override
  String get messageActionReply => 'Reply';

  @override
  String get messageActionReplyAll => 'Reply all';

  @override
  String get messageActionForward => 'Forward';

  @override
  String get messageActionForwardAsAttachment => 'Forward as attachment';

  @override
  String messageActionForwardAttachments(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
      
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: 'Forward $numberString attachments',
      one: 'Forward attachment',
    );
    return '$_temp0';
  }

  @override
  String get messagesActionForwardAttachments => 'Forward attachments';

  @override
  String get messageActionDelete => 'Delete';

  @override
  String get messageActionMoveToInbox => 'Move to inbox';

  @override
  String get messageActionMove => 'Move';

  @override
  String get messageStatusSeen => 'Is read';

  @override
  String get messageStatusUnseen => 'Is unread';

  @override
  String get messageStatusFlagged => 'Is flagged';

  @override
  String get messageStatusUnflagged => 'Is not flagged';

  @override
  String get messageActionMarkAsJunk => 'Mark as junk';

  @override
  String get messageActionMarkAsNotJunk => 'Mark as not junk';

  @override
  String get messageActionArchive => 'Archive';

  @override
  String get messageActionUnarchive => 'Move to Inbox';

  @override
  String get messageActionRedirect => 'Redirect';

  @override
  String get messageActionAddNotification => 'Add notification';

  @override
  String get resultDeleted => 'Deleted';

  @override
  String get resultMovedToJunk => 'Marked as junk';

  @override
  String get resultMovedToInbox => 'Moved to Inbox';

  @override
  String get resultArchived => 'Archived';

  @override
  String get resultRedirectedSuccess => 'Message redirected 👍';

  @override
  String resultRedirectedFailure(String details) {
    return 'Unable to redirect message.\n\nThe server responded with the following details: \"$details\"';
  }

  @override
  String get redirectTitle => 'Redirect';

  @override
  String get redirectInfo => 'Redirect this message to the following recipient(s). Redirecting does not alter the message.';

  @override
  String get redirectEmailInputRequired => 'You need to add at least one valid email address.';

  @override
  String searchQueryDescription(String folder) {
    return 'Search in $folder...';
  }

  @override
  String searchQueryTitle(String query) {
    return 'Search \"$query\"';
  }

  @override
  String get legaleseUsage => 'By using Maily you agree to our [PP] and to our [TC].';

  @override
  String get legalesePrivacyPolicy => 'Privacy Policy';

  @override
  String get legaleseTermsAndConditions => 'Terms & Conditions';

  @override
  String get aboutApplicationLegalese => 'Maily is free software published under the GNU General Public License.';

  @override
  String get feedbackActionSuggestFeature => 'Suggest a feature';

  @override
  String get feedbackActionReportProblem => 'Report a problem';

  @override
  String get feedbackActionHelpDeveloping => 'Help developing Maily';

  @override
  String get feedbackTitle => 'Feedback';

  @override
  String get feedbackIntro => 'Thank you for testing Maily!';

  @override
  String get feedbackProvideInfoRequest => 'Please provide this information when you report a problem:';

  @override
  String get feedbackResultInfoCopied => 'Copied to clipboard';

  @override
  String get accountsTitle => 'Accounts';

  @override
  String get accountsActionReorder => 'Reorder accounts';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSecurityBlockExternalImages => 'Block external images';

  @override
  String get settingsSecurityBlockExternalImagesDescriptionTitle => 'External images';

  @override
  String get settingsSecurityBlockExternalImagesDescriptionText => 'Email messages can contain images that are either integrated or hosted on external servers. The latter, external images can expose information to the sender of the message, e.g. to let the sender know that you have opened the message. This option allows you to block such external images, which reduces the risk of exposing sensitive information. You can still opt in to load such images on a per-message-basis when you read a message.';

  @override
  String get settingsSecurityMessageRenderingHtml => 'Show full message contents';

  @override
  String get settingsSecurityMessageRenderingPlainText => 'Show only the text of messages';

  @override
  String get settingsSecurityLaunchModeLabel => 'How should Maily open links?';

  @override
  String get settingsSecurityLaunchModeExternal => 'Open links externally';

  @override
  String get settingsSecurityLaunchModeInApp => 'Open links in Maily';

  @override
  String get settingsActionAccounts => 'Manage accounts';

  @override
  String get settingsActionDesign => 'Appearance';

  @override
  String get settingsActionFeedback => 'Provide feedback';

  @override
  String get settingsActionWelcome => 'Show welcome';

  @override
  String get settingsReadReceipts => 'Read receipts';

  @override
  String get readReceiptsSettingsIntroduction => 'Do you want to display read receipt requests?';

  @override
  String get readReceiptOptionAlways => 'Always';

  @override
  String get readReceiptOptionNever => 'Never';

  @override
  String get settingsFolders => 'Folders';

  @override
  String get folderNamesIntroduction => 'What names do you prefer for your folders?';

  @override
  String get folderNamesSettingLocalized => 'Names given by Maily';

  @override
  String get folderNamesSettingServer => 'Names given by the service';

  @override
  String get folderNamesSettingCustom => 'My own custom names';

  @override
  String get folderNamesEditAction => 'Edit custom names';

  @override
  String get folderNamesCustomTitle => 'Custom names';

  @override
  String get folderAddAction => 'Create folder';

  @override
  String get folderAddTitle => 'Create folder';

  @override
  String get folderAddNameLabel => 'Name';

  @override
  String get folderAddNameHint => 'Name of the new folder';

  @override
  String get folderAccountLabel => 'Account';

  @override
  String get folderMailboxLabel => 'Folder';

  @override
  String get folderAddResultSuccess => 'Folder created 😊';

  @override
  String folderAddResultFailure(String details) {
    return 'Folder could not be created.\n\nThe server responded with $details';
  }

  @override
  String get folderDeleteAction => 'Delete';

  @override
  String get folderDeleteConfirmTitle => 'Confirm';

  @override
  String folderDeleteConfirmText(String name) {
    return 'Do you really want to delete the folder $name?';
  }

  @override
  String get folderDeleteResultSuccess => 'Folder deleted.';

  @override
  String folderDeleteResultFailure(String details) {
    return 'Folder could not be deleted.\n\nThe server responded with $details';
  }

  @override
  String get settingsDevelopment => 'Development settings';

  @override
  String get developerModeTitle => 'Development mode';

  @override
  String get developerModeIntroduction => 'If you enable the development mode you will be able to view the source code of messages and convert text attachments to messages.';

  @override
  String get developerModeEnable => 'Enable development mode';

  @override
  String get developerShowAsEmail => 'Convert text to email';

  @override
  String get developerShowAsEmailFailed => 'This text cannot be converted into a MIME message.';

  @override
  String get designTitle => 'Design Settings';

  @override
  String get designSectionThemeTitle => 'Theme';

  @override
  String get designThemeOptionLight => 'Light';

  @override
  String get designThemeOptionDark => 'Dark';

  @override
  String get designThemeOptionSystem => 'System';

  @override
  String get designThemeOptionCustom => 'Custom';

  @override
  String get designSectionCustomTitle => 'Enable dark theme';

  @override
  String designThemeCustomStart(String time) {
    return 'from $time';
  }

  @override
  String designThemeCustomEnd(String time) {
    return 'until $time';
  }

  @override
  String get designSectionColorTitle => 'Color Scheme';

  @override
  String get securitySettingsTitle => 'Security';

  @override
  String get securitySettingsIntro => 'Adapt the security settings to your personal needs.';

  @override
  String get securityUnlockWithFaceId => 'Unlock Maily with Face ID.';

  @override
  String get securityUnlockWithTouchId => 'Unlock Maily with Touch ID.';

  @override
  String get securityUnlockReason => 'Unlock Maily.';

  @override
  String get securityUnlockDisableReason => 'Unlock Maily to turn off lock.';

  @override
  String get securityUnlockNotAvailable => 'Your device does not support biometrics, possibly you need to set up unlock options first.';

  @override
  String get securityUnlockLabel => 'Lock Maily';

  @override
  String get securityUnlockDescriptionTitle => 'Lock Maily';

  @override
  String get securityUnlockDescriptionText => 'You can choose to lock access to Maily, so that others cannot read your email even when they have access to your device.';

  @override
  String get securityLockImmediately => 'Lock immediately';

  @override
  String get securityLockAfter5Minutes => 'Lock after 5 minutes';

  @override
  String get securityLockAfter30Minutes => 'Lock after 30 minutes';

  @override
  String get lockScreenTitle => 'Maily is locked';

  @override
  String get lockScreenIntro => 'Maily is locked, please authenticate to proceed.';

  @override
  String get lockScreenUnlockAction => 'Unlock';

  @override
  String get addAccountTitle => 'Add Account';

  @override
  String get addAccountEmailLabel => 'Email';

  @override
  String get addAccountEmailHint => 'Please enter your email address';

  @override
  String addAccountResolvingSettingsLabel(String email) {
    return 'Resolving $email...';
  }

  @override
  String addAccountResolvedSettingsWrongAction(String provider) {
    return 'Not on $provider?';
  }

  @override
  String addAccountResolvingSettingsFailedInfo(String email) {
    return 'Unable to resolve $email. Please go back to change it or set up the account manually.';
  }

  @override
  String get addAccountEditManuallyAction => 'Edit manually';

  @override
  String get addAccountPasswordLabel => 'Password';

  @override
  String get addAccountPasswordHint => 'Please enter your password';

  @override
  String get addAccountApplicationPasswordRequiredInfo => 'This provider requires you to set up an app specific password.';

  @override
  String get addAccountApplicationPasswordRequiredButton => 'Create app specific password';

  @override
  String get addAccountApplicationPasswordRequiredAcknowledged => 'Understood';

  @override
  String get addAccountVerificationStep => 'Verification';

  @override
  String get addAccountSetupAccountStep => 'Account Setup';

  @override
  String addAccountVerifyingSettingsLabel(String email) {
    return 'Verifying $email...';
  }

  @override
  String addAccountVerifyingSuccessInfo(String email) {
    return 'Successfully signed into $email.';
  }

  @override
  String addAccountVerifyingFailedInfo(String email) {
    return 'Sorry, but there was a problem. Please check your email $email and password.';
  }

  @override
  String addAccountOauthOptionsText(String provider) {
    return 'Sign in with $provider or create an app-specific password.';
  }

  @override
  String addAccountOauthSignIn(String provider) {
    return 'Sign in with $provider';
  }

  @override
  String get addAccountOauthSignInGoogle => 'Sign in with Google';

  @override
  String get addAccountOauthSignInWithAppPassword => 'Alternatively, create an app password to sign in.';

  @override
  String get accountAddImapAccessSetupMightBeRequired => 'Your provider might require you to setup access for email apps manually.';

  @override
  String get addAccountSetupImapAccessButtonLabel => 'Setup email access';

  @override
  String get addAccountNameOfUserLabel => 'Your name';

  @override
  String get addAccountNameOfUserHint => 'The name that recipients see';

  @override
  String get addAccountNameOfAccountLabel => 'Account name';

  @override
  String get addAccountNameOfAccountHint => 'Please enter the name of your account';

  @override
  String editAccountTitle(String name) {
    return 'Edit $name';
  }

  @override
  String editAccountFailureToConnectInfo(String name) {
    return 'Maily could not connect $name.';
  }

  @override
  String get editAccountFailureToConnectRetryAction => 'Retry';

  @override
  String get editAccountFailureToConnectChangePasswordAction => 'Change Password';

  @override
  String get editAccountFailureToConnectFixedTitle => 'Connected';

  @override
  String get editAccountFailureToConnectFixedInfo => 'The account is connected again.';

  @override
  String get editAccountIncludeInUnifiedLabel => 'Include in unified account';

  @override
  String editAccountAliasLabel(String email) {
    return 'Alias email addresses for $email:';
  }

  @override
  String get editAccountNoAliasesInfo => 'You have no known aliases for this account yet.';

  @override
  String editAccountAliasRemoved(String email) {
    return '$email alias removed';
  }

  @override
  String get editAccountAddAliasAction => 'Add alias';

  @override
  String get editAccountPlusAliasesSupported => 'Supports + aliases';

  @override
  String get editAccountCheckPlusAliasAction => 'Test support for + aliases';

  @override
  String get editAccountBccMyself => 'BCC myself';

  @override
  String get editAccountBccMyselfDescriptionTitle => 'BCC myself';

  @override
  String get editAccountBccMyselfDescriptionText => 'You can automatically send messages to yourself for every message you send from this account with the \"BCC myself\" feature. Usually this is not required and wanted as all outgoing messages are stored in the \"Sent\" folder anyhow.';

  @override
  String get editAccountServerSettingsAction => 'Edit server settings';

  @override
  String get editAccountDeleteAccountAction => 'Delete account';

  @override
  String get editAccountDeleteAccountConfirmationTitle => 'Confirm';

  @override
  String editAccountDeleteAccountConfirmationQuery(String name) {
    return 'Do you want to delete the account $name?';
  }

  @override
  String editAccountTestPlusAliasTitle(String name) {
    return '+ Aliases for $name';
  }

  @override
  String get editAccountTestPlusAliasStepIntroductionTitle => 'Introduction';

  @override
  String editAccountTestPlusAliasStepIntroductionText(String accountName, String example) {
    return 'Your account $accountName might support so called + aliases like $example.\nA + alias helps you to protect your identity and helps you against spam.\nTo test this, a test message will be sent to this generated address. If it arrives, your provider supports + aliases and you can easily generate them on demand when writing a new mail message.';
  }

  @override
  String get editAccountTestPlusAliasStepTestingTitle => 'Testing';

  @override
  String get editAccountTestPlusAliasStepResultTitle => 'Result';

  @override
  String editAccountTestPlusAliasStepResultSuccess(String name) {
    return 'Your account $name supports + aliases.';
  }

  @override
  String editAccountTestPlusAliasStepResultNoSuccess(String name) {
    return 'Your account $name does not support + aliases.';
  }

  @override
  String get editAccountAddAliasTitle => 'Add alias';

  @override
  String get editAccountEditAliasTitle => 'Edit alias';

  @override
  String get editAccountAliasAddAction => 'Add';

  @override
  String get editAccountAliasUpdateAction => 'Update';

  @override
  String get editAccountEditAliasNameLabel => 'Alias name';

  @override
  String get editAccountEditAliasEmailLabel => 'Alias email';

  @override
  String get editAccountEditAliasEmailHint => 'Your alias email address';

  @override
  String editAccountEditAliasDuplicateError(String email) {
    return 'There is already an alias with $email.';
  }

  @override
  String get editAccountEnableLogging => 'Enable logging';

  @override
  String get editAccountLoggingEnabled => 'Log enabled, please restart';

  @override
  String get editAccountLoggingDisabled => 'Log disabled, please restart';

  @override
  String get accountDetailsFallbackTitle => 'Server Settings';

  @override
  String get errorTitle => 'Error';

  @override
  String get accountProviderStepTitle => 'Email Service Provider';

  @override
  String get accountProviderCustom => 'Other email service';

  @override
  String accountDetailsErrorHostProblem(String incomingHost, String outgoingHost) {
    return 'Maily cannot reach the specified mail server. Please check your incoming server setting \"$incomingHost\" and your outgoing server setting \"$outgoingHost\".';
  }

  @override
  String accountDetailsErrorLoginProblem(String userName, String password) {
    return 'Unable to log your in. Please check your user name \"$userName\" and your password \"$password\".';
  }

  @override
  String get accountDetailsUserNameLabel => 'Login name';

  @override
  String get accountDetailsUserNameHint => 'Your user name, if different from email';

  @override
  String get accountDetailsPasswordLabel => 'Login password';

  @override
  String get accountDetailsPasswordHint => 'Your password';

  @override
  String get accountDetailsBaseSectionTitle => 'Base settings';

  @override
  String get accountDetailsIncomingLabel => 'Incoming server';

  @override
  String get accountDetailsIncomingHint => 'Domain like imap.domain.com';

  @override
  String get accountDetailsOutgoingLabel => 'Outgoing server';

  @override
  String get accountDetailsOutgoingHint => 'Domain like smtp.domain.com';

  @override
  String get accountDetailsAdvancedIncomingSectionTitle => 'Advanced incoming settings';

  @override
  String get accountDetailsIncomingServerTypeLabel => 'Incoming type:';

  @override
  String get accountDetailsOptionAutomatic => 'automatic';

  @override
  String get accountDetailsIncomingSecurityLabel => 'Incoming security:';

  @override
  String get accountDetailsSecurityOptionNone => 'Plain (no encryption)';

  @override
  String get accountDetailsIncomingPortLabel => 'Incoming port';

  @override
  String get accountDetailsPortHint => 'Leave empty to determine automatically';

  @override
  String get accountDetailsIncomingUserNameLabel => 'Incoming user name';

  @override
  String get accountDetailsAlternativeUserNameHint => 'Your user name, if different from above';

  @override
  String get accountDetailsIncomingPasswordLabel => 'Incoming password';

  @override
  String get accountDetailsAlternativePasswordHint => 'Your password, if different from above';

  @override
  String get accountDetailsAdvancedOutgoingSectionTitle => 'Advanced outgoing settings';

  @override
  String get accountDetailsOutgoingServerTypeLabel => 'Outgoing type:';

  @override
  String get accountDetailsOutgoingSecurityLabel => 'Outgoing security:';

  @override
  String get accountDetailsOutgoingPortLabel => 'Outgoing port';

  @override
  String get accountDetailsOutgoingUserNameLabel => 'Outgoing user name';

  @override
  String get accountDetailsOutgoingPasswordLabel => 'Outgoing password';

  @override
  String get composeTitleNew => 'New message';

  @override
  String get composeTitleForward => 'Forward';

  @override
  String get composeTitleReply => 'Reply';

  @override
  String get composeEmptyMessage => 'empty message';

  @override
  String get composeWarningNoSubject => 'You have not specified a subject. Do you want to sent the message without a subject?';

  @override
  String get composeActionSentWithoutSubject => 'Send';

  @override
  String get composeMailSendSuccess => 'Mail sent 😊';

  @override
  String composeSendErrorInfo(String details) {
    return 'Sorry, your mail could not be send. We received the following error:\n$details.';
  }

  @override
  String get composeRequestReadReceiptAction => 'Request read receipt';

  @override
  String get composeSaveDraftAction => 'Save as draft';

  @override
  String get composeMessageSavedAsDraft => 'Draft saved';

  @override
  String composeMessageSavedAsDraftErrorInfo(String details) {
    return 'Your draft could not be saved with the following error:\n$details';
  }

  @override
  String get composeConvertToPlainTextEditorAction => 'Convert to plain text';

  @override
  String get composeConvertToHtmlEditorAction => 'Convert to rich message (HTML)';

  @override
  String get composeContinueEditingAction => 'Continue editing';

  @override
  String get composeCreatePlusAliasAction => 'Create new + alias...';

  @override
  String get composeSenderHint => 'Sender';

  @override
  String get composeRecipientHint => 'Recipient email';

  @override
  String get composeSubjectLabel => 'Subject';

  @override
  String get composeSubjectHint => 'Message subject';

  @override
  String get composeAddAttachmentAction => 'Add';

  @override
  String composeRemoveAttachmentAction(String name) {
    return 'Remove $name';
  }

  @override
  String get composeLeftByMistake => 'Left by mistake?';

  @override
  String get attachTypeFile => 'File';

  @override
  String get attachTypePhoto => 'Photo';

  @override
  String get attachTypeVideo => 'Video';

  @override
  String get attachTypeAudio => 'Audio';

  @override
  String get attachTypeLocation => 'Location';

  @override
  String get attachTypeGif => 'Animated Gif';

  @override
  String get attachTypeGifSearch => 'search GIPHY';

  @override
  String get attachTypeSticker => 'Sticker';

  @override
  String get attachTypeStickerSearch => 'search GIPHY';

  @override
  String get attachTypeAppointment => 'Appointment';

  @override
  String get languageSettingTitle => 'Language';

  @override
  String get languageSettingLabel => 'Choose the language for Maily:';

  @override
  String get languageSettingSystemOption => 'System language';

  @override
  String get languageSettingConfirmationTitle => 'Use English for Maily?';

  @override
  String get languageSettingConfirmationQuery => 'Please confirm to use English as your chosen language.';

  @override
  String get languageSetInfo => 'Maily is now shown in English. Please restart the app to take effect.';

  @override
  String get languageSystemSetInfo => 'Maily will now use the system\'s language or English if the system\'s language is not supported. Please restart the app to take effect.';

  @override
  String get swipeSettingTitle => 'Swipe gestures';

  @override
  String get swipeSettingLeftToRightLabel => 'Left to right swipe';

  @override
  String get swipeSettingRightToLeftLabel => 'Right to left swipe';

  @override
  String get swipeSettingChangeAction => 'Change';

  @override
  String get signatureSettingsTitle => 'Signature';

  @override
  String get signatureSettingsComposeActionsInfo => 'Enable the signature for the following messages:';

  @override
  String get signatureSettingsAccountInfo => 'You can specify account specific signatures in the account settings.';

  @override
  String signatureSettingsAddForAccount(String account) {
    return 'Add signature for $account';
  }

  @override
  String get defaultSenderSettingsTitle => 'Default sender';

  @override
  String get defaultSenderSettingsLabel => 'Select the sender for new messages.';

  @override
  String defaultSenderSettingsFirstAccount(String email) {
    return 'First account ($email)';
  }

  @override
  String get defaultSenderSettingsAliasInfo => 'You can set up email alias addresses in the [AS].';

  @override
  String get defaultSenderSettingsAliasAccountSettings => 'account settings';

  @override
  String get replySettingsTitle => 'Message format';

  @override
  String get replySettingsIntro => 'In what format do you want to answer or forward email by default?';

  @override
  String get replySettingsFormatHtml => 'Always rich format (HTML)';

  @override
  String get replySettingsFormatSameAsOriginal => 'Use same format as originating email';

  @override
  String get replySettingsFormatPlainText => 'Always text-only';

  @override
  String get moveTitle => 'Move message';

  @override
  String moveSuccess(String mailbox) {
    return 'Messaged moved to $mailbox.';
  }

  @override
  String get editorArtInputLabel => 'Your input';

  @override
  String get editorArtInputHint => 'Enter text here';

  @override
  String get editorArtWaitingForInputHint => 'waiting for input...';

  @override
  String get fontSerifBold => 'Serif bold';

  @override
  String get fontSerifItalic => 'Serif italic';

  @override
  String get fontSerifBoldItalic => 'Serif bold italic';

  @override
  String get fontSans => 'Sans';

  @override
  String get fontSansBold => 'Sans bold';

  @override
  String get fontSansItalic => 'Sans italic';

  @override
  String get fontSansBoldItalic => 'Sans bold italic';

  @override
  String get fontScript => 'Script';

  @override
  String get fontScriptBold => 'Script bold';

  @override
  String get fontFraktur => 'Fraktur';

  @override
  String get fontFrakturBold => 'Fraktur bold';

  @override
  String get fontMonospace => 'Monospace';

  @override
  String get fontFullwidth => 'Fullwidth';

  @override
  String get fontDoublestruck => 'Double struck';

  @override
  String get fontCapitalized => 'Capitalized';

  @override
  String get fontCircled => 'Circled';

  @override
  String get fontParenthesized => 'Parenthesized';

  @override
  String get fontUnderlinedSingle => 'Underlined';

  @override
  String get fontUnderlinedDouble => 'Underlined double';

  @override
  String get fontStrikethroughSingle => 'Strike through';

  @override
  String get fontCrosshatch => 'Crosshatch';

  @override
  String accountLoadError(String name) {
    return 'Unable to connect to your account $name. Has the password been changed?';
  }

  @override
  String get accountLoadErrorEditAction => 'Edit account';

  @override
  String get extensionsTitle => 'Extensions';

  @override
  String get extensionsIntro => 'With extensions e-mail service providers, companies and developers can adapt Maily with useful functionalities.';

  @override
  String get extensionsLearnMoreAction => 'Learn more about extensions';

  @override
  String get extensionsReloadAction => 'Reload extensions';

  @override
  String get extensionDeactivateAllAction => 'Deactivate all extensions';

  @override
  String get extensionsManualAction => 'Load manually';

  @override
  String get extensionsManualUrlLabel => 'Url of extension';

  @override
  String extensionsManualLoadingError(String url) {
    return 'Unable to download extension from \"$url\".';
  }

  @override
  String get icalendarAcceptTentatively => 'Tentatively';

  @override
  String get icalendarActionChangeParticipantStatus => 'Change';

  @override
  String get icalendarLabelSummary => 'Title';

  @override
  String get icalendarNoSummaryInfo => '(no title)';

  @override
  String get icalendarLabelDescription => 'Description';

  @override
  String get icalendarLabelStart => 'Start';

  @override
  String get icalendarLabelEnd => 'End';

  @override
  String get icalendarLabelDuration => 'Duration';

  @override
  String get icalendarLabelLocation => 'Location';

  @override
  String get icalendarLabelTeamsUrl => 'Link';

  @override
  String get icalendarLabelRecurrenceRule => 'Repeats';

  @override
  String get icalendarLabelParticipants => 'Participants';

  @override
  String get icalendarParticipantStatusNeedsAction => 'You are asked to answer this invitation.';

  @override
  String get icalendarParticipantStatusAccepted => 'You have accepted this invitation.';

  @override
  String get icalendarParticipantStatusDeclined => 'You have declined this invitation.';

  @override
  String get icalendarParticipantStatusAcceptedTentatively => 'You have tentatively accepted this invitation.';

  @override
  String get icalendarParticipantStatusDelegated => 'You have delegated this invitation.';

  @override
  String get icalendarParticipantStatusInProcess => 'The task is in progress.';

  @override
  String get icalendarParticipantStatusPartial => 'The task is partially done.';

  @override
  String get icalendarParticipantStatusCompleted => 'The task is done.';

  @override
  String get icalendarParticipantStatusOther => 'Your status is unknown.';

  @override
  String get icalendarParticipantStatusChangeTitle => 'Your Status';

  @override
  String get icalendarParticipantStatusChangeText => 'Do you want to accept this invitation?';

  @override
  String icalendarParticipantStatusSentFailure(String details) {
    return 'Unable to send reply.\nThe server responded with the following details:\n$details';
  }

  @override
  String get icalendarExportAction => 'Export';

  @override
  String icalendarReplyStatusNeedsAction(String attendee) {
    return '$attendee has not answered this invitation.';
  }

  @override
  String icalendarReplyStatusAccepted(String attendee) {
    return '$attendee has accepted the appointment.';
  }

  @override
  String icalendarReplyStatusDeclined(String attendee) {
    return '$attendee has declined this invitation.';
  }

  @override
  String icalendarReplyStatusAcceptedTentatively(String attendee) {
    return '$attendee has tentatively accepted this invitation.';
  }

  @override
  String icalendarReplyStatusDelegated(String attendee) {
    return '$attendee has delegated this invitation.';
  }

  @override
  String icalendarReplyStatusInProcess(String attendee) {
    return '$attendee has started this task.';
  }

  @override
  String icalendarReplyStatusPartial(String attendee) {
    return '$attendee has partially done this task.';
  }

  @override
  String icalendarReplyStatusCompleted(String attendee) {
    return '$attendee has finished this task.';
  }

  @override
  String icalendarReplyStatusOther(String attendee) {
    return '$attendee has answered with an unknown status.';
  }

  @override
  String get icalendarReplyWithoutParticipants => 'This calendar reply contains no participants.';

  @override
  String icalendarReplyWithoutStatus(String attendee) {
    return '$attendee replied without an participation status.';
  }

  @override
  String get composeAppointmentTitle => 'Create Appointment';

  @override
  String get composeAppointmentLabelDay => 'day';

  @override
  String get composeAppointmentLabelTime => 'time';

  @override
  String get composeAppointmentLabelAllDayEvent => 'All day';

  @override
  String get composeAppointmentLabelRepeat => 'Repeat';

  @override
  String get composeAppointmentLabelRepeatOptionNever => 'Never';

  @override
  String get composeAppointmentLabelRepeatOptionDaily => 'Daily';

  @override
  String get composeAppointmentLabelRepeatOptionWeekly => 'Weekly';

  @override
  String get composeAppointmentLabelRepeatOptionMonthly => 'Monthly';

  @override
  String get composeAppointmentLabelRepeatOptionYearly => 'Annually';

  @override
  String get composeAppointmentRecurrenceFrequencyLabel => 'Frequency';

  @override
  String get composeAppointmentRecurrenceIntervalLabel => 'Interval';

  @override
  String get composeAppointmentRecurrenceDaysLabel => 'On days';

  @override
  String get composeAppointmentRecurrenceUntilLabel => 'Until';

  @override
  String get composeAppointmentRecurrenceUntilOptionUnlimited => 'Unlimited';

  @override
  String composeAppointmentRecurrenceUntilOptionRecommended(String duration) {
    return 'Recommended ($duration)';
  }

  @override
  String get composeAppointmentRecurrenceUntilOptionSpecificDate => 'Until chosen date';

  @override
  String composeAppointmentRecurrenceMonthlyOnDayOfMonth(int day) {
    final intl.NumberFormat dayNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
      
    );
    final String dayString = dayNumberFormat.format(day);

    return 'On the $dayString. day of the month';
  }

  @override
  String get composeAppointmentRecurrenceMonthlyOnWeekDay => 'Weekday in month';

  @override
  String get composeAppointmentRecurrenceFirst => 'First';

  @override
  String get composeAppointmentRecurrenceSecond => 'Second';

  @override
  String get composeAppointmentRecurrenceThird => 'Third';

  @override
  String get composeAppointmentRecurrenceLast => 'Last';

  @override
  String get composeAppointmentRecurrenceSecondLast => 'Second-last';

  @override
  String durationYears(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
      
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$numberString years',
      one: '1 year',
    );
    return '$_temp0';
  }

  @override
  String durationMonths(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
      
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$numberString months',
      one: '1 month',
    );
    return '$_temp0';
  }

  @override
  String durationWeeks(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
      
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$numberString weeks',
      one: '1 week',
    );
    return '$_temp0';
  }

  @override
  String durationDays(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
      
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$numberString days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String durationHours(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
      
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$numberString hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String durationMinutes(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
      
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$numberString minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String get durationEmpty => 'No duration';
}
