import 'package:flutter/services.dart' show rootBundle;

import '../logger.dart';
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
    try {
      final text = await rootBundle.loadString('assets/keys.txt');
      final lines =
          text.contains('\r\n') ? text.split('\r\n') : text.split('\n');
      for (final line in lines) {
        if (line.startsWith('#')) {
          continue;
        }
        if (line.startsWith('giphy:')) {
          _giphy = line.substring('giphy:'.length).trim();
        } else if (line.startsWith('oauth/')) {
          final splitIndex = line.indexOf(':', 'oauth/'.length);
          final key = line.substring('oauth/'.length, splitIndex);
          final value = line.substring(splitIndex + 1);
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
      }
    } catch (e) {
      logger.e(
        'no assets/keys.txt found. '
        'Ensure to specify it in the pubspec.yaml and '
        'add the relevant keys there.',
      );
    }
  }

  String? _giphy;
  String? get giphy => _giphy;
  bool get hasGiphy => _giphy != null;

  final oauth = <String, OauthClientId>{};

  bool hasOauthFor(String incomingHostname) => oauth[incomingHostname] != null;
}