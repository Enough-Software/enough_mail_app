import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/util/http_helper.dart';
import 'package:enough_serialization/enough_serialization.dart';
import 'package:collection/collection.dart' show IterableExtension;

extension MailAccountExtension on MailAccount {
  void addExtensionSerializationConfiguration() {
    objectCreators['extensions'] = (map) => <AppExtension>[];
    objectCreators['extensions.value'] = (map) => AppExtension();
  }

  List<AppExtension>? get appExtensions => attributes['extensions'];
  set appExtensions(List<AppExtension?>? value) =>
      attributes['extensions'] = value;

  AppExtensionActionDescription? get appExtensionForgotPassword => appExtensions
      ?.firstWhereOrNull((ext) => ext.forgotPasswordAction != null)
      ?.forgotPasswordAction;

  List<AppExtensionActionDescription> get appExtensionsAccountSideMenu {
    final entries = <AppExtensionActionDescription>[];
    final extensions = appExtensions;
    if (extensions != null) {
      for (final ext in extensions) {
        if (ext.accountSideMenu != null) {
          entries.addAll(ext.accountSideMenu!);
        }
      }
    }
    return entries;
  }
}

class AppExtension extends SerializableObject {
  AppExtension() {
    objectCreators['forgotPassword'] = (map) => AppExtensionActionDescription();
    objectCreators['accountSideMenu'] =
        (map) => <AppExtensionActionDescription>[];
    objectCreators['accountSideMenu.value'] =
        (map) => AppExtensionActionDescription();
    objectCreators['signatureHtml'] = (map) => Map<String, String>();
  }

  int? get version => attributes['version'];
  List<AppExtensionActionDescription>? get accountSideMenu =>
      attributes['accountSideMenu'];
  AppExtensionActionDescription? get forgotPasswordAction =>
      attributes['forgotPassword'];
  Map<String, String>? get signatureHtml => attributes['signatureHtml'];

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

  static String urlFor(String domain) {
    return 'https://$domain/.maily.json';
  }

  static Future<List<AppExtension>> loadFor(MailAccount mailAccount) async {
    final domains = <String, Future<AppExtension?>>{};
    _addEmail(mailAccount.email!, domains);
    _addHostname(mailAccount.incoming!.serverConfig!.hostname!, domains);
    _addHostname(mailAccount.outgoing!.serverConfig!.hostname!, domains);
    final allExtensions = await Future.wait(domains.values);
    final appExtensions = <AppExtension>[];
    allExtensions.forEach((ext) {
      if (ext != null) {
        appExtensions.add(ext);
      }
    });
    mailAccount.appExtensions = appExtensions;
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
      if (httpResult.statusCode != 200) {
        return null;
      }
      final result = AppExtension();
      Serializer().deserialize(httpResult.text!, result);
      if (result.version == 1) {
        return result;
      }
    } catch (e, s) {
      print('Unable to load extension from $url: $e $s');
    }
    return null;
  }
}

class AppExtensionActionDescription extends SerializableObject {
  AppExtensionActionDescription() {
    objectCreators['label'] = (map) => Map<String, String>();
  }

  AppExtensionAction? get action =>
      AppExtensionAction.parse(attributes['action']);
  String? get icon => attributes['icon'];
  Map<String, String>? get labelByLanguage => attributes['label'];

  String? getLabel(String languageCode) {
    final map = labelByLanguage;
    if (map == null) {
      return null;
    }
    return map[languageCode] ?? map['en'];
  }
}

enum AppExtensionActionMechanism { inapp, external }

class AppExtensionAction {
  final AppExtensionActionMechanism mechanism;
  final String url;

  AppExtensionAction(this.mechanism, this.url);

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
    return AppExtensionAction(mechanism, url);
  }
}
