import 'package:enough_mail/enough_mail.dart';

import '../account/model.dart';

class Sender {
  Sender(this.address, this.account, {this.isPlaceHolderForPlusAlias = false});
  MailAddress address;
  final RealAccount account;
  final bool isPlaceHolderForPlusAlias;

  @override
  String toString() => address.toString();
}
