import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../account/provider.dart';
import '../mail/provider.dart';
import 'base.dart';
import 'error_screen.dart';
import 'screens.dart';

/// Displays the mail for a given account
class EMailScreen extends ConsumerWidget {
  /// Creates a [EMailScreen]
  const EMailScreen({super.key, required this.email, this.encodedMailboxPath});

  /// The email of the account to display
  final String email;

  /// The optional mailbox encoded path
  final String? encodedMailboxPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(findAccountByEmailProvider(email: email));
    final encodedMailboxPath = this.encodedMailboxPath;

    if (account == null) {
      if (ref.read(realAccountsProvider).isEmpty) {
        return const WelcomeScreen();
      }

      return const MailScreenForDefaultAccount();
    }

    if (encodedMailboxPath == null) {
      return MailScreen(
        account: account,
      );
    }

    final mailboxValue = ref.watch(
      findMailboxProvider(
        account: account,
        encodedMailboxPath: encodedMailboxPath,
      ),
    );

    return mailboxValue.when(
      loading: () => const BasePage(
        content: Center(
          child: PlatformProgressIndicator(),
        ),
      ),
      error: (error, stack) => ErrorScreen(error: error, stackTrace: stack),
      data: (mailbox) => MailScreen(
        account: account,
        mailbox: mailbox,
      ),
    );
  }
}
