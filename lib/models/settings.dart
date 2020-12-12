import 'package:enough_serialization/enough_serialization.dart';

class Settings extends SerializableObject {
  bool get blockExternalImages => attributes['blockExternalImages'] ?? false;
  set blockExternalImages(bool value) =>
      attributes['blockExternalImages'] = value;

  String get preferredComposeMailAddress =>
      attributes['preferredComposeMailAddress'];
  set preferredComposeMailAddress(String value) =>
      attributes['preferredComposeMailAddress'] = value;
}
