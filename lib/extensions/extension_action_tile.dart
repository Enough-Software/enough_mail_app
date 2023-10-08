import 'dart:io';

import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' hide WebViewConfiguration;

import '../account/model.dart';
import '../localization/extension.dart';
import '../locator.dart';
import '../models/models.dart';
import '../routes.dart';
import '../services/navigation_service.dart';
import 'extensions.dart';

class ExtensionActionTile extends StatelessWidget {
  const ExtensionActionTile({super.key, required this.actionDescription});
  final AppExtensionActionDescription actionDescription;

  static Widget buildSideMenuForAccount(
      BuildContext context, RealAccount? currentAccount) {
    if (currentAccount == null || currentAccount.isVirtual) {
      return Container();
    }
    final actions = currentAccount.appExtensionsAccountSideMenu;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: buildActionWidgets(context, actions),
    );
  }

  static List<Widget> buildActionWidgets(
    BuildContext context,
    List<AppExtensionActionDescription> actions, {
    bool withDivider = true,
  }) {
    if (actions.isEmpty) {
      return [];
    }
    final widgets = <Widget>[];
    if (withDivider) {
      widgets.add(const Divider());
    }
    for (final action in actions) {
      widgets.add(ExtensionActionTile(actionDescription: action));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = context.text.localeName;

    return PlatformListTile(
      leading: actionDescription.icon == null
          ? null
          : Image.network(
              actionDescription.icon!,
              height: 24,
              width: 24,
            ),
      title: Text(actionDescription.getLabel(languageCode)!),
      onTap: () {
        final url = actionDescription.action!.url;
        switch (actionDescription.action!.mechanism) {
          case AppExtensionActionMechanism.inApp:
            final navService = locator<NavigationService>();
            if (!(Platform.isIOS || Platform.isMacOS)) {
              // close app drawer:
              navService.pop();
            }
            navService.push(
              Routes.webview,
              arguments: WebViewConfiguration(
                actionDescription.getLabel(languageCode),
                Uri.parse(url),
              ),
            );
            break;
          case AppExtensionActionMechanism.external:
            launchUrl(Uri.parse(url));
            break;
        }
      },
    );
  }
}
