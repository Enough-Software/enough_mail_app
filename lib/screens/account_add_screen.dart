import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/events/account_add_event.dart';
import 'package:enough_mail_app/events/app_event_bus.dart';
import 'package:enough_mail_app/locator.dart';
import 'package:enough_mail_app/models/account.dart';
import 'package:enough_mail_app/routes.dart';
import 'package:enough_mail_app/screens/base.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/util/validator.dart';
import 'package:enough_mail_app/widgets/password_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AccountAddScreen extends StatefulWidget {
  @override
  _AccountAddScreenState createState() => _AccountAddScreenState();
}

class _AccountAddScreenState extends State<AccountAddScreen> {
  MailAccount account = MailAccount();
  final List<Step> _steps = [];
  int _currentStep = 0;
  int _progressedSteps = 0;
  bool _isContinueAvailable = false;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _accountNameController = TextEditingController();
  TextEditingController _userNameController = TextEditingController();

  ClientConfig _clientConfig;
  bool _isClientConfigResolving = false;
  bool _isManualSettings = false;
  bool _isAccountVerifying = false;

  bool _isAccountVerified = false;

  MailClient mailClient;

  Future<void> navigateToManualSettings() async {
    if (_clientConfig == null) {
      account.incoming = MailServerConfig(
        authentication: PlainAuthentication('', ''),
        serverConfig: ServerConfig(),
      );
      account.outgoing = MailServerConfig(
        authentication: PlainAuthentication('', ''),
        serverConfig: ServerConfig(),
      );
    } else {
      account.incoming = MailServerConfig(
        authentication: PlainAuthentication(
            _clientConfig.preferredIncomingServer.getUserName(account.email),
            ''),
        serverConfig: _clientConfig.preferredIncomingServer,
      );
      account.outgoing = MailServerConfig(
        authentication: PlainAuthentication(
            _clientConfig.preferredOutgoingServer.getUserName(account.email),
            ''),
        serverConfig: _clientConfig.preferredOutgoingServer,
      );
    }
    final result = await locator<NavigationService>()
        .push(Routes.accountServerDetails, arguments: Account(account));
    if (result is AccountResolvedEvent) {
      setState(() {
        account = result.account;
        mailClient = result.mailClient;
        _currentStep = 2;
        _isAccountVerified = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build: current step=$_currentStep');
    _steps.clear();
    _steps.addAll([
      Step(
          title: Text('Email'),
          content: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  final isValid = Validator.validateEmail(value);
                  if (isValid) {
                    account.email = value;
                  }
                  if (isValid != _isContinueAvailable) {
                    setState(() {
                      _isContinueAvailable = isValid;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Please enter your email address',
                  icon: const Icon(Icons.email),
                ),
              ),
            ],
          ),
          //state: StepState.editing,
          isActive: true),
      Step(
        title: Text('Password'),
        //state: StepState.complete,
        isActive: _currentStep >= 1,
        content: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (_isClientConfigResolving) ...{
              Row(
                children: [
                  Container(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator()),
                  Expanded(
                    child: Text('Resolving ${account.email}...'),
                  ),
                ],
              ),
            } else if (_clientConfig != null) ...{
              Column(
                children: [
                  PasswordField(
                    controller: _passwordController,
                    onChanged: (value) {
                      bool isValid = value.isNotEmpty &&
                          (_clientConfig != null || _isManualSettings);
                      if (isValid != _isContinueAvailable) {
                        setState(() {
                          _isContinueAvailable = isValid;
                        });
                      }
                    },
                    labelText: 'Password',
                    hintText: 'Please enter your password',
                  ),
                  RaisedButton(
                    onPressed: navigateToManualSettings,
                    child: Text('Not on ${_clientConfig?.displayName}?'),
                  )
                ],
              ),
            } else ...{
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Unable to resolve ${account.email}. Please go back to change it or set up the account manually.'),
                  RaisedButton(
                    child: Text('Edit manually'),
                    onPressed: navigateToManualSettings,
                  )
                ],
              ),
            },
          ],
        ),
      ),
      Step(
        title: Text('Verification'),
        content: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (_isAccountVerifying) ...{
              Row(
                children: [
                  Container(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator()),
                  Expanded(
                    child: Text('Verifying ${account.email}...'),
                  ),
                ],
              ),
            } else if (_isAccountVerified) ...{
              Text('Successfully signed into ${account.email}.'),
              TextField(
                controller: _userNameController,
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  bool isValid = value.isNotEmpty &&
                      _accountNameController.text.isNotEmpty;
                  if (isValid != _isContinueAvailable) {
                    setState(() {
                      _isContinueAvailable = isValid;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Your name',
                  hintText: 'Please enter your name',
                  icon: const Icon(Icons.account_circle),
                ),
              ),
              TextField(
                controller: _accountNameController,
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  bool isValid =
                      value.isNotEmpty && _userNameController.text.isNotEmpty;
                  if (isValid != _isContinueAvailable) {
                    setState(() {
                      _isContinueAvailable = isValid;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Account name',
                  hintText: 'Please enter the name of your account',
                  icon: const Icon(Icons.email),
                ),
              ),
            } else ...{
              Text(
                  'Sorry, but there was a problem. Please check your email ${account.email} and password.'),
            }
          ],
        ),
      ),
    ]);

    return Base.buildAppChrome(
      context,
      title: 'Add Account',
      content: Column(children: [
        Expanded(
          child: Stepper(
            steps: _steps,
            type: StepperType.vertical,
            onStepContinue: _isContinueAvailable
                ? () async {
                    var step = _currentStep + 1;
                    if (step < _steps.length) {
                      setState(() {
                        _currentStep = step;
                        _isContinueAvailable = false;
                      });
                    }
                    _onStepProgressed(step);
                  }
                : null,
            onStepCancel: () => Navigator.pop(context),
            currentStep: _currentStep,
            onStepTapped: (index) {
              if (index != _currentStep && index <= _progressedSteps) {
                setState(() {
                  _currentStep = index;
                  _isContinueAvailable = true;
                });
              }
            },
          ),
        )
      ]),
    );
  }

