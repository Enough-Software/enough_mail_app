import 'package:enough_mail/enough_mail.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../account/model.dart';
import '../mail/provider.dart';

class MailboxSelector extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final mailboxTreeData = ref.watch(mailboxTreeProvider(account: account));

    return mailboxTreeData.when(
      loading: () => const Center(child: PlatformProgressIndicator()),
      error: (error, stack) => Center(child: Text('$error')),
      data: (mailboxTree) {
        final mailboxes =
            mailboxTree.flatten((box) => !(box?.isNotSelectable ?? true));
        final items = mailboxes
            .map(
              (box) =>
                  DropdownMenuItem(value: box, child: Text(box?.path ?? '')),
            )
            .toList();
        if (showRoot) {
          final first = mailboxes.first;
          if (first != null) {
            items.insert(
              0,
              DropdownMenuItem(child: Text(first.pathSeparator)),
            );
          }
        }

        return PlatformDropdownButton<Mailbox>(
          items: items,
          value: mailbox,
          onChanged: onChanged,
        );
      },
    );
  }
}
