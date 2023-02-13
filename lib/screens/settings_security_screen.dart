import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:enough_mail_app/models/settings.dart';
import 'package:enough_mail_app/services/biometrics_service.dart';
import 'package:enough_mail_app/services/settings_service.dart';
import 'package:enough_mail_app/util/localized_dialog_helper.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.g.dart';
import '../locator.dart';
import 'base.dart';

class SettingsSecurityScreen extends StatefulWidget {
  const SettingsSecurityScreen({Key? key}) : super(key: key);

  @override
  State<SettingsSecurityScreen> createState() => _SettingsSecurityScreenState();
}

class _SettingsSecurityScreenState extends State<SettingsSecurityScreen> {
  late bool _blockExternalImages;
  late bool _preferPlainTextMessages;
  late bool _enableBiometricLock;
  late LockTimePreference _lockTimePreference;
  late launcher.LaunchMode _urlLaunchMode;
  bool? _isBiometricsSupported;
  // Future<bool>? _biometricsSupportedFuture;

  @override
  void initState() {
    super.initState();
    final settings = locator<SettingsService>().settings;
    _blockExternalImages = settings.blockExternalImages;
    _preferPlainTextMessages = settings.preferPlainTextMessages;
    _enableBiometricLock = settings.enableBiometricLock;
    _lockTimePreference = settings.lockTimePreference;
    _urlLaunchMode = settings.urlLaunchMode;
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 4.0,
                  ),
                  child: Text(localizations.securitySettingsIntro),
                ),
                const Divider(),
                Row(
                  children: [
                    Expanded(
                      child: PlatformCheckboxListTile(
                        value: _blockExternalImages,
                        onChanged: (value) async {
                          setState(() {
                            _blockExternalImages = value ?? false;
                          });
                          final service = locator<SettingsService>();
                          service.settings = service.settings
                              .copyWith(blockExternalImages: value);
                          await service.save();
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
                      final service = locator<SettingsService>();
                      service.settings = service.settings
                          .copyWith(preferPlainTextMessages: value ?? false);
                      setState(() {
                        _preferPlainTextMessages = value ?? false;
                      });
                      await service.save();
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
                const Divider(),
                if (_isBiometricsSupported == false)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(localizations.securityUnlockNotAvailable),
                  )
                else if (_isBiometricsSupported == true) ...[
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
                              final service = locator<SettingsService>();
                              service.settings = service.settings.copyWith(
                                  enableBiometricLock: enableBiometricLock);
                              await service.save();
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
                  if (_enableBiometricLock)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: PlatformDropdownButton<LockTimePreference>(
                        value: _lockTimePreference,
                        onChanged: (value) async {
                          if (value != null) {
                            final service = locator<SettingsService>();
                            service.settings = service.settings
                                .copyWith(lockTimePreference: value);
                            setState(() {
                              _lockTimePreference = value;
                            });
                            await service.save();
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
                ] else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 4.0),
                  child: Text(localizations.settingsSecurityLaunchModeLabel),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: PlatformDropdownButton<launcher.LaunchMode>(
                    value: _urlLaunchMode,
                    onChanged: (value) async {
                      if (value != null) {
                        final service = locator<SettingsService>();
                        service.settings =
                            service.settings.copyWith(urlLaunchMode: value);
                        setState(() {
                          _urlLaunchMode = value;
                        });
                        await service.save();
                      }
                    },
                    items: [
                      DropdownMenuItem(
                        value: launcher.LaunchMode.externalApplication,
                        child: Text(
                            localizations.settingsSecurityLaunchModeExternal),
                      ),
                      DropdownMenuItem(
                        value: launcher.LaunchMode.inAppWebView,
                        child:
                            Text(localizations.settingsSecurityLaunchModeInApp),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
