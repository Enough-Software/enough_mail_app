import 'package:enough_mail_app/models/settings.dart';
import 'package:enough_mail_app/services/biometrics_service.dart';
import 'package:enough_mail_app/services/settings_service.dart';
import 'package:enough_mail_app/util/localized_dialog_helper.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../locator.dart';
import 'base.dart';

class SettingsSecurityScreen extends StatefulWidget {
  @override
  _SettingsSecurityScreenState createState() => _SettingsSecurityScreenState();
}

class _SettingsSecurityScreenState extends State<SettingsSecurityScreen> {
  late Settings _settings;
  late bool _blockExternalImages;
  late bool _preferPlainTextMessages;
  late bool _enableBiometricLock;
  late LockTimePreference _lockTimePreference;
  bool? _isBiometricsSupported;
  Future<bool>? _biometricsSupportedFuture;

  @override
  void initState() {
    super.initState();
    final settings = locator<SettingsService>().settings;
    _settings = settings;
    _blockExternalImages = settings.blockExternalImages;
    _preferPlainTextMessages = settings.preferPlainTextMessages;
    _enableBiometricLock = settings.enableBiometricLock;
    _lockTimePreference = settings.lockTimePreference;
    if (_enableBiometricLock) {
      _isBiometricsSupported = true;
    } else {
      _checkBiometricsSupport();
    }
  }

  void _checkBiometricsSupport() async {
    final supported = await locator<BiometricsService>().isDeviceSupported();
    if (mounted) {
      setState(() {
        _isBiometricsSupported = supported;
      });
    }
  }

  String _getLockTimePreferenceName(
      LockTimePreference preference, AppLocalizations localizations) {
    switch (preference) {
      case LockTimePreference.immediately:
        return localizations.securityLockImmediately;
      case LockTimePreference.after5minutes:
        return localizations.securityLockAfter5Minutes;
      case LockTimePreference.after30minutes:
        return localizations.securityLockAfter30Minutes;
    }
  }

  @override
  Widget build(BuildContext context) {
    //final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    return Base.buildAppChrome(
      context,
      title: localizations.securitySettingsTitle,
      content: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(localizations.securitySettingsIntro),
                Divider(),
                Row(
                  children: [
                    Expanded(
                      child: PlatformCheckboxListTile(
                        value: _blockExternalImages,
                        onChanged: (value) async {
                          setState(() {
                            _blockExternalImages = value ?? false;
                          });
                          _settings.blockExternalImages = value;
                          await locator<SettingsService>().save();
                        },
                        title: Text(
                          localizations.settingsSecurityBlockExternalImages,
                        ),
                      ),
                    ),
                    PlatformIconButton(
                      icon: Icon(CommonPlatformIcons.info),
                      onPressed: () => LocalizedDialogHelper.showTextDialog(
                        context,
                        localizations
                            .settingsSecurityBlockExternalImagesDescriptionTitle,
                        localizations
                            .settingsSecurityBlockExternalImagesDescriptionText,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: PlatformDropdownButton<bool>(
                    value: _preferPlainTextMessages,
                    onChanged: (value) async {
                      _settings.preferPlainTextMessages = value ?? false;
                      setState(() {
                        _preferPlainTextMessages = value ?? false;
                      });
                      await locator<SettingsService>().save();
                    },
                    items: [
                      DropdownMenuItem(
                        value: false,
                        child: Text(
                            localizations.settingsSecurityMessageRenderingHtml),
                      ),
                      DropdownMenuItem(
                        value: true,
                        child: Text(localizations
                            .settingsSecurityMessageRenderingPlainText),
                      ),
                    ],
                  ),
                ),
                Divider(),
                if (_isBiometricsSupported == false) ...{
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(localizations.securityUnlockNotAvailable),
                  ),
                } else if (_isBiometricsSupported == true) ...{
                  Row(
                    children: [
                      Expanded(
                        child: PlatformCheckboxListTile(
                          value: _enableBiometricLock,
                          onChanged: (value) async {
                            final enableBiometricLock = (value == true);
                            String? reason = enableBiometricLock
                                ? null
                                : localizations.securityUnlockDisableReason;
                            final didAuthenticate =
                                await locator<BiometricsService>()
                                    .authenticate(reason: reason);
                            if (didAuthenticate) {
                              setState(() {
                                _enableBiometricLock = enableBiometricLock;
                              });
                              _settings.enableBiometricLock =
                                  enableBiometricLock;
                              await locator<SettingsService>().save();
                            }
                          },
                          title: Text(
                            localizations.securityUnlockLabel,
                          ),
                        ),
                      ),
                      PlatformIconButton(
                        icon: Icon(CommonPlatformIcons.info),
                        onPressed: () => LocalizedDialogHelper.showTextDialog(
                          context,
                          localizations.securityUnlockDescriptionTitle,
                          localizations.securityUnlockDescriptionText,
                        ),
                      ),
                    ],
                  ),
                  if (_enableBiometricLock) ...{
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: PlatformDropdownButton<LockTimePreference>(
                        value: _lockTimePreference,
                        onChanged: (value) async {
                          if (value != null) {
                            _settings.lockTimePreference = value;
                            setState(() {
                              _lockTimePreference = value;
                            });
                            await locator<SettingsService>().save();
                          }
                        },
                        items: LockTimePreference.values
                            .map((preference) => DropdownMenuItem(
                                  value: preference,
                                  child: Text(
                                    _getLockTimePreferenceName(
                                        preference, localizations),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  },
                } else ...{
                  const Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                },
              ],
            ),
          ),
        ),
      ),
    );
  }
}
