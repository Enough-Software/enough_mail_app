import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/account.dart';
import 'package:enough_mail_app/services/icon_service.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';

import '../locator.dart';

class MailboxTree extends StatelessWidget {
  final Account account;
  final void Function(Mailbox mailbox) onSelected;
  final Mailbox? current;

  const MailboxTree(
      {Key? key, required this.account, required this.onSelected, this.current})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mailboxTreeData = locator<MailService>().getMailboxTreeFor(account);
    if (mailboxTreeData == null) {
      return Container();
    }
    final mailboxTreeElements = mailboxTreeData.root.children!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final element in mailboxTreeElements)
          buildMailboxElement(element, 0),
      ],
    );
  }

  Widget buildMailboxElement(TreeElement<Mailbox?> element, final int level) {
    final mailbox = element.value!;
    final title = Padding(
      padding: EdgeInsets.only(left: level * 8.0),
      child: Text(mailbox.name),
    );
    if (element.children == null) {
      final isCurrent = (mailbox == current);
      final iconData = locator<IconService>().getForMailbox(mailbox);
      return SelectablePlatformListTile(
        leading: Icon(iconData),
        title: title,
        onTap: isCurrent ? null : () => onSelected(mailbox),
        selected: isCurrent,
      );
    }
    return Material(
      child: ExpansionTile(
        title: title,
        children: [
          for (final childElement in element.children!)
            buildMailboxElement(childElement, level + 1),
        ],
      ),
    );
  }
}
