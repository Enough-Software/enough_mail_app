import 'package:enough_mail/enough_mail.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../account/model.dart';
import '../account/provider.dart';
import '../localization/extension.dart';
import '../mail/provider.dart';
import '../util/localized_dialog_helper.dart';
import '../widgets/password_field.dart';
import 'base.dart';
import 'mail_screen_for_default_account.dart';

/// Allows to edit server details for an account.
class AccountServerDetailsScreen extends ConsumerWidget {
  /// Creates a [AccountServerDetailsScreen].
  const AccountServerDetailsScreen({
    super.key,
    this.accountEmail,
    this.account,
    this.title,
  });

  /// The email address of the account to edit.
  final String? accountEmail;

  /// The account to edit.
  final RealAccount? account;

  /// The title of the screen, if it should differ from the account's name.
  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountEmail = this.accountEmail;
    final account = this.account ??
        (accountEmail != null
            ? ref.watch(
                findRealAccountByEmailProvider(email: accountEmail),
              )
            : null);
    if (account == null) {
      return const MailScreenForDefaultAccount();
    }
    final editor = AccountServerDetailsEditor(account: account);

    return BasePage(
      title: title ?? account.name,
      content: editor,
      appBarActions: const [
        _SaveButton(),
      ],
    );
  }
}

class AccountServerDetailsEditor extends StatefulHookConsumerWidget {
  const AccountServerDetailsEditor({
    super.key,
    required this.account,
  });
  final RealAccount account;

  @override
  ConsumerState<AccountServerDetailsEditor> createState() =>
      _AccountServerDetailsEditorState();

  Future<void> testConnection(BuildContext context) async {
    await _AccountServerDetailsEditorState._currentState
        ?.testConnection(context);
  }
}

class _SaveButton extends StatefulWidget {
  const _SaveButton();

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
    extends ConsumerState<AccountServerDetailsEditor> {
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
    _emailController.text = mailAccount.email;
    _setupFields(
      incoming.serverConfig,
      outgoing.serverConfig,
      incomingAuth,
      outgoingAuth,
    );
    super.initState();
  }

  void _setupFields(
    ServerConfig? incoming,
    ServerConfig? outgoing,
    UserNameBasedAuthentication? incomingAuth,
    UserNameBasedAuthentication? outgoingAuth,
  ) {
    final incomingPassword =
        incomingAuth is PlainAuthentication ? incomingAuth.password : null;
    if (incomingAuth?.userName != null) {
      _userNameController.text = incomingAuth?.userName ?? '';
    }
    if (incomingPassword != null) {
      _passwordController.text = incomingPassword;
    }
    final incomingHostName = incoming?.hostname;
    _incomingHostDomainController.text = incomingHostName ?? '';
    _incomingHostPortController.text = incoming?.port.toString() ?? '';
    if (incomingAuth?.userName != null) {
      _incomingUserNameController.text = incomingAuth?.userName ?? '';
    }
    if (incomingPassword != null) {
      _incomingPasswordController.text = incomingPassword;
    }
    _incomingSecurity = incoming?.socketType ?? SocketType.ssl;
    _incomingServerType = incoming?.type ?? ServerType.imap;
    _outgoingHostDomainController.text = outgoing?.hostname ?? '';
    _outgoingHostPortController.text = outgoing?.port.toString() ?? '';
    if (outgoingAuth?.userName != null) {
      _outgoingUserNameController.text = outgoingAuth?.userName ?? '';
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
    final localizations = ref.text;
    final mailAccount = widget.account.mailAccount;
    final userName = (_userNameController.text.isEmpty)
        ? mailAccount.email
        : _userNameController.text;
    final password = _passwordController.text;
    final incomingServerConfig = ServerConfig(
      type: _incomingServerType,
      hostname: _incomingHostDomainController.text,
      port: int.tryParse(_incomingHostPortController.text) ?? 0,
      socketType: _incomingSecurity,
      authentication: Authentication.plain,
      usernameType: UsernameType.unknown,
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
      port: int.tryParse(_outgoingHostPortController.text) ?? 0,
      socketType: _outgoingSecurity,
      authentication: Authentication.plain,
      usernameType: UsernameType.unknown,
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
          ref,
          localizations.errorTitle,
          localizations.accountDetailsErrorHostProblem(
            _incomingHostDomainController.text,
            _outgoingHostDomainController.text,
          ),
        );
      }

      return;
    } else {
      final incoming = mailAccount.incoming;
      final outgoing = mailAccount.outgoing;
      if (mounted) {
        setState(() {
          _incomingHostPortController.text =
              incoming.serverConfig.port.toString();
          _incomingServerType = incoming.serverConfig.type;
          _incomingSecurity = incoming.serverConfig.socketType;
          _outgoingHostPortController.text =
              outgoing.serverConfig.port.toString();
          _outgoingServerType = outgoing.serverConfig.type;
          _outgoingSecurity = outgoing.serverConfig.socketType;
        });
      }
    }
    // now try to sign in:
    final connectedAccount = await ref.read(
      firstTimeMailClientSourceProvider(
        account: RealAccount(mailAccount),
      ).future,
    );

