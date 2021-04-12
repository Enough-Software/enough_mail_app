import 'package:enough_mail_app/models/swipe.dart';
import 'package:enough_mail_app/models/theme_settings.dart';
import 'package:enough_serialization/enough_serialization.dart';

class Settings extends SerializableObject {
  Settings() {
    objectCreators['themeSettings'] = (map) => ThemeSettings();
    transformers['swipeLeftToRightAction'] = (value) =>
        value is SwipeAction ? value.index : SwipeAction.values[value];
    transformers['swipeRightToLeftAction'] = (value) =>
        value is SwipeAction ? value.index : SwipeAction.values[value];
  }

  bool get blockExternalImages => attributes['blockExternalImages'] ?? false;
  set blockExternalImages(bool value) =>
      attributes['blockExternalImages'] = value;

  String get preferredComposeMailAddress =>
      attributes['preferredComposeMailAddress'];
  set preferredComposeMailAddress(String value) =>
      attributes['preferredComposeMailAddress'] = value;

  String get languageTag => attributes['languageTag'];
  set languageTag(String value) => attributes['languageTag'] = value;

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

  bool get useInternationalizedStandardFoldersNames =>
      attributes['useI18nFolders'] ?? true;
  set useInternationalizedStandardFoldersNames(bool value) =>
      attributes['useI18nFolders'] = value;

  String get customStandardFolderNames => attributes['customFolderNames'];
  set customStandardFolderNames(String value) =>
      attributes['customFolderNames'] = value;
}
