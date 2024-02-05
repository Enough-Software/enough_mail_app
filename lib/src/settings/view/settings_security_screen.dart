import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import '../../app_lifecycle/provider.dart';
import '../../localization/extension.dart';
import '../../lock/provider.dart';
import '../../lock/service.dart';
import '../../screens/base.dart';
import '../../util/localized_dialog_helper.dart';
import '../model.dart';
import '../provider.dart';

class SettingsSecurityScreen extends HookConsumerWidget {
  const SettingsSecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = ref.text;
    final settings = ref.watch(settingsProvider);
    final isBiometricsSupported = useState<bool?>(null);
    useMemoized(() async {
      final supported = await BiometricsService.instance.isDeviceSupported();
      isBiometricsSupported.value = supported;
    });

    String getLockTimePreferenceName(LockTimePreference preference) {
      switch (preference) {
        case LockTimePreference.immediately:
          return localizations.securityLockImmediately;
        case LockTimePreference.after5minutes:
          return localizations.securityLockAfter5Minutes;
        case LockTimePreference.after30minutes:
          return localizations.securityLockAfter30Minutes;
      }
    }

    return BasePage(
      title: localizations.securitySettingsTitle,
      content: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  child: Text(
                    localizations.securitySettingsIntro,
                  ),
                ),
                const Divider(),
                Row(
                  children: [
                    Expanded(
                      child: PlatformCheckboxListTile(
                        value: settings.blockExternalImages,
                        onChanged: (value) {
                          ref.read(settingsProvider.notifier).update(
                                settings.copyWith(
                                  blockExternalImages: value ?? false,
                                ),
                              );
                        },
                        title: Text(
                          localizations.settingsSecurityBlockExternalImages,
                        ),
                      ),
                    ),
                    PlatformIconButton(
                      icon: Icon(CommonPlatformIcons.info),
                      onPressed: () => LocalizedDialogHelper.showTextDialog(
                        ref,
                        localizations
                            .settingsSecurityBlockExternalImagesDescriptionTitle,
                        localizations
                            .settingsSecurityBlockExternalImagesDescriptionText,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: PlatformDropdownButton<bool>(
                    value: settings.preferPlainTextMessages,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).update(
                            settings.copyWith(
                              preferPlainTextMessages: value ?? false,
                            ),
                          );
                    },
                    items: [
                      DropdownMenuItem(
                        value: false,
                        child: Text(
                          localizations.settingsSecurityMessageRenderingHtml,
                        ),
                      ),
                      DropdownMenuItem(
                        value: true,
                        child: Text(
                          localizations
                              .settingsSecurityMessageRenderingPlainText,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                if (!(isBiometricsSupported.value ?? false))
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(localizations.securityUnlockNotAvailable),
                  )
                else if (isBiometricsSupported.value ?? false) ...[
                  Row(
                    children: [
                      Expanded(
                        child: PlatformCheckboxListTile(
                          value: settings.enableBiometricLock,
                          onChanged: (value) async {
                            final enableBiometricLock = value ?? false;
                            final String? reason = enableBiometricLock
                                ? null
                                : localizations.securityUnlockDisableReason;
                            ref
                                .read(appLifecycleProvider.notifier)
                                .ignoreNextInactivationCycle();
                            final didAuthenticate =
                                await BiometricsService.instance.authenticate(
                              localizations,
                              reason: reason,
                            );
                            if (didAuthenticate) {
                              if (enableBiometricLock && context.mounted) {
                                AppLock.ignoreNextSettingsChange = true;
                              }
                              await ref.read(settingsProvider.notifier).update(
                                    settings.copyWith(
                                      enableBiometricLock: enableBiometricLock,
                                    ),
                                  );
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
                          ref,
                          localizations.securityUnlockDescriptionTitle,
                          localizations.securityUnlockDescriptionText,
                        ),
                      ),
                    ],
                  ),
                  if (settings.enableBiometricLock)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: PlatformDropdownButton<LockTimePreference>(
                        value: settings.lockTimePreference,
                        onChanged: (value) {
                          ref.read(settingsProvider.notifier).update(
                                settings.copyWith(
                                  lockTimePreference: value,
                                ),
                              );
                        },
                        items: LockTimePreference.values
                            .map((preference) => DropdownMenuItem(
                                  value: preference,
                                  child: Text(
                                    getLockTimePreferenceName(preference),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                ] else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
                  child: Text(localizations.settingsSecurityLaunchModeLabel),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: PlatformDropdownButton<launcher.LaunchMode>(
                    value: settings.urlLaunchMode,
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(settingsProvider.notifier).update(
                              settings.copyWith(
                                urlLaunchMode: value,
                              ),
                            );
                      }
                    },
                    items: [
                      DropdownMenuItem(
                        value: launcher.LaunchMode.externalApplication,
                        child: Text(
                          localizations.settingsSecurityLaunchModeExternal,
                        ),
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
