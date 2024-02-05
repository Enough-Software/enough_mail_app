import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../account/model.dart';
import '../../account/provider.dart';
import '../../extensions/extensions.dart';
import '../../localization/extension.dart';
import '../../screens/base.dart';
import '../../util/localized_dialog_helper.dart';
import '../provider.dart';

/// A screen to configure the developer mode.
class SettingsDeveloperModeScreen extends HookConsumerWidget {
  /// Creates a new [SettingsDeveloperModeScreen].
  const SettingsDeveloperModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final localizations = ref.text;
    final isDeveloperModeEnabled = ref.watch(
      settingsProvider.select(
        (value) => value.enableDeveloperMode,
      ),
    );

    final developerModeState = useState(isDeveloperModeEnabled);

    return BasePage(
      title: localizations.settingsDevelopment,
      content: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.developerModeTitle,
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  localizations.developerModeIntroduction,
                  style: theme.textTheme.bodySmall,
                ),
                PlatformCheckboxListTile(
                  value: isDeveloperModeEnabled,
                  onChanged: (value) async {
                    developerModeState.value = value ?? false;
                    final settings = ref.read(settingsProvider);
                    await ref.read(settingsProvider.notifier).update(
                          settings.copyWith(
                            enableDeveloperMode: value ?? false,
                          ),
                        );
                  },
                  title: Text(localizations.developerModeEnable),
                ),
                const Divider(),
                Text(
                  localizations.extensionsTitle,
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  localizations.extensionsIntro,
                  style: theme.textTheme.bodySmall,
                ),
                PlatformTextButton(
                  child: Text(localizations.extensionsLearnMoreAction),
                  onPressed: () => launchUrl(
                    Uri.parse(
                      'https://github.com/Enough-Software/enough_mail_app/wiki/Extensions',
                    ),
                  ),
                ),
                PlatformListTile(
                  title: Text(localizations.extensionsReloadAction),
                  onTap: () => _reloadExtensions(context, ref),
                ),
                PlatformListTile(
                  title: Text(localizations.extensionDeactivateAllAction),
                  onTap: () => _deactivateAllExtensions(ref),
                ),
                PlatformListTile(
                  title: Text(localizations.extensionsManualAction),
                  onTap: () => _loadExtensionManually(context, ref),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadExtensionManually(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final localizations = ref.text;
    final controller = TextEditingController();
    final url = await LocalizedDialogHelper.showWidgetDialog<String>(
      ref,
      DecoratedPlatformTextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: localizations.extensionsManualUrlLabel,
        ),
        keyboardType: TextInputType.url,
      ),
      title: localizations.extensionsManualAction,
      actions: [
        PlatformTextButton(
          child: Text(localizations.actionCancel),
          onPressed: () => context.pop(),
        ),
        PlatformTextButton(
          child: Text(localizations.actionOk),
          onPressed: () {
            final urlText = controller.text.trim();
            context.pop(urlText);
          },
        ),
      ],
    );
    // controller.dispose();
    if (url != null) {
      var usedUrl = url;
      if (url.length > 4) {
        if (!url.contains(':')) {
          usedUrl = 'https://$url';
        }
        if (!url.endsWith('json')) {
          usedUrl = url.endsWith('/') ? '$url.maily.json' : '$url/.maily.json';
        }
        final appExtension = await AppExtension.loadFromUrl(usedUrl);
        if (appExtension != null) {
          final currentAccount = ref.read(currentAccountProvider);
          ((currentAccount is RealAccount)
                  ? currentAccount
                  : ref.read(realAccountsProvider).first)
              .appExtensions = [appExtension];
          if (context.mounted) {
            _showExtensionDetails(context, ref, url, appExtension);
          }
          await ref.read(realAccountsProvider.notifier).save();
        } else if (context.mounted) {
          await LocalizedDialogHelper.showTextDialog(
            ref,
            localizations.errorTitle,
            localizations.extensionsManualLoadingError(url),
          );
        }
      } else if (context.mounted) {
        await LocalizedDialogHelper.showTextDialog(
          ref,
          localizations.errorTitle,
          'Invalid URL "$url"',
        );
      }
    }
  }

  void _deactivateAllExtensions(WidgetRef ref) {
    final accounts = ref.read(realAccountsProvider);
    for (final account in accounts) {
      account.appExtensions = [];
    }
    ref.read(realAccountsProvider.notifier).save();
  }

  Future<void> _reloadExtensions(BuildContext context, WidgetRef ref) async {
    final localizations = ref.text;
    final accounts = ref.read(realAccountsProvider);
    final domains = <_AccountDomain>[];
    for (final account in accounts) {
      account.appExtensions = [];
      _addEmail(account, account.email, domains);
      _addHostname(
        account,
        account.mailAccount.incoming.serverConfig.hostname,
        domains,
      );
      _addHostname(
        account,
        account.mailAccount.outgoing.serverConfig.hostname,
        domains,
      );
    }
    await LocalizedDialogHelper.showWidgetDialog(
      ref,
      SingleChildScrollView(
        child: Column(
          children: [
            for (final domain in domains)
              PlatformListTile(
                title: Text(domain.domain),
                subtitle: Text(AppExtension.urlFor(domain.domain)),
                trailing: FutureBuilder<AppExtension?>(
                  future: domain.future,
                  builder: (context, snapshot) {
                    final data = snapshot.data;
                    if (data != null) {
                      domain.account?.appExtensions?.add(data);

                      return PlatformIconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () => _showExtensionDetails(
                          context,
                          ref,
                          domain.domain,
                          data,
                        ),
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.done) {
                      return const Icon(Icons.cancel_outlined);
                    }

                    return const PlatformProgressIndicator();
                  },
                ),
              ),
          ],
        ),
      ),
      title: localizations.extensionsTitle,
    );
  }

  void _addEmail(
    RealAccount? account,
    String email,
    List<_AccountDomain> domains,
  ) {
    _addDomain(account, email.substring(email.indexOf('@') + 1), domains);
  }

  void _addHostname(
    RealAccount? account,
    String hostname,
    List<_AccountDomain> domains,
  ) {
    final domainIndex = hostname.indexOf('.');
    if (domainIndex != -1) {
      _addDomain(account, hostname.substring(domainIndex + 1), domains);
    }
  }

  void _addDomain(
    RealAccount? account,
    String domain,
    List<_AccountDomain> domains,
  ) {
    if (!domains.any((k) => k.domain == domain)) {
      domains
          .add(_AccountDomain(account, domain, AppExtension.loadFrom(domain)));
    }
  }

  void _showExtensionDetails(
    BuildContext context,
    WidgetRef ref,
    String? domainOrUrl,
    AppExtension data,
  ) {
    final accountSideMenu = data.accountSideMenu;
    final forgotPasswordAction = data.forgotPasswordAction;

    LocalizedDialogHelper.showWidgetDialog(
      ref,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Version: ${data.version}'),
          if (accountSideMenu != null) ...[
            const Divider(),
            const Text('Account side menus:'),
            for (final entry in accountSideMenu)
              Text('"${entry.getLabel('en')}": ${entry.action?.url}'),
          ],
          if (forgotPasswordAction != null) ...[
            const Divider(),
            const Text('Forgot password:'),
            Text(
              '"${forgotPasswordAction.getLabel('en')}": '
              '${forgotPasswordAction.action?.url}',
            ),
          ],
          if (data.signatureHtml != null) ...[
            const Divider(),
            const Text('Signature:'),
            Text('${data.getSignatureHtml('en')}'),
          ],
        ],
      ),
      title: '$domainOrUrl Extension',
    );
  }
}

class _AccountDomain {
  _AccountDomain(this.account, this.domain, this.future);
  final RealAccount? account;
  final String domain;
  final Future<AppExtension?> future;
}
