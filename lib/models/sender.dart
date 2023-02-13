import 'package:enough_mail/enough_mail.dart';
import 'account.dart';

class Sender {
  MailAddress address;
  final RealAccount account;
  final bool isPlaceHolderForPlusAlias;

  Sender(this.address, this.account, {this.isPlaceHolderForPlusAlias = false});

  @override
  String toString() {
    return address.toString();
  }
}
