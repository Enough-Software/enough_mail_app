import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.g.dart';
import 'app_localizations_en.g.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.g.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('de')
  ];

  /// Default signature text
  ///
  /// In en, this message translates to:
  /// **'Sent with Maily'**
  String get signature;

  /// Generic cancel action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// Generic OK action
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get actionOk;

  /// Generic done action
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// Generic next action
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get actionNext;

  /// Generic skip action
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get actionSkip;

  /// Generic undo action
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get actionUndo;

  /// Generic delete action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// Generic accept action
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get actionAccept;

  /// Generic decline action
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get actionDecline;

  /// Generic edit action
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// Copy action for email addresses
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get actionAddressCopy;

  /// Compose action for email addresses
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get actionAddressCompose;

  /// Search action for email addresses
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get actionAddressSearch;

  /// Message shown on splash screen while loading
  ///
  /// In en, this message translates to:
  /// **'Maily starting...'**
  String get splashLoading1;

  /// Message shown on splash screen while loading
  ///
  /// In en, this message translates to:
  /// **'Getting your Maily engine ready...'**
  String get splashLoading2;

  /// Message shown on splash screen while loading
  ///
  /// In en, this message translates to:
  /// **'Launching Maily in 10, 9, 8...'**
  String get splashLoading3;

  /// Welcome panel title
  ///
  /// In en, this message translates to:
  /// **'Maily'**
  String get welcomePanel1Title;

  /// Welcome message shown on first panel
  ///
  /// In en, this message translates to:
  /// **'Welcome to Maily, your friendly and fast email helper!'**
  String get welcomePanel1Text;

  /// Welcome panel title
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get welcomePanel2Title;

  /// Welcome message shown on second panel
  ///
  /// In en, this message translates to:
  /// **'Manage unlimited email accounts. Read and search for mails in all your accounts at once.'**
  String get welcomePanel2Text;

  /// Welcome panel title
  ///
  /// In en, this message translates to:
  /// **'Swipe & Long-Press'**
  String get welcomePanel3Title;

  /// Welcome message shown on third panel
  ///
  /// In en, this message translates to:
  /// **'Swipe your mails to delete them or to mark them read. Long-press a message to select and manage several messages.'**
  String get welcomePanel3Text;

  /// Welcome panel title
  ///
  /// In en, this message translates to:
  /// **'Keep your Inbox clean'**
  String get welcomePanel4Title;

  /// Welcome message shown on fourth panel
  ///
  /// In en, this message translates to:
  /// **'Unsubscribe newsletters with just one tap.'**
  String get welcomePanel4Text;

  /// Button showing login option
  ///
  /// In en, this message translates to:
  /// **'Sign in to your mail account'**
  String get welcomeActionSignIn;

  /// Hint shown in empty search field
  ///
  /// In en, this message translates to:
  /// **'Your search'**
  String get homeSearchHint;

  /// Action to show mails as stack
  ///
  /// In en, this message translates to:
  /// **'Show as stack'**
  String get homeActionsShowAsStack;

  /// Action to show mails as list
  ///
  /// In en, this message translates to:
  /// **'Show as list'**
  String get homeActionsShowAsList;

  /// Message shown when there are no messages in the folder
  ///
  /// In en, this message translates to:
  /// **'All done!\n\nThere are no messages in this folder.'**
  String get homeEmptyFolderMessage;

  /// Message shown when there are no messages found in a search query
  ///
  /// In en, this message translates to:
  /// **'No messages found.'**
  String get homeEmptySearchMessage;

  /// Title of confirmation dialog when deleting all messages
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get homeDeleteAllTitle;

  /// Question in confirmation dialog when deleting all messages
  ///
  /// In en, this message translates to:
  /// **'Really delete all messages?'**
  String get homeDeleteAllQuestion;

  /// Action to tap to delete all messages (must be short).
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get homeDeleteAllAction;

  /// Option to remove deleted messages from disk.
  ///
  /// In en, this message translates to:
  /// **'Scrub messages'**
  String get homeDeleteAllScrubOption;

  /// Message shown after all messages have been deleted.
  ///
  /// In en, this message translates to:
  /// **'All messages deleted.'**
  String get homeDeleteAllSuccess;

  /// Action to tap to mark all messages as seen / read (must be short).
  ///
  /// In en, this message translates to:
  /// **'All read'**
  String get homeMarkAllSeenAction;

  /// Action to tap to mark all messages as unseen / unread (must be short).
  ///
  /// In en, this message translates to:
  /// **'All unread'**
  String get homeMarkAllUnseenAction;

  /// Tooltip for 'compose new message' floating action button.
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get homeFabTooltip;

  /// Title shown while message source itself is being loaded.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get homeLoadingMessageSourceTitle;

  /// Message shown while loading message.
  ///
  /// In en, this message translates to:
  /// **'loading {name}...'**
  String homeLoading(String name);

  /// Swipe action for marking a message as read / unread.
  ///
  /// In en, this message translates to:
  /// **'Mark as read/unread'**
  String get swipeActionToggleRead;

  /// Swipe action for deleting a message.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get swipeActionDelete;

  /// Swipe action for moving a message to junk.
  ///
  /// In en, this message translates to:
  /// **'Mark as junk'**
  String get swipeActionMarkJunk;

  /// Swipe action for moving a message to archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get swipeActionArchive;

  /// Swipe action for marking a message as flagged / unflagged.
  ///
  /// In en, this message translates to:
  /// **'Toggle flag'**
  String get swipeActionFlag;

  /// Message shown after moving messages to junk. Message formatted using the plural JSON scheme.
  ///
  /// In en, this message translates to:
  /// **'{number,plural, =1{One message marked as junk} other{Marked {number} messages as junk}}'**
  String multipleMovedToJunk(int number);

  /// Message shown after moving messages from junk, trash or archive back to the Inbox. Message formatted using the plural JSON scheme.
  ///
  /// In en, this message translates to:
  /// **'{number,plural, =1{Moved one message to inbox} other{Moved {number} messages to inbox}}'**
  String multipleMovedToInbox(int number);

  /// Message shown after moving messages to archive. Message formatted using the plural JSON scheme.
  ///
  /// In en, this message translates to:
  /// **'{number,plural, =1{Archived one message} other{Archived {number} messages}}'**
  String multipleMovedToArchive(int number);

  /// Message shown after moving messages to trash. Message formatted using the plural JSON scheme.
  ///
  /// In en, this message translates to:
  /// **'{number,plural, =1{Deleted one message} other{Deleted {number} messages}}'**
  String multipleMovedToTrash(int number);

  /// Short info shown when a multiple message action is triggered without selecting at least one message first.
  ///
  /// In en, this message translates to:
  /// **'Please select messages first.'**
  String get multipleSelectionNeededInfo;

  /// Title of move dialog for multiple messages. Message formatted using the plural JSON scheme.
  ///
  /// In en, this message translates to:
  /// **'{number,plural, =1{Move message} other{Move {number} messages}}'**
  String multipleMoveTitle(int number);

  /// Action for several messages.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get messageActionMultipleMarkSeen;

  /// Action for several messages.
  ///
  /// In en, this message translates to:
  /// **'Mark as unread'**
  String get messageActionMultipleMarkUnseen;

  /// Action for several messages.
  ///
  /// In en, this message translates to:
  /// **'Flag messages'**
  String get messageActionMultipleMarkFlagged;

  /// Action for several messages.
  ///
  /// In en, this message translates to:
  /// **'Unflag messages'**
  String get messageActionMultipleMarkUnflagged;

  /// No description provided for @messageActionViewInSafeMode.
  ///
  /// In en, this message translates to:
  /// **'View without external content'**
  String get messageActionViewInSafeMode;

  /// Shown as replacement when there is no known sender of a message.
  ///
  /// In en, this message translates to:
  /// **'<no sender>'**
  String get emailSenderUnknown;

  /// Date range title.
  ///
  /// In en, this message translates to:
  /// **'future'**
  String get dateRangeFuture;

  /// Date range title.
  ///
  /// In en, this message translates to:
  /// **'tomorrow'**
  String get dateRangeTomorrow;

  /// Date range title.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get dateRangeToday;

  /// Date range title.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get dateRangeYesterday;

  /// Date range title.
  ///
  /// In en, this message translates to:
  /// **'this week'**
  String get dateRangeCurrentWeek;

  /// Date range title.
  ///
  /// In en, this message translates to:
  /// **'last week'**
  String get dateRangeLastWeek;

  /// Date range title.
  ///
  /// In en, this message translates to:
  /// **'this month'**
  String get dateRangeCurrentMonth;

  /// Date range title.
  ///
  /// In en, this message translates to:
  /// **'last month'**
  String get dateRangeLastMonth;

  /// Date range title.
  ///
  /// In en, this message translates to:
  /// **'this year'**
  String get dateRangeCurrentYear;

  /// Date range title.
  ///
  /// In en, this message translates to:
  /// **'long ago'**
  String get dateRangeLongAgo;

  /// Unknown date.
  ///
  /// In en, this message translates to:
  /// **'undefined'**
  String get dateUndefined;

  /// Message data is today.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get dateDayToday;

  /// Message data is yesterday.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get dateDayYesterday;

  /// Message data is a recent weekday.
  ///
  /// In en, this message translates to:
  /// **'last {day}'**
  String dateDayLastWeekday(String day);

  /// Menu entry for about.
  ///
  /// In en, this message translates to:
  /// **'About Maily'**
  String get drawerEntryAbout;

  /// Menu entry for settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get drawerEntrySettings;

  /// Title shown for accounts drop down. Message formatted using the plural JSON scheme.
  ///
  /// In en, this message translates to:
  /// **'{number,plural, =1{One account} other{{number} accounts}}'**
  String drawerAccountsSectionTitle(int number);

  /// Menu entry for adding a new account.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get drawerEntryAddAccount;

  /// Name of unified account.
  ///
  /// In en, this message translates to:
  /// **'Unified account'**
  String get unifiedAccountName;

  /// Folder name of unified account.
  ///
  /// In en, this message translates to:
  /// **'Unified Inbox'**
  String get unifiedFolderInbox;

  /// Folder name of unified account.
  ///
  /// In en, this message translates to:
  /// **'Unified Sent'**
  String get unifiedFolderSent;

  /// Folder name of unified account.
  ///
  /// In en, this message translates to:
  /// **'Unified Drafts'**
  String get unifiedFolderDrafts;

  /// Folder name of unified account.
  ///
  /// In en, this message translates to:
  /// **'Unified Trash'**
  String get unifiedFolderTrash;

  /// Folder name of unified account.
  ///
  /// In en, this message translates to:
  /// **'Unified Archive'**
  String get unifiedFolderArchive;

  /// Folder name of unified account.
  ///
  /// In en, this message translates to:
  /// **'Unified Junk'**
  String get unifiedFolderJunk;

  /// Folder name.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get folderInbox;

  /// Folder name.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get folderSent;

  /// Folder name.
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get folderDrafts;

  /// Folder name.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get folderTrash;

  /// Folder name.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get folderArchive;

  /// Folder name.
  ///
  /// In en, this message translates to:
  /// **'Junk'**
  String get folderJunk;

  /// Show contents of a message on a separate screen.
  ///
  /// In en, this message translates to:
  /// **'View contents'**
  String get viewContentsAction;

  /// Show source code of a message.
  ///
  /// In en, this message translates to:
  /// **'View source'**
  String get viewSourceAction;

  /// Info shown when an email could not be downloaded.
  ///
  /// In en, this message translates to:
  /// **'Message could not be downloaded.'**
  String get detailsErrorDownloadInfo;

  /// Retry action shown when an email could not be downloaded.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get detailsErrorDownloadRetry;

  /// Label for sender(s) of email.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get detailsHeaderFrom;

  /// Label for [to] recipient(s) of email.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get detailsHeaderTo;

  /// Label for [CC] - carbon copy - recipient(s) of email.
  ///
  /// In en, this message translates to:
  /// **'CC'**
  String get detailsHeaderCc;

  /// Label for [BCC] - blind carbon copy - recipient(s) of email.
  ///
  /// In en, this message translates to:
  /// **'BCC'**
  String get detailsHeaderBcc;

  /// Label for date of email.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get detailsHeaderDate;

  /// Shown instead of the subject when it is undefined.
  ///
  /// In en, this message translates to:
  /// **'<without subject>'**
  String get subjectUndefined;

  /// Action for showing images. Only visible when external images are blocked.
  ///
  /// In en, this message translates to:
  /// **'Show images'**
  String get detailsActionShowImages;

  /// Action shown for unsubscribable newsletter.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribe'**
  String get detailsNewsletterActionUnsubscribe;

  /// Action shown after re-subscribable newsletter has been unsubscribed.
  ///
  /// In en, this message translates to:
  /// **'Re-subscribe'**
  String get detailsNewsletterActionResubscribe;

  /// Status shown for unsubscribed newsletter.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribed'**
  String get detailsNewsletterStatusUnsubscribed;

  /// Title for unsubscribe newsletter dialog.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribe'**
  String get detailsNewsletterUnsubscribeDialogTitle;

  /// Question for unsubscribe newsletter dialog.
  ///
  /// In en, this message translates to:
  /// **'Do you want to unsubscribe from the mailing list {listName}?'**
  String detailsNewsletterUnsubscribeDialogQuestion(String listName);

  /// Action for unsubscribe newsletter dialog.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribe'**
  String get detailsNewsletterUnsubscribeDialogAction;

  /// Title for dialog after unsubscribing newsletter successfully.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribed'**
  String get detailsNewsletterUnsubscribeSuccessTitle;

  /// Text confirmation after successfully unsubscribing a newsletter.
  ///
  /// In en, this message translates to:
  /// **'You are now unsubscribed from the mailing list {listName}.'**
  String detailsNewsletterUnsubscribeSuccessMessage(String listName);

  /// Title for dialog after unsubscribing newsletter failed.
  ///
  /// In en, this message translates to:
  /// **'Not unsubscribed'**
  String get detailsNewsletterUnsubscribeFailureTitle;

  /// Text confirmation after unsubscribing a newsletter failed.
  ///
  /// In en, this message translates to:
  /// **'Sorry, but I was unable to unsubscribe you from {listName} automatically.'**
  String detailsNewsletterUnsubscribeFailureMessage(String listName);

  /// Title for re-subscribe newsletter dialog.
  ///
  /// In en, this message translates to:
  /// **'Re-subscribe'**
  String get detailsNewsletterResubscribeDialogTitle;

  /// Question for re-subscribe newsletter dialog.
  ///
  /// In en, this message translates to:
  /// **'Do you want to subscribe to this mailing list {listName} again?'**
  String detailsNewsletterResubscribeDialogQuestion(String listName);

  /// Action for re-subscribe newsletter dialog.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get detailsNewsletterResubscribeDialogAction;

  /// Title for dialog after re-subscribed newsletter successfully.
  ///
  /// In en, this message translates to:
  /// **'Subscribed'**
  String get detailsNewsletterResubscribeSuccessTitle;

  /// Text confirmation after successfully re-subscribing a newsletter.
  ///
  /// In en, this message translates to:
  /// **'You are now subscribed to the mailing list {listName} again.'**
  String detailsNewsletterResubscribeSuccessMessage(String listName);

  /// Title for dialog after re-subscribing newsletter failed.
  ///
  /// In en, this message translates to:
  /// **'Not subscribed'**
  String get detailsNewsletterResubscribeFailureTitle;

  /// Text confirmation after re-subscribing a newsletter failed.
  ///
  /// In en, this message translates to:
  /// **'Sorry, but the subscribe request has failed for mailing list {listName}.'**
  String detailsNewsletterResubscribeFailureMessage(String listName);

  /// Action to send the read receipt for the shown message.
  ///
  /// In en, this message translates to:
  /// **'Send read receipt'**
  String get detailsSendReadReceiptAction;

  /// Status after sending the read receipt for the shown message.
  ///
  /// In en, this message translates to:
  /// **'Read receipt sent ✔'**
  String get detailsReadReceiptSentStatus;

  /// Message subject for read receipts.
  ///
  /// In en, this message translates to:
  /// **'Read receipt'**
  String get detailsReadReceiptSubject;

  /// Open action for attachments without interactive viewer.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get attachmentActionOpen;

  /// Action for single message.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get messageActionReply;

  /// Action for single message.
  ///
  /// In en, this message translates to:
  /// **'Reply all'**
  String get messageActionReplyAll;

  /// Action for single message.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get messageActionForward;

  /// Action for single message.
  ///
  /// In en, this message translates to:
  /// **'Forward as attachment'**
  String get messageActionForwardAsAttachment;

  /// Action for single message to forward the given number of attachments.
  ///
  /// In en, this message translates to:
  /// **'{number,plural, =1{Forward attachment} other{Forward {number} attachments}}'**
  String messageActionForwardAttachments(int number);

  /// Action for multiple selected messages to forward all attachments of the messages.
  ///
  /// In en, this message translates to:
  /// **'Forward attachments'**
  String get messagesActionForwardAttachments;

  /// Action for single message.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get messageActionDelete;

  /// Action for single message.
  ///
  /// In en, this message translates to:
  /// **'Move to inbox'**
  String get messageActionMoveToInbox;

  /// Action for single message.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get messageActionMove;

  /// Status of single message.
  ///
  /// In en, this message translates to:
  /// **'Is read'**
  String get messageStatusSeen;

  /// Status of single message.
  ///
  /// In en, this message translates to:
  /// **'Is unread'**
  String get messageStatusUnseen;

  /// Status of single message.
  ///
  /// In en, this message translates to:
  /// **'Is flagged'**
  String get messageStatusFlagged;

  /// Status of single message.
  ///
  /// In en, this message translates to:
  /// **'Is not flagged'**
  String get messageStatusUnflagged;

  /// Action for single message.
  ///
  /// In en, this message translates to:
  /// **'Mark as junk'**
  String get messageActionMarkAsJunk;

  /// Action for single message.
  ///
  /// In en, this message translates to:
  /// **'Mark as not junk'**
  String get messageActionMarkAsNotJunk;

  /// Action for single message.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get messageActionArchive;

  /// Action for single message.
  ///
  /// In en, this message translates to:
  /// **'Move to Inbox'**
  String get messageActionUnarchive;

  /// Action for single message.
  ///
  /// In en, this message translates to:
  /// **'Redirect'**
  String get messageActionRedirect;

  /// Action for single message.
  ///
  /// In en, this message translates to:
  /// **'Add notification'**
  String get messageActionAddNotification;

  /// Successful short snackbar message after deleting message(s).
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get resultDeleted;

  /// Successful short snackbar message after moving message(s) to junk.
  ///
  /// In en, this message translates to:
  /// **'Marked as junk'**
  String get resultMovedToJunk;

  /// Successful short snackbar message after moving message(s) to inbox.
  ///
  /// In en, this message translates to:
  /// **'Moved to Inbox'**
  String get resultMovedToInbox;

  /// Successful short snackbar message after moving message(s) to archive.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get resultArchived;

  /// Successful snackbar message after redirecting message to new recipient(s).
  ///
  /// In en, this message translates to:
  /// **'Message redirected 👍'**
  String get resultRedirectedSuccess;

  /// Failure snackbar message after failed to redirect message to new recipient(s).
  ///
  /// In en, this message translates to:
  /// **'Unable to redirect message.\n\nThe server responded with the following details: \"{details}\"'**
  String resultRedirectedFailure(String details);

  /// Title of redirect dialog.
  ///
  /// In en, this message translates to:
  /// **'Redirect'**
  String get redirectTitle;

  /// Short explanation of redirect action in redirect dialog.
  ///
  /// In en, this message translates to:
  /// **'Redirect this message to the following recipient(s). Redirecting does not alter the message.'**
  String get redirectInfo;

  /// Information when redirect is wanted but no address has been entered.
  ///
  /// In en, this message translates to:
  /// **'You need to add at least one valid email address.'**
  String get redirectEmailInputRequired;

  /// Description of search within the given folder.
  ///
  /// In en, this message translates to:
  /// **'Search in {folder}...'**
  String searchQueryDescription(String folder);

  /// Title for a search with the given query.
  ///
  /// In en, this message translates to:
  /// **'Search \"{query}\"'**
  String searchQueryTitle(String query);

  /// Legal info shown on initial welcome screen and later in about. [PP] is replaced with the legalesePrivacyPolicy text and [TC] with legaleseTermsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'By using Maily you agree to our [PP] and to our [TC].'**
  String get legaleseUsage;

  /// Translation of privacy policy
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get legalesePrivacyPolicy;

  /// Translation of Terms & Conditions
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get legaleseTermsAndConditions;

  /// Legal info shown in about dialog.
  ///
  /// In en, this message translates to:
  /// **'Maily is free software published under the GNU General Public License.'**
  String get aboutApplicationLegalese;

  /// Action to suggest a feature.
  ///
  /// In en, this message translates to:
  /// **'Suggest a feature'**
  String get feedbackActionSuggestFeature;

  /// Action to report a problem.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get feedbackActionReportProblem;

  /// Action to help developing.
  ///
  /// In en, this message translates to:
  /// **'Help developing Maily'**
  String get feedbackActionHelpDeveloping;

  /// Title of feedback settings screen.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackTitle;

  /// Intro for feedback settings screen.
  ///
  /// In en, this message translates to:
  /// **'Thank you for testing Maily!'**
  String get feedbackIntro;

  /// Request to provide device and app information when reporting a problem.
  ///
  /// In en, this message translates to:
  /// **'Please provide this information when you report a problem:'**
  String get feedbackProvideInfoRequest;

  /// Info shown after copying device and app info to clipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get feedbackResultInfoCopied;

  /// Title of accounts settings screen.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accountsTitle;

  /// No description provided for @accountsActionReorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder accounts'**
  String get accountsActionReorder;

  /// Title of base settings screen.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Settings option to block external options.
  ///
  /// In en, this message translates to:
  /// **'Block external images'**
  String get settingsSecurityBlockExternalImages;

  /// Title of dialog that shows additional information about the 'block external images' option.
  ///
  /// In en, this message translates to:
  /// **'External images'**
  String get settingsSecurityBlockExternalImagesDescriptionTitle;

  /// Text of dialog that shows additional information about the 'block external images' option.
  ///
  /// In en, this message translates to:
  /// **'Email messages can contain images that are either integrated or hosted on external servers. The latter, external images can expose information to the sender of the message, e.g. to let the sender know that you have opened the message. This option allows you to block such external images, which reduces the risk of exposing sensitive information. You can still opt in to load such images on a per-message-basis when you read a message.'**
  String get settingsSecurityBlockExternalImagesDescriptionText;

  /// Option for how to render messages.
  ///
  /// In en, this message translates to:
  /// **'Show full message contents'**
  String get settingsSecurityMessageRenderingHtml;

  /// Option for how to render messages.
  ///
  /// In en, this message translates to:
  /// **'Show only the text of messages'**
  String get settingsSecurityMessageRenderingPlainText;

  /// Option for how to launch URLs.
  ///
  /// In en, this message translates to:
  /// **'How should Maily open links?'**
  String get settingsSecurityLaunchModeLabel;

  /// Option for how to launch URLs.
  ///
  /// In en, this message translates to:
  /// **'Open links externally'**
  String get settingsSecurityLaunchModeExternal;

  /// Option for how to launch URLs.
  ///
  /// In en, this message translates to:
  /// **'Open links in Maily'**
  String get settingsSecurityLaunchModeInApp;

  /// Settings action to manage accounts.
  ///
  /// In en, this message translates to:
  /// **'Manage accounts'**
  String get settingsActionAccounts;

  /// Settings action to manage the visualization of the app.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsActionDesign;

  /// Settings action to provide feedback about the app.
  ///
  /// In en, this message translates to:
  /// **'Provide feedback'**
  String get settingsActionFeedback;

  /// Settings action to show welcome screen of the app again.
  ///
  /// In en, this message translates to:
  /// **'Show welcome'**
  String get settingsActionWelcome;

  /// Settings action to customize read receipts.
  ///
  /// In en, this message translates to:
  /// **'Read receipts'**
  String get settingsReadReceipts;

  /// Introduction text for managing read receipt requests.
  ///
  /// In en, this message translates to:
  /// **'Do you want to display read receipt requests?'**
  String get readReceiptsSettingsIntroduction;

  /// Display option for read receipt requests.
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get readReceiptOptionAlways;

  /// Display option for read receipt requests.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get readReceiptOptionNever;

  /// Settings action to customize folders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get settingsFolders;

  /// Introduction for folder names setting.
  ///
  /// In en, this message translates to:
  /// **'What names do you prefer for your folders?'**
  String get folderNamesIntroduction;

  /// Folder name setting option.
  ///
  /// In en, this message translates to:
  /// **'Names given by Maily'**
  String get folderNamesSettingLocalized;

  /// Folder name setting option.
  ///
  /// In en, this message translates to:
  /// **'Names given by the service'**
  String get folderNamesSettingServer;

  /// Folder name setting option.
  ///
  /// In en, this message translates to:
  /// **'My own custom names'**
  String get folderNamesSettingCustom;

  /// Action to specify custom folder names.
  ///
  /// In en, this message translates to:
  /// **'Edit custom names'**
  String get folderNamesEditAction;

  /// Title of dialog to specify custom folder names.
  ///
  /// In en, this message translates to:
  /// **'Custom names'**
  String get folderNamesCustomTitle;

  /// Action to create a new folder.
  ///
  /// In en, this message translates to:
  /// **'Create folder'**
  String get folderAddAction;

  /// Dialog title when creating a new folder.
  ///
  /// In en, this message translates to:
  /// **'Create folder'**
  String get folderAddTitle;

  /// Label for input field for the folder name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get folderAddNameLabel;

  /// Hint for input field for the folder name.
  ///
  /// In en, this message translates to:
  /// **'Name of the new folder'**
  String get folderAddNameHint;

  /// No description provided for @folderAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get folderAccountLabel;

  /// No description provided for @folderMailboxLabel.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get folderMailboxLabel;

  /// Info for showing the creation success.
  ///
  /// In en, this message translates to:
  /// **'Folder created 😊'**
  String get folderAddResultSuccess;

  /// Info for showing a folder creation error.
  ///
  /// In en, this message translates to:
  /// **'Folder could not be created.\n\nThe server responded with {details}'**
  String folderAddResultFailure(String details);

  /// Action to delete an existing folder.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get folderDeleteAction;

  /// Dialog title to confirm deleting a folder.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get folderDeleteConfirmTitle;

  /// Dialog text to confirm deleting a folder.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete the folder {name}?'**
  String folderDeleteConfirmText(String name);

  /// Info for showing the creation success.
  ///
  /// In en, this message translates to:
  /// **'Folder deleted.'**
  String get folderDeleteResultSuccess;

  /// Info for showing a folder deletion error.
  ///
  /// In en, this message translates to:
  /// **'Folder could not be deleted.\n\nThe server responded with {details}'**
  String folderDeleteResultFailure(String details);

  /// Settings action to specify the development options.
  ///
  /// In en, this message translates to:
  /// **'Development settings'**
  String get settingsDevelopment;

  /// Title of the development mode section.
  ///
  /// In en, this message translates to:
  /// **'Development mode'**
  String get developerModeTitle;

  /// Text explaining the development mode.
  ///
  /// In en, this message translates to:
  /// **'If you enable the development mode you will be able to view the source code of messages and convert text attachments to messages.'**
  String get developerModeIntroduction;

  /// Text in checkbox to enable the development mode.
  ///
  /// In en, this message translates to:
  /// **'Enable development mode'**
  String get developerModeEnable;

  /// Action to convert text into an email.
  ///
  /// In en, this message translates to:
  /// **'Convert text to email'**
  String get developerShowAsEmail;

  /// Text shown when text cannot be converted into an email.
  ///
  /// In en, this message translates to:
  /// **'This text cannot be converted into a MIME message.'**
  String get developerShowAsEmailFailed;

  /// Title of design settings screen.
  ///
  /// In en, this message translates to:
  /// **'Design Settings'**
  String get designTitle;

  /// Title of theme section on design settings screen.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get designSectionThemeTitle;

  /// Theme option.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get designThemeOptionLight;

  /// Theme option.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get designThemeOptionDark;

  /// Theme option.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get designThemeOptionSystem;

  /// Theme option.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get designThemeOptionCustom;

  /// Title of custom theme option section on design settings screen.
  ///
  /// In en, this message translates to:
  /// **'Enable dark theme'**
  String get designSectionCustomTitle;

  /// Start time of custom theme setting.
  ///
  /// In en, this message translates to:
  /// **'from {time}'**
  String designThemeCustomStart(String time);

  /// End time of custom theme setting.
  ///
  /// In en, this message translates to:
  /// **'until {time}'**
  String designThemeCustomEnd(String time);

  /// Title of color section on design settings screen.
  ///
  /// In en, this message translates to:
  /// **'Color Scheme'**
  String get designSectionColorTitle;

  /// Title of security settings screen.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securitySettingsTitle;

  /// Introduction of security settings screen.
  ///
  /// In en, this message translates to:
  /// **'Adapt the security settings to your personal needs.'**
  String get securitySettingsIntro;

  /// iOS-specific unlock reason.
  ///
  /// In en, this message translates to:
  /// **'Unlock Maily with Face ID.'**
  String get securityUnlockWithFaceId;

  /// iOS-specific unlock reason.
  ///
  /// In en, this message translates to:
  /// **'Unlock Maily with Touch ID.'**
  String get securityUnlockWithTouchId;

  /// Generic unlock reason.
  ///
  /// In en, this message translates to:
  /// **'Unlock Maily.'**
  String get securityUnlockReason;

  /// Generic unlock disable reason.
  ///
  /// In en, this message translates to:
  /// **'Unlock Maily to turn off lock.'**
  String get securityUnlockDisableReason;

  /// Message when biometric authentication is not available.
  ///
  /// In en, this message translates to:
  /// **'Your device does not support biometrics, possibly you need to set up unlock options first.'**
  String get securityUnlockNotAvailable;

  /// Label of biometric authentication lock feature.
  ///
  /// In en, this message translates to:
  /// **'Lock Maily'**
  String get securityUnlockLabel;

  /// Title to explain lock feature via biometric authentication.
  ///
  /// In en, this message translates to:
  /// **'Lock Maily'**
  String get securityUnlockDescriptionTitle;

  /// Text explaining lock feature via biometric authentication.
  ///
  /// In en, this message translates to:
  /// **'You can choose to lock access to Maily, so that others cannot read your email even when they have access to your device.'**
  String get securityUnlockDescriptionText;

  /// Lock timing option.
  ///
  /// In en, this message translates to:
  /// **'Lock immediately'**
  String get securityLockImmediately;

  /// Lock timing option.
  ///
  /// In en, this message translates to:
  /// **'Lock after 5 minutes'**
  String get securityLockAfter5Minutes;

  /// Lock timing option.
  ///
  /// In en, this message translates to:
  /// **'Lock after 30 minutes'**
  String get securityLockAfter30Minutes;

  /// Title of lock screen.
  ///
  /// In en, this message translates to:
  /// **'Maily is locked'**
  String get lockScreenTitle;

  /// Text on lock screen.
  ///
  /// In en, this message translates to:
  /// **'Maily is locked, please authenticate to proceed.'**
  String get lockScreenIntro;

  /// Action to unlock on lock screen.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get lockScreenUnlockAction;

  /// Title of add account screen.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get addAccountTitle;

  /// Label and section header of email address input field.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get addAccountEmailLabel;

  /// Hint text of email address input field.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get addAccountEmailHint;

  /// Label shown while resolving the settings for the specified email address.
  ///
  /// In en, this message translates to:
  /// **'Resolving {email}...'**
  String addAccountResolvingSettingsLabel(String email);

  /// Button text shown for the user to edit server settings manually when the resolving was successful but turned out a different than expected provider name.
  ///
  /// In en, this message translates to:
  /// **'Not on {provider}?'**
  String addAccountResolvedSettingsWrongAction(String provider);

  /// Info shown after resolving the settings for the specified email address failed.
  ///
  /// In en, this message translates to:
  /// **'Unable to resolve {email}. Please go back to change it or set up the account manually.'**
  String addAccountResolvingSettingsFailedInfo(String email);

  /// Action shown after account settings could not be automatically be discovered.
  ///
  /// In en, this message translates to:
  /// **'Edit manually'**
  String get addAccountEditManuallyAction;

  /// Label and section header of password input field.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get addAccountPasswordLabel;

  /// Hint text of password input field.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get addAccountPasswordHint;

  /// Text shown when the provider of the email account requires app specific passwords to be set up.
  ///
  /// In en, this message translates to:
  /// **'This provider requires you to set up an app specific password.'**
  String get addAccountApplicationPasswordRequiredInfo;

  /// Button text for setting up app specific password.
  ///
  /// In en, this message translates to:
  /// **'Create app specific password'**
  String get addAccountApplicationPasswordRequiredButton;

  /// Acknowledgement to be confirmed by user to acknowledge the fact that an app specific password is required.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get addAccountApplicationPasswordRequiredAcknowledged;

  /// Section header of verification/log in step.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get addAccountVerificationStep;

  /// Section header of account setup step.
  ///
  /// In en, this message translates to:
  /// **'Account Setup'**
  String get addAccountSetupAccountStep;

  /// Info shown while the account settings for the given email are verified.
  ///
  /// In en, this message translates to:
  /// **'Verifying {email}...'**
  String addAccountVerifyingSettingsLabel(String email);

  /// Info shown after the account settings for the given email have been verified.
  ///
  /// In en, this message translates to:
  /// **'Successfully signed into {email}.'**
  String addAccountVerifyingSuccessInfo(String email);

  /// Info shown after the account settings for the given email could not be verified.
  ///
  /// In en, this message translates to:
  /// **'Sorry, but there was a problem. Please check your email {email} and password.'**
  String addAccountVerifyingFailedInfo(String email);

  /// Info shown oauth process fails and the user can try again or use an app-specific password.
  ///
  /// In en, this message translates to:
  /// **'Sign in with {provider} or create an app-specific password.'**
  String addAccountOauthOptionsText(String provider);

  /// Label of button to sign in via oauth with the given provider.
  ///
  /// In en, this message translates to:
  /// **'Sign in with {provider}'**
  String addAccountOauthSignIn(String provider);

  /// Label of button to sign in via oauth with the Google.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get addAccountOauthSignInGoogle;

  /// Info to set up app specific password.
  ///
  /// In en, this message translates to:
  /// **'Alternatively, create an app password to sign in.'**
  String get addAccountOauthSignInWithAppPassword;

  /// Info shown when login fails for a provider that is know to require manual activation of IMAP access.
  ///
  /// In en, this message translates to:
  /// **'Your provider might require you to setup access for email apps manually.'**
  String get accountAddImapAccessSetupMightBeRequired;

  /// Label of button to launch website with instructions.
  ///
  /// In en, this message translates to:
  /// **'Setup email access'**
  String get addAccountSetupImapAccessButtonLabel;

  /// Label for user name input field.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get addAccountNameOfUserLabel;

  /// Hint for user name input field.
  ///
  /// In en, this message translates to:
  /// **'The name that recipients see'**
  String get addAccountNameOfUserHint;

  /// Label for account name input field.
  ///
  /// In en, this message translates to:
  /// **'Account name'**
  String get addAccountNameOfAccountLabel;

  /// Hint for account name input field.
  ///
  /// In en, this message translates to:
  /// **'Please enter the name of your account'**
  String get addAccountNameOfAccountHint;

  /// Title for screen when editing the account with the given name.
  ///
  /// In en, this message translates to:
  /// **'Edit {name}'**
  String editAccountTitle(String name);

  /// Info about not being able to connect to the named service. Most common causes are temporary network problems or a changed password.
  ///
  /// In en, this message translates to:
  /// **'Maily could not connect {name}.'**
  String editAccountFailureToConnectInfo(String name);

  /// Action to retry connecting to service again.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get editAccountFailureToConnectRetryAction;

  /// Action to change password for the service.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get editAccountFailureToConnectChangePasswordAction;

  /// Title of dialog shown after successfully connecting a failed account again.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get editAccountFailureToConnectFixedTitle;

  /// Message of dialog shown after successfully connecting a failed account again.
  ///
  /// In en, this message translates to:
  /// **'The account is connected again.'**
  String get editAccountFailureToConnectFixedInfo;

  /// Label for opting this account in/out of the unified account.
  ///
  /// In en, this message translates to:
  /// **'Include in unified account'**
  String get editAccountIncludeInUnifiedLabel;

  /// Label for any alias addresses that have been specified for the given email address.
  ///
  /// In en, this message translates to:
  /// **'Alias email addresses for {email}:'**
  String editAccountAliasLabel(String email);

  /// Info when there have been no aliases specified for this account.
  ///
  /// In en, this message translates to:
  /// **'You have no known aliases for this account yet.'**
  String get editAccountNoAliasesInfo;

  /// Info given after an alias was removed.
  ///
  /// In en, this message translates to:
  /// **'{email} alias removed'**
  String editAccountAliasRemoved(String email);

  /// Button text for adding an alias to this account.
  ///
  /// In en, this message translates to:
  /// **'Add alias'**
  String get editAccountAddAliasAction;

  /// Info shown when + aliases are supported by this account.
  ///
  /// In en, this message translates to:
  /// **'Supports + aliases'**
  String get editAccountPlusAliasesSupported;

  /// Button text for testing of + aliases are supported by this account.
  ///
  /// In en, this message translates to:
  /// **'Test support for + aliases'**
  String get editAccountCheckPlusAliasAction;

  /// Label of checkbox to enable the BCC-MYSELF-Feature.
  ///
  /// In en, this message translates to:
  /// **'BCC myself'**
  String get editAccountBccMyself;

  /// Title of alert explaining the BCC-MYSELF-Feature.
  ///
  /// In en, this message translates to:
  /// **'BCC myself'**
  String get editAccountBccMyselfDescriptionTitle;

  /// Explanation of the the BCC-MYSELF-Feature.
  ///
  /// In en, this message translates to:
  /// **'You can automatically send messages to yourself for every message you send from this account with the \"BCC myself\" feature. Usually this is not required and wanted as all outgoing messages are stored in the \"Sent\" folder anyhow.'**
  String get editAccountBccMyselfDescriptionText;

  /// Button text for editing the server settings of  this account.
  ///
  /// In en, this message translates to:
  /// **'Edit server settings'**
  String get editAccountServerSettingsAction;

  /// Button text for deleting this account.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get editAccountDeleteAccountAction;

  /// Title for confirmation dialog when deleting this account.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get editAccountDeleteAccountConfirmationTitle;

  /// Request to confirm when deleting this account.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete the account {name}?'**
  String editAccountDeleteAccountConfirmationQuery(String name);

  /// Title for dialog shown while testing + alias support
  ///
  /// In en, this message translates to:
  /// **'+ Aliases for {name}'**
  String editAccountTestPlusAliasTitle(String name);

  /// Title for introducing concept of + aliases.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get editAccountTestPlusAliasStepIntroductionTitle;

  /// Text for introducing concept of + aliases.
  ///
  /// In en, this message translates to:
  /// **'Your account {accountName} might support so called + aliases like {example}.\nA + alias helps you to protect your identity and helps you against spam.\nTo test this, a test message will be sent to this generated address. If it arrives, your provider supports + aliases and you can easily generate them on demand when writing a new mail message.'**
  String editAccountTestPlusAliasStepIntroductionText(String accountName, String example);

  /// Title while testing concept of + aliases.
  ///
  /// In en, this message translates to:
  /// **'Testing'**
  String get editAccountTestPlusAliasStepTestingTitle;

  /// Title after testing concept of + aliases.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get editAccountTestPlusAliasStepResultTitle;

  /// Result when account supports + aliases
  ///
  /// In en, this message translates to:
  /// **'Your account {name} supports + aliases.'**
  String editAccountTestPlusAliasStepResultSuccess(String name);

  /// Result when account does not supports + aliases
  ///
  /// In en, this message translates to:
  /// **'Your account {name} does not support + aliases.'**
  String editAccountTestPlusAliasStepResultNoSuccess(String name);

  /// Title when adding new alias.
  ///
  /// In en, this message translates to:
  /// **'Add alias'**
  String get editAccountAddAliasTitle;

  /// Title when editing alias.
  ///
  /// In en, this message translates to:
  /// **'Edit alias'**
  String get editAccountEditAliasTitle;

  /// Action when adding new alias.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get editAccountAliasAddAction;

  /// Action when editing alias.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get editAccountAliasUpdateAction;

  /// Label for alias name input field.
  ///
  /// In en, this message translates to:
  /// **'Alias name'**
  String get editAccountEditAliasNameLabel;

  /// Label for alias email input field.
  ///
  /// In en, this message translates to:
  /// **'Alias email'**
  String get editAccountEditAliasEmailLabel;

  /// Hint for alias email input field.
  ///
  /// In en, this message translates to:
  /// **'Your alias email address'**
  String get editAccountEditAliasEmailHint;

  /// Error when the alias email is already known
  ///
  /// In en, this message translates to:
  /// **'There is already an alias with {email}.'**
  String editAccountEditAliasDuplicateError(String email);

  /// Label developer mode option to enable logging.
  ///
  /// In en, this message translates to:
  /// **'Enable logging'**
  String get editAccountEnableLogging;

  /// Short message shown after the log has been enabled.
  ///
  /// In en, this message translates to:
  /// **'Log enabled, please restart'**
  String get editAccountLoggingEnabled;

  /// Short message shown after the log has been disabled.
  ///
  /// In en, this message translates to:
  /// **'Log disabled, please restart'**
  String get editAccountLoggingDisabled;

  /// Title shown when account name is not set.
  ///
  /// In en, this message translates to:
  /// **'Server Settings'**
  String get accountDetailsFallbackTitle;

  /// Title for error dialogs.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// Step to select a provider.
  ///
  /// In en, this message translates to:
  /// **'Email Service Provider'**
  String get accountProviderStepTitle;

  /// When no standard provider is chosen.
  ///
  /// In en, this message translates to:
  /// **'Other email service'**
  String get accountProviderCustom;

  /// Error details when no connection to server could be established at all
  ///
  /// In en, this message translates to:
  /// **'Maily cannot reach the specified mail server. Please check your incoming server setting \"{incomingHost}\" and your outgoing server setting \"{outgoingHost}\".'**
  String accountDetailsErrorHostProblem(String incomingHost, String outgoingHost);

  /// Error details when login fails
  ///
  /// In en, this message translates to:
  /// **'Unable to log your in. Please check your user name \"{userName}\" and your password \"{password}\".'**
  String accountDetailsErrorLoginProblem(String userName, String password);

  /// Label for user name input field.
  ///
  /// In en, this message translates to:
  /// **'Login name'**
  String get accountDetailsUserNameLabel;

  /// Hint for user name input field.
  ///
  /// In en, this message translates to:
  /// **'Your user name, if different from email'**
  String get accountDetailsUserNameHint;

  /// Label for password input field.
  ///
  /// In en, this message translates to:
  /// **'Login password'**
  String get accountDetailsPasswordLabel;

  /// Hint for user password input field.
  ///
  /// In en, this message translates to:
  /// **'Your password'**
  String get accountDetailsPasswordHint;

  /// Title of base settings section.
  ///
  /// In en, this message translates to:
  /// **'Base settings'**
  String get accountDetailsBaseSectionTitle;

  /// Label for incoming server domain field.
  ///
  /// In en, this message translates to:
  /// **'Incoming server'**
  String get accountDetailsIncomingLabel;

  /// Hint for incoming server domain field.
  ///
  /// In en, this message translates to:
  /// **'Domain like imap.domain.com'**
  String get accountDetailsIncomingHint;

  /// Label for outgoing server domain field.
  ///
  /// In en, this message translates to:
  /// **'Outgoing server'**
  String get accountDetailsOutgoingLabel;

  /// Hint for outgoing server domain field.
  ///
  /// In en, this message translates to:
  /// **'Domain like smtp.domain.com'**
  String get accountDetailsOutgoingHint;

  /// Title of incoming settings section.
  ///
  /// In en, this message translates to:
  /// **'Advanced incoming settings'**
  String get accountDetailsAdvancedIncomingSectionTitle;

  /// Label for server type dropdown.
  ///
  /// In en, this message translates to:
  /// **'Incoming type:'**
  String get accountDetailsIncomingServerTypeLabel;

  /// Option when the server type/security should be discovered automatically.
  ///
  /// In en, this message translates to:
  /// **'automatic'**
  String get accountDetailsOptionAutomatic;

  /// Label for server security dropdown.
  ///
  /// In en, this message translates to:
  /// **'Incoming security:'**
  String get accountDetailsIncomingSecurityLabel;

  /// Label for security dropdown option without encryption.
  ///
  /// In en, this message translates to:
  /// **'Plain (no encryption)'**
  String get accountDetailsSecurityOptionNone;

  /// Label for incoming port input field.
  ///
  /// In en, this message translates to:
  /// **'Incoming port'**
  String get accountDetailsIncomingPortLabel;

  /// Hint for port input fields.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to determine automatically'**
  String get accountDetailsPortHint;

  /// Label for incoming user name input field.
  ///
  /// In en, this message translates to:
  /// **'Incoming user name'**
  String get accountDetailsIncomingUserNameLabel;

  /// Label for alternative user name input fields.
  ///
  /// In en, this message translates to:
  /// **'Your user name, if different from above'**
  String get accountDetailsAlternativeUserNameHint;

  /// Label for incoming password input field.
  ///
  /// In en, this message translates to:
  /// **'Incoming password'**
  String get accountDetailsIncomingPasswordLabel;

  /// Label for alternative user name input fields.
  ///
  /// In en, this message translates to:
  /// **'Your password, if different from above'**
  String get accountDetailsAlternativePasswordHint;

  /// Title of incoming settings section.
  ///
  /// In en, this message translates to:
  /// **'Advanced outgoing settings'**
  String get accountDetailsAdvancedOutgoingSectionTitle;

  /// Label for server type dropdown.
  ///
  /// In en, this message translates to:
  /// **'Outgoing type:'**
  String get accountDetailsOutgoingServerTypeLabel;

  /// Label for server security dropdown.
  ///
  /// In en, this message translates to:
  /// **'Outgoing security:'**
  String get accountDetailsOutgoingSecurityLabel;

  /// Label for outgoing port input field.
  ///
  /// In en, this message translates to:
  /// **'Outgoing port'**
  String get accountDetailsOutgoingPortLabel;

  /// Label for outgoing user name input field.
  ///
  /// In en, this message translates to:
  /// **'Outgoing user name'**
  String get accountDetailsOutgoingUserNameLabel;

  /// Label for outgoing password input field.
  ///
  /// In en, this message translates to:
  /// **'Outgoing password'**
  String get accountDetailsOutgoingPasswordLabel;

  /// Title for compose screen when a new message is created.
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get composeTitleNew;

  /// Title for compose screen when a message is forwarded.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get composeTitleForward;

  /// Title for compose screen when a message is replied.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get composeTitleReply;

  /// Message text for message without text.
  ///
  /// In en, this message translates to:
  /// **'empty message'**
  String get composeEmptyMessage;

  /// Warning shown when trying to send a message without subject.
  ///
  /// In en, this message translates to:
  /// **'You have not specified a subject. Do you want to sent the message without a subject?'**
  String get composeWarningNoSubject;

  /// Action to send message without subject.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get composeActionSentWithoutSubject;

  /// Notification shown after a mail was sent successfully.
  ///
  /// In en, this message translates to:
  /// **'Mail sent 😊'**
  String get composeMailSendSuccess;

  /// Error shown when email could not be send
  ///
  /// In en, this message translates to:
  /// **'Sorry, your mail could not be send. We received the following error:\n{details}.'**
  String composeSendErrorInfo(String details);

  /// Action to request a read receipt for this message
  ///
  /// In en, this message translates to:
  /// **'Request read receipt'**
  String get composeRequestReadReceiptAction;

  /// Action to save a message as draft
  ///
  /// In en, this message translates to:
  /// **'Save as draft'**
  String get composeSaveDraftAction;

  /// Info shown when message was saved as draft successfully
  ///
  /// In en, this message translates to:
  /// **'Draft saved'**
  String get composeMessageSavedAsDraft;

  /// Info shown when message could not be saved as a draft
  ///
  /// In en, this message translates to:
  /// **'Your draft could not be saved with the following error:\n{details}'**
  String composeMessageSavedAsDraftErrorInfo(String details);

  /// Action to write a plain text message instead of an html message
  ///
  /// In en, this message translates to:
  /// **'Convert to plain text'**
  String get composeConvertToPlainTextEditorAction;

  /// Action to write a HTML message instead of a text message
  ///
  /// In en, this message translates to:
  /// **'Convert to rich message (HTML)'**
  String get composeConvertToHtmlEditorAction;

  /// Action to return to compose screen when draft cannot be saved
  ///
  /// In en, this message translates to:
  /// **'Continue editing'**
  String get composeContinueEditingAction;

  /// Action to create a new + alias as a sender
  ///
  /// In en, this message translates to:
  /// **'Create new + alias...'**
  String get composeCreatePlusAliasAction;

  /// Hint for From input field
  ///
  /// In en, this message translates to:
  /// **'Sender'**
  String get composeSenderHint;

  /// Hint for To input field
  ///
  /// In en, this message translates to:
  /// **'Recipient email'**
  String get composeRecipientHint;

  /// Label for Subject input field
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get composeSubjectLabel;

  /// Hint for Subject input field
  ///
  /// In en, this message translates to:
  /// **'Message subject'**
  String get composeSubjectHint;

  /// Action to add an attachment - should be short!
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get composeAddAttachmentAction;

  /// Action to remove an attachment
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String composeRemoveAttachmentAction(String name);

  /// Info shown after leaving compose screen to allow an easy return
  ///
  /// In en, this message translates to:
  /// **'Left by mistake?'**
  String get composeLeftByMistake;

  /// Attachment type to add
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get attachTypeFile;

  /// Attachment type to add
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get attachTypePhoto;

  /// Attachment type to add
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get attachTypeVideo;

  /// Attachment type to add
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get attachTypeAudio;

  /// Attachment type to add
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get attachTypeLocation;

  /// Attachment type to add
  ///
  /// In en, this message translates to:
  /// **'Animated Gif'**
  String get attachTypeGif;

  /// Text for searching in GIPHY service for GIF
  ///
  /// In en, this message translates to:
  /// **'search GIPHY'**
  String get attachTypeGifSearch;

  /// Attachment type to add
  ///
  /// In en, this message translates to:
  /// **'Sticker'**
  String get attachTypeSticker;

  /// Text for searching in GIPHY service for sticker
  ///
  /// In en, this message translates to:
  /// **'search GIPHY'**
  String get attachTypeStickerSearch;

  /// Attachment type to add
  ///
  /// In en, this message translates to:
  /// **'Appointment'**
  String get attachTypeAppointment;

  /// Title of language setting screen
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSettingTitle;

  /// Label for language setting dropdown screen
  ///
  /// In en, this message translates to:
  /// **'Choose the language for Maily:'**
  String get languageSettingLabel;

  /// Option to use the system's settings
  ///
  /// In en, this message translates to:
  /// **'System language'**
  String get languageSettingSystemOption;

  /// Title of dialog to confirm when switching the language
  ///
  /// In en, this message translates to:
  /// **'Use English for Maily?'**
  String get languageSettingConfirmationTitle;

  /// Query to be confirmed by user when switching the language
  ///
  /// In en, this message translates to:
  /// **'Please confirm to use English as your chosen language.'**
  String get languageSettingConfirmationQuery;

  /// Info text after having specified the language.
  ///
  /// In en, this message translates to:
  /// **'Maily is now shown in English. Please restart the app to take effect.'**
  String get languageSetInfo;

  /// Info text after choosing the system's language for Maily.
  ///
  /// In en, this message translates to:
  /// **'Maily will now use the system\'s language or English if the system\'s language is not supported. Please restart the app to take effect.'**
  String get languageSystemSetInfo;

  /// Title of swipe setting screen
  ///
  /// In en, this message translates to:
  /// **'Swipe gestures'**
  String get swipeSettingTitle;

  /// Label for swipe gesture
  ///
  /// In en, this message translates to:
  /// **'Left to right swipe'**
  String get swipeSettingLeftToRightLabel;

  /// Label for swipe gesture
  ///
  /// In en, this message translates to:
  /// **'Right to left swipe'**
  String get swipeSettingRightToLeftLabel;

  /// Action for changing a swipe gesture
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get swipeSettingChangeAction;

  /// Title of signature setting screen
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get signatureSettingsTitle;

  /// Text before selecting message types for a signature (new, forward, reply).
  ///
  /// In en, this message translates to:
  /// **'Enable the signature for the following messages:'**
  String get signatureSettingsComposeActionsInfo;

  /// Informational text before showing link to account settings.
  ///
  /// In en, this message translates to:
  /// **'You can specify account specific signatures in the account settings.'**
  String get signatureSettingsAccountInfo;

  /// Action to add account specific signature.
  ///
  /// In en, this message translates to:
  /// **'Add signature for {account}'**
  String signatureSettingsAddForAccount(String account);

  /// Title of default sender setting screen
  ///
  /// In en, this message translates to:
  /// **'Default sender'**
  String get defaultSenderSettingsTitle;

  /// Description of default sender setting screen
  ///
  /// In en, this message translates to:
  /// **'Select the sender for new messages.'**
  String get defaultSenderSettingsLabel;

  /// The default sender is the one from the first account
  ///
  /// In en, this message translates to:
  /// **'First account ({email})'**
  String defaultSenderSettingsFirstAccount(String email);

  /// Info about that email aliases can be set up in the account settings. [AS] is the place, where defaultSenderSettingsAliasAccountSettings is included as a link.
  ///
  /// In en, this message translates to:
  /// **'You can set up email alias addresses in the [AS].'**
  String get defaultSenderSettingsAliasInfo;

  /// Text of the account settings link.
  ///
  /// In en, this message translates to:
  /// **'account settings'**
  String get defaultSenderSettingsAliasAccountSettings;

  /// Reply settings title.
  ///
  /// In en, this message translates to:
  /// **'Message format'**
  String get replySettingsTitle;

  /// Reply settings introduction text.
  ///
  /// In en, this message translates to:
  /// **'In what format do you want to answer or forward email by default?'**
  String get replySettingsIntro;

  /// Reply settings option.
  ///
  /// In en, this message translates to:
  /// **'Always rich format (HTML)'**
  String get replySettingsFormatHtml;

  /// Reply settings option.
  ///
  /// In en, this message translates to:
  /// **'Use same format as originating email'**
  String get replySettingsFormatSameAsOriginal;

  /// Reply settings option.
  ///
  /// In en, this message translates to:
  /// **'Always text-only'**
  String get replySettingsFormatPlainText;

  /// Title of move to mailbox dialog.
  ///
  /// In en, this message translates to:
  /// **'Move message'**
  String get moveTitle;

  /// Message after moving message successfully.
  ///
  /// In en, this message translates to:
  /// **'Messaged moved to {mailbox}.'**
  String moveSuccess(String mailbox);

  /// Label of input field when inserting a formatted text
  ///
  /// In en, this message translates to:
  /// **'Your input'**
  String get editorArtInputLabel;

  /// Hint of input field when inserting a formatted text
  ///
  /// In en, this message translates to:
  /// **'Enter text here'**
  String get editorArtInputHint;

  /// Text shown while waiting for input
  ///
  /// In en, this message translates to:
  /// **'waiting for input...'**
  String get editorArtWaitingForInputHint;

  /// Font name
  ///
  /// In en, this message translates to:
  /// **'Serif bold'**
  String get fontSerifBold;

  /// Font name
  ///
  /// In en, this message translates to:
  /// **'Serif italic'**
  String get fontSerifItalic;

  /// Font name
  ///
  /// In en, this message translates to:
  /// **'Serif bold italic'**
  String get fontSerifBoldItalic;

  /// Font name
  ///
  /// In en, this message translates to:
  /// **'Sans'**
  String get fontSans;

  /// Font name
  ///
  /// In en, this message translates to:
  /// **'Sans bold'**
  String get fontSansBold;

  /// Font name
  ///
  /// In en, this message translates to:
  /// **'Sans italic'**
  String get fontSansItalic;

  /// Font name
  ///
  /// In en, this message translates to:
  /// **'Sans bold italic'**
  String get fontSansBoldItalic;

  /// Font name
  ///
  /// In en, this message translates to:
  /// **'Script'**
  String get fontScript;

  /// Font name
  ///
  /// In en, this message translates to:
  /// **'Script bold'**
  String get fontScriptBold;

  /// Font name
  ///
  /// In en, this message translates to:
  /// **'Fraktur'**
  String get fontFraktur;

  /// Font name
  ///
  /// In en, this message translates to:
  /// **'Fraktur bold'**
  String get fontFrakturBold;

  /// Font name
  ///
  /// In en, this message translates to:
  /// **'Monospace'**
  String get fontMonospace;

  /// Font name
  ///
  /// In en, this message translates to:
  /// **'Fullwidth'**
  String get fontFullwidth;

  /// Font name
  ///
  /// In en, this message translates to:
  /// **'Double struck'**
  String get fontDoublestruck;

  /// Font name
  ///
  /// In en, this message translates to:
  /// **'Capitalized'**
  String get fontCapitalized;

  /// Font name
  ///
  /// In en, this message translates to:
  /// **'Circled'**
  String get fontCircled;

  /// Font name
  ///
  /// In en, this message translates to:
  /// **'Parenthesized'**
  String get fontParenthesized;

  /// Font name
  ///
  /// In en, this message translates to:
  /// **'Underlined'**
  String get fontUnderlinedSingle;

  /// Font name
  ///
  /// In en, this message translates to:
  /// **'Underlined double'**
  String get fontUnderlinedDouble;

  /// Font name
  ///
  /// In en, this message translates to:
  /// **'Strike through'**
  String get fontStrikethroughSingle;

  /// Font name
  ///
  /// In en, this message translates to:
  /// **'Crosshatch'**
  String get fontCrosshatch;

  /// Message shown when single account could not be loaded.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to your account {name}. Has the password been changed?'**
  String accountLoadError(String name);

  /// Action to edit account
  ///
  /// In en, this message translates to:
  /// **'Edit account'**
  String get accountLoadErrorEditAction;

  /// Title of extension section within the development settings
  ///
  /// In en, this message translates to:
  /// **'Extensions'**
  String get extensionsTitle;

  /// Explanation of extensions
  ///
  /// In en, this message translates to:
  /// **'With extensions e-mail service providers, companies and developers can adapt Maily with useful functionalities.'**
  String get extensionsIntro;

  /// Label for launching a website with more information
  ///
  /// In en, this message translates to:
  /// **'Learn more about extensions'**
  String get extensionsLearnMoreAction;

  /// Action to refresh extensions
  ///
  /// In en, this message translates to:
  /// **'Reload extensions'**
  String get extensionsReloadAction;

  /// Action to deactivate / unload any extension
  ///
  /// In en, this message translates to:
  /// **'Deactivate all extensions'**
  String get extensionDeactivateAllAction;

  /// Action to load extension manually
  ///
  /// In en, this message translates to:
  /// **'Load manually'**
  String get extensionsManualAction;

  /// Label for URL input field
  ///
  /// In en, this message translates to:
  /// **'Url of extension'**
  String get extensionsManualUrlLabel;

  /// Message shown when extensions could not be loaded.
  ///
  /// In en, this message translates to:
  /// **'Unable to download extension from \"{url}\".'**
  String extensionsManualLoadingError(String url);

  /// Action to accept an icalendar invitation tentatively
  ///
  /// In en, this message translates to:
  /// **'Tentatively'**
  String get icalendarAcceptTentatively;

  /// Action to change an icalendar invitation participant status
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get icalendarActionChangeParticipantStatus;

  /// Label of the summary info of an icalendar object
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get icalendarLabelSummary;

  /// Info shown when the icalendar object has no summary (no title)
  ///
  /// In en, this message translates to:
  /// **'(no title)'**
  String get icalendarNoSummaryInfo;

  /// Label of the description info of an icalendar object
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get icalendarLabelDescription;

  /// Label of the start datetime info of an icalendar object
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get icalendarLabelStart;

  /// Label of the end datetime info of an icalendar object
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get icalendarLabelEnd;

  /// Label of the duration info of an icalendar object
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get icalendarLabelDuration;

  /// Label of the location info of an icalendar object
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get icalendarLabelLocation;

  /// Label of the ms teams url info of an icalendar object
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get icalendarLabelTeamsUrl;

  /// Label of the recurrence info of an icalendar object
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get icalendarLabelRecurrenceRule;

  /// Label of the participants info of an icalendar object
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get icalendarLabelParticipants;

  /// Participant status of the current user for a icalendar object
  ///
  /// In en, this message translates to:
  /// **'You are asked to answer this invitation.'**
  String get icalendarParticipantStatusNeedsAction;

  /// Participant status of the current user for a icalendar object
  ///
  /// In en, this message translates to:
  /// **'You have accepted this invitation.'**
  String get icalendarParticipantStatusAccepted;

  /// Participant status of the current user for a icalendar object
  ///
  /// In en, this message translates to:
  /// **'You have declined this invitation.'**
  String get icalendarParticipantStatusDeclined;

  /// Participant status of the current user for a icalendar object
  ///
  /// In en, this message translates to:
  /// **'You have tentatively accepted this invitation.'**
  String get icalendarParticipantStatusAcceptedTentatively;

  /// Participant status of the current user for a icalendar object
  ///
  /// In en, this message translates to:
  /// **'You have delegated this invitation.'**
  String get icalendarParticipantStatusDelegated;

  /// Participant status of the current user for a icalendar object
  ///
  /// In en, this message translates to:
  /// **'The task is in progress.'**
  String get icalendarParticipantStatusInProcess;

  /// Participant status of the current user for a icalendar object
  ///
  /// In en, this message translates to:
  /// **'The task is partially done.'**
  String get icalendarParticipantStatusPartial;

  /// Participant status of the current user for a icalendar object
  ///
  /// In en, this message translates to:
  /// **'The task is done.'**
  String get icalendarParticipantStatusCompleted;

  /// Participant status of the current user for a icalendar object
  ///
  /// In en, this message translates to:
  /// **'Your status is unknown.'**
  String get icalendarParticipantStatusOther;

  /// Title for dialog to change participant status
  ///
  /// In en, this message translates to:
  /// **'Your Status'**
  String get icalendarParticipantStatusChangeTitle;

  /// Text of dialog to change participant status
  ///
  /// In en, this message translates to:
  /// **'Do you want to accept this invitation?'**
  String get icalendarParticipantStatusChangeText;

  /// Failure message for a status change reply
  ///
  /// In en, this message translates to:
  /// **'Unable to send reply.\nThe server responded with the following details:\n{details}'**
  String icalendarParticipantStatusSentFailure(String details);

  /// Action to export the invite to the native calendar
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get icalendarExportAction;

  /// Valid Calendar reply
  ///
  /// In en, this message translates to:
  /// **'{attendee} has not answered this invitation.'**
  String icalendarReplyStatusNeedsAction(String attendee);

  /// Valid Calendar reply
  ///
  /// In en, this message translates to:
  /// **'{attendee} has accepted the appointment.'**
  String icalendarReplyStatusAccepted(String attendee);

  /// Valid Calendar reply
  ///
  /// In en, this message translates to:
  /// **'{attendee} has declined this invitation.'**
  String icalendarReplyStatusDeclined(String attendee);

  /// Valid Calendar reply
  ///
  /// In en, this message translates to:
  /// **'{attendee} has tentatively accepted this invitation.'**
  String icalendarReplyStatusAcceptedTentatively(String attendee);

  /// Valid Calendar reply
  ///
  /// In en, this message translates to:
  /// **'{attendee} has delegated this invitation.'**
  String icalendarReplyStatusDelegated(String attendee);

  /// Valid Calendar reply
  ///
  /// In en, this message translates to:
  /// **'{attendee} has started this task.'**
  String icalendarReplyStatusInProcess(String attendee);

  /// Valid Calendar reply
  ///
  /// In en, this message translates to:
  /// **'{attendee} has partially done this task.'**
  String icalendarReplyStatusPartial(String attendee);

  /// Valid Calendar reply
  ///
  /// In en, this message translates to:
  /// **'{attendee} has finished this task.'**
  String icalendarReplyStatusCompleted(String attendee);

  /// Valid Calendar reply
  ///
  /// In en, this message translates to:
  /// **'{attendee} has answered with an unknown status.'**
  String icalendarReplyStatusOther(String attendee);

  /// Calendar reply without any participant
  ///
  /// In en, this message translates to:
  /// **'This calendar reply contains no participants.'**
  String get icalendarReplyWithoutParticipants;

  /// Calendar reply without any participant status
  ///
  /// In en, this message translates to:
  /// **'{attendee} replied without an participation status.'**
  String icalendarReplyWithoutStatus(String attendee);

  /// Title for adding a new appointment screen
  ///
  /// In en, this message translates to:
  /// **'Create Appointment'**
  String get composeAppointmentTitle;

  /// Label for select day button
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get composeAppointmentLabelDay;

  /// Label for select time button
  ///
  /// In en, this message translates to:
  /// **'time'**
  String get composeAppointmentLabelTime;

  /// Label for is all day toggle
  ///
  /// In en, this message translates to:
  /// **'All day'**
  String get composeAppointmentLabelAllDayEvent;

  /// Label for repeat drop-down
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get composeAppointmentLabelRepeat;

  /// Option for repeat drop-down
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get composeAppointmentLabelRepeatOptionNever;

  /// Option for repeat drop-down
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get composeAppointmentLabelRepeatOptionDaily;

  /// Option for repeat drop-down
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get composeAppointmentLabelRepeatOptionWeekly;

  /// Option for repeat drop-down
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get composeAppointmentLabelRepeatOptionMonthly;

  /// Option for repeat drop-down
  ///
  /// In en, this message translates to:
  /// **'Annually'**
  String get composeAppointmentLabelRepeatOptionYearly;

  /// Label for frequency drop-down
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get composeAppointmentRecurrenceFrequencyLabel;

  /// Label for interval drop-down
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get composeAppointmentRecurrenceIntervalLabel;

  /// Label for days selection area in a weekly or monthly recurrence
  ///
  /// In en, this message translates to:
  /// **'On days'**
  String get composeAppointmentRecurrenceDaysLabel;

  /// Label for choosing end date of recurrence
  ///
  /// In en, this message translates to:
  /// **'Until'**
  String get composeAppointmentRecurrenceUntilLabel;

  /// Option for no end date of recurrence
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get composeAppointmentRecurrenceUntilOptionUnlimited;

  /// Option for standard end date of recurrence with the given duration
  ///
  /// In en, this message translates to:
  /// **'Recommended ({duration})'**
  String composeAppointmentRecurrenceUntilOptionRecommended(String duration);

  /// Option for specific end date of recurrence
  ///
  /// In en, this message translates to:
  /// **'Until chosen date'**
  String get composeAppointmentRecurrenceUntilOptionSpecificDate;

  /// Option for repeating an event always on that day of the month
  ///
  /// In en, this message translates to:
  /// **'On the {day}. day of the month'**
  String composeAppointmentRecurrenceMonthlyOnDayOfMonth(int day);

  /// Monthly repeat on weekday of a chosen week
  ///
  /// In en, this message translates to:
  /// **'Weekday in month'**
  String get composeAppointmentRecurrenceMonthlyOnWeekDay;

  /// Monthly day option
  ///
  /// In en, this message translates to:
  /// **'First'**
  String get composeAppointmentRecurrenceFirst;

  /// Monthly day option
  ///
  /// In en, this message translates to:
  /// **'Second'**
  String get composeAppointmentRecurrenceSecond;

  /// Monthly day option
  ///
  /// In en, this message translates to:
  /// **'Third'**
  String get composeAppointmentRecurrenceThird;

  /// Monthly day option
  ///
  /// In en, this message translates to:
  /// **'Last'**
  String get composeAppointmentRecurrenceLast;

  /// Monthly day option
  ///
  /// In en, this message translates to:
  /// **'Second-last'**
  String get composeAppointmentRecurrenceSecondLast;

  /// Duration. Message formatted using the plural JSON scheme.
  ///
  /// In en, this message translates to:
  /// **'{number,plural, =1{1 year} other{{number} years}}'**
  String durationYears(int number);

  /// Duration. Message formatted using the plural JSON scheme.
  ///
  /// In en, this message translates to:
  /// **'{number,plural, =1{1 month} other{{number} months}}'**
  String durationMonths(int number);

  /// Duration. Message formatted using the plural JSON scheme.
  ///
  /// In en, this message translates to:
  /// **'{number,plural, =1{1 week} other{{number} weeks}}'**
  String durationWeeks(int number);

  /// Duration. Message formatted using the plural JSON scheme.
  ///
  /// In en, this message translates to:
  /// **'{number,plural, =1{1 day} other{{number} days}}'**
  String durationDays(int number);

  /// Duration. Message formatted using the plural JSON scheme.
  ///
  /// In en, this message translates to:
  /// **'{number,plural, =1{1 hour} other{{number} hours}}'**
  String durationHours(int number);

  /// Duration. Message formatted using the plural JSON scheme.
  ///
  /// In en, this message translates to:
  /// **'{number,plural, =1{1 minute} other{{number} minutes}}'**
  String durationMinutes(int number);

  /// Text shown when the duration is 0
  ///
  /// In en, this message translates to:
  /// **'No duration'**
  String get durationEmpty;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
