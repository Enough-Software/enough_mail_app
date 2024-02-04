import 'package:enough_mail/enough_mail.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/compose_data.dart';
import '../models/swipe.dart';
import 'theme/model.dart';

part 'model.g.dart';

/// The shown name for folders
enum FolderNameSetting {
  /// Show the name as defined by the server
  server,

  /// Show localized names
  localized,

  /// Show the names as defined by the user
  custom,
}

/// The display setting for read receipts
enum ReadReceiptDisplaySetting {
  /// Always show read receipt requests
  always,

  /// Never show read receipt requests
  never,

  // forContacts,
}

/// The format preference for replies
enum ReplyFormatPreference {
  /// Always reply in HTML format
  alwaysHtml,

  /// Reply in the same format as the original message
  sameFormat,

  /// Always reply in plain text format
  alwaysPlainText,
}

/// The app lock time preference
enum LockTimePreference {
  /// Lock the app immediately when bringing it to the background
  immediately,

  /// Lock the app after 5 minutes
  after5minutes,

  /// Lock the app after 30 minutes
  after30minutes,
}

/// Provides more information about [LockTimePreference]
extension ExtensionLockTimePreference on LockTimePreference {
  /// Returns true if the app requires authorization
  bool requiresAuthorization(DateTime? lastPausedTimeStamp) =>
      lastPausedTimeStamp == null ||
      lastPausedTimeStamp.isBefore(DateTime.now().subtract(duration));

  /// Returns the duration for this lock time preference
  Duration get duration {
    switch (this) {
      case LockTimePreference.immediately:
        return Duration.zero;
      case LockTimePreference.after5minutes:
        return const Duration(minutes: 5);
      case LockTimePreference.after30minutes:
        return const Duration(minutes: 30);
    }
  }
}

/// Contains the settings of the app
@JsonSerializable()
class Settings {
  /// Creates new settings
  const Settings({
    this.blockExternalImages = false,
    this.preferredComposeMailAddress,
    this.languageTag,
    this.themeSettings = const ThemeSettings(),
    this.swipeLeftToRightAction = SwipeAction.markRead,
    this.swipeRightToLeftAction = SwipeAction.delete,
    this.folderNameSetting = FolderNameSetting.localized,
    this.customFolderNames,
    this.enableDeveloperMode = false,
    this.signatureHtml,
    this.signaturePlain,
    this.signatureActions = const [ComposeAction.newMessage],
    this.readReceiptDisplaySetting = ReadReceiptDisplaySetting.always,
    this.defaultSender,
    this.preferPlainTextMessages = false,
    this.urlLaunchMode = LaunchMode.externalApplication,
    this.replyFormatPreference = ReplyFormatPreference.alwaysHtml,
    this.enableBiometricLock = false,
    this.lockTimePreference = LockTimePreference.immediately,
  });

