import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../hoster/service.dart';
import '../localization/extension.dart';

/// Allows to select a mail hoster
class MailHosterSelector extends ConsumerWidget {
  /// Creates a [MailHosterSelector]
  const MailHosterSelector({super.key, required this.onSelected});

  /// Called when a mail hoster has been selected
  final void Function(MailHoster? hoster) onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = ref.text;
    final hosters = MailHosterService.instance.hosters;

    return ListView.separated(
      itemBuilder: (context, index) {
        if (index == 0) {
          return Center(
            child: PlatformTextButton(
              child: Text(localizations.accountProviderCustom),
              onPressed: () => onSelected(null),
            ),
          );
        }
        final provider = hosters[index - 1];

        return Center(
          child: provider.buildSignInButton(
            ref,
            onPressed: () => onSelected(provider),
          ),
        );
      },
      separatorBuilder: (context, index) => const Divider(),
      itemCount: hosters.length + 1,
    );
  }
}
