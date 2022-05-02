import 'package:enough_mail_app/locator.dart';
import 'package:enough_mail_app/services/providers.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.g.dart';

class AccountProviderSelector extends StatelessWidget {
  final void Function(Provider? provider) onSelected;
  const AccountProviderSelector({Key? key, required this.onSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
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
