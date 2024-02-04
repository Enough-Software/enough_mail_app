import 'dart:convert';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:enough_mail/enough_mail.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

import '../account/model.dart';
import '../logger.dart';
import '../util/http_helper.dart';

part 'extensions.g.dart';

/// Server side mail account extensions
extension MailAccountExtension on RealAccount {
  /// The forgot password app extension for this account
  AppExtensionActionDescription? get appExtensionForgotPassword => appExtensions
      ?.firstWhereOrNull((ext) => ext.forgotPasswordAction != null)
      ?.forgotPasswordAction;

  /// The menu app extensions for this account
  List<AppExtensionActionDescription> get appExtensionsAccountSideMenu {
    final entries = <AppExtensionActionDescription>[];
    final extensions = appExtensions;
    if (extensions != null) {
      for (final ext in extensions) {
        final accountSideMenu = ext.accountSideMenu;
        if (accountSideMenu != null) {
          entries.addAll(accountSideMenu);
        }
      }
    }

    return entries;
  }
}

/// [AppExtension]s allow to dynamically configure the app for a
/// given [MailAccount]
@JsonSerializable()
class AppExtension {
  /// Creates a new [AppExtension]
  const AppExtension({
    this.version,
    this.accountSideMenu,
    this.forgotPasswordAction,
    this.signatureHtml,
  });

  /// Creates a new [AppExtension] from the given [json]
  factory AppExtension.fromJson(Map<String, dynamic> json) =>
      _$AppExtensionFromJson(json);

  /// The version of the app extension
  final int? version;

  /// Elements to add to the account side/hamburger menu
  final List<AppExtensionActionDescription>? accountSideMenu;

  /// The action to perform when the user forgot the password
  @JsonKey(name: 'forgotPassword')
  final AppExtensionActionDescription? forgotPasswordAction;

  /// The signature html for each language
  final Map<String, String>? signatureHtml;

  /// The signature html for the given [languageCode].
  ///
  /// Falls back to `en` if no signature for the given [languageCode] is found.
  String? getSignatureHtml(String languageCode) {
    final map = signatureHtml;
    if (map == null) {
      return null;
    }
    var signature = map[languageCode];
    if (signature == null && languageCode != 'en') {
      signature = map['en'];
    }

    return signature;
  }

  /// Converts this [AppExtension] to JSON.
  Map<String, dynamic> toJson() => _$AppExtensionToJson(this);

  /// REtrieves the app extension url for the given [domain]
  static String urlFor(String domain) => 'https://$domain/.maily.json';

  //// Loads the app extensions for the given [mailAccount]
  static Future<List<AppExtension>> loadFor(MailAccount mailAccount) async {
    try {
      final domains = <String, Future<AppExtension?>>{};
      _addEmail(mailAccount.email, domains);
      final incomingHostname = mailAccount.incoming.serverConfig.hostname;
      _addHostname(incomingHostname, domains);
      final outgoingHostname = mailAccount.outgoing.serverConfig.hostname;
      _addHostname(outgoingHostname, domains);
      final allExtensions = await Future.wait(domains.values);
      final appExtensions = <AppExtension>[];
      for (final ext in allExtensions) {
        if (ext != null) {
          appExtensions.add(ext);
        }
      }

      return appExtensions;
    } catch (e, s) {
      logger.e(
        'Unable to load app extensions for mail account '
        '${mailAccount.email}: $e',
        error: e,
        stackTrace: s,
      );

      return const [];
    }
  }

  static void _addEmail(
    String email,
    Map<String, Future<AppExtension?>> domains,
  ) {
    _addDomain(email.substring(email.indexOf('@') + 1), domains);
  }

  static void _addHostname(
    String hostname,
    Map<String, Future<AppExtension?>> domains,
  ) {
    final domainIndex = hostname.indexOf('.');
    if (domainIndex != -1) {
      _addDomain(hostname.substring(domainIndex + 1), domains);
    }
  }

