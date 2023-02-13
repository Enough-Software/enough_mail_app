import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/locator.dart';
import 'package:enough_mail_app/models/account.dart';
import 'package:enough_mail_app/screens/base.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/util/localized_dialog_helper.dart';
import 'package:enough_mail_app/widgets/password_field.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.g.dart';

class AccountServerDetailsScreen extends StatelessWidget {
  final RealAccount account;
  final String? title;
  final bool includeDrawer;
  const AccountServerDetailsScreen({
    Key? key,
    required this.account,
    this.title,
    this.includeDrawer = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final editor = AccountServerDetailsEditor(account: account);
    return Base.buildAppChrome(
      context,
      title: title ?? account.name,
      content: editor,
      includeDrawer: includeDrawer,
      appBarActions: [
        const _SaveButton(),
      ],
    );
  }
}

class AccountServerDetailsEditor extends StatefulWidget {
  final RealAccount account;

  const AccountServerDetailsEditor({
    Key? key,
    required this.account,
  }) : super(key: key);

  @override
  State<AccountServerDetailsEditor> createState() =>
      _AccountServerDetailsEditorState();

  void testConnection(BuildContext context) async {
    await _AccountServerDetailsEditorState._currentState
        ?.testConnection(context);
  }
}

class _SaveButton extends StatefulWidget {
  const _SaveButton({Key? key}) : super(key: key);

