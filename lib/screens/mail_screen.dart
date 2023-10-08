import 'package:enough_platform_widgets/platform.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../account/model.dart';
import '../localization/extension.dart';
import '../mail/provider.dart';
import 'base.dart';
import 'message_source_screen.dart';

/// Displays the mail for a given account
class MailScreen extends ConsumerWidget {
  /// Creates a [MailScreen]
  const MailScreen({super.key, required this.account});

  /// The account to display
  final Account account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = context.text;
    final sourceFuture = ref.watch(sourceProvider(account: account));
    final title =
        account is UnifiedAccount ? text.unifiedAccountName : account.name;
    final subtitle = account.fromAddress.email;

    return sourceFuture.when(
      loading: () => BasePage(
        title: title,
        subtitle: subtitle,
        content: const Center(
          child: PlatformProgressIndicator(),
        ),
      ),
      error: (error, stack) => BasePage(
        title: title,
        subtitle: subtitle,
        content: Center(child: Text('$error')),
      ),
      data: (source) => MessageSourceScreen(messageSource: source),
    );
  }
}
