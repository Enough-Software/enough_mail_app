import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/cupertino.dart';

class User with ChangeNotifier {
  String? _name;
  String? get name => _name;
  set name(String? value) {
    _name = value;
    notifyListeners();
  }

  List<MailAccount> accounts = <MailAccount>[];
}
