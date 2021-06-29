import 'package:enough_mail_app/extensions/extensions.dart';
import 'package:enough_mail_app/models/account.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/services/settings_service.dart';
import 'package:enough_mail_app/util/localized_dialog_helper.dart';
import 'package:enough_mail_app/widgets/button_text.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../locator.dart';
import 'base.dart';

class SettingsDeveloperModeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingsDeveloperModeScreenState();
  }
}

class _SettingsDeveloperModeScreenState
    extends State<SettingsDeveloperModeScreen> {
  bool? isDeveloperModeEnabled = false;

  @override
  void initState() {
    isDeveloperModeEnabled =
        locator<SettingsService>().settings.enableDeveloperMode;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    return Base.buildAppChrome(
      context,
      title: localizations.settingsDevelopment,
      content: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(localizations.developerModeTitle,
                    style: theme.textTheme.subtitle1),
                Text(localizations.developerModeIntroduction,
                    style: theme.textTheme.caption),
                PlatformCheckboxListTile(
                  value: isDeveloperModeEnabled,
                  onChanged: (value) async {
                    setState(() {
                      isDeveloperModeEnabled = value;
                    });
                    final service = locator<SettingsService>();
                    service.settings.enableDeveloperMode = value;
                    await service.save();
                  },
                  title: Text(localizations.developerModeEnable),
                ),
                Divider(),
                Text(localizations.extensionsTitle,
                    style: theme.textTheme.subtitle1),
                Text(localizations.extensionsIntro,
                    style: theme.textTheme.caption),
                PlatformTextButton(
                  child: ButtonText(localizations.extensionsLearnMoreAction),
                  onPressed: () => launch(
                      'https://github.com/Enough-Software/enough_mail_app/wiki/Extensions'),
                ),
                PlatformListTile(
                  title: Text(localizations.extensionsReloadAction),
                  onTap: _reloadExtensions,
                ),
                PlatformListTile(
                  title: Text(localizations.extensionDeactivateAllAction),
                  onTap: _deactivateAllExtensions,
                ),
                PlatformListTile(
                  title: Text(localizations.extensionsManualAction),
                  onTap: _loadExtensionManually,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _loadExtensionManually() async {
    final localizations = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    String? url;
    final NavigationService? navService = locator<NavigationService>();
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
          onPressed: () => navService!.pop(false),
        ),
        PlatformTextButton(
          child: ButtonText(localizations.actionOk),
          onPressed: () {
            url = controller.text.trim();
            navService!.pop(true);
          },
        ),
      ],
    );
    // controller.dispose();
    if (result == true) {
      if (url!.length > 4) {
        if (url!.indexOf(':') == -1) {
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
          var account = locator<MailService>().currentAccount!;
          if (account.isVirtual) {
            account = locator<MailService>().accounts.first;
          }
          account.appExtensions = [appExtension];
          _showExtensionDetails(url, appExtension);
        } else {
          await LocalizedDialogHelper.showTextDialog(
            context,
            localizations.errorTitle,
            localizations.extensionsManualLoardingError(url!),
          );
        }
      } else {
        await LocalizedDialogHelper.showTextDialog(
            context, localizations.errorTitle, 'Invalid URL "$url"');
      }
    }
  }

  void _deactivateAllExtensions() {
    final accounts = locator<MailService>().accounts;
    for (final account in accounts) {
      account.appExtensions = [];
    }
  }

  void _reloadExtensions() async {
    final localizations = AppLocalizations.of(context)!;
    final accounts = locator<MailService>().accounts;
    final domains = <_AccountDomain>[];
    for (final account in accounts) {
      account.appExtensions = [];
      _addEmail(account, account.email, domains);
      _addHostname(
          account, account.account.incoming!.serverConfig!.hostname!, domains);
      _addHostname(
          account, account.account.outgoing!.serverConfig!.hostname!, domains);
    }
    LocalizedDialogHelper.showWidgetDialog(
      context,
      SingleChildScrollView(
        child: Column(
          children: [
            for (final domain in domains) ...{
              PlatformListTile(
                title: Text(domain.domain),
                subtitle: Text(AppExtension.urlFor(domain.domain)),
                trailing: FutureBuilder<AppExtension?>(
                  future: domain.future,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      domain.account!.appExtensions!.add(snapshot.data);
                      return PlatformIconButton(
                        icon: Icon(Icons.check),
                        onPressed: () => _showExtensionDetails(
                            domain.domain, snapshot.data!),
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.done) {
                      return Icon(Icons.cancel_outlined);
                    }
                    return PlatformProgressIndicator();
                  },
                ),
              ),
            },
          ],
        ),
      ),
      title: localizations.extensionsTitle,
    );
  }

  void _addEmail(Account? account, String email, List<_AccountDomain> domains) {
    _addDomain(account, email.substring(email.indexOf('@') + 1), domains);
  }

  void _addHostname(
      Account? account, String hostname, List<_AccountDomain> domains) {
    final domainIndex = hostname.indexOf('.');
    if (domainIndex != -1) {
      _addDomain(account, hostname.substring(domainIndex + 1), domains);
    }
  }

  void _addDomain(
      Account? account, String domain, List<_AccountDomain> domains) {
    if (!domains.any((k) => k.domain == domain)) {
      domains
          .add(_AccountDomain(account, domain, AppExtension.loadFrom(domain)));
    }
  }

  void _showExtensionDetails(String? domainOrUrl, AppExtension data) {
    LocalizedDialogHelper.showWidgetDialog(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Version: ${data.version}'),
          if (data.accountSideMenu != null) ...{
            Divider(),
            Text('Account side menus:'),
            for (final entry in data.accountSideMenu!) ...{
              Text('"${entry.getLabel('en')}": ${entry.action!.url}'),
            },
          },
          if (data.forgotPasswordAction != null) ...{
            Divider(),
            Text('Forgot password:'),
            Text(
                '"${data.forgotPasswordAction!.getLabel('en')}": ${data.forgotPasswordAction!.action!.url}'),
          },
          if (data.signatureHtml != null) ...{
            Divider(),
            Text('Signature:'),
            Text('${data.getSignatureHtml('en')}'),
          },
        ],
      ),
      title: '$domainOrUrl Extension',
    );
  }
}

class _AccountDomain {
  final Account? account;
  final String domain;
  final Future<AppExtension?> future;

  _AccountDomain(this.account, this.domain, this.future);
}
