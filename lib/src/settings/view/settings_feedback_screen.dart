import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import '../../localization/extension.dart';
import '../../scaffold_messenger/service.dart';
import '../../screens/base.dart';

class SettingsFeedbackScreen extends StatefulHookConsumerWidget {
  const SettingsFeedbackScreen({super.key});

  @override
  ConsumerState<SettingsFeedbackScreen> createState() =>
      _SettingsFeedbackScreenState();
}

class _SettingsFeedbackScreenState
    extends ConsumerState<SettingsFeedbackScreen> {
  String? info;

  @override
  void initState() {
    super.initState();
    _loadAppInformation();
  }

  Future<void> _loadAppInformation() async {
    final packageInfo = await PackageInfo.fromPlatform();
    var textualInfo =
        'Maily v${packageInfo.version}+${packageInfo.buildNumber}\n'
        'Platform '
        '${Platform.operatingSystem} ${Platform.operatingSystemVersion}\n';
    final deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      textualInfo += '${androidInfo.manufacturer}/${androidInfo.model} '
          '(${androidInfo.device})\nAndroid ${androidInfo.version.release} '
          'with API level ${androidInfo.version.sdkInt}';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;
      textualInfo += '${iosInfo.localizedModel}\n'
          '${iosInfo.systemName}/${iosInfo.systemVersion}\n';
    } else if (Platform.isWindows) {
      final windowsInfo = await deviceInfoPlugin.windowsInfo;
      textualInfo += '${windowsInfo.productName}\n${windowsInfo.majorVersion}.'
          '${windowsInfo.minorVersion} ${windowsInfo.displayVersion}\n';
    } else if (Platform.isMacOS) {
      final macOsInfo = await deviceInfoPlugin.macOsInfo;
      textualInfo += '${macOsInfo.model}\n'
          'MacOS ${macOsInfo.majorVersion}.${macOsInfo.minorVersion} '
          '${macOsInfo.osRelease}\n';
    }
    setState(() {
      info = textualInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = ref.text;

    return BasePage(
      title: localizations.feedbackTitle,
      content: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    localizations.feedbackIntro,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (info == null)
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: PlatformProgressIndicator(),
                  )
                else ...[
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      localizations.feedbackProvideInfoRequest,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(info ?? ''),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: PlatformIconButton(
                      icon: Icon(CommonPlatformIcons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: info ?? ''));
                        ScaffoldMessengerService.instance.showTextSnackBar(
                          localizations,
                          localizations.feedbackResultInfoCopied,
                        );
                      },
                    ),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: PlatformTextButton(
                    child: Text(localizations.feedbackActionSuggestFeature),
                    onPressed: () async {
                      await launcher
                          .launchUrl(Uri.parse('https://maily.userecho.com/'));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: PlatformTextButton(
                    child: Text(localizations.feedbackActionReportProblem),
                    onPressed: () async {
                      await launcher
                          .launchUrl(Uri.parse('https://maily.userecho.com/'));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: PlatformTextButton(
                    child: Text(localizations.feedbackActionHelpDeveloping),
                    onPressed: () async {
                      await launcher.launchUrl(
                        Uri.parse(
                          'https://github.com/Enough-Software/enough_mail_app',
                        ),
                      );
                    },
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
