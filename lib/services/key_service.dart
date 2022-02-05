/// contains rate limited beta keys,
/// production keys are stored locally only
import 'package:enough_mail_app/oauth/oauth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

class KeyService {
  KeyService();

  Future init() async {
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
            oauth[key] = OauthClientId(value.substring(0, valueIndex),
                value.substring(valueIndex + 1));
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(
            'no assets/keys.txt found. Ensure to specify it in the pubspec.yaml and add the relevant keys there.');
      }
    }
  }

  String? _giphy;
  String? get giphy => _giphy;
  bool get hasGiphy => (_giphy != null);

  final oauth = <String, OauthClientId>{};

  bool hasOauthFor(String incomingHostname) {
    return (oauth[incomingHostname] != null);
  }
}
