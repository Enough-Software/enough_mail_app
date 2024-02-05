import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../account/model.dart';
import '../localization/extension.dart';
import '../logger.dart';
import '../models/compose_data.dart';
import 'model.dart';
import 'storage.dart';

/// Provides the settings
final settingsProvider =
    NotifierProvider<SettingsNotifier, Settings>(SettingsNotifier.new);

/// Provides the settings
class SettingsNotifier extends Notifier<Settings> {
  /// Creates a [SettingsNotifier]
  SettingsNotifier({
    Settings settings = const Settings(),
    SettingsStorage storage = const SettingsStorage(),
  })  : _initialSettings = settings,
        _storage = storage;

  final Settings _initialSettings;
  final SettingsStorage _storage;

  @override
  Settings build() => _initialSettings;

  /// Initializes the settings notifier
  Future<void> init() async {
    try {
      final settings = await _storage.load();
      state = settings;
    } catch (e) {
      logger.e('Unable to load settings: $e');
    }
  }

  /// Updates and saves the given [value] settings
  Future<void> update(Settings value) async {
    state = value;
    try {
      await _storage.save(value);
    } catch (e) {
      logger.e('Unable to save settings: $e');
    }
  }

  /// Retrieves the HTML signature for the specified [account]
  /// and [composeAction]
  String getSignatureHtml(
    RealAccount account,
    ComposeAction composeAction,
    String? languageCode,
  ) {
    if (!state.signatureActions.contains(composeAction)) {
      return '';
    }

    return account.getSignatureHtml(languageCode) ?? getSignatureHtmlGlobal();
  }

  /// Retrieves the global signature
  String getSignatureHtmlGlobal() =>
      state.signatureHtml ?? '<p>---<br/>${ref.text.signature}</p>';

  /// Retrieves the plain text signature for the specified account
  String getSignaturePlain(
    RealAccount account,
    ComposeAction composeAction,
  ) {
    if (!state.signatureActions.contains(composeAction)) {
      return '';
    }

    return account.signaturePlain ?? getSignaturePlainGlobal();
  }

  /// Retrieves the global plain text signature
  String getSignaturePlainGlobal() =>
      state.signaturePlain ?? '\n---\n${ref.text.signature}';
}
