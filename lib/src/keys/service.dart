// ignore_for_file: do_not_use_environment

import '../oauth/oauth.dart';

/// Allows to load the keys from assets/keys.txt
class KeyService {
  /// Creates a new [KeyService]
  KeyService._();

  static final _instance = KeyService._();

  /// Retrieves access to the [KeyService] singleton
  static KeyService get instance => _instance;

  /// Loads the key data
  Future<void> init() async {
    void addOauth(String key, String value) {
      if (value.isEmpty) {
        return;
      }
      final valueIndex = value.indexOf(':');
      if (valueIndex == -1) {
        oauth[key] = OauthClientId(value, null);
      } else {
        oauth[key] = OauthClientId(
          value.substring(0, valueIndex),
          value.substring(valueIndex + 1),
        );
      }
    }

    const giphyApiKey = String.fromEnvironment('GIPHY_API_KEY');
    _giphy = giphyApiKey.isEmpty ? null : giphyApiKey;
    addOauth(
      'imap.gmail.com',
      const String.fromEnvironment('OAUTH_GMAIL'),
    );
    addOauth(
      'outlook.office365.com',
      const String.fromEnvironment('OAUTH_OUTLOOK'),
    );
  }

  String? _giphy;

  /// The giphy API key
  String? get giphy => _giphy;

  /// Whether the giphy API key is available
  bool get hasGiphy => _giphy != null;

  /// The oauth client ids
  final oauth = <String, OauthClientId>{};

  /// Whether the oauth client id is available for the given [incomingHostname]
  bool hasOauthFor(String incomingHostname) => oauth[incomingHostname] != null;
}
