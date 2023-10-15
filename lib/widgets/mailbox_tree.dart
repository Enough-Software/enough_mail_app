import 'package:enough_mail/enough_mail.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../account/model.dart';
import '../locator.dart';
import '../mail/provider.dart';
import '../services/icon_service.dart';

class MailboxTree extends ConsumerWidget {
  const MailboxTree({
    super.key,
    required this.account,
    required this.onSelected,
  });

  final Account account;
  final void Function(Mailbox mailbox) onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mailboxTreeValue = ref.watch(mailboxTreeProvider(account: account));
    final currentMailbox = ref.watch(currentMailboxProvider);

    return mailboxTreeValue.when(
      loading: () => Center(
        child: PlatformCircularProgressIndicator(),
      ),
      error: (error, stacktrace) => Center(child: Text('$error')),
      data: (tree) {
        final mailboxTreeElements = tree.root.children;
        if (mailboxTreeElements == null) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final element in mailboxTreeElements)
              _buildMailboxElement(element, 0, currentMailbox),
          ],
        );
      },
    );
  }

  Widget _buildMailboxElement(
    TreeElement<Mailbox?> element,
    final int level,
    Mailbox? current,
  ) {
    final mailbox = element.value;
    if (mailbox == null) {
      return const SizedBox.shrink();
    }

    final title = Padding(
      padding: EdgeInsets.only(left: level * 8.0),
      child: Text(mailbox.name),
    );
    final children = element.children;
    if (children == null) {
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
          for (final childElement in children)
            _buildMailboxElement(childElement, level + 1, current),
        ],
      ),
    );
  }
}
