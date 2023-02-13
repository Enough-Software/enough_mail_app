import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/compose_data.dart';
import 'package:enough_mail_app/models/swipe.dart';
import 'package:enough_mail_app/models/theme_settings.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'settings.g.dart';

enum FolderNameSetting { server, localized, custom }

enum ReadReceiptDisplaySetting {
  always,
  never, // forContacts
}

enum ReplyFormatPreference { alwaysHtml, sameFormat, alwaysPlainText }

enum LockTimePreference { immediately, after5minutes, after30minutes }

extension ExtensionLockTimePreference on LockTimePreference {
  bool requiresAuthorization(DateTime? lastPausedTimeStamp) =>
      lastPausedTimeStamp == null ||
      lastPausedTimeStamp.isBefore(DateTime.now().subtract(duration));

  Duration get duration {
    switch (this) {
      case LockTimePreference.immediately:
        return const Duration();
      case LockTimePreference.after5minutes:
        return const Duration(minutes: 5);
      case LockTimePreference.after30minutes:
        return const Duration(minutes: 30);
    }
  }
}

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

  final bool blockExternalImages;

  final String? preferredComposeMailAddress;

  final String? languageTag;

  final ThemeSettings themeSettings;

  final SwipeAction swipeLeftToRightAction;

  final SwipeAction swipeRightToLeftAction;

  final FolderNameSetting folderNameSetting;

  final List<String>? customFolderNames;

  final bool enableDeveloperMode;

  final String? signatureHtml;

  final String? signaturePlain;

  final List<ComposeAction> signatureActions;

  final ReadReceiptDisplaySetting readReceiptDisplaySetting;

  final MailAddress? defaultSender;

  final bool preferPlainTextMessages;

  /// The launch mode for links - either "in app" or "external"
  final LaunchMode urlLaunchMode;

  final ReplyFormatPreference replyFormatPreference;

  final bool enableBiometricLock;

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
        signaturePlain: null,
        signatureHtml: null,
      );

  Settings removeLanguageTag() => Settings(
        blockExternalImages: blockExternalImages,
        customFolderNames: customFolderNames,
        defaultSender: defaultSender,
        enableBiometricLock: enableBiometricLock,
        enableDeveloperMode: enableDeveloperMode,
        folderNameSetting: folderNameSetting,
        languageTag: null,
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
