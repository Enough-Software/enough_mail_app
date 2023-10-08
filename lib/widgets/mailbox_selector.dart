import 'package:enough_mail/enough_mail.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';

import '../account/model.dart';
import '../locator.dart';
import '../services/mail_service.dart';

class MailboxSelector extends StatelessWidget {
  const MailboxSelector({
    super.key,
    required this.account,
    this.showRoot = true,
    this.mailbox,
    required this.onChanged,
  });
  final Account account;
  final bool showRoot;
  final Mailbox? mailbox;
  final void Function(Mailbox? mailbox) onChanged;

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
