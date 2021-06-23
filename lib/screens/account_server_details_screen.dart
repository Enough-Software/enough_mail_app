import 'package:enough_mail/discover/client_config.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/locator.dart';
import 'package:enough_mail_app/models/account.dart';
import 'package:enough_mail_app/screens/base.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/widgets/password_field.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AccountServerDetailsScreen extends StatefulWidget {
  final Account account;
  final String? title;
  final bool includeDrawer;

  AccountServerDetailsScreen({
    Key? key,
    required this.account,
    this.title,
    this.includeDrawer = true,
  }) : super(key: key);

  @override
  _AccountServerDetailsScreenState createState() =>
      _AccountServerDetailsScreenState();
}

class _AccountServerDetailsScreenState
    extends State<AccountServerDetailsScreen> {
  late TextEditingController _emailController;
  late TextEditingController _userNameController;
  late TextEditingController _passwordController;
  late TextEditingController _incomingHostDomainController;
  late TextEditingController _incomingHostPortController;
  late TextEditingController _incomingUserNameController;
  late TextEditingController _incomingPasswordController;
  late SocketType _incomingSecurity;
  late ServerType _incomingServerType;
  late TextEditingController _outgoingHostDomainController;
  late TextEditingController _outgoingHostPortController;
  late TextEditingController _outgoingUserNameController;
  late TextEditingController _outgoingPasswordController;
  late SocketType _outgoingSecurity;
  late ServerType _outgoingServerType;

  @override
  void initState() {
    final mailAccount = widget.account.account;
    final incoming = mailAccount.incoming;
    final incomingAuth = incoming?.authentication as PlainAuthentication?;
    final outgoing = mailAccount.outgoing;
    final outgoingAuth = outgoing?.authentication as PlainAuthentication?;
    _emailController = TextEditingController(text: mailAccount.email);
    _userNameController = TextEditingController(text: incomingAuth?.userName);
    _passwordController = TextEditingController(text: incomingAuth?.password);
    _incomingHostDomainController =
        TextEditingController(text: incoming?.serverConfig?.hostname);
    _incomingHostPortController =
        TextEditingController(text: incoming?.serverConfig?.port?.toString());
    _incomingUserNameController =
        TextEditingController(text: incomingAuth?.userName);
    _incomingPasswordController =
        TextEditingController(text: incomingAuth?.password);
    _incomingSecurity = incoming?.serverConfig?.socketType ?? SocketType.ssl;
    _incomingServerType = incoming?.serverConfig?.type ?? ServerType.imap;
    _outgoingHostDomainController =
        TextEditingController(text: outgoing?.serverConfig?.hostname);
    _outgoingHostPortController =
        TextEditingController(text: outgoing?.serverConfig?.port?.toString());
    _outgoingUserNameController =
        TextEditingController(text: outgoingAuth?.userName);
    _outgoingPasswordController =
        TextEditingController(text: outgoingAuth?.password);
    _outgoingSecurity = outgoing?.serverConfig?.socketType ?? SocketType.ssl;
    _outgoingServerType = outgoing?.serverConfig?.type ?? ServerType.smtp;

    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _userNameController.dispose();
    _passwordController.dispose();
    _incomingHostDomainController.dispose();
    _incomingHostPortController.dispose();
    _incomingUserNameController.dispose();
    _incomingPasswordController.dispose();
    _outgoingHostDomainController.dispose();
    _outgoingHostPortController.dispose();
    _outgoingUserNameController.dispose();
    _outgoingPasswordController.dispose();
    super.dispose();
  }

  Future<void> testConnection(AppLocalizations localizations) async {
    final mailAccount = widget.account.account;
    mailAccount.email = _emailController.text;
    final userName = (_userNameController.text.isEmpty)
        ? mailAccount.email
        : _userNameController.text;
    mailAccount.userName = userName;
    final password = _passwordController.text;

    final incomingServerConfig = mailAccount.incoming?.serverConfig ??
        ServerConfig(
          type: _incomingServerType,
          hostname: _incomingHostDomainController.text,
          port: int.tryParse(_incomingHostPortController.text),
          socketType: _incomingSecurity,
        );
    final incomingUserName = (_incomingUserNameController.text.isEmpty)
        ? userName
        : _incomingUserNameController.text;
    final incomingPassword = (_incomingPasswordController.text.isEmpty)
        ? password
        : _incomingPasswordController.text;
    mailAccount.incoming = MailServerConfig(
        serverConfig: incomingServerConfig,
        authentication:
            PlainAuthentication(incomingUserName, incomingPassword));
    final outgoingServerConfig = mailAccount.outgoing?.serverConfig ??
        ServerConfig(
          type: _outgoingServerType,
          hostname: _outgoingHostDomainController.text,
          port: int.tryParse(_outgoingHostPortController.text),
          socketType: _outgoingSecurity,
        );
    final outgoingUserName = (_outgoingUserNameController.text.isEmpty)
        ? userName
        : _outgoingUserNameController.text;
    final outgoingPassword = (_outgoingPasswordController.text.isEmpty)
        ? password
        : _outgoingPasswordController.text;
    mailAccount.outgoing = MailServerConfig(
      serverConfig: outgoingServerConfig,
      authentication: PlainAuthentication(outgoingUserName, outgoingPassword),
    );
    //print('account: $mailAccount');
    final completed = await Discover.complete(mailAccount);
    if (!completed) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(localizations.errorTitle),
          content: Text(
            localizations.accountDetailsErrorHostProblem(
              _incomingHostDomainController.text,
              _outgoingHostDomainController.text,
            ),
          ),
        ),
      );
      return;
    } else {
      final incoming = mailAccount.incoming!;
      final outgoing = mailAccount.outgoing!;
      setState(() {
        _incomingHostPortController.text =
            incoming.serverConfig?.port?.toString() ?? '';
        _incomingServerType = incoming.serverConfig?.type ?? ServerType.imap;
        _incomingSecurity = incoming.serverConfig?.socketType ?? SocketType.ssl;
        _outgoingHostPortController.text =
            outgoing.serverConfig?.port?.toString() ?? '';
        _outgoingServerType = outgoing.serverConfig?.type ?? ServerType.smtp;
        _outgoingSecurity = outgoing.serverConfig?.socketType ?? SocketType.ssl;
      });
    }
    // now try to sign in:
    final mailClient = await locator<MailService>().connect(mailAccount);
    if (mailClient != null && mailClient.isConnected) {
      locator<NavigationService>().pop(
        ConnectedAccount(widget.account.account, mailClient),
      );
    } else {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(localizations.errorTitle),
          content: Text(
            localizations.accountDetailsErrorLoginProblem(
                incomingUserName!, password),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Base.buildAppChrome(
      context,
      title: widget.title ?? widget.account.name,
      content: buildContent(localizations, context),
      includeDrawer: widget.includeDrawer,
      appBarActions: [
        PlatformIconButton(
          icon: Icon(Icons.save),
          onPressed: () => testConnection(localizations),
        ),
      ],
    );
  }

  Widget buildContent(AppLocalizations localizations, BuildContext context) {
    return SingleChildScrollView(
      child: Material(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                DecoratedPlatformTextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: localizations.addAccountEmailLabel,
                    hintText: localizations.addAccountEmailHint,
                  ),
                ),
                DecoratedPlatformTextField(
                  controller: _userNameController,
                  decoration: InputDecoration(
                    labelText: localizations.accountDetailsUserNameLabel,
                    hintText: localizations.accountDetailsUserNameHint,
                  ),
                ),
                PasswordField(
                    controller: _passwordController,
                    labelText: localizations.accountDetailsPasswordLabel,
                    hintText: localizations.accountDetailsPasswordHint),
                ExpansionTile(
                  title: Text(localizations.accountDetailsBaseSectionTitle),
                  initiallyExpanded: true,
                  children: [
                    DecoratedPlatformTextField(
                      controller: _incomingHostDomainController,
                      decoration: InputDecoration(
                        labelText: localizations.accountDetailsIncomingLabel,
                        hintText: localizations.accountDetailsIncomingHint,
                      ),
                    ),
                    DecoratedPlatformTextField(
                      controller: _outgoingHostDomainController,
                      decoration: InputDecoration(
                        labelText: localizations.accountDetailsOutgoingLabel,
                        hintText: localizations.accountDetailsOutgoingHint,
                      ),
                    ),
                  ],
                ),
                ExpansionTile(
                  title: Text(
                      localizations.accountDetailsAdvancedIncomingSectionTitle),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(localizations
                              .accountDetailsIncomingServerTypeLabel),
                        ),
                        PlatformDropdownButton<ServerType>(
                            items: [
                              DropdownMenuItem(
                                  child: Text(localizations
                                      .accountDetailsOptionAutomatic)),
                              DropdownMenuItem(
                                child: Text('IMAP'),
                                value: ServerType.imap,
                              ),
                              DropdownMenuItem(
                                child: Text('POP'),
                                value: ServerType.pop,
                              ),
                            ],
                            value: _incomingServerType,
                            onChanged: (value) =>
                                setState(() => _incomingServerType = value!)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(localizations
                              .accountDetailsIncomingSecurityLabel),
                        ),
                        PlatformDropdownButton<SocketType>(
                            items: [
                              DropdownMenuItem(
                                  child: Text(localizations
                                      .accountDetailsOptionAutomatic)),
                              DropdownMenuItem(
                                child: Text('SSL'),
                                value: SocketType.ssl,
                              ),
                              DropdownMenuItem(
                                child: Text('Start TLS'),
                                value: SocketType.starttls,
                              ),
                              DropdownMenuItem(
                                child: Text(localizations
                                    .accountDetailsSecurityOptionNone),
                                value: SocketType.plain,
                              ),
                            ],
                            value: _incomingSecurity,
                            onChanged: (value) =>
                                setState(() => _incomingSecurity = value!)),
                      ],
                    ),
                    DecoratedPlatformTextField(
                      controller: _incomingHostPortController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText:
                            localizations.accountDetailsIncomingPortLabel,
                        hintText: localizations.accountDetailsPortHint,
                      ),
                    ),
                    DecoratedPlatformTextField(
                      controller: _incomingUserNameController,
                      decoration: InputDecoration(
                        labelText:
                            localizations.accountDetailsIncomingUserNameLabel,
                        hintText:
                            localizations.accountDetailsAlternativeUserNameHint,
                      ),
                    ),
                    PasswordField(
                        controller: _incomingPasswordController,
                        labelText:
                            localizations.accountDetailsIncomingPasswordLabel,
                        hintText: localizations
                            .accountDetailsAlternativePasswordHint),
                  ],
                ),
                ExpansionTile(
                  title: Text(
                      localizations.accountDetailsAdvancedOutgoingSectionTitle),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(localizations
                              .accountDetailsOutgoingServerTypeLabel),
                        ),
                        PlatformDropdownButton<ServerType>(
                            items: [
                              DropdownMenuItem(
                                  child: Text(localizations
                                      .accountDetailsOptionAutomatic)),
                              DropdownMenuItem(
                                child: Text('SMTP'),
                                value: ServerType.smtp,
                              ),
                            ],
                            value: _outgoingServerType,
                            onChanged: (value) =>
                                setState(() => _outgoingServerType = value!)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(localizations
                              .accountDetailsOutgoingSecurityLabel),
                        ),
                        PlatformDropdownButton<SocketType>(
                            items: [
                              DropdownMenuItem(
                                  child: Text(localizations
                                      .accountDetailsOptionAutomatic)),
                              DropdownMenuItem(
                                child: Text('SSL'),
                                value: SocketType.ssl,
                              ),
                              DropdownMenuItem(
                                child: Text('Start TLS'),
                                value: SocketType.starttls,
                              ),
                              DropdownMenuItem(
                                child: Text(localizations
                                    .accountDetailsSecurityOptionNone),
                                value: SocketType.plain,
                              ),
                            ],
                            value: _outgoingSecurity,
                            onChanged: (value) =>
                                setState(() => _outgoingSecurity = value!)),
                      ],
                    ),
                    DecoratedPlatformTextField(
                      controller: _outgoingHostPortController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText:
                            localizations.accountDetailsOutgoingPortLabel,
                        hintText: localizations.accountDetailsPortHint,
                      ),
                    ),
                    DecoratedPlatformTextField(
                      controller: _outgoingUserNameController,
                      decoration: InputDecoration(
                        labelText:
                            localizations.accountDetailsOutgoingUserNameLabel,
                        hintText:
                            localizations.accountDetailsAlternativeUserNameHint,
                      ),
                    ),
                    PasswordField(
                      controller: _outgoingPasswordController,
                      labelText:
                          localizations.accountDetailsOutgoingPasswordLabel,
                      hintText:
                          localizations.accountDetailsAlternativePasswordHint,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
