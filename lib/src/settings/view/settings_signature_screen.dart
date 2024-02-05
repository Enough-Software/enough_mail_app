import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../account/model.dart';
import '../../account/provider.dart';
import '../../localization/extension.dart';
import '../../models/compose_data.dart';
import '../../routes/routes.dart';
import '../../screens/base.dart';
import '../../widgets/signature.dart';
import '../provider.dart';

class SettingsSignatureScreen extends HookConsumerWidget {
  const SettingsSignatureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signatureActions = ref.watch(
      settingsProvider.select(
        (value) => value.signatureActions,
      ),
    );
    final signatureEnabledFor = useMemoized(() {
      final result = <ComposeAction, bool>{};
      for (final action in ComposeAction.values) {
        result[action] = signatureActions.contains(action);
      }

      return result;
    });

    final theme = Theme.of(context);
    final localizations = ref.text;
    final accounts = ref.read(realAccountsProvider);
    final accountsWithSignature = List<RealAccount>.from(
      accounts.where(
        (account) => account.getSignatureHtml(localizations.localeName) != null,
      ),
    );
    String getActionName(ComposeAction action) {
      switch (action) {
        case ComposeAction.answer:
          return localizations.composeTitleReply;
        case ComposeAction.forward:
          return localizations.composeTitleForward;
        case ComposeAction.newMessage:
          return localizations.composeTitleNew;
      }
    }

    return BasePage(
      title: localizations.signatureSettingsTitle,
      content: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(localizations.signatureSettingsComposeActionsInfo),
                for (final action in ComposeAction.values)
                  PlatformCheckboxListTile(
                    value: signatureEnabledFor[action],
                    onChanged: (value) {
                      if (value != null) {
                        // TODO(RV): check if this is actually updated
                        signatureEnabledFor[action] = value;
                        ref.read(settingsProvider.notifier).update(
                              ref.read(settingsProvider).copyWith(
                                    signatureActions: value
                                        ? signatureActions + [action]
                                        : signatureActions
                                            .where((a) => a != action)
                                            .toList(),
                                  ),
                            );
                      }
                    },
                    title: Text(getActionName(action)),
                  ),

                const Divider(),
                const SignatureWidget(), //  global signature
                if (accounts.length > 1) ...[
                  const Divider(),
                  if (accountsWithSignature.isNotEmpty)
                    for (final account in accountsWithSignature) ...[
                      Text(account.name, style: theme.textTheme.titleMedium),
                      SignatureWidget(
                        account: account,
                      ),
                      const Divider(),
                    ],
                  Text(localizations.signatureSettingsAccountInfo),
                  PlatformTextButton(
                    onPressed: () {
                      context.pushNamed(Routes.settingsAccounts);
                    },
                    child: Text(localizations.settingsActionAccounts),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
