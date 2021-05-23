import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail/mail_address.dart';
import 'package:enough_mail_app/models/compose_data.dart';
import 'package:enough_mail_app/routes.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/services/scaffold_messenger_service.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';

import '../locator.dart';

class MailAddressChip extends StatefulWidget {
  final MailAddress mailAddress;
  MailAddressChip({Key key, @required this.mailAddress}) : super(key: key);

  @override
  _MailAddressChipState createState() => _MailAddressChipState();
}

enum _AddressAction { none, copy, compose, search }

class _MailAddressChipState extends State<MailAddressChip> {
  // bool isShowingPersonalName = true;

  String getText() {
    return (widget.mailAddress.personalName?.isNotEmpty ?? false)
        ? widget.mailAddress.personalName
        : widget.mailAddress.email;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return PlatformPopupMenuButton<_AddressAction>(
      child: PlatformChip(label: Text(getText())),
      title: widget.mailAddress.hasPersonalName
          ? Text(widget.mailAddress.personalName)
          : null,
      message: Text(widget.mailAddress.email, style: theme.textTheme.caption),
      itemBuilder: (context) => [
        PlatformPopupMenuItem(
          value: _AddressAction.copy,
          child: PlatformListTile(
            leading: Icon(Icons.copy),
            title: Text(localizations.actionAddressCopy),
          ),
        ),
        PlatformPopupMenuItem(
          value: _AddressAction.compose,
          child: PlatformListTile(
            leading: Icon(Icons.add),
            title: Text(localizations.actionAddressCompose),
          ),
        ),
        PlatformPopupMenuItem(
          value: _AddressAction.search,
          child: PlatformListTile(
            leading: Icon(Icons.search),
            title: Text(localizations.actionAddressSearch),
          ),
        ),
      ],
      onSelected: (value) async {
        switch (value) {
          case _AddressAction.none:
            break;
          case _AddressAction.copy:
            Clipboard.setData(ClipboardData(text: widget.mailAddress.email));
            locator<ScaffoldMessengerService>()
                .showTextSnackBar(localizations.feedbackResultInfoCopied);
            break;
          case _AddressAction.compose:
            final messageBuilder = MessageBuilder()..to = [widget.mailAddress];
            final composeData =
                ComposeData(null, messageBuilder, ComposeAction.newMessage);
            locator<NavigationService>()
                .push(Routes.mailCompose, arguments: composeData);
            break;
          case _AddressAction.search:
            final search =
                MailSearch(widget.mailAddress.email, SearchQueryType.fromOrTo);
            final source = await locator<MailService>().search(search);
            locator<NavigationService>()
                .push(Routes.messageSource, arguments: source);
            break;
        }
      },
    );
  }
}
