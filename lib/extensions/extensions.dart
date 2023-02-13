import 'dart:convert';

import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/util/http_helper.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import '../models/account.dart';

part 'extensions.g.dart';

/// Server side mail account extensions
extension MailAccountExtension on RealAccount {
  AppExtensionActionDescription? get appExtensionForgotPassword => appExtensions
      ?.firstWhereOrNull((ext) => ext.forgotPasswordAction != null)
      ?.forgotPasswordAction;

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

@JsonSerializable()
class AppExtension {
  const AppExtension({
    this.version,
    this.accountSideMenu,
    this.forgotPasswordAction,
    this.signatureHtml,
  });

  factory AppExtension.fromJson(Map<String, dynamic> json) =>
      _$AppExtensionFromJson(json);

  final int? version;
  final List<AppExtensionActionDescription>? accountSideMenu;
  @JsonKey(name: 'forgotPassword')
  final AppExtensionActionDescription? forgotPasswordAction;
  final Map<String, String>? signatureHtml;

  static const attributeName = 'extensions';

  String? getSignatureHtml(String languageCode) {
    final map = signatureHtml;
    if (map == null) {
      return null;
    }
    var sign = map[languageCode];
    if (sign == null && languageCode != 'en') {
      sign = map['en'];
    }
    return sign;
  }

  Map<String, dynamic> toJson() => _$AppExtensionToJson(this);

  static String urlFor(String domain) {
    return 'https://$domain/.maily.json';
  }

  static Future<List<AppExtension>> loadFor(MailAccount mailAccount) async {
    final domains = <String, Future<AppExtension?>>{};
    _addEmail(mailAccount.email, domains);
    _addHostname(mailAccount.incoming.serverConfig.hostname!, domains);
    _addHostname(mailAccount.outgoing.serverConfig.hostname!, domains);
    final allExtensions = await Future.wait(domains.values);
    final appExtensions = <AppExtension>[];
    for (final ext in allExtensions) {
      if (ext != null) {
        appExtensions.add(ext);
      }
    }
    return appExtensions;
  }

  static void _addEmail(
      String email, Map<String, Future<AppExtension?>> domains) {
    _addDomain(email.substring(email.indexOf('@') + 1), domains);
  }

  static void _addHostname(
      String hostname, Map<String, Future<AppExtension?>> domains) {
    final domainIndex = hostname.indexOf('.');
    if (domainIndex != -1) {
      _addDomain(hostname.substring(domainIndex + 1), domains);
    }
  }

  static void _addDomain(
      String domain, Map<String, Future<AppExtension?>> domains) {
    if (!domains.containsKey(domain)) {
      domains[domain] = loadFrom(domain);
    }
  }

  static Future<AppExtension?> loadFrom(String domain) async {
    return loadFromUrl(urlFor(domain));
  }

  static Future<AppExtension?> loadFromUrl(String url) async {
    try {
      final httpResult = await HttpHelper.httpGet(url);
      final text = httpResult.text;
      if (httpResult.statusCode != 200 || text == null || text.isEmpty) {
        return null;
      }

      final result = AppExtension.fromJson(jsonDecode(text));
      if (result.version == 1) {
        return result;
      }
    } catch (e, s) {
      if (kDebugMode) {
        print('Unable to load extension from $url: $e $s');
      }
    }
    return null;
  }
}

@JsonSerializable()
class AppExtensionActionDescription {
  const AppExtensionActionDescription(
      {this.action, this.icon, this.labelByLanguage});

  factory AppExtensionActionDescription.fromJson(Map<String, dynamic> json) =>
      _$AppExtensionActionDescriptionFromJson(json);

  final AppExtensionAction? action;
  final String? icon;

  @JsonKey(name: 'label')
  final Map<String, String>? labelByLanguage;

  String? getLabel(String languageCode) {
    final map = labelByLanguage;
    if (map == null) {
      return null;
    }
    return map[languageCode] ?? map['en'];
  }

  Map<String, dynamic> toJson() => _$AppExtensionActionDescriptionToJson(this);
}

enum AppExtensionActionMechanism { inapp, external }

@JsonSerializable()
class AppExtensionAction {
  const AppExtensionAction({
    required this.mechanism,
    required this.url,
  });

  factory AppExtensionAction.fromJson(Map<String, dynamic> json) =>
      _$AppExtensionActionFromJson(json);

  final AppExtensionActionMechanism mechanism;
  final String url;

  Map<String, dynamic> toJson() => _$AppExtensionActionToJson(this);

  static AppExtensionAction? parse(String? link) {
    if (link == null || link.isEmpty) {
      return null;
    }
    final splitIndex = link.indexOf(':');
    if (splitIndex == -1 || splitIndex == link.length - 1) {
      return null;
    }
    final mechanismText = link.substring(0, splitIndex);
    final mechanism = (mechanismText == 'inapp')
        ? AppExtensionActionMechanism.inapp
        : AppExtensionActionMechanism.external;
    final url = link.substring(splitIndex + 1);
    return AppExtensionAction(mechanism: mechanism, url: url);
  }
}