  @override
  _SaveButtonState createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  var _isSaving = false;
  @override
  Widget build(BuildContext context) {
    if (_isSaving) {
      return const PlatformProgressIndicator();
    }
    return PlatformIconButton(
      icon: Icon(PlatformInfo.isCupertino
          ? CupertinoIcons.check_mark_circled
          : Icons.save),
      onPressed: () async {
        setState(() {
          _isSaving = true;
        });
        await _AccountServerDetailsEditorState._currentState
            ?.testConnection(context);
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      },
    );
  }
}

class _AccountServerDetailsEditorState
    extends State<AccountServerDetailsEditor> {
  static _AccountServerDetailsEditorState? _currentState;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _incomingHostDomainController =
      TextEditingController();
  final TextEditingController _incomingHostPortController =
      TextEditingController();
  final TextEditingController _incomingUserNameController =
      TextEditingController();
  final TextEditingController _incomingPasswordController =
      TextEditingController();
  late SocketType _incomingSecurity;
  late ServerType _incomingServerType;
  final TextEditingController _outgoingHostDomainController =
      TextEditingController();
  final TextEditingController _outgoingHostPortController =
      TextEditingController();
  final TextEditingController _outgoingUserNameController =
      TextEditingController();
  final TextEditingController _outgoingPasswordController =
      TextEditingController();
  late SocketType _outgoingSecurity;
  late ServerType _outgoingServerType;

  @override
  void initState() {
    _currentState = this;
    final mailAccount = widget.account.mailAccount;
    final incoming = mailAccount.incoming;
    final incomingAuth =
        incoming.authentication as UserNameBasedAuthentication?;
    final outgoing = mailAccount.outgoing;
    final outgoingAuth =
        outgoing.authentication as UserNameBasedAuthentication?;
    _emailController.text = mailAccount.email ?? '';
    _setupFields(incoming.serverConfig, outgoing.serverConfig, incomingAuth,
        outgoingAuth);
    super.initState();
  }

  void _setupFields(
      ServerConfig? incoming,
      ServerConfig? outgoing,
      UserNameBasedAuthentication? incomingAuth,
      UserNameBasedAuthentication? outgoingAuth) {
    final incomingPassword =
        incomingAuth is PlainAuthentication ? incomingAuth.password : null;
    if (incomingAuth?.userName != null) {
      _userNameController.text = incomingAuth!.userName;
    }
    if (incomingPassword != null) {
      _passwordController.text = incomingPassword;
    }
    final incomingHostName = incoming?.hostname;
    _incomingHostDomainController.text = incomingHostName ?? '';
    _incomingHostPortController.text = incoming?.port?.toString() ?? '';
    if (incomingAuth?.userName != null) {
      _incomingUserNameController.text = incomingAuth!.userName;
    }
    if (incomingPassword != null) {
      _incomingPasswordController.text = incomingPassword;
    }
    _incomingSecurity = incoming?.socketType ?? SocketType.ssl;
    _incomingServerType = incoming?.type ?? ServerType.imap;
    _outgoingHostDomainController.text = outgoing?.hostname ?? '';
    _outgoingHostPortController.text = outgoing?.port?.toString() ?? '';
    if (outgoingAuth?.userName != null) {
      _outgoingUserNameController.text = outgoingAuth!.userName;
    }
    if (outgoingAuth is PlainAuthentication) {
      _outgoingPasswordController.text = outgoingAuth.password;
    }
    _outgoingSecurity = outgoing?.socketType ?? SocketType.ssl;
    _outgoingServerType = outgoing?.type ?? ServerType.smtp;
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

  Future<void> testConnection(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    final mailAccount = widget.account.mailAccount;
    final userName = (_userNameController.text.isEmpty)
        ? mailAccount.email
        : _userNameController.text;
    final password = _passwordController.text;
    final incomingServerConfig = ServerConfig(
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
    final outgoingServerConfig = ServerConfig(
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

    final newAccount = mailAccount.copyWith(
      email: _emailController.text,
      userName: userName,
      incoming: MailServerConfig(
        serverConfig: incomingServerConfig,
        authentication: PlainAuthentication(incomingUserName, incomingPassword),
      ),
      outgoing: MailServerConfig(
        serverConfig: outgoingServerConfig,
        authentication: PlainAuthentication(outgoingUserName, outgoingPassword),
      ),
    );

    //print('account: $mailAccount');
    final completedAccount = await Discover.complete(newAccount);
    if (completedAccount == null) {
      if (mounted) {
        await LocalizedDialogHelper.showTextDialog(
          context,
          localizations.errorTitle,
          localizations.accountDetailsErrorHostProblem(
            _incomingHostDomainController.text,
            _outgoingHostDomainController.text,
          ),
        );
      }
      return;
    } else {
      final incoming = mailAccount.incoming!;
      final outgoing = mailAccount.outgoing!;
      if (mounted) {
        setState(() {
          _incomingHostPortController.text =
              incoming.serverConfig.port?.toString() ?? '';
          _incomingServerType = incoming.serverConfig.type ?? ServerType.imap;
          _incomingSecurity =
              incoming.serverConfig.socketType ?? SocketType.ssl;
          _outgoingHostPortController.text =
              outgoing.serverConfig.port?.toString() ?? '';
          _outgoingServerType = outgoing.serverConfig.type ?? ServerType.smtp;
          _outgoingSecurity =
              outgoing.serverConfig.socketType ?? SocketType.ssl;
        });
      }
    }
    // now try to sign in:
    final connectedAccount =
        await locator<MailService>().connectFirstTime(mailAccount);
    final mailClient = connectedAccount?.mailClient;
    if (mailClient != null && mailClient.isConnected) {
      locator<NavigationService>().pop(connectedAccount);
    } else if (mounted) {
      await LocalizedDialogHelper.showTextDialog(
        context,
        localizations.errorTitle,
        localizations.accountDetailsErrorLoginProblem(
          incomingUserName,
          password,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Material(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                DecoratedPlatformTextField(
                  autocorrect: false,
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: localizations.addAccountEmailLabel,
                    hintText: localizations.addAccountEmailHint,
                  ),
                ),
                DecoratedPlatformTextField(
                  autocorrect: false,
                  controller: _userNameController,
                  decoration: InputDecoration(
                    labelText: localizations.accountDetailsUserNameLabel,
                    hintText: localizations.accountDetailsUserNameHint,
                  ),
                ),
                PasswordField(
                  controller: _passwordController,
                  labelText: localizations.accountDetailsPasswordLabel,
                  hintText: localizations.accountDetailsPasswordHint,
                ),
                ExpansionTile(
                  title: Text(localizations.accountDetailsBaseSectionTitle),
                  initiallyExpanded: true,
                  children: [
                    DecoratedPlatformTextField(
                      autocorrect: false,
                      controller: _incomingHostDomainController,
                      decoration: InputDecoration(
                        labelText: localizations.accountDetailsIncomingLabel,
                        hintText: localizations.accountDetailsIncomingHint,
                      ),
                    ),
                    DecoratedPlatformTextField(
                      autocorrect: false,
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
                              const DropdownMenuItem(
                                value: ServerType.imap,
                                child: Text('IMAP'),
                              ),
                              const DropdownMenuItem(
                                value: ServerType.pop,
                                child: Text('POP'),
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
                              const DropdownMenuItem(
                                value: SocketType.ssl,
                                child: Text('SSL'),
                              ),
                              const DropdownMenuItem(
                                value: SocketType.starttls,
                                child: Text('Start TLS'),
                              ),
                              DropdownMenuItem(
                                value: SocketType.plain,
                                child: Text(localizations
                                    .accountDetailsSecurityOptionNone),
                              ),
                            ],
                            value: _incomingSecurity,
                            onChanged: (value) =>
                                setState(() => _incomingSecurity = value!)),
                      ],
                    ),
                    DecoratedPlatformTextField(
                      autocorrect: false,
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
                      autocorrect: false,
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
                              const DropdownMenuItem(
                                value: ServerType.smtp,
                                child: Text('SMTP'),
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
                              const DropdownMenuItem(
                                value: SocketType.ssl,
                                child: Text('SSL'),
                              ),
                              const DropdownMenuItem(
                                value: SocketType.starttls,
                                child: Text('Start TLS'),
                              ),
                              DropdownMenuItem(
                                value: SocketType.plain,
                                child: Text(localizations
                                    .accountDetailsSecurityOptionNone),
                              ),
                            ],
                            value: _outgoingSecurity,
                            onChanged: (value) =>
                                setState(() => _outgoingSecurity = value!)),
                      ],
                    ),
                    DecoratedPlatformTextField(
                      autocorrect: false,
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
                      autocorrect: false,
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
