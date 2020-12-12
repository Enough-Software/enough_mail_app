import 'package:enough_mail_app/models/settings.dart';
import 'package:enough_serialization/enough_serialization.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsService {
  static const String _keySettings = 'settings';
  final Serializer _serializer = Serializer();
  FlutterSecureStorage _storage;

  Settings _settings;
  Settings get settings => _settings;

  Future<void> init() async {
    _storage ??= FlutterSecureStorage();
    final json = await _storage.read(key: _keySettings);
    _settings = Settings();
    if (json != null) {
      _serializer.deserialize(json, _settings);
    }
  }

  Future<void> save() async {
    final json = _serializer.serialize(_settings);
    _storage ??= FlutterSecureStorage();
    await _storage.write(key: _keySettings, value: json);
  }
}