  static void _addDomain(
    String domain,
    Map<String, Future<AppExtension?>> domains,
  ) {
    if (!domains.containsKey(domain)) {
      domains[domain] = loadFrom(domain);
    }
  }

  /// Loads the app extension from the given [domain]
  static Future<AppExtension?> loadFrom(String domain) async =>
      loadFromUrl(urlFor(domain));

  /// Loads the app extension from the given [url]
  static Future<AppExtension?> loadFromUrl(
    String url, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    String? text = '<>';
    try {
      final response = await http.get(Uri.parse(url)).timeout(timeout);
      if (response.statusCode != 200) {
        return null;
      }
      text = response.text;
      if (text == null || text.isEmpty) {
        return null;
      }

      final result = AppExtension.fromJson(jsonDecode(text));
      if (result.version == 1) {
        return result;
      }
    } catch (e, s) {
      logger.e(
        'Unable to load extension from $url / text $text: $e',
        error: e,
        stackTrace: s,
      );

      return null;
    }

    return null;
  }
}

/// Defines a translatable action
@JsonSerializable()
class AppExtensionActionDescription {
  /// Creates a new [AppExtensionActionDescription]
  const AppExtensionActionDescription({
    this.action,
    this.icon,
    this.labelByLanguage,
  });

  /// Creates a new [AppExtensionActionDescription] from the given [json]
  factory AppExtensionActionDescription.fromJson(Map<String, dynamic> json) =>
      _$AppExtensionActionDescriptionFromJson(json);

  /// The action to perform
  @JsonKey(
    fromJson: AppExtensionAction._parse,
    toJson: AppExtensionAction._toJson,
  )
  final AppExtensionAction? action;

  /// The icon to display
  final String? icon;

  /// The label to display for each language
  @JsonKey(name: 'label')
  final Map<String, String>? labelByLanguage;

  /// The label to display for the given [languageCode]
  ///
  /// Falls back to `en` if no label for the given [languageCode] is found.
  String? getLabel(String languageCode) {
    final map = labelByLanguage;
    if (map == null) {
      return null;
    }

    return map[languageCode] ?? map['en'];
  }

  /// Converts this [AppExtensionActionDescription] to JSON.
  Map<String, dynamic> toJson() => _$AppExtensionActionDescriptionToJson(this);
}

/// Defines an action
enum AppExtensionActionMechanism {
  /// An action is opened in-app
  inApp,

  /// An action is opened in an external app/browser
  external,
}

/// Defines an action
@JsonSerializable()
class AppExtensionAction {
  /// Creates a new [AppExtensionAction]
  const AppExtensionAction({
    required this.mechanism,
    required this.url,
  });

  /// Creates a new [AppExtensionAction] from the given [json]
  factory AppExtensionAction.fromJson(Map<String, dynamic> json) =>
      _$AppExtensionActionFromJson(json);

  /// The action mechanism
  final AppExtensionActionMechanism mechanism;

  /// The url to open
  final String url;

  /// Converts this [AppExtensionAction] to JSON.
  Map<String, dynamic> toJson() => _$AppExtensionActionToJson(this);

  static AppExtensionAction? _parse(String? link) {
    if (link == null || link.isEmpty) {
      return null;
    }
    final splitIndex = link.indexOf(':');
    if (splitIndex == -1 || splitIndex == link.length - 1) {
      return null;
    }
    final mechanismText = link.substring(0, splitIndex);
    final mechanism = (mechanismText.toLowerCase() == 'inapp')
        ? AppExtensionActionMechanism.inApp
        : AppExtensionActionMechanism.external;
    final url = link.substring(splitIndex + 1);

    return AppExtensionAction(mechanism: mechanism, url: url);
  }

  static String? _toJson(AppExtensionAction? action) {
    if (action == null) {
      return null;
    }

    return '${action.mechanism.toString()}:${action.url}';
  }
}
