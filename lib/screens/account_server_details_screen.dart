import 'package:enough_mail/discover/client_config.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/events/account_add_event.dart';
import 'package:enough_mail_app/locator.dart';
import 'package:enough_mail_app/models/account.dart';
import 'package:enough_mail_app/screens/base.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/widgets/password_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AccountServerDetailsScreen extends StatefulWidget {
  final Account account;
  final String title;
  final bool includeDrawer;

  AccountServerDetailsScreen(
      {Key key, @required this.account, this.title, this.includeDrawer})
      : super(key: key);

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

  Future<void> testConnection() async {
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
          title: Text('Error'),
          content: Text(
              'Unable to verify your account settings. Please check your incoming server setting "${incomingHostDomainController.text}" and your outgoing server setting "${outgoingHostDomainController.text}".'),
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
          title: Text('Error'),
          content: Text(
              'Unable to log your in. Please check your user name "$incomingUserName" and your password "$password".'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Base.buildAppChrome(
      context,
      title: widget.title ?? widget.account.name ?? 'Server settings',
      content: buildContent(context),
      includeDrawer: widget.includeDrawer,
      appBarActions: [
        IconButton(
          icon: Icon(Icons.save),
          onPressed: testConnection,
        ),
      ],
    );
  }

  Widget buildContent(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Your email address',
              ),
            ),
            TextField(
              controller: userNameController,
              decoration: InputDecoration(
                labelText: 'Login name',
                hintText: 'Your user name, if different from email',
              ),
            ),
            PasswordField(
                controller: passwordController,
                labelText: 'Login password',
                hintText: 'Your password'),
            ExpansionTile(
              title: Text('Base settings'),
              initiallyExpanded: true,
              children: [
                TextField(
                  controller: incomingHostDomainController,
                  decoration: InputDecoration(
                    labelText: 'Incoming server',
                    hintText: 'Domain like imap.domain.com',
                  ),
                ),
                TextField(
                  controller: outgoingHostDomainController,
                  decoration: InputDecoration(
                      labelText: 'Outgoing server',
                      hintText: 'Domain like smtp.domain.com'),
                ),
              ],
            ),
            ExpansionTile(
              title: Text('Advanced incoming settings'),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Incoming type:  '),
                    DropdownButton<ServerType>(
                        items: [
                          DropdownMenuItem(child: Text('automatic')),
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
                    Text('Incoming security:  '),
                    DropdownButton<SocketType>(
                        items: [
                          DropdownMenuItem(child: Text('automatic')),
                          DropdownMenuItem(
                            child: Text('SSL'),
                            value: SocketType.ssl,
                          ),
                          DropdownMenuItem(
                            child: Text('Start TLS'),
                            value: SocketType.starttls,
                          ),
                          DropdownMenuItem(
                            child: Text('Plain (no encryption)'),
                            value: SocketType.plain,
                          ),
                        ],
                        value: incomingSecurity,
                        onChanged: (value) =>
                            setState(() => incomingSecurity = value)),
                  ],
                ),
                TextField(
                  controller: incomingHostPortController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Incoming port',
                    hintText: 'Leave empty to determine automatically',
                  ),
                ),
                TextField(
                  controller: incomingUserNameController,
                  decoration: InputDecoration(
                    labelText: 'Incoming login name',
                    hintText: 'Your user name, if different from above',
                  ),
                ),
                PasswordField(
                    controller: incomingPasswordController,
                    labelText: 'Incoming login password',
                    hintText: 'Your password, if different from above'),
              ],
            ),
            ExpansionTile(
              title: Text('Advanced outgoing settings'),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Outgoing type:  '),
                    DropdownButton<ServerType>(
                        items: [
                          DropdownMenuItem(child: Text('automatic')),
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
                    Text('Outgoing security:  '),
                    DropdownButton<SocketType>(
                        items: [
                          DropdownMenuItem(child: Text('automatic')),
                          DropdownMenuItem(
                            child: Text('SSL'),
                            value: SocketType.ssl,
                          ),
                          DropdownMenuItem(
                            child: Text('Start TLS'),
                            value: SocketType.starttls,
                          ),
                          DropdownMenuItem(
                            child: Text('Plain (no encryption)'),
                            value: SocketType.plain,
                          ),
                        ],
                        value: outgoingSecurity,
                        onChanged: (value) =>
                            setState(() => outgoingSecurity = value)),
                  ],
                ),
                TextField(
                  controller: outgoingHostPortController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Outgoing port',
                    hintText: 'Leave empty to determine automatically',
                  ),
                ),
                TextField(
                  controller: outgoingUserNameController,
                  decoration: InputDecoration(
                    labelText: 'Outgoing login name',
                    hintText: 'Your user name, if different from above',
                  ),
                ),
                PasswordField(
                    controller: outgoingPasswordController,
                    labelText: 'Outgoing login password',
                    hintText: 'Your password, if different from above'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
