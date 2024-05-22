import 'package:enough_mail/enough_mail.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;

import '../keys/service.dart';
import '../logger.dart';
import '../util/http_helper.dart';

/// Defines the ID and secret of an OAuth client
class OauthClientId {
  /// Creates a new [OauthClientId]
  const OauthClientId(this.id, this.secret);

  /// The ID of the OAuth client
  final String id;

  /// The secret of the OAuth client
  final String? secret;
}

/// Provides means to authenticate with an OAuth provider
/// and to refresh the access token
abstract class OauthClient {
  /// Creates a new [OauthClient]
  OauthClient(this.incomingHostName);

  /// The hostname of the incoming mail server
  final String incomingHostName;

  /// Whether this client is enabled
  bool get isEnabled => oauthClientId != null;

  /// The [OauthClientId] for this client
  OauthClientId? get oauthClientId =>
      KeyService.instance.oauth[incomingHostName];

  /// Authenticates with the given [email] address
  Future<OauthToken?> authenticate(String email) async {
    try {
      final oauthClientId = this.oauthClientId;
      if (oauthClientId == null) {
        logger.d('no oauth client id for $incomingHostName');

        return Future.value();
      }
      final token = await _authenticate(oauthClientId, email, incomingHostName);
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

  /// Refreshes the given [token]
  Future<OauthToken?> refresh(OauthToken token) async {
    final oauthClientId = this.oauthClientId;
    if (oauthClientId == null) {
      logger.d('no oauth client id for $incomingHostName');

      return Future.value();
    }
    try {
      final refreshedToken = await _refresh(
        oauthClientId,
        token,
        incomingHostName,
      );
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

  /// Subclasses have to implement the actual authentication
  Future<OauthToken> _authenticate(
    OauthClientId oauthClientId,
    String email,
    String provider,
  );

  /// Subclasses have to implement the actual token refresh
  Future<OauthToken> _refresh(
    OauthClientId oauthClientId,
    OauthToken token,
    String provider,
  );
}

/// Provide Gmail OAuth authentication
class GmailOAuthClient extends OauthClient {
  /// Creates a new [GmailOAuthClient]
  GmailOAuthClient() : super('imap.gmail.com');

  @override
  Future<OauthToken> _authenticate(
    OauthClientId oauthClientId,
    String email,
    String provider,
  ) async {
    final clientId = oauthClientId.id;
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
    final result = await FlutterWebAuth2.authenticate(
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
  Future<OauthToken> _refresh(
    OauthClientId oauthClientId,
    OauthToken token,
    String provider,
  ) async {
    final clientId = oauthClientId.id;
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

/// Provide Outlook OAuth authentication
class OutlookOAuthClient extends OauthClient {
  /// Creates a new [OutlookOAuthClient]
  OutlookOAuthClient() : super('outlook.office365.com');
  // source: https://docs.microsoft.com/en-us/exchange/client-developer/legacy-protocols/how-to-authenticate-an-imap-pop-smtp-application-by-using-oauth
  static const String _scope =
      'https://outlook.office.com/IMAP.AccessAsUser.All '
      'https://outlook.office.com/SMTP.Send offline_access';

  @override
  Future<OauthToken> _authenticate(
    OauthClientId oauthClientId,
    String email,
    String provider,
  ) async {
    final clientId = oauthClientId.id;
    final clientSecret = oauthClientId.secret;
    const callbackUrlScheme = 'maily://oauth';

    // Construct the url
    final uri = Uri.https(
      // cSpell: disable-next-line
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
    final result = await FlutterWebAuth2.authenticate(
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
  Future<OauthToken> _refresh(
    OauthClientId oauthClientId,
    OauthToken token,
    String provider,
  ) async {
    final clientId = oauthClientId.id;
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
