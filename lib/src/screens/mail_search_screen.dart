import 'package:enough_mail/enough_mail.dart';
import 'package:enough_platform_widgets/platform.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../localization/extension.dart';
import '../mail/provider.dart';
import 'base.dart';
import 'message_source_screen.dart';

/// Displays the search result for
class MailSearchScreen extends ConsumerWidget {
  /// Creates a [MailSearchScreen]
  const MailSearchScreen({
    super.key,
    required this.search,
  });

  /// The account to display
  final MailSearch search;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.text;
    final searchSource = ref.watch(
      mailSearchProvider(
        localizations: text,
        search: search,
      ),
    );

    return searchSource.when(
      loading: () => BasePage(
        title: text.searchQueryTitle(search.query),
        content: const Center(
          child: PlatformProgressIndicator(),
        ),
      ),
      error: (error, stack) => BasePage(
        title: text.searchQueryTitle(search.query),
        content: Center(child: Text('$error')),
      ),
      data: (source) => MessageSourceScreen(messageSource: source),
    );
  }
}
