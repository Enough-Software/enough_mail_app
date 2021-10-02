import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/compose_data.dart';
import 'package:enough_mail_app/models/swipe.dart';
import 'package:enough_mail_app/models/theme_settings.dart';
import 'package:enough_serialization/enough_serialization.dart';

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

class Settings extends SerializableObject {
  static const _keyThemeSettings = 'themeSettings';
  static const _keyCustomFolderNames = 'customFolderNames';
  static const _keyDefaultSender = 'defaultSender';
  static const _keySwipeLeftToRightAction = 'swipeLeftToRightAction';
  static const _keySwipeRightToLeftAction = 'swipeRightToLeftAction';
  static const _keyFolderNameSetting = 'folderNameSetting';
  static const _keyReadReceiptDisplaySetting = 'readReceiptDisplaySetting';
  static const _keySignatureActions = 'signatureActions';
  static const _keyReplyFormatPreference = 'replyFormatPreference';
  static const _keyEnableBiometricLock = 'enableBiometricLock';
  static const _keyLockTimePreference = 'enableBiometricLockTime';

  Settings() {
    objectCreators[_keyThemeSettings] = (map) => ThemeSettings();
    objectCreators[_keyCustomFolderNames] = (map) => <String>[];
    objectCreators[_keyDefaultSender] = (map) => MailAddress.empty();
    transformers[_keySwipeLeftToRightAction] = (value) =>
        value is SwipeAction ? value.index : SwipeAction.values[value];
    transformers[_keySwipeRightToLeftAction] = (value) =>
        value is SwipeAction ? value.index : SwipeAction.values[value];
    transformers[_keyFolderNameSetting] = (value) => value is FolderNameSetting
        ? value.index
        : FolderNameSetting.values[value];
    transformers[_keyReadReceiptDisplaySetting] = (value) =>
        value is ReadReceiptDisplaySetting
            ? value.index
            : ReadReceiptDisplaySetting.values[value];
    transformers[_keySignatureActions] = (value) =>
        value is ComposeAction ? value.index : ComposeAction.values[value];
    transformers[_keyReplyFormatPreference] = (value) =>
        value is ReplyFormatPreference
            ? value.index
            : ReplyFormatPreference.values[value];
    transformers[_keyLockTimePreference] = (value) =>
        value is LockTimePreference
            ? value.index
            : LockTimePreference.values[value];
  }

  bool get blockExternalImages => attributes['blockExternalImages'] ?? false;
  set blockExternalImages(bool? value) =>
      attributes['blockExternalImages'] = value;

  String? get preferredComposeMailAddress =>
      attributes['preferredComposeMailAddress'];
  set preferredComposeMailAddress(String? value) =>
      attributes['preferredComposeMailAddress'] = value;

  String? get languageTag => attributes['languageTag'];
  set languageTag(String? value) => attributes['languageTag'] = value;

  ThemeSettings get themeSettings {
    var themeSettings = attributes[_keyThemeSettings];
    if (themeSettings == null) {
      themeSettings = ThemeSettings();
      attributes[_keyThemeSettings] = themeSettings;
    }
    return themeSettings;
  }

  set themeSettings(ThemeSettings value) =>
      attributes[_keyThemeSettings] = value;

  SwipeAction get swipeLeftToRightAction =>
      attributes[_keySwipeLeftToRightAction] ?? SwipeAction.markRead;
  set swipeLeftToRightAction(SwipeAction value) =>
      attributes[_keySwipeLeftToRightAction] = value;

  SwipeAction get swipeRightToLeftAction =>
      attributes[_keySwipeRightToLeftAction] ?? SwipeAction.delete;
  set swipeRightToLeftAction(SwipeAction value) =>
      attributes[_keySwipeRightToLeftAction] = value;

  FolderNameSetting get folderNameSetting =>
      attributes[_keyFolderNameSetting] ?? FolderNameSetting.localized;
  set folderNameSetting(FolderNameSetting? value) =>
      attributes[_keyFolderNameSetting] = value;

  List<String>? get customFolderNames => attributes[_keyCustomFolderNames];
  set customFolderNames(List<String>? value) =>
      attributes[_keyCustomFolderNames] = value;

  bool get enableDeveloperMode => attributes['enableDeveloperMode'] ?? false;
  set enableDeveloperMode(bool? value) =>
      attributes['enableDeveloperMode'] = value;

  String? get signatureHtml => attributes['signatureHtml'];
  set signatureHtml(String? value) => attributes['signatureHtml'] = value;

  String? get signaturePlain => attributes['signaturePlain'];
  set signaturePlain(String? value) => attributes['signaturePlain'] = value;

  List<ComposeAction> get signatureActions =>
      attributes[_keySignatureActions] ?? [ComposeAction.newMessage];
  set signatureActions(List<ComposeAction> value) =>
      attributes[_keySignatureActions] = value;

  ReadReceiptDisplaySetting get readReceiptDisplaySetting =>
      attributes[_keyReadReceiptDisplaySetting] ??
      ReadReceiptDisplaySetting.always;
  set readReceiptDisplaySetting(ReadReceiptDisplaySetting? value) =>
      attributes[_keyReadReceiptDisplaySetting] = value;

  MailAddress? get defaultSender => attributes[_keyDefaultSender];
  set defaultSender(MailAddress? value) =>
      attributes[_keyDefaultSender] = value;

  bool get preferPlainTextMessages =>
      attributes['preferPlainTextMessages'] ?? false;
  set preferPlainTextMessages(bool value) =>
      attributes['preferPlainTextMessages'] = value;

  ReplyFormatPreference get replyFormatPreference =>
      attributes[_keyReplyFormatPreference] ?? ReplyFormatPreference.alwaysHtml;
  set replyFormatPreference(ReplyFormatPreference value) =>
      attributes[_keyReplyFormatPreference] = value;

  bool get enableBiometricLock => attributes[_keyEnableBiometricLock] ?? false;
  set enableBiometricLock(bool value) =>
      attributes[_keyEnableBiometricLock] = value;

  LockTimePreference get lockTimePreference =>
      attributes[_keyLockTimePreference] ?? LockTimePreference.immediately;

  set lockTimePreference(LockTimePreference value) =>
      attributes[_keyLockTimePreference] = value;
}
