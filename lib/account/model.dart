import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

import '../contact/model.dart';
import '../extensions/extensions.dart';

part 'model.g.dart';

/// Common functionality for accounts
abstract class Account extends ChangeNotifier {
  /// Is this a virtual account, e.g. a unified one?
  bool get isVirtual;

  ///  The name of the account
  String get name;
  set name(String value);

  /// Retrieves the email or emails associated with this account
  String get email;

  /// The from address for this account
  MailAddress get fromAddress;

  /// The key for comparing accounts
  String get key {
    final value = _key ?? email.toLowerCase();
    _key = value;

    return value;
  }

  String? _key;

  @override
  int get hashCode => key.hashCode;

  @override
  bool operator ==(Object other) => other is Account && other.key == key;
}

/// Allows to listen to mail account changes
@JsonSerializable()
class RealAccount extends Account {
  /// Creates a new [Account]
  RealAccount(
    MailAccount mailAccount, {
    this.appExtensions,
    this.contactManager,
  }) : _account = mailAccount;

  /// Creates a new [RealAccount] from JSON
  factory RealAccount.fromJson(Map<String, dynamic> json) =>
      _$RealAccountFromJson(json);

  /// Generates JSON from this [MailAccount]
  Map<String, dynamic> toJson() => _$RealAccountToJson(this);

  static const String attributeGravatarImageUrl = 'gravatar.img';
  static const String attributeExcludeFromUnified = 'excludeUnified';
  static const String attributePlusAliasTested = 'test.alias.plus';
  static const String attributeSentMailAddedAutomatically = 'sendMailAdded';
  static const String attributeSignatureHtml = 'signatureHtml';
  static const String attributeSignaturePlain = 'signaturePlain';
  static const String attributeBccMyself = 'bccMyself';
  static const String attributeEnableLogging = 'enableLogging';

  /// The underlying actual account
  @JsonKey(name: 'mailAccount', required: true)
  MailAccount _account;

  /// Retrieves the mail account
  MailAccount get mailAccount => _account;

  /// Updates the account with the given [mailAccount]
  set mailAccount(MailAccount mailAccount) {
    _account = mailAccount;
    notifyListeners();
  }

  /// Does this account have a login error?
  @JsonKey(includeToJson: false, includeFromJson: false)
  bool hasError = false;

  @override
  bool get isVirtual => false;

  @JsonKey(includeToJson: false, includeFromJson: false)
  @override
  String get name => _account.name;

  @override
  set name(String value) {
    _account = _account.copyWith(name: value);
    notifyListeners();
  }

  /// Should this account be excluded from the unified account?
  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get excludeFromUnified =>
      getAttribute(attributeExcludeFromUnified) ?? false;
  set excludeFromUnified(bool value) =>
      setAttribute(attributeExcludeFromUnified, value);

  /// Developer mode option: should logging be enabled for this account?
  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get enableLogging => getAttribute(attributeEnableLogging) ?? false;
  set enableLogging(bool value) => setAttribute(attributeEnableLogging, value);

  /// Retrieves the attribute with the given [key] name
  T? getAttribute<T>(String key) => _account.attributes[key] as T?;

  /// Sets the attribute [key] to [value]
  void setAttribute(String key, dynamic value) {
    if (value == null) {
      _account.attributes.remove(key);
    } else {
      _account = _account.copyWithAttribute(key, value);
    }
    notifyListeners();
  }

  /// Checks is this account has the [key] attribute
  bool hasAttribute(String key) => _account.hasAttribute(key);

  /// Retrieves the account specific signature for HTML messages
  /// Compare [signaturePlain]
  String? getSignatureHtml([String? languageCode]) {
    final signature = _account.attributes[attributeSignatureHtml];
    if (signature == null) {
      final extensions = appExtensions;
      if (extensions != null) {
        for (final ext in extensions) {
          final signature = ext.getSignatureHtml(languageCode ?? 'en');
          if (signature != null) {
            return signature;
          }
        }
      }
    }

    return signature;
  }

  /// Sets the account specific signature for HTML messages
  // ignore: avoid_setters_without_getters
  set signatureHtml(String? value) =>
      setAttribute(attributeSignatureHtml, value);

  /// Account-specific signature for plain text messages
  ///
  /// Compare [signatureHtml]
  @JsonKey(includeToJson: false, includeFromJson: false)
  String? get signaturePlain => _account.attributes[attributeSignaturePlain];
  set signaturePlain(String? value) =>
      setAttribute(attributeSignaturePlain, value);

  /// The name used for sending
  @JsonKey(includeToJson: false, includeFromJson: false)
  String? get userName => _account.userName;
  set userName(String? value) {
    _account = _account.copyWith(userName: value);
    notifyListeners();
  }

  /// The email associated with this account
  @override
  @JsonKey(includeToJson: false, includeFromJson: false)
  String get email => _account.email;
  set email(String value) {
    _account = _account.copyWith(email: value);
    notifyListeners();
  }

  @override
  MailAddress get fromAddress => _account.fromAddress;

  /// Does this account support + aliases like name+alias@domain.com?
  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get supportsPlusAliases => _account.supportsPlusAliases;
  set supportsPlusAliases(bool value) {
    _account = _account.copyWith(supportsPlusAliases: value);
    notifyListeners();
  }

  /// Should all outgoing messages be sent to the user as well?
  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get bccMyself => _account.hasAttribute(attributeBccMyself);
  set bccMyself(bool value) {
    if (value) {
      setAttribute(attributeBccMyself, value);
    } else {
      _account.attributes.remove(attributeBccMyself);
    }
    notifyListeners();
  }

  /// Allows to access the [ContactManager]
  @JsonKey(includeFromJson: false, includeToJson: false)
  ContactManager? contactManager;

  /// Adds the [alias]
  void addAlias(MailAddress alias) {
    _account = _account.copyWithAlias(alias);
    notifyListeners();
  }

  /// Removes the [alias]
  void removeAlias(MailAddress alias) {
    _account.aliases.remove(alias);
    notifyListeners();
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

  /// [AppExtension]s are account specific additional setting retrieved
  /// from the server during initial setup
  /// Retrieves the app extensions
  List<AppExtension>? appExtensions;

  /// Copies this account with the given data
  RealAccount copyWith({
    MailAccount? mailAccount,
    List<AppExtension>? appExtensions,
    ContactManager? contactManager,
  }) =>
      RealAccount(
        mailAccount ?? _account,
        appExtensions: appExtensions ?? this.appExtensions,
        contactManager: contactManager ?? this.contactManager,
      );
}

/// A unified account bundles folders of several accounts
class UnifiedAccount extends Account {
  /// Creates a new [UnifiedAccount]
  UnifiedAccount(this.accounts);

  /// The accounts
  final List<RealAccount> accounts;

  @override
  bool get isVirtual => true;

  @override
  String get name => '';

  @override
  set name(String value) {
    //_name = value;
    notifyListeners();
  }

  @override
  MailAddress get fromAddress => accounts.first.fromAddress;

  /// The emails of this account
  @override
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
  ConnectedAccount(super.account, this.mailClient);

  /// The client
  final MailClient mailClient;
}
