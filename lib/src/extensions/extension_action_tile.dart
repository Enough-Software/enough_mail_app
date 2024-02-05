import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart' hide WebViewConfiguration;

import '../account/model.dart';
import '../localization/extension.dart';
import '../models/models.dart';
import '../routes/routes.dart';
import 'extensions.dart';

class ExtensionActionTile extends ConsumerWidget {
  const ExtensionActionTile({super.key, required this.actionDescription});
  final AppExtensionActionDescription actionDescription;

  static Widget buildSideMenuForAccount(
    BuildContext context,
    RealAccount? currentAccount,
  ) {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.text.localeName;
    final icon = actionDescription.icon;

    return PlatformListTile(
      leading: icon == null
          ? null
          : Image.network(
              icon,
              height: 24,
              width: 24,
            ),
      title: Text(actionDescription.getLabel(languageCode) ?? ''),
      onTap: () {
        final action = actionDescription.action;
        if (action == null) {
          return;
        }

        final url = action.url;
        switch (action.mechanism) {
          case AppExtensionActionMechanism.inApp:
            final context = Routes.navigatorKey.currentContext;
            if (context != null) {
              if (!useAppDrawerAsRoot) {
                // close app drawer:
                context.pop();
              }
              context.pushNamed(
                Routes.webview,
                extra: WebViewConfiguration(
                  actionDescription.getLabel(languageCode),
                  Uri.parse(url),
                ),
              );
            }

            break;
          case AppExtensionActionMechanism.external:
            launchUrl(Uri.parse(url));
            break;
        }
      },
    );
  }
}
