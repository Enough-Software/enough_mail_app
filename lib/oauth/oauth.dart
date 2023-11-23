import 'package:enough_mail/enough_mail.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;

import '../keys/service.dart';
import '../logger.dart';
import '../util/http_helper.dart';

class OauthClientId {
  const OauthClientId(this.id, this.secret);

  final String id;
  final String? secret;
}

abstract class OauthClient {
  OauthClient(this.incomingHostName);
  final String incomingHostName;
  bool get isEnabled => oauthClientId != null;
  OauthClientId? get oauthClientId =>
      KeyService.instance.oauth[incomingHostName];

  Future<OauthToken?> authenticate(String email) async {
    try {
      final token = await _authenticate(email, incomingHostName);
      logger.d(
        'authenticated $email and received refresh '
        'token  ${token.refreshToken}',
      );

      return token;
    } catch (e, s) {
      logger.e('Unable to authenticate: $e', error: e, stackTrace: s);

      return Future.value();
    }
  }

  Future<OauthToken?> refresh(OauthToken token) async {
    try {
      final refreshedToken = await _refresh(token, incomingHostName);
      logger.d(
        'refreshed token and received  refresh token '
        '${refreshedToken.refreshToken}',
      );

      return refreshedToken;
    } catch (e, s) {
      logger.e('Unable to refresh tokens: $e', error: e, stackTrace: s);

      return Future.value();
    }
  }

  Future<OauthToken> _authenticate(String email, String provider);
  Future<OauthToken> _refresh(OauthToken token, String provider);
}

class GmailOAuthClient extends OauthClient {
  GmailOAuthClient() : super('imap.gmail.com');

  @override
  Future<OauthToken> _authenticate(String email, String provider) async {
    final clientId = oauthClientId!.id;
    final callbackUrlScheme = clientId.split('.').reversed.join('.');

    // Construct the url
    final uri = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': '$callbackUrlScheme:/',
      'scope': 'https://mail.google.com/',
      'login_hint': email,
    }).toString();

    // Present the dialog to the user
    final result = await FlutterWebAuth.authenticate(
      url: uri,
      callbackUrlScheme: callbackUrlScheme,
    );

    // Extract code from resulting url
    final code = Uri.parse(result).queryParameters['code'];

    // Use this code to get an access token
    final response = await http.post(
      Uri.parse('https://oauth2.googleapis.com/token'),
      body: {
        'client_id': clientId,
        'redirect_uri': '$callbackUrlScheme:/',
        'grant_type': 'authorization_code',
        'code': code,
      },
    );

    // Get the access token from the response
    final text = response.text;
    if (response.statusCode != 200 || text == null) {
      logger.e('received status code ${response.statusCode} with $text');
      throw StateError(
        'Unable to get Google OAuth token with code $code, '
        'status code=${response.statusCode}, response=$text',
      );
    }

    return OauthToken.fromText(text, provider: provider);
  }

  @override
  Future<OauthToken> _refresh(OauthToken token, String provider) async {
    final clientId = oauthClientId!.id;
    final callbackUrlScheme = clientId.split('.').reversed.join('.');
    final response = await http.post(
      Uri.parse('https://oauth2.googleapis.com/token'),
      body: {
        'client_id': clientId,
        'redirect_uri': '$callbackUrlScheme:/',
        'refresh_token': token.refreshToken,
        'grant_type': 'refresh_token',
      },
    );
    final text = response.text;
    if (response.statusCode != 200 || text == null) {
      logger.e(
        'refresh: received status code ${response.statusCode} with $text',
      );
      throw StateError(
        'Unable to refresh Google OAuth token $token, '
        'status code=${response.statusCode}, response=$text',
      );
    }

    return OauthToken.fromText(
      text,
      provider: provider,
      refreshToken: token.refreshToken,
    );
  }
}

class OutlookOAuthClient extends OauthClient {
  OutlookOAuthClient() : super('outlook.office365.com');
  // source: https://docs.microsoft.com/en-us/exchange/client-developer/legacy-protocols/how-to-authenticate-an-imap-pop-smtp-application-by-using-oauth
  static const String _scope =
      'https://outlook.office.com/IMAP.AccessAsUser.All '
      'https://outlook.office.com/SMTP.Send offline_access';

  @override
  Future<OauthToken> _authenticate(String email, String provider) async {
    final clientId = oauthClientId!.id;
    final clientSecret = oauthClientId!.secret;
    const callbackUrlScheme =
        //'https://login.microsoftonline.com/common/oauth2/nativeclient';
        'maily://oauth';

    // Construct the url
    final uri = Uri.https(
      'login.microsoftonline.com',
      '/common/oauth2/v2.0/authorize',
      {
        'response_type': 'code',
        'client_id': clientId,
        'client_secret': clientSecret,
        'redirect_uri': callbackUrlScheme,
        'scope': _scope,
        'login_hint': email,
      },
    ).toString();
    // print('authenticate URL: $uri');

    // Present the dialog to the user
    final result = await FlutterWebAuth.authenticate(
      url: uri,
      callbackUrlScheme: 'maily', //callbackUrlScheme,
    );

    // Extract code from resulting url
    final code = Uri.parse(result).queryParameters['code'];
    // Use this code to get an access token
    final response = await http.post(
      Uri.parse('https://login.microsoftonline.com/common/oauth2/v2.0/token'),
      body: {
        'client_id': clientId,
        'redirect_uri': callbackUrlScheme,
        'grant_type': 'authorization_code',
        'code': code,
      },
    );

    // Get the access token from the response
    final responseText = response.text;
    if (responseText == null) {
      throw StateError(
        'no response from '
        'https://login.microsoftonline.com/common/oauth2/v2.0/token',
      );
    }

    return OauthToken.fromText(responseText, provider: provider);
  }

  @override
  Future<OauthToken> _refresh(OauthToken token, String provider) async {
    final clientId = oauthClientId!.id;
    final response = await http.post(
      Uri.parse('https://login.microsoftonline.com/common/oauth2/v2.0/token'),
      body: {
        'client_id': clientId,
        'scope': _scope,
        'refresh_token': token.refreshToken,
        'grant_type': 'refresh_token',
      },
    );
    final text = response.text;
    if (response.statusCode != 200 || text == null) {
      throw StateError(
        'Unable to refresh Outlook OAuth token $token, '
        'status code=${response.statusCode}, response=$text',
      );
    }

    return OauthToken.fromText(
      text,
      provider: provider,
      refreshToken: token.refreshToken,
    );
  }
}
