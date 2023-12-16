import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../logger.dart';
import 'model.dart';

/// Allows to read and store settings
class SettingsStorage {
  /// Creates a [SettingsStorage]
  const SettingsStorage({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  static const String _keySettings = 'settings';

  final FlutterSecureStorage _storage;

  /// Loads the settings
  Future<Settings> load() async {
    final json = await _storage.read(key: _keySettings);
    if (json != null) {
      try {
        return Settings.fromJson(jsonDecode(json));
      } catch (e) {
        logger.d('error loading settings: $e');
      }
    }

    return const Settings();
  }

  /// Saves the given settings
  Future<void> save(Settings value) => _storage.write(
        key: _keySettings,
        value: jsonEncode(value.toJson()),
      );
}
