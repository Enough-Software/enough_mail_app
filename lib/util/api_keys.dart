/// contains rate limited beta keys,
/// production keys are stored locally only
import 'package:flutter/services.dart' show rootBundle;

class ApiKeys {
  ApiKeys._();

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  static Future init() async {
    _isInitialized = true;
    try {
      final text = await rootBundle.loadString('assets/keys.txt');
      if (text != null) {
        final lines = text.split('\n');
        for (final line in lines) {
          if (line.startsWith('giphy:')) {
            _giphy = line.substring('giphy:'.length).trim();
          }
        }
      }
    } catch (e) {
      print(
          'no assets/keys.txt found. Ensure to specify it in the pubspec.yaml and add the relevant keys there.');
    }
  }

  static String _giphy;
  static String get giphy => _giphy;
}
