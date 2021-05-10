import 'package:enough_html_editor/enough_html_editor.dart';
import 'package:enough_mail_app/models/account.dart';
import 'package:enough_mail_app/models/compose_data.dart';
import 'package:enough_mail_app/routes.dart';
import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/services/settings_service.dart';
import 'package:enough_mail_app/util/dialog_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../locator.dart';
import 'base.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class SettingsSignatureScreen extends StatefulWidget {
  @override
  _SettingsSignatureScreenState createState() =>
      _SettingsSignatureScreenState();
}

class _SettingsSignatureScreenState extends State<SettingsSignatureScreen> {
  final _signatureEnabledFor = <ComposeAction, bool>{};

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
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final accounts = locator<MailService>().accounts;
    final accountsWithSignature =
        accounts.where((account) => (account.signatureHtml != null));
    return Base.buildAppChrome(
      context,
      title: localizations.signatureSettingsTitle,
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(localizations.signatureSettingsComposeActionsInfo),
              for (final action in ComposeAction.values) ...{
                CheckboxListTile(
                  value: _signatureEnabledFor[action],
                  onChanged: (value) async {
                    setState(() {
                      _signatureEnabledFor[action] = value;
                    });
                  },
                  title: Text(getActionName(action, localizations)),
                ),
              },
              Divider(),
              SignatureWidget(), //  global signature
              if (accounts.length > 1) ...{
                Divider(),
                if (accountsWithSignature.isNotEmpty) ...{
                  for (final account in accountsWithSignature) ...{
                    Text(account.name, style: theme.textTheme.subtitle1),
                    SignatureWidget(
                      account: account,
                    ),
                    Divider(),
                  },
                },
                Text(localizations.signatureSettingsAccountInfo),
                TextButton(
                  onPressed: () {
                    locator<NavigationService>().push(Routes.settingsAccounts);
                  },
                  child: Text(localizations.settingsActionAccounts),
                ),
              },
            ],
          ),
        ),
      ),
    );
  }
}

class SignatureWidget extends StatefulWidget {
  final Account account;
  SignatureWidget({Key key, this.account}) : super(key: key);

  @override
  _SignatureWidgetState createState() => _SignatureWidgetState();
}

class _SignatureWidgetState extends State<SignatureWidget> {
  String _signature;

  @override
  void initState() {
    super.initState();

    _signature = widget.account != null
        ? widget.account.signatureHtml
        : locator<SettingsService>().getSignatureHtmlGlobal();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (_signature == null) {
      return ListTile(
        leading: Icon(Icons.add),
        title: Text(
          localizations.signatureSettingsAddForAccount(widget.account.name),
        ),
        onTap: _showEditor,
      );
    }
    return Stack(
      children: [
        HtmlWidget(
          _signature,
          onTapUrl: (url) async {
            if (await launcher.canLaunch(url)) {
              await launcher.launch(url);
            }
          },
        ),
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            icon: Icon(Icons.edit),
            onPressed: _showEditor,
          ),
        ),
      ],
    );
  }

  void _showEditor() async {
    final localizations = AppLocalizations.of(context);
    HtmlEditorApi editorApi;
    final result = await DialogHelper.showWidgetDialog(
        context,
        localizations.signatureSettingsTitle,
        SingleChildScrollView(
          child: PackagedHtmlEditor(
            initialContent: _signature ??
                locator<SettingsService>().getSignatureHtmlGlobal(),
            excludeDocumentLevelControls: true,
            onCreated: (api) => editorApi = api,
          ),
        ),
        defaultActions: DialogActions.okAndCancel,
        actions: _signature == null
            ? null
            : [
                TextButton(
                  child: Text(localizations.actionDelete),
                  onPressed: () async {
                    setState(() {
                      _signature = null;
                    });
                    Navigator.of(context).pop(false);
                    if (widget.account != null) {
                      widget.account.signatureHtml = null;
                      await locator<MailService>().saveAccounts();
                    } else {
                      final service = locator<SettingsService>();
                      service.settings.signatureHtml = null;
                      _signature = service.getSignatureHtmlGlobal();
                      await service.save();
                    }
                  },
                ),
                TextButton(
                  child: Text(localizations.actionCancel),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text(localizations.actionOk),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ]);
    if (result == true && editorApi != null) {
      final newSignature = await editorApi.getText();
      setState(() {
        _signature = newSignature;
      });
      if (widget.account == null) {
        final service = locator<SettingsService>();
        service.settings.signatureHtml = newSignature;
        await service.save();
      } else {
        widget.account.signatureHtml = newSignature;
        locator<MailService>().saveAccounts();
      }
    }
  }
}
