import 'package:enough_mail/mail_address.dart';
import 'package:flutter/material.dart';

//TODO show contact action sheet, ie copy email, write message, add contact, ignore, call, ...
class MailAddressChip extends StatefulWidget {
  final MailAddress mailAddress;
  MailAddressChip({Key key, @required this.mailAddress}) : super(key: key);

  @override
  _MailAddressChipState createState() => _MailAddressChipState();
}

class _MailAddressChipState extends State<MailAddressChip> {
  bool isShowingPersonalName = true;

  String getText() {
    return isShowingPersonalName &&
            (widget.mailAddress.personalName?.isNotEmpty ?? false)
        ? widget.mailAddress.personalName
        : widget.mailAddress.email;
  }

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(getText()),
      onPressed: handleOnPressed,
      visualDensity: VisualDensity.comfortable,
    );
  }

  void handleOnPressed() {
    setState(() {
      isShowingPersonalName = !isShowingPersonalName;
    });
  }
}
