import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/account.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';

import '../locator.dart';

class MailboxSelector extends StatelessWidget {
  final Account account;
  final bool showRoot;
  final Mailbox? mailbox;
  final void Function(Mailbox? mailbox) onChanged;
  const MailboxSelector({
    Key? key,
    required this.account,
    this.showRoot = true,
    this.mailbox,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mailboxTreeData = locator<MailService>().getMailboxTreeFor(account)!;
    final mailboxes = mailboxTreeData.flatten((box) => !box!.isNotSelectable);
    final items = mailboxes
        .map((box) => DropdownMenuItem(value: box, child: Text(box!.path)))
        .toList();
    if (showRoot) {
      items.insert(
        0,
        DropdownMenuItem(child: Text(mailboxes.first!.pathSeparator)),
      );
    }
    return PlatformDropdownButton<Mailbox>(
      items: items,
      value: mailbox,
      onChanged: onChanged,
    );
  }
}
