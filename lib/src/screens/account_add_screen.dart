import 'dart:async';

import 'package:enough_mail/enough_mail.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import '../account/model.dart';
import '../account/provider.dart';
import '../extensions/extensions.dart';
import '../hoster/service.dart';
import '../localization/app_localizations.g.dart';
import '../localization/extension.dart';
import '../logger.dart';
import '../mail/provider.dart';
import '../oauth/oauth.dart';
import '../routes/routes.dart';
import '../util/modal_bottom_sheet_helper.dart';
import '../util/validator.dart';
import '../widgets/account_hoster_selector.dart';
import '../widgets/password_field.dart';
import 'base.dart';

/// Adds a new account
class AccountAddScreen extends ConsumerStatefulWidget {
  /// Creates a new [AccountAddScreen]
  const AccountAddScreen({
    super.key,
  });

  @override
  ConsumerState<AccountAddScreen> createState() => _AccountAddScreenState();
}

class _AccountAddScreenState extends ConsumerState<AccountAddScreen> {
  static const int _stepEmail = 0;
  static const int _stepPassword = 1;
  static const int _stepAccountSetup = 2;

  late int _availableSteps;
  int _currentStep = 0;
  int _progressedSteps = 0;
  bool _isContinueAvailable = false;
  bool? _isApplicationSpecificPasswordAcknowledged = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _userNameController = TextEditingController();
  final _accountNameNode = FocusNode();

  bool _isProviderResolving = false;
  MailHoster? _mailHoster;
  final _isManualSettings = false;
  bool _isAccountVerifying = false;
  bool _isAccountVerified = false;
  MailClient? _mailClient;
  AppExtensionActionDescription? _extensionForgotPassword;

  RealAccount? _realAccount;

  Future<void> _navigateToManualSettings(
    BuildContext context,
    AppLocalizations localizations,
  ) async {
    final selectedHoster =
        await ModelBottomSheetHelper.showModalBottomSheet<MailHoster>(
      context,
      localizations.accountProviderStepTitle,
      MailHosterSelector(
        onSelected: (hoster) {
          context.pop(hoster);
        },
      ),
      useScrollView: false,
      appBarActions: [],
    );
    if (selectedHoster != null) {
      // a standard hoster has been chosen,
      // now query the password or start the oauth process:
      setState(() {
        _mailHoster = selectedHoster;
      });
      _onMailHosterChanged(selectedHoster, _emailController.text);
    } else {
      final account = MailAccount(
        email: _emailController.text.trim(),
        name: _userNameController.text.trim(),
        incoming: const MailServerConfig(
          authentication: PlainAuthentication('', ''),
          serverConfig: ServerConfig.empty(),
        ),
        outgoing: const MailServerConfig(
          authentication: PlainAuthentication('', ''),
          serverConfig: ServerConfig.empty(),
        ),
      );
      if (context.mounted) {
        final editResult = await context.pushNamed<ConnectedAccount>(
          Routes.accountServerDetails,
          extra: RealAccount(account),
        );
        if (editResult is ConnectedAccount) {
          setState(() {
            _realAccount = RealAccount(editResult.mailAccount);
            _mailClient = editResult.mailClient;
            _currentStep = 2;
            _isAccountVerified = true;
          });
        }
      }
    }
  }

