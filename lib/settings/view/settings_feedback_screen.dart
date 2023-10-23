import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import '../../localization/extension.dart';
import '../../screens/base.dart';
import '../../services/scaffold_messenger_service.dart';
import '../../widgets/button_text.dart';

class SettingsFeedbackScreen extends StatefulWidget {
  const SettingsFeedbackScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsFeedbackScreenState();
}

class _SettingsFeedbackScreenState extends State<SettingsFeedbackScreen> {
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
        'Platform ${Platform.operatingSystem} ${Platform.operatingSystemVersion}\n';
    if (Platform.isAndroid || Platform.isIOS) {
      final deviceInfoPlugin = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        textualInfo +=
            '${androidInfo.manufacturer}/${androidInfo.model} (${androidInfo.device})\nAndroid ${androidInfo.version.release} with API level ${androidInfo.version.sdkInt}';
      } else {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        textualInfo +=
            '${iosInfo.localizedModel}\n${iosInfo.systemName}/${iosInfo.systemVersion}\n';
      }
    }
    setState(() {
      info = textualInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = context.text;

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
                    child:
                        ButtonText(localizations.feedbackActionSuggestFeature),
                    onPressed: () async {
                      await launcher
                          .launchUrl(Uri.parse('https://maily.userecho.com/'));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: PlatformTextButton(
                    child:
                        ButtonText(localizations.feedbackActionReportProblem),
                    onPressed: () async {
                      await launcher
                          .launchUrl(Uri.parse('https://maily.userecho.com/'));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: PlatformTextButton(
                    child:
                        ButtonText(localizations.feedbackActionHelpDeveloping),
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
