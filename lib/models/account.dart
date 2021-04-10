import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/contact.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:flutter/cupertino.dart';

import '../locator.dart';

class Account extends ChangeNotifier {
  final MailAccount account;

  Account(this.account);

  bool get isVirtual => false;

  String get name => account?.name;

  bool get excludeFromUnified =>
      account.hasAttribute(MailService.attributeExcludeFromUnified);
  set excludeFromUnified(bool value) {
    if (value) {
      account.attributes[MailService.attributeExcludeFromUnified] = value;
    } else {
      account.attributes.remove(MailService.attributeExcludeFromUnified);
    }
  }

  set name(String value) {
    account.name = value;
    notifyListeners();
  }

  String get userName => account?.userName;
  set userName(String value) {
    account.userName = value;
    notifyListeners();
  }

  String get email => account?.email;
  set email(String value) {
    account.email = value;
    notifyListeners();
  }

  MailAddress get fromAddress => account?.fromAddress;

  get supportsPlusAliases => account?.supportsPlusAliases;
  set supportsPlusAliases(bool value) {
    account.supportsPlusAliases = value;
    notifyListeners();
  }

  ContactManager contactManager;

  Future<void> addAlias(MailAddress alias) {
    account.aliases ??= <MailAddress>[];
    account.aliases.add(alias);
    notifyListeners();
    return locator<MailService>().saveAccount(account);
  }

  Future<void> removeAlias(MailAddress alias) {
    account.aliases ??= <MailAddress>[];
    account.aliases.remove(alias);
    notifyListeners();
    return locator<MailService>().saveAccount(account);
  }

  void updateAlias(MailAddress alias) {
    notifyListeners();
  }

  List<MailAddress> get aliases => account?.aliases ?? <MailAddress>[];

  bool get hasAlias => account?.aliases?.isNotEmpty ?? false;
  bool get hasNoAlias => !hasAlias;

  String get imageUrlGravator =>
      account?.attributes[MailService.attributeGravatarImageUrl];

  bool get addsSentMailAutomatically =>
      account?.attributes[MailService.attributeSentMailAddedAutomatically] ??
      false;

  String _key;
  String get key {
    if (_key == null) {
      _key = email.toLowerCase();
    }
    return _key;
  }

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
        super(null);

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
