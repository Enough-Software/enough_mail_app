import 'package:enough_html_editor/enough_html_editor.dart';
import 'package:enough_mail_app/models/account.dart';
import 'package:enough_mail_app/models/compose_data.dart';
import 'package:enough_mail_app/routes.dart';
import 'package:enough_mail_app/services/icon_service.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/services/settings_service.dart';
import 'package:enough_mail_app/util/modal_bottom_sheet_helper.dart';
import 'package:enough_mail_app/widgets/button_text.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.g.dart';
import '../locator.dart';
import 'base.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class SettingsSignatureScreen extends StatefulWidget {
  const SettingsSignatureScreen({Key? key}) : super(key: key);

  @override
  State<SettingsSignatureScreen> createState() =>
      _SettingsSignatureScreenState();
}

class _SettingsSignatureScreenState extends State<SettingsSignatureScreen> {
  final _signatureEnabledFor = <ComposeAction, bool?>{};

  @override
  void initState() {
    super.initState();
    final enabledActions = locator<SettingsService>().settings.signatureActions;
    for (final action in ComposeAction.values) {
      _signatureEnabledFor[action] = enabledActions.contains(action);
    }
  }

  String getActionName(ComposeAction action, AppLocalizations localizations) {
    switch (action) {
      case ComposeAction.answer:
        return localizations.composeTitleReply;
      case ComposeAction.forward:
        return localizations.composeTitleForward;
      case ComposeAction.newMessage:
        return localizations.composeTitleNew;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final accounts = locator<MailService>().accounts;
    final accountsWithSignature = List<RealAccount>.from(
      accounts.where(
        (account) => (account is RealAccount && account.signatureHtml != null),
      ),
    );
    return Base.buildAppChrome(
      context,
      title: localizations.signatureSettingsTitle,
      content: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(localizations.signatureSettingsComposeActionsInfo),
                for (final action in ComposeAction.values)
                  PlatformCheckboxListTile(
                    value: _signatureEnabledFor[action],
                    onChanged: (value) async {
                      setState(() {
                        _signatureEnabledFor[action] = value;
                      });
                    },
                    title: Text(getActionName(action, localizations)),
                  ),

                const Divider(),
                const SignatureWidget(), //  global signature
                if (accounts.length > 1) ...[
                  const Divider(),
                  if (accountsWithSignature.isNotEmpty)
                    for (final account in accountsWithSignature) ...[
                      Text(account.name, style: theme.textTheme.subtitle1),
                      SignatureWidget(
                        account: account,
                      ),
                      const Divider(),
                    ],
                  Text(localizations.signatureSettingsAccountInfo),
                  PlatformTextButton(
                    onPressed: () {
                      locator<NavigationService>()
                          .push(Routes.settingsAccounts);
                    },
                    child: ButtonText(localizations.settingsActionAccounts),
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

class SignatureWidget extends StatefulWidget {
  const SignatureWidget({Key? key, this.account}) : super(key: key);
  final RealAccount? account;

  @override
  State<SignatureWidget> createState() => _SignatureWidgetState();
}

class _SignatureWidgetState extends State<SignatureWidget> {
  String? _signature;

  @override
  void initState() {
    super.initState();
    final account = widget.account;
    _signature = (account != null)
        ? account.signatureHtml
        : locator<SettingsService>().getSignatureHtmlGlobal();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    if (_signature == null) {
      return PlatformListTile(
        leading: const Icon(Icons.add),
        title: Text(
          localizations
              .signatureSettingsAddForAccount(widget.account?.name ?? ''),
        ),
        onTap: _showEditor,
      );
    }
    return Stack(
      children: [
        HtmlWidget(
          _signature!,
          onTapUrl: (url) async {
            return await launcher.launchUrl(Uri.parse(url));
          },
        ),
        Align(
          alignment: Alignment.topRight,
          child: PlatformIconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditor,
          ),
        ),
      ],
    );
  }

  void _showEditor() async {
    final localizations = AppLocalizations.of(context)!;
    final iconService = locator<IconService>();
    HtmlEditorApi? editorApi;

    final result = await ModelBottomSheetHelper.showModalBottomSheet(
      context,
      widget.account?.name ?? localizations.signatureSettingsTitle,
      PackagedHtmlEditor(
        initialContent:
            _signature ?? locator<SettingsService>().getSignatureHtmlGlobal(),
        excludeDocumentLevelControls: true,
        onCreated: (api) => editorApi = api,
      ),
      appBarActions: [
        if (_signature != null)
          DensePlatformIconButton(
            icon: Icon(iconService.messageActionDelete),
            onPressed: () async {
              setState(() {
                _signature = null;
              });
              Navigator.of(context).pop(false);
              if (widget.account != null) {
                widget.account!.signatureHtml = null;
                await locator<MailService>().saveAccounts();
              } else {
                final service = locator<SettingsService>();
                service.settings = service.settings.withoutSignatures();
                _signature = service.getSignatureHtmlGlobal();
                await service.save();
              }
            },
          ),
        DensePlatformIconButton(
          icon: Icon(CommonPlatformIcons.ok),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );

    if (result && editorApi != null) {
      final newSignature = await editorApi!.getText();
      setState(() {
        _signature = newSignature;
      });
      if (widget.account == null) {
        final service = locator<SettingsService>();
        service.settings =
            service.settings.copyWith(signatureHtml: newSignature);
        await service.save();
      } else {
        widget.account!.signatureHtml = newSignature;
        locator<MailService>().saveAccounts();
      }
    }
  }
}
