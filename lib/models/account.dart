import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/extensions/extensions.dart';
import 'package:enough_mail_app/models/contact.dart';
import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:flutter/cupertino.dart';

import '../locator.dart';

/// Common functionality for accounts
abstract class Account extends ChangeNotifier {
  /// Is this a virtual account, e.g. a unified one?
  bool get isVirtual;

  ///  The name of the account
  String get name;
  set name(String value);

  /// The from address for this account
  MailAddress get fromAddress;
}

/// Allows to listen to mail account changes
class RealAccount extends Account {
  /// Creates a new [Account]
  RealAccount(MailAccount account) : _account = account;

  static const String attributeGravatarImageUrl = 'gravatar.img';
  static const String attributeExcludeFromUnified = 'excludeUnified';
  static const String attributePlusAliasTested = 'test.alias.plus';
  static const String attributeSentMailAddedAutomatically = 'sendMailAdded';
  static const String attributeSignatureHtml = 'signatureHtml';
  static const String attributeSignaturePlain = 'signaturePlain';
  static const String attributeBccMyself = 'bccMyself';
  static const String attributeEnableLogging = 'enableLogging';

  /// The underlying actual account
  MailAccount _account;

  /// Retrieves the mail account
  MailAccount get mailAccount => _account;

  @override
  bool get isVirtual => false;

  @override
  String get name => _account.name;

  @override
  set name(String value) {
    _account = _account.copyWith(name: value);
    // TODO(RV): now this account is de-coupled from account manager aka MailService
    notifyListeners();
  }

  /// Should this account be excluded from the unified account?
  bool get excludeFromUnified =>
      _account.hasAttribute(attributeExcludeFromUnified);
  set excludeFromUnified(bool value) {
    if (value) {
      _account = _account.copyWithAttribute(attributeExcludeFromUnified, value);
    } else {
      _account.attributes.remove(attributeExcludeFromUnified);
    }
  }

  /// Developer mode option: should logging be enabled for this account?
  bool get enableLogging => getAttribute(attributeEnableLogging) ?? false;
  set enableLogging(bool value) => setAttribute(attributeEnableLogging, value);

  /// Retrieves the attribute with the given [key] name
  dynamic getAttribute(String key) {
    return _account.attributes[key];
  }

  /// Sets the attribute [key] to [value]
  void setAttribute(String key, dynamic value) {
    _account = _account.copyWithAttribute(key, value);
  }

  /// Checks is this account has the [key] attribute
  bool hasAttribute(String key) => _account.hasAttribute(name);

  /// Retrieves the account specific signature for HTML messages
  /// Compare [signaturePlain]
  String? get signatureHtml {
    var signature = _account.attributes[attributeSignatureHtml];
    if (signature == null) {
      final extensions = appExtensions;
      if (extensions != null) {
        final languageCode = locator<I18nService>().locale!.languageCode;
        for (final ext in extensions) {
          final signature = ext.getSignatureHtml(languageCode);
          if (signature != null) {
            return signature;
          }
        }
      }
    }
    return signature;
  }

  set signatureHtml(String? value) {
    if (value == null) {
      _account.attributes.remove(attributeSignatureHtml);
    } else {
      _account = _account.copyWithAttribute(attributeSignatureHtml, value);
    }
  }

  /// Account-specific signature for plain text messages
  ///
  /// Compare [signatureHtml]
  String? get signaturePlain => _account.attributes[attributeSignaturePlain];
  set signaturePlain(String? value) {
    if (value == null) {
      _account.attributes.remove(attributeSignaturePlain);
    } else {
      _account = _account.copyWithAttribute(attributeSignaturePlain, value);
    }
  }

  /// The name used for sending
  String? get userName => _account.userName;
  set userName(String? value) {
    _account = _account.copyWith(userName: value);
    notifyListeners();
  }

  /// The email associated with this account
  String get email => _account.email;
  set email(String value) {
    _account = _account.copyWith(email: value);
    notifyListeners();
  }

  @override
  MailAddress get fromAddress => _account.fromAddress;

  /// Does this account support + aliases like name+alias@domain.com?
  bool get supportsPlusAliases => _account.supportsPlusAliases;
  set supportsPlusAliases(bool value) {
    _account = _account.copyWith(supportsPlusAliases: value);
    notifyListeners();
  }

  /// Should all outgoing messages be sent to the user as well?
  bool get bccMyself => _account.hasAttribute(attributeBccMyself);
  set bccMyself(bool value) {
    if (value) {
      setAttribute(attributeBccMyself, value);
    } else {
      _account.attributes.remove(attributeBccMyself);
    }
  }

  /// Allows to access the [ContactManager]
  ContactManager? contactManager;

  /// Adds the [alias]
  Future<void> addAlias(MailAddress alias) {
    _account = _account.copyWithAlias(alias);
    notifyListeners();
    return locator<MailService>().saveAccount(_account);
  }

  /// Removes the [alias]
  Future<void> removeAlias(MailAddress alias) {
    _account.aliases.remove(alias);
    notifyListeners();
    return locator<MailService>().saveAccount(_account);
  }

  /// Retrieves the known alias addresses
  List<MailAddress> get aliases => _account.aliases;

  /// Checks if this account has at least 1 alias
  bool get hasAlias => _account.aliases.isNotEmpty;

  /// Checks if this account has now alias
  bool get hasNoAlias => _account.aliases.isEmpty;

  /// Retrieves the gravatar image URl for this email
  String? get imageUrlGravatar =>
      _account.attributes[attributeGravatarImageUrl];

  /// Marks if this account adds sent messages to the default SENT mailbox
  /// folder automatically
  bool get addsSentMailAutomatically =>
      _account.attributes[attributeSentMailAddedAutomatically] ?? false;

  /// Retrieves the key for comparing this account
  String get key {
    var k = _key;
    if (k == null) {
      k = email.toLowerCase();
      _key = k;
    }
    return k;
  }

  String? _key;

  /// [AppExtension]s are account specific additional setting retrieved
  /// from the server during initial setup
  /// Retrieves the app extensions
  List<AppExtension>? get appExtensions =>
      _account.attributes[AppExtension.attributeName];
  set appExtensions(List<AppExtension?>? value) {
    setAttribute(AppExtension.attributeName, value);
  }

  @override
  operator ==(Object other) => other is RealAccount && other.key == key;

  @override
  int get hashCode => key.hashCode;

  /// Copies this account with the given [mailAccount]
  RealAccount copyWith({required MailAccount mailAccount}) =>
      RealAccount(mailAccount);
}

/// A unified account bundles folders of several accounts
class UnifiedAccount extends Account {
  /// Creates a new [UnifiedAccount]
  UnifiedAccount(this.accounts, String name) : _name = name;

  /// The accounts
  final List<RealAccount> accounts;
  String _name;

  @override
  bool get isVirtual => true;

  @override
  String get name => _name;

  @override
  set name(String value) {
    _name = value;
    notifyListeners();
  }

  @override
  MailAddress get fromAddress => accounts.first.fromAddress;

  /// The emails of this account
  String get email => accounts.map((a) => a.email).join(';');

  /// Removes the given [account]
  void removeAccount(RealAccount account) {
    accounts.remove(account);
  }

  /// Adds the given [account]
  void addAccount(RealAccount account) {
    accounts.add(account);
  }
}

/// A account with an active [MailClient]
class ConnectedAccount extends RealAccount {
  /// Creates a new [ConnectedAccount]
  ConnectedAccount(MailAccount account, this.mailClient) : super(account);

  /// The client
  final MailClient mailClient;
}
