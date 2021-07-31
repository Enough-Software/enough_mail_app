import 'package:enough_mail_app/models/account.dart';
import 'package:enough_mail_app/models/compose_data.dart';
import 'package:enough_mail_app/models/settings.dart';
import 'package:enough_serialization/enough_serialization.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../locator.dart';
import 'i18n_service.dart';

class SettingsService {
  static const String _keySettings = 'settings';
  final Serializer _serializer = Serializer();
  FlutterSecureStorage? _storage;

  late Settings _settings;
  Settings get settings => _settings;

  Future<Settings> init() async {
    _storage ??= FlutterSecureStorage();
    final json = await _storage!.read(key: _keySettings);
    _settings = Settings();
    if (json != null) {
      _serializer.deserialize(json, _settings);
    }
    return _settings;
  }

  Future<void> save() async {
    final json = _serializer.serialize(_settings);
    _storage ??= FlutterSecureStorage();
    await _storage!.write(key: _keySettings, value: json);
  }

  /// Retrieves the HTML signature for the specified [account] and [composeAction]
  String getSignatureHtml(Account? account, ComposeAction composeAction) {
    if (!settings.signatureActions.contains(composeAction)) {
      return '';
    }
    return account!.signatureHtml ?? getSignatureHtmlGlobal();
  }

  /// Retrieves the global signature
  String getSignatureHtmlGlobal() {
    return settings.signatureHtml ?? '<p>---<br/>$_fallbackSignature</p>';
  }

  /// Retrieves the plain text signature for the specified account
  String getSignaturePlain(Account account, ComposeAction composeAction) {
    if (!settings.signatureActions.contains(composeAction)) {
      return '';
    }
    return account.signaturePlain ?? getSignaturePlainGlobal();
  }

  /// Retrieves the global plain text signature
  String getSignaturePlainGlobal() {
    return settings.signaturePlain ?? '\n---\n$_fallbackSignature';
  }

  String get _fallbackSignature =>
      locator<I18nService>().localizations.signature;
}
