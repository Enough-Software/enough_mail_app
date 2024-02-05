import 'package:enough_mail/enough_mail.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../account/provider.dart';
import '../../localization/extension.dart';
import '../../routes/routes.dart';
import '../../screens/base.dart';
import '../../widgets/text_with_links.dart';
import '../provider.dart';

class SettingsDefaultSenderScreen extends ConsumerWidget {
  const SettingsDefaultSenderScreen({super.key});

  // void initState() {
  //   final senders = locator<MailService>()
  //       .getSenders()
  //       .map((sender) => sender.address)
  //       .toList();

  //   _firstAccount = locator<I18nService>()
  //       .localizations
  //       .defaultSenderSettingsFirstAccount(senders.first.email);
  //   _senders = [null, ...senders];
  //   _selectedSender = locator<SettingsService>().settings.defaultSender;
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final localizations = ref.text;

    final defaultSender = ref.watch(
      settingsProvider.select(
        (value) => value.defaultSender,
      ),
    );

    final availableSenders =
        ref.watch(sendersProvider).map((sender) => sender.address).toList();
    final firstAccount = localizations
        .defaultSenderSettingsFirstAccount(availableSenders.first.email);
    final senders = [null, ...availableSenders];

    final aliasInfo = localizations.defaultSenderSettingsAliasInfo;
    final accountSettings =
        localizations.defaultSenderSettingsAliasAccountSettings;
    final asIndex = aliasInfo.indexOf('[AS]');
    final aliasInfoParts = [
      TextLink(aliasInfo.substring(0, asIndex)),
      TextLink.callback(
        accountSettings,
        () => context.pushNamed(Routes.settingsAccounts),
      ),
      TextLink(aliasInfo.substring(asIndex + '[AS]'.length)),
    ];

    return BasePage(
      title: localizations.defaultSenderSettingsTitle,
      content: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.defaultSenderSettingsLabel,
                  style: theme.textTheme.bodySmall,
                ),
                FittedBox(
                  child: PlatformDropdownButton<MailAddress>(
                    value: defaultSender,
                    onChanged: (value) async {
                      final settings = ref.read(settingsProvider);
                      await ref.read(settingsProvider.notifier).update(
                            settings.copyWith(defaultSender: value),
                          );
                    },
                    selectedItemBuilder: (context) => senders
                        .map(
                          (sender) => Text(sender?.toString() ?? firstAccount),
                        )
                        .toList(),
                    items: senders
                        .map(
                          (sender) => DropdownMenuItem(
                            value: sender,
                            child: Text(sender?.toString() ?? firstAccount),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: TextWithNamedLinks(
                    parts: aliasInfoParts,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
