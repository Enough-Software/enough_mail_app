import 'dart:async';

import 'package:enough_mail/enough_mail.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../localization/extension.dart';
import '../models/compose_data.dart';
import '../routes/routes.dart';
import '../scaffold_messenger/service.dart';
import 'icon_text.dart';

class MailAddressChip extends ConsumerWidget {
  const MailAddressChip({super.key, required this.mailAddress, this.icon});
  final MailAddress mailAddress;
  final Widget? icon;

  String get nameOrEmail => (mailAddress.hasPersonalName)
      ? mailAddress.personalName ?? mailAddress.email
      : mailAddress.email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = ref.text;
    final theme = Theme.of(context);

    return PlatformPopupMenuButton<_AddressAction>(
      cupertinoButtonPadding: EdgeInsets.zero,
      icon: icon,
      title: mailAddress.hasPersonalName ? Text(nameOrEmail) : null,
      message: Text(mailAddress.email, style: theme.textTheme.bodySmall),
      itemBuilder: (context) => [
        PlatformPopupMenuItem(
          value: _AddressAction.copy,
          child: IconText(
            icon: Icon(CommonPlatformIcons.copy),
            label: Text(localizations.actionAddressCopy),
          ),
        ),
        PlatformPopupMenuItem(
          value: _AddressAction.compose,
          child: IconText(
            icon: Icon(CommonPlatformIcons.add),
            label: Text(localizations.actionAddressCompose),
          ),
        ),
        PlatformPopupMenuItem(
          value: _AddressAction.search,
          child: IconText(
            icon: const Icon(Icons.search),
            label: Text(localizations.actionAddressSearch),
          ),
        ),
      ],
      onSelected: (value) async {
        switch (value) {
          case _AddressAction.none:
            break;
          case _AddressAction.copy:
            await Clipboard.setData(ClipboardData(text: mailAddress.email));
            ScaffoldMessengerService.instance.showTextSnackBar(
              localizations,
              localizations.feedbackResultInfoCopied,
            );
            break;
          case _AddressAction.compose:
            final messageBuilder = MessageBuilder()..to = [mailAddress];
            final composeData =
                ComposeData(null, messageBuilder, ComposeAction.newMessage);
            if (context.mounted) {
              unawaited(
                context.pushNamed(Routes.mailCompose, extra: composeData),
              );
            }
            break;
          case _AddressAction.search:
            final search = MailSearch(
              mailAddress.email,
              SearchQueryType.fromOrTo,
            );
            if (context.mounted) {
              unawaited(
                context.pushNamed(Routes.mailSearch, extra: search),
              );
            }
            break;
        }
      },
      child: PlatformChip(label: Text(nameOrEmail)),
    );
  }
}

enum _AddressAction { none, copy, compose, search }
