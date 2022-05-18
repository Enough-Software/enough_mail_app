import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/compose_data.dart';
import 'package:enough_mail_app/routes.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/services/scaffold_messenger_service.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.g.dart';
import 'package:flutter/services.dart';

import '../locator.dart';
import 'icon_text.dart';

class MailAddressChip extends StatelessWidget {
  final MailAddress mailAddress;
  final Widget? icon;
  const MailAddressChip({Key? key, required this.mailAddress, this.icon})
      : super(key: key);

  String get text => (mailAddress.hasPersonalName)
      ? mailAddress.personalName!
      : mailAddress.email;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return PlatformPopupMenuButton<_AddressAction>(
      cupertinoButtonPadding: EdgeInsets.zero,
      icon: icon,
      title:
          mailAddress.hasPersonalName ? Text(mailAddress.personalName!) : null,
      message: Text(mailAddress.email, style: theme.textTheme.caption),
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
            Clipboard.setData(ClipboardData(text: mailAddress.email));
            locator<ScaffoldMessengerService>()
                .showTextSnackBar(localizations.feedbackResultInfoCopied);
            break;
          case _AddressAction.compose:
            final messageBuilder = MessageBuilder()..to = [mailAddress];
            final composeData =
                ComposeData(null, messageBuilder, ComposeAction.newMessage);
            locator<NavigationService>()
                .push(Routes.mailCompose, arguments: composeData);
            break;
          case _AddressAction.search:
            final search =
                MailSearch(mailAddress.email, SearchQueryType.fromOrTo);
            final source = await locator<MailService>().search(search);
            locator<NavigationService>()
                .push(Routes.messageSource, arguments: source);
            break;
        }
      },
      child: PlatformChip(label: Text(text)),
    );
  }
}

enum _AddressAction { none, copy, compose, search }
