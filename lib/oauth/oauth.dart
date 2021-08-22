import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/locator.dart';
import 'package:enough_mail_app/services/key_service.dart';
import 'package:enough_mail_app/util/http_helper.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';

class OauthClientId {
  final String id;
  final String? secret;

  const OauthClientId(this.id, this.secret);
}

abstract class OauthClient {
  final String incomingHostName;
  bool get isEnabled => (oauthClientId != null);
  OauthClientId? get oauthClientId =>
      locator<KeyService>().oauth[incomingHostName];
  OauthClient(this.incomingHostName);

  Future<OauthToken?> authenticate(String email) async {
    try {
      final token = await _authenticate(email);
      token.provider = incomingHostName;
      return token;
    } catch (e, s) {
      print('Unable to authenticate: $e $s');
      return Future.value();
    }
  }

  Future<OauthToken?> refresh(OauthToken token) async {
    try {
      final refreshedToken = await _refresh(token);
      refreshedToken.provider = incomingHostName;
      return refreshedToken;
    } catch (e, s) {
      print('Unable to authenticate: $e $s');
      return Future.value();
    }
  }

  Future<OauthToken> _authenticate(String email);
  Future<OauthToken> _refresh(OauthToken token);
}

class GmailOAuthClient extends OauthClient {
  GmailOAuthClient() : super('imap.gmail.com');

  @override
  Future<OauthToken> _authenticate(String email) async {
    final clientId = oauthClientId!.id;
    final callbackUrlScheme = clientId.split('.').reversed.join('.');

    // Construct the url
    final uri = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': '$callbackUrlScheme:/',
      'scope': 'https://mail.google.com/',
      'login_hint': email,
    });
    print('authenticate URL: $uri');

    // Present the dialog to the user
    final result = await FlutterWebAuth.authenticate(
        url: uri.toString(), callbackUrlScheme: callbackUrlScheme);

    // Extract code from resulting url
    final code = Uri.parse(result).queryParameters['code'];

    // Use this code to get an access token
    final response = await HttpHelper.httpPost(
        'https://oauth2.googleapis.com/token', //'https://www.googleapis.com/oauth2/v4/token',
        body: {
          'client_id': clientId,
          'redirect_uri': '$callbackUrlScheme:/',
          'grant_type': 'authorization_code',
          'code': code,
        });

    // Get the access token from the response
    print('authorization code token:');
    print(response.text);
    return OauthToken.fromText(response.text!);
  }

  @override
  Future<OauthToken> _refresh(OauthToken token) async {
    final clientId = oauthClientId!.id;
    final callbackUrlScheme = clientId.split('.').reversed.join('.');
    final response =
        await HttpHelper.httpPost('https://oauth2.googleapis.com/token', body: {
      'client_id': clientId,
      'redirect_uri': '$callbackUrlScheme:/',
      'refresh_token': token.refreshToken,
      'grant_type': 'refresh_token',
    });

    // Get the access token from the response
    print('refresh token:');
    print(response.text);
    return OauthToken.fromText(response.text!);
  }
}

class OutlookOAuthClient extends OauthClient {
  OutlookOAuthClient() : super('outlook.office365.com');

  @override
  Future<OauthToken> _authenticate(String email) async {
    final clientId = oauthClientId!.id;
    final clientSecret = oauthClientId!.secret;
    final callbackUrlScheme = 'maily://oauth';

    // Construct the url
    final uri = Uri.https(
        'login.microsoftonline.com', '/common/oauth2/v2.0/authorize', {
      'response_type': 'code',
      'client_id': clientId,
      'client_secret': clientSecret,
      'redirect_uri': '$callbackUrlScheme',
      'scope': //TODO check scopes once test app registration is completed
          'https://outlook.office.com/mail.read https://outlook.office.com/mail.send',
      'login_hint': email,
    });
    print('authenticate URL: $uri');

    // Present the dialog to the user
    final result = await FlutterWebAuth.authenticate(
        url: uri.toString(), callbackUrlScheme: callbackUrlScheme);

    // Extract code from resulting url
    final code = Uri.parse(result).queryParameters['code'];

    // Use this code to get an access token
    final response = await HttpHelper.httpPost(
        'https://login.microsoftonline.com/common/oauth2/v2.0/token',
        body: {
          'client_id': clientId,
          'client_secret': clientSecret,
          'redirect_uri': '$callbackUrlScheme:/',
          'grant_type': 'authorization_code',
          'code': code,
        });

    // Get the access token from the response
    print('authorization code token:');
    print(response.text);
    return OauthToken.fromText(response.text!);
  }

  @override
  Future<OauthToken> _refresh(OauthToken token) async {
    final clientId = oauthClientId!.id;
    final callbackUrlScheme = clientId.split('.').reversed.join('.');
    final response =
        await HttpHelper.httpPost('https://oauth2.googleapis.com/token', body: {
      'client_id': clientId,
      'redirect_uri': '$callbackUrlScheme:/',
      'refresh_token': token.refreshToken,
      'grant_type': 'refresh_token',
    });

    // Get the access token from the response
    print('refresh token:');
    print(response.text);
    return OauthToken.fromText(response.text!);
  }
}
