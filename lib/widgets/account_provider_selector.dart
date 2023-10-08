import '../l10n/extension.dart';
import '../locator.dart';
import '../services/providers.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';

class AccountProviderSelector extends StatelessWidget {
  const AccountProviderSelector({super.key, required this.onSelected});
  final void Function(Provider? provider) onSelected;

  @override
  Widget build(BuildContext context) {
    final localizations = context.text;
    final providers = locator<ProviderService>().providers;

    return ListView.separated(
      itemBuilder: (context, index) {
        if (index == 0) {
          return Center(
            child: PlatformTextButton(
              child: PlatformText(localizations.accountProviderCustom),
              onPressed: () => onSelected(null),
            ),
          );
        }
        final provider = providers[index - 1];
        return Center(
          child: provider.buildSignInButton(
            context,
            onPressed: () => onSelected(provider),
          ),
        );
      },
      separatorBuilder: (context, index) => const Divider(),
      itemCount: providers.length + 1,
    );
  }
}
