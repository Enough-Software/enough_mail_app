import 'package:enough_mail/discover/client_config.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/events/account_add_event.dart';
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
  final String title;
  final bool includeDrawer;

  AccountServerDetailsScreen({
    Key key,
    @required this.account,
    this.title,
    this.includeDrawer = true,
  }) : super(key: key);

  @override
  _AccountServerDetailsScreenState createState() =>
      _AccountServerDetailsScreenState();
}

class _AccountServerDetailsScreenState
    extends State<AccountServerDetailsScreen> {
  TextEditingController emailController;
  TextEditingController userNameController;
  TextEditingController passwordController;
  TextEditingController incomingHostDomainController;
  TextEditingController outgoingHostDomainController;
  TextEditingController incomingHostPortController;
  TextEditingController incomingUserNameController;
  TextEditingController incomingPasswordController;
  SocketType incomingSecurity;
  ServerType incomingServerType;
  TextEditingController outgoingHostPortController;
  TextEditingController outgoingUserNameController;
  TextEditingController outgoingPasswordController;
  SocketType outgoingSecurity;
  ServerType outgoingServerType;

  @override
  void initState() {
    final mailAccount = widget.account?.account;
    final incoming = mailAccount?.incoming;
    final incomingAuth = incoming?.authentication as PlainAuthentication;
    final outgoing = mailAccount?.outgoing;
    final outgoingAuth = outgoing?.authentication as PlainAuthentication;
    emailController = TextEditingController(text: mailAccount?.email);
    userNameController = TextEditingController(text: incomingAuth?.userName);
    passwordController = TextEditingController(text: incomingAuth?.password);
    incomingHostDomainController =
        TextEditingController(text: incoming?.serverConfig?.hostname);
    incomingHostPortController =
        TextEditingController(text: incoming?.serverConfig?.port?.toString());
    incomingUserNameController =
        TextEditingController(text: incomingAuth?.userName);
    incomingPasswordController =
        TextEditingController(text: incomingAuth?.password);
    incomingSecurity = incoming?.serverConfig?.socketType;
    incomingServerType = incoming?.serverConfig?.type;
    outgoingHostDomainController =
        TextEditingController(text: outgoing?.serverConfig?.hostname);
    outgoingHostPortController =
        TextEditingController(text: outgoing?.serverConfig?.port?.toString());
    outgoingUserNameController =
        TextEditingController(text: outgoingAuth?.userName);
    outgoingPasswordController =
        TextEditingController(text: outgoingAuth?.password);
    outgoingSecurity = outgoing?.serverConfig?.socketType;
    outgoingServerType = outgoing?.serverConfig?.type;

    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    userNameController.dispose();
    passwordController.dispose();
    incomingHostDomainController.dispose();
    incomingHostPortController.dispose();
    incomingUserNameController.dispose();
    incomingPasswordController.dispose();
    outgoingHostDomainController.dispose();
    outgoingHostPortController.dispose();
    outgoingUserNameController.dispose();
    outgoingPasswordController.dispose();
    super.dispose();
  }

  Future<void> testConnection(AppLocalizations localizations) async {
    final mailAccount = widget.account.account;
    mailAccount.email = emailController.text;
    final userName = userNameController.text?.isEmpty ?? true
        ? mailAccount.email
        : userNameController.text;
    mailAccount.userName = userName;
    final password = passwordController.text;

    final incomingServerConfig = mailAccount.incoming?.serverConfig ??
        ServerConfig(
            type: incomingServerType,
            hostname: incomingHostDomainController.text,
            port: int.tryParse(incomingHostPortController.text),
            socketType: incomingSecurity);
    final incomingUserName = incomingUserNameController.text?.isEmpty ?? true
        ? userName
        : incomingUserNameController.text;
    final incomingPassword = incomingPasswordController.text?.isEmpty ?? true
        ? password
        : incomingPasswordController.text;
    mailAccount.incoming = MailServerConfig(
        serverConfig: incomingServerConfig,
        authentication:
            PlainAuthentication(incomingUserName, incomingPassword));
    final outgoingServerConfig = mailAccount.outgoing?.serverConfig ??
        ServerConfig(
            type: outgoingServerType,
            hostname: outgoingHostDomainController.text,
            port: int.tryParse(outgoingHostPortController.text),
            socketType: outgoingSecurity);
    final outgoingUserName = outgoingUserNameController.text?.isEmpty ?? true
        ? userName
        : outgoingUserNameController.text;
    final outgoingPassword = outgoingPasswordController.text?.isEmpty ?? true
        ? password
        : outgoingPasswordController.text;
    mailAccount.outgoing = MailServerConfig(
        serverConfig: outgoingServerConfig,
        authentication:
            PlainAuthentication(outgoingUserName, outgoingPassword));
    //print('account: $mailAccount');
    final completed = await Discover.complete(mailAccount);
    if (!completed) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(localizations.errorTitle),
          content: Text(localizations.accountDetailsErrorHostProblem(
              incomingHostDomainController.text,
              outgoingHostDomainController.text)),
        ),
      );
      return;
    } else {
      setState(() {
        incomingHostPortController.text =
            mailAccount.incoming.serverConfig.port.toString();
        incomingServerType = mailAccount.incoming.serverConfig.type;
        incomingSecurity = mailAccount.incoming.serverConfig.socketType;
        outgoingHostPortController.text =
            mailAccount.outgoing.serverConfig.port.toString();
        outgoingServerType = mailAccount.outgoing.serverConfig.type;
        outgoingSecurity = mailAccount.outgoing.serverConfig.socketType;
      });
    }
    // now try to sign in:
    final mailClient = await locator<MailService>().connect(mailAccount);
    if (mailClient?.isConnected ?? false) {
      locator<NavigationService>().pop(
          AccountResolvedEvent(context, widget.account.account, mailClient));
    } else {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(localizations.errorTitle),
          content: Text(localizations.accountDetailsErrorLoginProblem(
              incomingUserName, password)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Base.buildAppChrome(
      context,
      title: widget.title ??
          widget.account.name ??
          localizations.accountDetailsFallbackTitle,
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
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: localizations.addAccountEmailLabel,
                    hintText: localizations.addAccountEmailHint,
                  ),
                ),
                DecoratedPlatformTextField(
                  controller: userNameController,
                  decoration: InputDecoration(
                    labelText: localizations.accountDetailsUserNameLabel,
                    hintText: localizations.accountDetailsUserNameHint,
                  ),
                ),
                PasswordField(
                    controller: passwordController,
                    labelText: localizations.accountDetailsPasswordLabel,
                    hintText: localizations.accountDetailsPasswordHint),
                ExpansionTile(
                  title: Text(localizations.accountDetailsBaseSectionTitle),
                  initiallyExpanded: true,
                  children: [
                    DecoratedPlatformTextField(
                      controller: incomingHostDomainController,
                      decoration: InputDecoration(
                        labelText: localizations.accountDetailsIncomingLabel,
                        hintText: localizations.accountDetailsIncomingHint,
                      ),
                    ),
                    DecoratedPlatformTextField(
                      controller: outgoingHostDomainController,
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
                            value: incomingServerType,
                            onChanged: (value) =>
                                setState(() => incomingServerType = value)),
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
                            value: incomingSecurity,
                            onChanged: (value) =>
                                setState(() => incomingSecurity = value)),
                      ],
                    ),
                    DecoratedPlatformTextField(
                      controller: incomingHostPortController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText:
                            localizations.accountDetailsIncomingPortLabel,
                        hintText: localizations.accountDetailsPortHint,
                      ),
                    ),
                    DecoratedPlatformTextField(
                      controller: incomingUserNameController,
                      decoration: InputDecoration(
                        labelText:
                            localizations.accountDetailsIncomingUserNameLabel,
                        hintText:
                            localizations.accountDetailsAlternativeUserNameHint,
                      ),
                    ),
                    PasswordField(
                        controller: incomingPasswordController,
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
                            value: outgoingServerType,
                            onChanged: (value) =>
                                setState(() => outgoingServerType = value)),
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
                            value: outgoingSecurity,
                            onChanged: (value) =>
                                setState(() => outgoingSecurity = value)),
                      ],
                    ),
                    DecoratedPlatformTextField(
                      controller: outgoingHostPortController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText:
                            localizations.accountDetailsOutgoingPortLabel,
                        hintText: localizations.accountDetailsPortHint,
                      ),
                    ),
                    DecoratedPlatformTextField(
                      controller: outgoingUserNameController,
                      decoration: InputDecoration(
                        labelText:
                            localizations.accountDetailsOutgoingUserNameLabel,
                        hintText:
                            localizations.accountDetailsAlternativeUserNameHint,
                      ),
                    ),
                    PasswordField(
                      controller: outgoingPasswordController,
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
