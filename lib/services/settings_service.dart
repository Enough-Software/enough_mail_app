import 'dart:convert';

import 'package:enough_mail_app/models/account.dart';
import 'package:enough_mail_app/models/compose_data.dart';
import 'package:enough_mail_app/models/settings.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../locator.dart';
import 'i18n_service.dart';

class SettingsService {
  static const String _keySettings = 'settings';
  FlutterSecureStorage? _storage;

  late Settings settings;

  Future<Settings> init() async {
    _storage ??= const FlutterSecureStorage();
    final json = await _storage!.read(key: _keySettings);
    if (json != null) {
      settings = Settings.fromJson(jsonDecode(json));
    } else {
      settings = const Settings();
    }
    return settings;
  }

  Future<void> save() async {
    final json = settings.toJson();
    _storage ??= const FlutterSecureStorage();
    await _storage!.write(key: _keySettings, value: jsonEncode(json));
  }

  /// Retrieves the HTML signature for the specified [account] and [composeAction]
  String getSignatureHtml(RealAccount account, ComposeAction composeAction) {
    if (!settings.signatureActions.contains(composeAction)) {
      return '';
    }
    return account.signatureHtml ?? getSignatureHtmlGlobal();
  }

  /// Retrieves the global signature
  String getSignatureHtmlGlobal() {
    return settings.signatureHtml ?? '<p>---<br/>$_fallbackSignature</p>';
  }

  /// Retrieves the plain text signature for the specified account
  String getSignaturePlain(RealAccount account, ComposeAction composeAction) {
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
