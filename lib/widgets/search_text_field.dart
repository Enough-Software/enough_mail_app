import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/message_source.dart';
import 'package:enough_mail_app/routes.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_platform_widgets/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.g.dart';
import '../locator.dart';

/// A dedicated search field optimized for Cupertino
class CupertinoSearch extends StatelessWidget {
  const CupertinoSearch({Key? key, required this.messageSource})
      : super(key: key);

  final MessageSource messageSource;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return CupertinoSearchFlowTextField(
        onSubmitted: _onSearchSubmitted,
        cancelText: localizations.actionCancel);
  }

  void _onSearchSubmitted(String text) {
    final search = MailSearch(text, SearchQueryType.allTextHeaders);
    final next = messageSource.search(search);
    locator<NavigationService>().push(
      Routes.messageSource,
      arguments: next,
    );
  }
}
