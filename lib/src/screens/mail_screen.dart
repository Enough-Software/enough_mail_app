import 'package:enough_mail/enough_mail.dart';
import 'package:enough_platform_widgets/platform.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../account/model.dart';
import '../account/provider.dart';
import '../localization/extension.dart';
import '../mail/provider.dart';
import '../routes/routes.dart';
import 'base.dart';
import 'error_screen.dart';
import 'screens.dart';

/// Displays the mail for a given account
class MailScreen extends HookConsumerWidget {
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
    final text = ref.text;
    final sourceFuture = ref.watch(
      sourceProvider(
        account: account,
        mailbox: mailbox,
      ),
    );
    if (useAppDrawerAsRoot) {
      // when the app drawer is below in the widget tree,
      // set the account and mailbox:
      useMemoized(() async {
        await Future.delayed(const Duration(milliseconds: 10));
        ref.read(currentAccountProvider.notifier).state = account;
        ref.read(currentMailboxProvider.notifier).state = mailbox;
      });
    }

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
