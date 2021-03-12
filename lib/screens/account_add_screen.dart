import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/events/account_add_event.dart';
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
import 'package:url_launcher/url_launcher.dart' as launcher;

class AccountAddScreen extends StatefulWidget {
  @override
  _AccountAddScreenState createState() => _AccountAddScreenState();
}

class _AccountAddScreenState extends State<AccountAddScreen> {
  MailAccount account = MailAccount();
  int _availableSteps;
  int _currentStep = 0;
  int _progressedSteps = 0;
  bool _isContinueAvailable = false;
  String _providerAppplicationPasswordUrl;
  bool _isApplicationSpecificPasswordAcknowledged = false;
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
  void initState() {
    _availableSteps = 3;
    if (locator<MailService>().accounts?.isNotEmpty ?? false) {
      _userNameController.text = locator<MailService>().accounts.first.userName;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('build: current step=$_currentStep');
    return Base.buildAppChrome(
      context,
      title: 'Add Account',
      content: Column(
        children: [
          Expanded(
            child: Stepper(
              type: StepperType.vertical,
              onStepContinue: _isContinueAvailable
                  ? () async {
                      var step = _currentStep + 1;
                      if (step < _availableSteps) {
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
              steps: [
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
                  isActive: true,
                ),
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
                            if (_providerAppplicationPasswordUrl != null) ...{
                              Text(
                                  'For this provider you need to set up an app specific password.'),
                              ElevatedButton(
                                onPressed: () async {
                                  await launcher
                                      .launch(_providerAppplicationPasswordUrl);
                                },
                                child: Text('Setup app specific password'),
                              ),
                              CheckboxListTile(
                                onChanged: (value) => setState(() =>
                                    _isApplicationSpecificPasswordAcknowledged =
                                        value),
                                value:
                                    _isApplicationSpecificPasswordAcknowledged,
                                title: Text('Understood'),
                              ),
                            },
                            if (_providerAppplicationPasswordUrl == null ||
                                _isApplicationSpecificPasswordAcknowledged) ...{
                              PasswordField(
                                controller: _passwordController,
                                onChanged: (value) {
                                  bool isValid = value.isNotEmpty &&
                                      (_clientConfig != null ||
                                          _isManualSettings);
                                  if (isValid != _isContinueAvailable) {
                                    setState(() {
                                      _isContinueAvailable = isValid;
                                    });
                                  }
                                },
                                labelText: 'Password',
                                hintText: 'Please enter your password',
                              ),
                              ElevatedButton(
                                onPressed: navigateToManualSettings,
                                child: Text(
                                    'Not on ${_clientConfig?.displayName}?'),
                              ),
                            },
                          ],
                        ),
                      } else ...{
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Unable to resolve ${account.email}. Please go back to change it or set up the account manually.'),
                            ElevatedButton(
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
                            bool isValid = value.isNotEmpty &&
                                _userNameController.text.isNotEmpty;
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
              ],
            ),
          )
        ],
      ),
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
        final clientConfig =
            await Discover.discover(account.email, isLogEnabled: true);
        print('done discovering settings: ${clientConfig?.displayName}');
        final incomingHostname =
            clientConfig?.preferredIncomingServer?.hostname;
        if (incomingHostname != null) {
          print('incoming host: $incomingHostname');
          _providerAppplicationPasswordUrl = <String, String>{
            'outlook.office365.com':
                'https://support.microsoft.com/account-billing/using-app-passwords-with-apps-that-don-t-support-two-step-verification-5896ed9b-4263-e681-128a-a6f2979a7944',
            'imap.yahoo.com': 'https://help.yahoo.com/kb/SLN15241.html',
            'imap.gmail.com':
                'https://support.google.com/accounts/answer/185833'
          }[incomingHostname];
          _isApplicationSpecificPasswordAcknowledged = false;
        }
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
}
