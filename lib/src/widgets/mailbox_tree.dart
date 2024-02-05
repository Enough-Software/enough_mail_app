import 'package:enough_mail/enough_mail.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../account/model.dart';
import '../localization/app_localizations.g.dart';
import '../localization/extension.dart';
import '../mail/model.dart';
import '../mail/provider.dart';
import '../settings/model.dart';
import '../settings/provider.dart';
import '../settings/theme/icon_service.dart';

/// Displays a tree of mailboxes
class MailboxTree extends ConsumerWidget {
  /// Creates a new [MailboxTree]
  const MailboxTree({
    super.key,
    required this.account,
    required this.onSelected,
    this.isReselectPossible = false,
  });

  /// The associated account
  final Account account;

  /// Callback when a mailbox is selected
  final void Function(Mailbox mailbox) onSelected;

  /// Set to true if the user should be able to reselect the current mailbox
  final bool isReselectPossible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mailboxTreeValue = ref.watch(mailboxTreeProvider(account: account));
    final currentMailbox = ref.watch(currentMailboxProvider);
    final settings = ref.watch(settingsProvider);
    final localizations = ref.text;

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
              _buildMailboxElement(
                localizations,
                settings,
                element,
                0,
                currentMailbox,
              ),
          ],
        );
      },
    );
  }

  Widget _buildMailboxElement(
    AppLocalizations localizations,
    Settings settings,
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
      child: Text(mailbox.localizedName(localizations, settings)),
    );
    final children = element.children;
    if (children == null) {
      final isCurrent =
          mailbox == current || (current == null && mailbox.isInbox);
      final iconData = IconService.instance.getForMailbox(mailbox);

      return SelectablePlatformListTile(
        leading: Icon(iconData),
        title: title,
        onTap:
            isCurrent && !isReselectPossible ? null : () => onSelected(mailbox),
        selected: isCurrent,
      );
    }

    return Material(
      child: ExpansionTile(
        title: title,
        children: [
          for (final childElement in children)
            _buildMailboxElement(
              localizations,
              settings,
              childElement,
              level + 1,
              current,
            ),
        ],
      ),
    );
  }
}
