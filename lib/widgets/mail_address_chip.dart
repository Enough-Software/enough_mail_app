import 'package:enough_mail/enough_mail.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../localization/extension.dart';
import '../locator.dart';
import '../models/compose_data.dart';
import '../routes.dart';
import '../services/mail_service.dart';
import '../services/navigation_service.dart';
import '../services/scaffold_messenger_service.dart';
import 'icon_text.dart';

class MailAddressChip extends StatelessWidget {
  const MailAddressChip({super.key, required this.mailAddress, this.icon});
  final MailAddress mailAddress;
  final Widget? icon;

  String get text => (mailAddress.hasPersonalName)
      ? mailAddress.personalName!
      : mailAddress.email;

  @override
  Widget build(BuildContext context) {
    final localizations = context.text;
    final theme = Theme.of(context);
    return PlatformPopupMenuButton<_AddressAction>(
      cupertinoButtonPadding: EdgeInsets.zero,
      icon: icon,
      title:
          mailAddress.hasPersonalName ? Text(mailAddress.personalName!) : null,
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
            locator<ScaffoldMessengerService>()
                .showTextSnackBar(localizations.feedbackResultInfoCopied);
            break;
          case _AddressAction.compose:
            final messageBuilder = MessageBuilder()..to = [mailAddress];
            final composeData =
                ComposeData(null, messageBuilder, ComposeAction.newMessage);
            await locator<NavigationService>()
                .push(Routes.mailCompose, arguments: composeData);
            break;
          case _AddressAction.search:
            final search =
                MailSearch(mailAddress.email, SearchQueryType.fromOrTo);
            final source = await locator<MailService>().search(search);
            await locator<NavigationService>()
                .push(Routes.messageSource, arguments: source);
            break;
        }
      },
      child: PlatformChip(label: Text(text)),
    );
  }
}

enum _AddressAction { none, copy, compose, search }
