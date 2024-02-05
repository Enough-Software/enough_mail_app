import 'package:enough_mail/enough_mail.dart';
import 'package:enough_platform_widgets/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../localization/extension.dart';
import '../models/message_source.dart';
import '../routes/routes.dart';

/// A dedicated search field optimized for Cupertino
class CupertinoSearch extends ConsumerWidget {
  /// Creates a new [CupertinoSearch]
  const CupertinoSearch({super.key, required this.messageSource});

  /// The source in which should be searched
  final MessageSource messageSource;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = ref.text;

    return CupertinoSearchFlowTextField(
      onSubmitted: (text) => _onSearchSubmitted(ref, text.trim()),
      cancelText: localizations.actionCancel,
    );
  }

  void _onSearchSubmitted(WidgetRef ref, String text) {
    if (text.isEmpty) {
      return;
    }
    final search = MailSearch(text, SearchQueryType.allTextHeaders);
    final next = messageSource.search(ref.text, search);
    ref.context.pushNamed(
      Routes.messageSource,
      pathParameters: {
        Routes.pathParameterEmail: messageSource.account.email,
      },
      extra: next,
    );
  }
}