  @override
  void initState() {
    _availableSteps = 3;
    final accounts = ref.read(realAccountsProvider);
    if (accounts.isNotEmpty) {
      _userNameController.text = accounts.first.userName ?? '';
    }
    super.initState();
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _userNameController.dispose();
    _accountNameNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print('build: current step=$_currentStep');
    final localizations = ref.text;

    return BasePage(
      title: localizations.addAccountTitle,
      content: Column(
        children: [
          Expanded(
            child: PlatformStepper(
              onStepContinue: _isContinueAvailable
                  ? () async {
                      final step = _currentStep + 1;
                      await _onStepProgressed(step);
                    }
                  : null,
              onStepCancel: () => context.pop(),
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
                _buildEmailStep(context, localizations),
                _buildPasswordStep(context, localizations),
                _buildAccountSetupStep(context, localizations),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onStepProgressed(int step) async {
    if (step < _availableSteps) {
      setState(() {
        _currentStep = step;
        _isContinueAvailable = false;
      });
    }
    _progressedSteps = step;
    switch (step - 1) {
      case _stepEmail:
        await _discover(_emailController.text);
        break;
      case _stepPassword:
        final mailHoster = _mailHoster;
        if (mailHoster != null) {
          await _verifyAccount(mailHoster);
        }
        break;
      case _stepAccountSetup:
        await _finalizeAccount();
        break;
    }
  }

  Future _discover(String email) async {
    // email address has been entered
    if (!_isProviderResolving) {
      setState(() {
        _isProviderResolving = true;
      });
    }
    if (kDebugMode) {
      print('discover settings for $email');
    }
    final provider = await MailHosterService.instance.discover(email);
    if (!mounted) {
      // ignore if user has cancelled operation
      return;
    }
    if (kDebugMode) {
      print('done discovering settings: ${provider?.displayName}');
    }
    if (provider?.appSpecificPasswordSetupUrl != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
    _isApplicationSpecificPasswordAcknowledged = false;
    final domainName = email.substring(email.lastIndexOf('@') + 1);
    _accountNameController.text = domainName;
    if (provider != null) {
      _onMailHosterChanged(provider, email);
    }

    setState(() {
      _isProviderResolving = false;
      _mailHoster = provider;
      _isContinueAvailable =
          (provider != null) && _passwordController.text.isNotEmpty;
    });
  }

  Future _loginWithOAuth(
    MailHoster mailHoster,
    OauthClient oauthClient,
    String email,
  ) async {
    setState(() {
      _isAccountVerifying = true;
      _currentStep = _stepAccountSetup;
      _progressedSteps = _stepAccountSetup;
    });
    final token = await oauthClient.authenticate(email);

    // when the user either has cancelled the verification,
    // not granted the scope or the verification failed for other reasons,
    // then token will be null
    if (token == null) {
      setState(() {
        _isAccountVerifying = false;
        _currentStep = _stepPassword;
        _progressedSteps = _stepAccountSetup;
      });
    } else {
      final domainName = email.substring(email.lastIndexOf('@') + 1);
      final mailAccount = MailAccount.fromDiscoveredSettingsWithAuth(
        name: domainName,
        email: email,
        auth: OauthAuthentication(email, token),
        config: mailHoster.clientConfig,
      );
      final connectedAccount = await ref.read(
        firstTimeMailClientSourceProvider(
          account: RealAccount(mailAccount),
        ).future,
      );
      _mailClient = connectedAccount?.mailClient;
      final isVerified = _mailClient?.isConnected ?? false;
      if (connectedAccount != null && isVerified) {
        if (mailHoster is GmailMailHoster || mailHoster is OutlookMailHoster) {
          _realAccount = connectedAccount;
        } else {
          try {
            final extensions = await AppExtension.loadFor(mailAccount);
            _realAccount = connectedAccount.copyWith(appExtensions: extensions);
          } catch (e, s) {
            logger.e(
              'Unable to load app extensions for ${mailAccount.email}: $e',
              error: e,
              stackTrace: s,
            );
          }
        }
      } else {
        FocusManager.instance.primaryFocus?.unfocus();
      }
      setState(() {
        _isAccountVerifying = false;
        _isAccountVerified = isVerified;
        _isContinueAvailable =
            isVerified && _userNameController.text.trim().isNotEmpty;
      });
    }
  }

  Future _verifyAccount(MailHoster mailHoster) async {
    // password and possibly manual account details have been specified
    setState(() {
      _isAccountVerifying = true;
    });
    final mailAccount = MailAccount.fromDiscoveredSettings(
      name: _emailController.text,
      userName: _emailController.text,
      email: _emailController.text,
      password: _passwordController.text,
      config: mailHoster.clientConfig,
    );
    final connectedAccount = await ref.read(
      firstTimeMailClientSourceProvider(
        account: RealAccount(mailAccount),
      ).future,
    );
    _mailClient = connectedAccount?.mailClient;

    final isVerified = _mailClient?.isConnected ?? false;
    if (connectedAccount != null && isVerified) {
      final extensions = await AppExtension.loadFor(mailAccount);
      _realAccount = connectedAccount.copyWith(appExtensions: extensions);
    } else {
      FocusManager.instance.primaryFocus?.unfocus();
    }
    setState(() {
      _isAccountVerifying = false;
      _isAccountVerified = isVerified;
      _isContinueAvailable =
          isVerified && _userNameController.text.trim().isNotEmpty;
    });
  }

  Future _finalizeAccount() async {
    final account = _realAccount;
    final mailClient = _mailClient;
    if (account == null || mailClient == null) {
      if (kDebugMode) {
        print('No account or mail client available');
      }

      return;
    }
    // Account name has been specified
    account
      ..name = _accountNameController.text.trim()
      ..userName = _userNameController.text.trim();
    ref.read(realAccountsProvider.notifier).addAccount(account);

    if (PlatformInfo.isCupertino) {
      context.goNamed(Routes.appDrawer);
      unawaited(
        context.pushNamed(
          Routes.mailForAccount,
          pathParameters: {Routes.pathParameterEmail: account.key},
        ),
      );
    } else {
      context.pushReplacementNamed(
        Routes.mailForAccount,
        pathParameters: {Routes.pathParameterEmail: account.key},
      );
    }
  }

  Step _buildEmailStep(BuildContext context, AppLocalizations localizations) =>
      Step(
        title: _currentStep == 0
            ? Text(localizations.addAccountEmailLabel)
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(localizations.addAccountEmailLabel),
                  Text(
                    _emailController.text,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
        content: Column(
          children: [
            DecoratedPlatformTextField(
              autocorrect: false,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              cupertinoShowLabel: false,
              onChanged: (value) {
                final isValid = Validator.validateEmail(value);
                final account = _realAccount;
                if (isValid && account != null) {
                  account.email = value;
                }
                if (isValid != _isContinueAvailable) {
                  setState(() {
                    _isContinueAvailable = isValid;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: localizations.addAccountEmailLabel,
                hintText: localizations.addAccountEmailHint,
                icon: const Icon(Icons.email),
              ),
              autofocus: true,
              onSubmitted: (value) {
                if (_isContinueAvailable) {
                  _onStepProgressed(1);
                }
              },
            ),
          ],
        ),
        //state: StepState.editing,
        isActive: true,
      );

  Step _buildPasswordStep(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    final mailHoster = _mailHoster;
    final oauthClient = mailHoster?.oauthClient;
    final appSpecificPasswordSetupUrl = mailHoster?.appSpecificPasswordSetupUrl;
    final extensionForgotPassword = _extensionForgotPassword;

    return Step(
      title: Text(localizations.addAccountPasswordLabel),
      //state: StepState.complete,
      isActive: _currentStep >= 1,
      content: Column(
        children: [
          if (_isProviderResolving)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  child: const PlatformProgressIndicator(),
                ),
                Expanded(
                  child: Text(
                    localizations.addAccountResolvingSettingsLabel(
                      _emailController.text,
                    ),
                  ),
                ),
              ],
            )
          else if (mailHoster != null)
            _buildPasswordStepWithMailHoster(
              oauthClient,
              localizations,
              mailHoster,
              context,
              appSpecificPasswordSetupUrl,
              extensionForgotPassword,
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.addAccountResolvingSettingsFailedInfo(
                    _emailController.text,
                  ),
                ),
                PlatformElevatedButton(
                  child: Text(localizations.addAccountEditManuallyAction),
                  onPressed: () =>
                      _navigateToManualSettings(context, localizations),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Column _buildPasswordStepWithMailHoster(
    OauthClient? oauthClient,
    AppLocalizations localizations,
    MailHoster mailHoster,
    BuildContext context,
    String? appSpecificPasswordSetupUrl,
    AppExtensionActionDescription? extensionForgotPassword,
  ) =>
      Column(
        children: [
          if (oauthClient != null)
            ..._buildOauthAuthenticationSection(
              localizations,
              mailHoster,
              context,
              oauthClient,
              appSpecificPasswordSetupUrl,
            )
          else if (mailHoster.appSpecificPasswordSetupUrl != null)
            ..._buildAppSpecificPasswordSection(localizations, mailHoster),
          if (mailHoster.appSpecificPasswordSetupUrl == null ||
              (_isApplicationSpecificPasswordAcknowledged ?? false))
            PasswordField(
              controller: _passwordController,
              cupertinoShowLabel: false,
              onChanged: (value) {
                final bool isValid = value.isNotEmpty &&
                    (_mailHoster?.clientConfig != null || _isManualSettings);
                if (isValid != _isContinueAvailable) {
                  setState(() {
                    _isContinueAvailable = isValid;
                  });
                }
              },
              autofocus: true,
              labelText: localizations.addAccountPasswordLabel,
              hintText: localizations.addAccountPasswordHint,
              onSubmitted: (value) {
                if (_isContinueAvailable) {
                  _onStepProgressed(2);
                }
              },
            ),
          PlatformTextButton(
            onPressed: () => _navigateToManualSettings(context, localizations),
            child: Text(
              localizations.addAccountResolvedSettingsWrongAction(
                _mailHoster?.displayName ?? '<unknown>',
              ),
            ),
          ),
          if (extensionForgotPassword != null)
            PlatformTextButton(
              onPressed: () {
                final languageCode = localizations.localeName;
                final url = (extensionForgotPassword.action?.url ?? '')
                    .replaceAll('{user.email}', _emailController.text)
                    .replaceAll('{language}', languageCode);
                launcher.launchUrl(Uri.parse(url));
              },
              child: Text(
                extensionForgotPassword.getLabel(localizations.localeName) ??
                    '',
              ),
            ),
        ],
      );

  List<Widget> _buildAppSpecificPasswordSection(
    AppLocalizations localizations,
    MailHoster mailHoster,
  ) =>
      [
        Text(localizations.addAccountApplicationPasswordRequiredInfo),
        PlatformTextButton(
          onPressed: () async {
            await launcher.launchUrl(
              Uri.parse(mailHoster.appSpecificPasswordSetupUrl ?? ''),
            );
          },
          child: Text(
            localizations.addAccountApplicationPasswordRequiredButton,
          ),
        ),
        PlatformCheckboxListTile(
          onChanged: (value) => setState(
            () => _isApplicationSpecificPasswordAcknowledged = value,
          ),
          value: _isApplicationSpecificPasswordAcknowledged,
          title: Text(
            localizations.addAccountApplicationPasswordRequiredAcknowledged,
          ),
        ),
      ];

  List<Widget> _buildOauthAuthenticationSection(
    AppLocalizations localizations,
    MailHoster mailHoster,
    BuildContext context,
    OauthClient oauthClient,
    String? appSpecificPasswordSetupUrl,
  ) =>
      [
        // The user can continue to sign in with the provider
        // or by using an app-specific password
        Text(
          localizations.addAccountOauthOptionsText(
            mailHoster.displayName ?? '<unknown>',
          ),
        ),
        FittedBox(
          child: mailHoster.buildSignInButton(
            ref,
            onPressed: () => _loginWithOAuth(
              mailHoster,
              oauthClient,
              _emailController.text,
            ),
            isSignInButton: true,
          ),
        ),
        if (appSpecificPasswordSetupUrl != null) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              localizations.addAccountOauthSignInWithAppPassword,
            ),
          ),
          PlatformTextButton(
            onPressed: () async {
              await launcher.launchUrl(Uri.parse(appSpecificPasswordSetupUrl));
            },
            child: Text(
              localizations.addAccountApplicationPasswordRequiredButton,
            ),
          ),
          PlatformCheckboxListTile(
            onChanged: (value) => setState(
              () => _isApplicationSpecificPasswordAcknowledged = value,
            ),
            value: _isApplicationSpecificPasswordAcknowledged,
            title: Text(
              localizations.addAccountApplicationPasswordRequiredAcknowledged,
            ),
          ),
        ],
      ];

  Step _buildAccountSetupStep(
    BuildContext context,
    AppLocalizations localizations,
  ) =>
      Step(
        title: Text(_isAccountVerified
            ? localizations.addAccountSetupAccountStep
            : localizations.addAccountVerificationStep),
        content: Column(
          children: [
            if (_isAccountVerifying)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: const PlatformProgressIndicator(),
                  ),
                  Expanded(
                    child: Text(
                      localizations.addAccountVerifyingSettingsLabel(
                        _emailController.text,
                      ),
                    ),
                  ),
                ],
              )
            else if (_isAccountVerified)
              ..._buildAccountVerifiedSection(localizations)
            else
              ..._buildAccountVerificationFailedSection(localizations),
          ],
        ),
      );

  List<Widget> _buildAccountVerificationFailedSection(
    AppLocalizations localizations,
  ) =>
      [
        Text(
          localizations.addAccountVerifyingFailedInfo(
            _emailController.text,
          ),
        ),
        if (_mailHoster?.manualImapAccessSetupUrl != null) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
              localizations.accountAddImapAccessSetupMightBeRequired,
            ),
          ),
          PlatformTextButton(
            child: Text(
              localizations.addAccountSetupImapAccessButtonLabel,
            ),
            onPressed: () => launcher.launchUrl(
              Uri.parse(_mailHoster?.manualImapAccessSetupUrl ?? ''),
            ),
          ),
        ],
      ];

  List<Widget> _buildAccountVerifiedSection(AppLocalizations localizations) => [
        Text(
          localizations.addAccountVerifyingSuccessInfo(
            _emailController.text,
          ),
        ),
        DecoratedPlatformTextField(
          controller: _userNameController,
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.words,
          onChanged: (value) {
            final bool isValid = value.trim().isNotEmpty &&
                _accountNameController.text.trim().isNotEmpty;
            if (isValid != _isContinueAvailable) {
              setState(() {
                _isContinueAvailable = isValid;
              });
            }
          },
          decoration: InputDecoration(
            labelText: localizations.addAccountNameOfUserLabel,
            hintText: localizations.addAccountNameOfUserHint,
            icon: const Icon(Icons.account_circle),
          ),
          autofocus: true,
          cupertinoAlignLabelOnTop: true,
          onSubmitted: (_) => _accountNameNode.requestFocus(),
        ),
        DecoratedPlatformTextField(
          focusNode: _accountNameNode,
          controller: _accountNameController,
          keyboardType: TextInputType.text,
          onChanged: (value) {
            final bool isValid =
                value.isNotEmpty && _userNameController.text.trim().isNotEmpty;
            if (isValid != _isContinueAvailable) {
              setState(() {
                _isContinueAvailable = isValid;
              });
            }
          },
          decoration: InputDecoration(
            labelText: localizations.addAccountNameOfAccountLabel,
            hintText: localizations.addAccountNameOfAccountHint,
            icon: const Icon(Icons.email),
          ),
          cupertinoAlignLabelOnTop: true,
          onSubmitted: (_) {
            if (_isContinueAvailable) {
              _onStepProgressed(3);
            }
          },
        ),
      ];

  void _onMailHosterChanged(MailHoster provider, String email) {
    final email = _emailController.text.trim();
    final mailAccount = MailAccount.fromDiscoveredSettings(
      name: email,
      email: email,
      userName: email,
      password: _passwordController.text,
      config: provider.clientConfig,
    );
    final realAccount = RealAccount(mailAccount);
    _realAccount = realAccount;
    AppExtension.loadFor(mailAccount).then((value) {
      realAccount.appExtensions = value;
      final forgotPwUrl = realAccount.appExtensionForgotPassword;
      if (forgotPwUrl != null) {
        setState(() {
          _extensionForgotPassword = forgotPwUrl;
        });
      }
    });
  }
}
