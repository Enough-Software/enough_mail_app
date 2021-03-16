import 'package:enough_mail_app/models/theme_settings.dart';
import 'package:enough_serialization/enough_serialization.dart';

class Settings extends SerializableObject {
  Settings() {
    objectCreators['themeSettings'] = (map) => ThemeSettings();
  }

  bool get blockExternalImages => attributes['blockExternalImages'] ?? false;
  set blockExternalImages(bool value) =>
      attributes['blockExternalImages'] = value;

  String get preferredComposeMailAddress =>
      attributes['preferredComposeMailAddress'];
  set preferredComposeMailAddress(String value) =>
      attributes['preferredComposeMailAddress'] = value;

  ThemeSettings get themeSettings {
    var themeSettings = attributes['themeSettings'];
    if (themeSettings == null) {
      themeSettings = ThemeSettings();
      attributes['themeSettings'] = themeSettings;
    }
    return themeSettings;
  }

  set themeSettings(ThemeSettings value) => attributes['themeSettings'] = value;
}
