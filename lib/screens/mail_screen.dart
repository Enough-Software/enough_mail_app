import 'package:enough_mail/enough_mail.dart';
import 'package:enough_platform_widgets/platform.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../account/model.dart';
import '../account/provider.dart';
import '../localization/extension.dart';
import '../mail/provider.dart';
import 'base.dart';
import 'error_screen.dart';
import 'screens.dart';

/// Displays the mail for a given account
class MailScreen extends ConsumerWidget {
  /// Creates a [MailScreen]
  const MailScreen({
    super.key,
    required this.account,
    this.mailbox,
    this.showSplashWhileLoading = false,
  });

  /// The account to display
  final Account account;

  /// The optional mailbox
  final Mailbox? mailbox;

  /// Should the splash screen shown while loading the message source?
  final bool showSplashWhileLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = context.text;
    final sourceFuture = ref.watch(
      sourceProvider(
        account: account,
        mailbox: mailbox,
      ),
    );
    final title =
        account is UnifiedAccount ? text.unifiedAccountName : account.name;
    final subtitle = account.fromAddress.email;

    return ProviderScope(
      overrides: [
        currentMailboxProvider.overrideWith((ref) => mailbox),
        currentAccountProvider.overrideWith((ref) => account),
      ],
      child: sourceFuture.when(
        loading: () => showSplashWhileLoading
            ? const SplashScreen()
            : BasePage(
                title: title,
                subtitle: subtitle,
                content: const Center(
                  child: PlatformProgressIndicator(),
                ),
              ),
        error: (error, stack) => ErrorScreen(
          error: error,
          stackTrace: stack,
        ),
        data: (source) => MessageSourceScreen(messageSource: source),
      ),
    );
  }
}
