import 'package:enough_mail/enough_mail.dart';
import 'package:enough_platform_widgets/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../localization/extension.dart';
import '../locator.dart';
import '../models/message_source.dart';
import '../routes.dart';
import '../services/navigation_service.dart';

/// A dedicated search field optimized for Cupertino
class CupertinoSearch extends StatelessWidget {
  const CupertinoSearch({super.key, required this.messageSource});

  final MessageSource messageSource;

  @override
  Widget build(BuildContext context) {
    final localizations = context.text;
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
