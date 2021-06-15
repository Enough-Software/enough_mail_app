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
  Settings() {
    objectCreators['themeSettings'] = (map) => ThemeSettings();
    objectCreators['customFolderNames'] = (map) => <String>[];
    transformers['swipeLeftToRightAction'] = (value) =>
        value is SwipeAction ? value.index : SwipeAction.values[value];
    transformers['swipeRightToLeftAction'] = (value) =>
        value is SwipeAction ? value.index : SwipeAction.values[value];
    transformers['folderNameSetting'] = (value) => value is FolderNameSetting
        ? value.index
        : FolderNameSetting.values[value];
    transformers['readReceiptDisplaySetting'] = (value) =>
        value is ReadReceiptDisplaySetting
            ? value.index
            : ReadReceiptDisplaySetting.values[value];
    transformers['signatureActions'] = (value) =>
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
    var themeSettings = attributes['themeSettings'];
    if (themeSettings == null) {
      themeSettings = ThemeSettings();
      attributes['themeSettings'] = themeSettings;
    }
    return themeSettings;
  }

  set themeSettings(ThemeSettings value) => attributes['themeSettings'] = value;

  SwipeAction get swipeLeftToRightAction =>
      attributes['swipeLeftToRightAction'] ?? SwipeAction.markRead;
  set swipeLeftToRightAction(SwipeAction value) =>
      attributes['swipeLeftToRightAction'] = value;

  SwipeAction get swipeRightToLeftAction =>
      attributes['swipeRightToLeftAction'] ?? SwipeAction.delete;
  set swipeRightToLeftAction(SwipeAction value) =>
      attributes['swipeRightToLeftAction'] = value;

  FolderNameSetting get folderNameSetting =>
      attributes['folderNameSetting'] ?? FolderNameSetting.localized;
  set folderNameSetting(FolderNameSetting? value) =>
      attributes['folderNameSetting'] = value;

  List<String>? get customFolderNames => attributes['customFolderNames'];
  set customFolderNames(List<String>? value) =>
      attributes['customFolderNames'] = value;

  bool get enableDeveloperMode => attributes['enableDeveloperMode'] ?? false;
  set enableDeveloperMode(bool? value) =>
      attributes['enableDeveloperMode'] = value;

  String? get signatureHtml => attributes['signatureHtml'];
  set signatureHtml(String? value) => attributes['signatureHtml'] = value;

  String? get signaturePlain => attributes['signaturePlain'];
  set signaturePlain(String? value) => attributes['signaturePlain'] = value;

  List<ComposeAction> get signatureActions =>
      attributes['signatureActions'] ?? [ComposeAction.newMessage];
  set signatureActions(List<ComposeAction> value) =>
      attributes['signatureActions'] = value;

  ReadReceiptDisplaySetting get readReceiptDisplaySetting =>
      attributes['readReceiptDisplaySetting'] ??
      ReadReceiptDisplaySetting.always;
  set readReceiptDisplaySetting(ReadReceiptDisplaySetting? value) =>
      attributes['readReceiptDisplaySetting'] = value;
}
