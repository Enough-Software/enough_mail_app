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

class Settings extends SerializableObject {
  static const _themeSettings = 'themeSettings';
  static const _customFolderNames = 'customFolderNames';
  static const _defaultSender = 'defaultSender';
  static const _swipeLeftToRightAction = 'swipeLeftToRightAction';
  static const _swipeRightToLeftAction = 'swipeRightToLeftAction';
  static const _folderNameSetting = 'folderNameSetting';
  static const _readReceiptDisplaySetting = 'readReceiptDisplaySetting';
  static const _signatureActions = 'signatureActions';
  Settings() {
    objectCreators[_themeSettings] = (map) => ThemeSettings();
    objectCreators[_customFolderNames] = (map) => <String>[];
    objectCreators[_defaultSender] = (map) => MailAddress.empty();
    transformers[_swipeLeftToRightAction] = (value) =>
        value is SwipeAction ? value.index : SwipeAction.values[value];
    transformers[_swipeRightToLeftAction] = (value) =>
        value is SwipeAction ? value.index : SwipeAction.values[value];
    transformers[_folderNameSetting] = (value) => value is FolderNameSetting
        ? value.index
        : FolderNameSetting.values[value];
    transformers[_readReceiptDisplaySetting] = (value) =>
        value is ReadReceiptDisplaySetting
            ? value.index
            : ReadReceiptDisplaySetting.values[value];
    transformers[_signatureActions] = (value) =>
        value is ComposeAction ? value.index : ComposeAction.values[value];
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
    var themeSettings = attributes[_themeSettings];
    if (themeSettings == null) {
      themeSettings = ThemeSettings();
      attributes[_themeSettings] = themeSettings;
    }
    return themeSettings;
  }

  set themeSettings(ThemeSettings value) => attributes[_themeSettings] = value;

  SwipeAction get swipeLeftToRightAction =>
      attributes[_swipeLeftToRightAction] ?? SwipeAction.markRead;
  set swipeLeftToRightAction(SwipeAction value) =>
      attributes[_swipeLeftToRightAction] = value;

  SwipeAction get swipeRightToLeftAction =>
      attributes[_swipeRightToLeftAction] ?? SwipeAction.delete;
  set swipeRightToLeftAction(SwipeAction value) =>
      attributes[_swipeRightToLeftAction] = value;

  FolderNameSetting get folderNameSetting =>
      attributes[_folderNameSetting] ?? FolderNameSetting.localized;
  set folderNameSetting(FolderNameSetting? value) =>
      attributes[_folderNameSetting] = value;

  List<String>? get customFolderNames => attributes[_customFolderNames];
  set customFolderNames(List<String>? value) =>
      attributes[_customFolderNames] = value;

  bool get enableDeveloperMode => attributes['enableDeveloperMode'] ?? false;
  set enableDeveloperMode(bool? value) =>
      attributes['enableDeveloperMode'] = value;

  String? get signatureHtml => attributes['signatureHtml'];
  set signatureHtml(String? value) => attributes['signatureHtml'] = value;

  String? get signaturePlain => attributes['signaturePlain'];
  set signaturePlain(String? value) => attributes['signaturePlain'] = value;

  List<ComposeAction> get signatureActions =>
      attributes[_signatureActions] ?? [ComposeAction.newMessage];
  set signatureActions(List<ComposeAction> value) =>
      attributes[_signatureActions] = value;

  ReadReceiptDisplaySetting get readReceiptDisplaySetting =>
      attributes[_readReceiptDisplaySetting] ??
      ReadReceiptDisplaySetting.always;
  set readReceiptDisplaySetting(ReadReceiptDisplaySetting? value) =>
      attributes[_readReceiptDisplaySetting] = value;

  MailAddress? get defaultSender => attributes[_defaultSender];
  set defaultSender(MailAddress? value) => attributes[_defaultSender] = value;

  bool get preferPlainTextMessages =>
      attributes['preferPlainTextMessages'] ?? false;
  set preferPlainTextMessages(bool value) =>
      attributes['preferPlainTextMessages'] = value;
}