  Future<void> _onStepProgressed(int step) async {
    _progressedSteps = step;
    switch (step) {
      case 1:
        // email address has been entered
        if (!_isClientConfigResolving) {
          setState(() {
            _isClientConfigResolving = true;
          });
        }
        print('discover settings for ${account.email}');
        var clientConfig =
            await Discover.discover(account.email, isLogEnabled: true);
        print('done discovering settings: ${clientConfig?.displayName}');
        var domainName =
            account.email.substring(account.email.lastIndexOf('@') + 1);
        _accountNameController.text = domainName;
        setState(() {
          _isClientConfigResolving = false;
          _clientConfig = clientConfig;
          _isContinueAvailable =
              (clientConfig != null) && _passwordController.text.isNotEmpty;
        });
        break;
      case 2:
        // password and possibly manual account details have been specified
        setState(() {
          _isAccountVerifying = true;
        });
        var mailAccount = MailAccount.fromDiscoveredSettings('account name',
            _emailController.text, _passwordController.text, _clientConfig);
        mailClient = await locator<MailService>().connect(mailAccount);

        final isVerified = mailClient?.isConnected ?? false;
        if (isVerified) {
          account = mailAccount;
        }
        setState(() {
          _isAccountVerifying = false;
          _isAccountVerified = isVerified;
          _isContinueAvailable = false;
        });
        break;
      case 3:
        // Account name has been specified
        account.name = _accountNameController.text;
        account.userName = _userNameController.text;
        final service = locator<MailService>();
        await service.addAccount(account, mailClient);
        locator<NavigationService>().push(Routes.messageSource,
            arguments: service.messageSource, replace: true, fade: true);
    }
  }

  void showSnackBarMessage(String message, [MaterialColor color = Colors.red]) {
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }
}
