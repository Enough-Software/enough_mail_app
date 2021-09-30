import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/extensions/extensions.dart';
import 'package:enough_mail_app/models/contact.dart';
import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:flutter/cupertino.dart';

import '../locator.dart';

class Account extends ChangeNotifier {
  static const String attributeGravatarImageUrl = 'gravatar.img';
  static const String attributeExcludeFromUnified = 'excludeUnified';
  static const String attributePlusAliasTested = 'test.alias.plus';
  static const String attributeSentMailAddedAutomatically = 'sendMailAdded';
  static const String attributeSignatureHtml = 'signatureHtml';
  static const String attributeSignaturePlain = 'signaturePlain';
  static const String attributeBccMyself = 'bccMyself';

  final MailAccount account;

  Account(this.account);

  bool get isVirtual => false;

  String get name => account.name ?? '';
  set name(String value) {
    account.name = value;
    notifyListeners();
  }

  bool get excludeFromUnified =>
      account.hasAttribute(attributeExcludeFromUnified);
  set excludeFromUnified(bool value) {
    if (value) {
      account.attributes[attributeExcludeFromUnified] = value;
    } else {
      account.attributes.remove(attributeExcludeFromUnified);
    }
  }

  dynamic getAttribute(String key) {
    return account.attributes[key];
  }

  void setAttribute(String key, dynamic value) {
    account.attributes[key] = value;
  }

  String? get signatureHtml {
    var signature = account.attributes[attributeSignatureHtml];
    if (signature == null) {
      final extensions = account.appExtensions;
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
      account.attributes.remove(attributeSignatureHtml);
    } else {
      account.attributes[attributeSignatureHtml] = value;
    }
  }

  String? get signaturePlain => account.attributes[attributeSignaturePlain];
  set signaturePlain(String? value) {
    if (value == null) {
      account.attributes.remove(attributeSignaturePlain);
    } else {
      account.attributes[attributeSignaturePlain] = value;
    }
  }

  String? get userName => account.userName;
  set userName(String? value) {
    account.userName = value;
    notifyListeners();
  }

  String get email => account.email!;
  set email(String value) {
    account.email = value;
    notifyListeners();
  }

  MailAddress get fromAddress => account.fromAddress;

  bool get supportsPlusAliases => account.supportsPlusAliases;
  set supportsPlusAliases(bool value) {
    account.supportsPlusAliases = value;
    notifyListeners();
  }

  bool get bccMyself => account.hasAttribute(attributeBccMyself);
  set bccMyself(bool value) {
    if (value) {
      account.attributes[attributeBccMyself] = value;
    } else {
      account.attributes.remove(attributeBccMyself);
    }
  }

  ContactManager? contactManager;

  Future<void> addAlias(MailAddress alias) {
    account.aliases ??= <MailAddress>[];
    account.aliases!.add(alias);
    notifyListeners();
    return locator<MailService>().saveAccount(account);
  }

  Future<void> removeAlias(MailAddress alias) {
    account.aliases ??= <MailAddress>[];
    account.aliases!.remove(alias);
    notifyListeners();
    return locator<MailService>().saveAccount(account);
  }

  void updateAlias(MailAddress alias) {
    notifyListeners();
  }

  List<MailAddress> get aliases => account.aliases ?? <MailAddress>[];

  bool get hasAlias => account.aliases?.isNotEmpty ?? false;
  bool get hasNoAlias => !hasAlias;

  String? get imageUrlGravator => account.attributes[attributeGravatarImageUrl];

  bool get addsSentMailAutomatically =>
      account.attributes[attributeSentMailAddedAutomatically] ?? false;

  String? _key;
  String get key {
    var k = _key;
    if (k == null) {
      k = email.toLowerCase();
      _key = k;
    }
    return k;
  }

  List<AppExtension?>? get appExtensions => account.appExtensions;
  set appExtensions(List<AppExtension?>? value) =>
      account.appExtensions = value;

  @override
  operator ==(Object o) => o is Account && o.key == key;

  @override
  int get hashCode => key.hashCode;
}

class UnifiedAccount extends Account {
  final List<Account> accounts;
  final String _name;

  UnifiedAccount(this.accounts, String name)
      : _name = name,
        super(MailAccount()
          ..name = 'unified'
          ..email = 'info@enough.de');

  @override
  bool get isVirtual => true;

  @override
  String get name => _name;

  @override
  MailAddress get fromAddress => accounts.first.fromAddress;

  @override
  String get email => accounts.map((a) => a.email).join(';');

  void removeAccount(Account account) {
    accounts.remove(account);
  }

  void addAccount(Account account) {
    accounts.add(account);
  }
}

class ConnectedAccount extends Account {
  final MailClient mailClient;
  ConnectedAccount(MailAccount account, this.mailClient) : super(account);
}