  /// Creates settings from the given [json]
  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);

  /// Converts these settings to JSON
  Map<String, dynamic> toJson() => _$SettingsToJson(this);

  /// Should external images being blocked?
  final bool blockExternalImages;

  /// The preferred email address for sending new messages
  final String? preferredComposeMailAddress;

  /// The language of the app
  final String? languageTag;

  /// The theme settings
  final ThemeSettings themeSettings;

  /// The action for swiping from left to right
  final SwipeAction swipeLeftToRightAction;

  /// The action for swiping from right to left
  final SwipeAction swipeRightToLeftAction;

  /// The folder name setting
  final FolderNameSetting folderNameSetting;

  /// The custom folder names
  final List<String>? customFolderNames;

  /// Should the developer mode of the app be active?
  final bool enableDeveloperMode;

  /// The default, global HTML signature
  final String? signatureHtml;

  /// The default, global plain text signature
  final String? signaturePlain;

  /// The  signature actions
  final List<ComposeAction> signatureActions;

  /// Should read receipt requests been shown?
  final ReadReceiptDisplaySetting readReceiptDisplaySetting;

  /// The default sender
  final MailAddress? defaultSender;

  /// Should messages been shown in plain text when possible?
  final bool preferPlainTextMessages;

  /// The launch mode for links - either "in app" or "external"
  final LaunchMode urlLaunchMode;

  /// The default reply format
  final ReplyFormatPreference replyFormatPreference;

  /// Should the app be locked with biometric authentication?
  final bool enableBiometricLock;

  /// The lock time preference

  @JsonKey(name: 'enableBiometricLockTime')
  final LockTimePreference lockTimePreference;

  /// Copies this settings with the given values
  Settings copyWith({
    bool? blockExternalImages,
    String? preferredComposeMailAddress,
    String? languageTag,
    ThemeSettings? themeSettings,
    SwipeAction? swipeLeftToRightAction,
    SwipeAction? swipeRightToLeftAction,
    FolderNameSetting? folderNameSetting,
    List<String>? customFolderNames,
    bool? enableDeveloperMode,
    String? signatureHtml,
    String? signaturePlain,
    List<ComposeAction>? signatureActions,
    ReadReceiptDisplaySetting? readReceiptDisplaySetting,
    MailAddress? defaultSender,
    bool? preferPlainTextMessages,
    LaunchMode? urlLaunchMode,
    ReplyFormatPreference? replyFormatPreference,
    bool? enableBiometricLock,
    LockTimePreference? lockTimePreference,
  }) =>
      Settings(
        blockExternalImages: blockExternalImages ?? this.blockExternalImages,
        preferredComposeMailAddress:
            preferredComposeMailAddress ?? this.preferredComposeMailAddress,
        languageTag: languageTag ?? this.languageTag,
        themeSettings: themeSettings ?? this.themeSettings,
        swipeLeftToRightAction:
            swipeLeftToRightAction ?? this.swipeLeftToRightAction,
        swipeRightToLeftAction:
            swipeRightToLeftAction ?? this.swipeRightToLeftAction,
        folderNameSetting: folderNameSetting ?? this.folderNameSetting,
        customFolderNames: customFolderNames ?? this.customFolderNames,
        enableDeveloperMode: enableDeveloperMode ?? this.enableDeveloperMode,
        signatureHtml: signatureHtml ?? this.signatureHtml,
        signaturePlain: signaturePlain ?? this.signaturePlain,
        signatureActions: signatureActions ?? this.signatureActions,
        readReceiptDisplaySetting:
            readReceiptDisplaySetting ?? this.readReceiptDisplaySetting,
        defaultSender: defaultSender ?? this.defaultSender,
        preferPlainTextMessages:
            preferPlainTextMessages ?? this.preferPlainTextMessages,
        urlLaunchMode: urlLaunchMode ?? this.urlLaunchMode,
        replyFormatPreference:
            replyFormatPreference ?? this.replyFormatPreference,
        enableBiometricLock: enableBiometricLock ?? this.enableBiometricLock,
        lockTimePreference: lockTimePreference ?? this.lockTimePreference,
      );

  /// Copies the settings without the signatures
  Settings withoutSignatures() => Settings(
        blockExternalImages: blockExternalImages,
        customFolderNames: customFolderNames,
        defaultSender: defaultSender,
        enableBiometricLock: enableBiometricLock,
        enableDeveloperMode: enableDeveloperMode,
        folderNameSetting: folderNameSetting,
        languageTag: languageTag,
        lockTimePreference: lockTimePreference,
        preferPlainTextMessages: preferPlainTextMessages,
        preferredComposeMailAddress: preferredComposeMailAddress,
        readReceiptDisplaySetting: readReceiptDisplaySetting,
        replyFormatPreference: replyFormatPreference,
        signatureActions: signatureActions,
        swipeLeftToRightAction: swipeLeftToRightAction,
        swipeRightToLeftAction: swipeRightToLeftAction,
        themeSettings: themeSettings,
        urlLaunchMode: urlLaunchMode,
      );

  Settings removeLanguageTag() => Settings(
        blockExternalImages: blockExternalImages,
        customFolderNames: customFolderNames,
        defaultSender: defaultSender,
        enableBiometricLock: enableBiometricLock,
        enableDeveloperMode: enableDeveloperMode,
        folderNameSetting: folderNameSetting,
        lockTimePreference: lockTimePreference,
        preferPlainTextMessages: preferPlainTextMessages,
        preferredComposeMailAddress: preferredComposeMailAddress,
        readReceiptDisplaySetting: readReceiptDisplaySetting,
        replyFormatPreference: replyFormatPreference,
        signatureActions: signatureActions,
        signatureHtml: signatureHtml,
        signaturePlain: signaturePlain,
        swipeLeftToRightAction: swipeLeftToRightAction,
        swipeRightToLeftAction: swipeRightToLeftAction,
        themeSettings: themeSettings,
        urlLaunchMode: urlLaunchMode,
      );
}