    final mailClient = connectedAccount?.mailClient;
    if (mailClient != null && mailClient.isConnected) {
      if (context.mounted) {
        context.pop(connectedAccount);
      }
    } else if (mounted) {
      await LocalizedDialogHelper.showTextDialog(
        ref,
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
    final localizations = ref.text;

    return SingleChildScrollView(
      child: Material(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
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
                    localizations.accountDetailsAdvancedIncomingSectionTitle,
                  ),
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(localizations
                              .accountDetailsIncomingServerTypeLabel),
                        ),
                        PlatformDropdownButton<ServerType>(
                          items: [
                            DropdownMenuItem(
                              child: Text(
                                localizations.accountDetailsOptionAutomatic,
                              ),
                            ),
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
                          onChanged: (value) {
                            if (value != null) {
                              setState(
                                () => _incomingServerType = value,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(localizations
                              .accountDetailsIncomingSecurityLabel),
                        ),
                        PlatformDropdownButton<SocketType>(
                          items: [
                            DropdownMenuItem(
                              child: Text(
                                localizations.accountDetailsOptionAutomatic,
                              ),
                            ),
                            const DropdownMenuItem(
                              value: SocketType.ssl,
                              child: Text('SSL'),
                            ),
                            const DropdownMenuItem(
                              // cSpell: ignore starttls
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
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _incomingSecurity = value);
                            }
                          },
                        ),
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
                      hintText:
                          localizations.accountDetailsAlternativePasswordHint,
                    ),
                  ],
                ),
                ExpansionTile(
                  title: Text(
                    localizations.accountDetailsAdvancedOutgoingSectionTitle,
                  ),
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            localizations.accountDetailsOutgoingServerTypeLabel,
                          ),
                        ),
                        PlatformDropdownButton<ServerType>(
                          items: [
                            DropdownMenuItem(
                              child: Text(
                                localizations.accountDetailsOptionAutomatic,
                              ),
                            ),
                            const DropdownMenuItem(
                              value: ServerType.smtp,
                              child: Text('SMTP'),
                            ),
                          ],
                          value: _outgoingServerType,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _outgoingServerType = value);
                            }
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(localizations
                              .accountDetailsOutgoingSecurityLabel),
                        ),
                        PlatformDropdownButton<SocketType>(
                          items: [
                            DropdownMenuItem(
                              child: Text(
                                localizations.accountDetailsOptionAutomatic,
                              ),
                            ),
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
                              child: Text(
                                localizations.accountDetailsSecurityOptionNone,
                              ),
                            ),
                          ],
                          value: _outgoingSecurity,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _outgoingSecurity = value);
                            }
                          },
                        ),
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
