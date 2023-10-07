import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../extensions/extensions.dart';
import '../../l10n/extension.dart';
import '../../locator.dart';
import '../../models/account.dart';
import '../../screens/base.dart';
import '../../services/mail_service.dart';
import '../../services/navigation_service.dart';
import '../../util/localized_dialog_helper.dart';
import '../../widgets/button_text.dart';
import '../provider.dart';

class SettingsDeveloperModeScreen extends HookConsumerWidget {
  const SettingsDeveloperModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final localizations = context.text;
    final isDeveloperModeEnabled = ref.watch(
      settingsProvider.select(
        (value) => value.enableDeveloperMode,
      ),
    );

    final developerModeState = useState(isDeveloperModeEnabled);

    return Base.buildAppChrome(
      context,
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
                  child: ButtonText(localizations.extensionsLearnMoreAction),
                  onPressed: () => launchUrl(
                    Uri.parse(
                      'https://github.com/Enough-Software/enough_mail_app/wiki/Extensions',
                    ),
                  ),
                ),
                PlatformListTile(
                  title: Text(localizations.extensionsReloadAction),
                  onTap: () => _reloadExtensions(context),
                ),
                PlatformListTile(
                  title: Text(localizations.extensionDeactivateAllAction),
                  onTap: _deactivateAllExtensions,
                ),
                PlatformListTile(
                  title: Text(localizations.extensionsManualAction),
                  onTap: () => _loadExtensionManually(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadExtensionManually(BuildContext context) async {
    final localizations = context.text;
    final controller = TextEditingController();
    String? url;
    final NavigationService navService = locator<NavigationService>();
    final result = await LocalizedDialogHelper.showWidgetDialog(
      context,
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
          child: ButtonText(localizations.actionCancel),
          onPressed: () => navService.pop(false),
        ),
        PlatformTextButton(
          child: ButtonText(localizations.actionOk),
          onPressed: () {
            url = controller.text.trim();
            navService.pop(true);
          },
        ),
      ],
    );
    // controller.dispose();
    if (result == true && url != null) {
      if (url!.length > 4) {
        if (!url!.contains(':')) {
          url = 'https://$url';
        }
        if (!url!.endsWith('json')) {
          if (url!.endsWith('/')) {
            url = '$url.maily.json';
          } else {
            url = '$url/.maily.json';
          }
        }
        final appExtension = await AppExtension.loadFromUrl(url!);
        if (appExtension != null) {
          final currentAccount = locator<MailService>().currentAccount;
          final account = (currentAccount is RealAccount
                  ? currentAccount
                  : locator<MailService>()
                      .accounts
                      .firstWhere((account) => account is RealAccount))
              as RealAccount;
          account.appExtensions = [appExtension];
          if (context.mounted) {
            _showExtensionDetails(context, url, appExtension);
          }
        } else if (context.mounted) {
          await LocalizedDialogHelper.showTextDialog(
            context,
            localizations.errorTitle,
            localizations.extensionsManualLoadingError(url!),
          );
        }
      } else if (context.mounted) {
        await LocalizedDialogHelper.showTextDialog(
            context, localizations.errorTitle, 'Invalid URL "$url"');
      }
    }
  }

  void _deactivateAllExtensions() {
    final accounts = locator<MailService>().accounts;
    for (final account in accounts) {
      if (account is RealAccount) {
        account.appExtensions = [];
      }
    }
  }

  Future<void> _reloadExtensions(BuildContext context) async {
    final localizations = context.text;
    final accounts = locator<MailService>().accounts;
    final domains = <_AccountDomain>[];
    for (final account in accounts) {
      if (account is RealAccount) {
        account.appExtensions = [];
        _addEmail(account, account.email, domains);
        _addHostname(account,
            account.mailAccount.incoming.serverConfig.hostname!, domains);
        _addHostname(account,
            account.mailAccount.outgoing.serverConfig.hostname!, domains);
      }
    }
    await LocalizedDialogHelper.showWidgetDialog(
      context,
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
                    if (snapshot.hasData) {
                      domain.account!.appExtensions!.add(snapshot.data!);
                      return PlatformIconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () => _showExtensionDetails(
                          context,
                          domain.domain,
                          snapshot.data!,
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
      RealAccount? account, String email, List<_AccountDomain> domains) {
    _addDomain(account, email.substring(email.indexOf('@') + 1), domains);
  }

  void _addHostname(
      RealAccount? account, String hostname, List<_AccountDomain> domains) {
    final domainIndex = hostname.indexOf('.');
    if (domainIndex != -1) {
      _addDomain(account, hostname.substring(domainIndex + 1), domains);
    }
  }

  void _addDomain(
      RealAccount? account, String domain, List<_AccountDomain> domains) {
    if (!domains.any((k) => k.domain == domain)) {
      domains
          .add(_AccountDomain(account, domain, AppExtension.loadFrom(domain)));
    }
  }

  void _showExtensionDetails(
    BuildContext context,
    String? domainOrUrl,
    AppExtension data,
  ) {
    LocalizedDialogHelper.showWidgetDialog(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Version: ${data.version}'),
          if (data.accountSideMenu != null) ...[
            const Divider(),
            const Text('Account side menus:'),
            for (final entry in data.accountSideMenu!)
              Text('"${entry.getLabel('en')}": ${entry.action!.url}'),
          ],
          if (data.forgotPasswordAction != null) ...[
            const Divider(),
            const Text('Forgot password:'),
            Text(
                '"${data.forgotPasswordAction!.getLabel('en')}": ${data.forgotPasswordAction!.action!.url}'),
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
