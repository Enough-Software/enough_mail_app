import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../account/model.dart';
import '../account/provider.dart';

class AccountSelector extends ConsumerWidget {
  const AccountSelector({
    super.key,
    required this.onChanged,
    required this.account,
    this.excludeAccountsWithErrors = true,
  });
  final RealAccount? account;
  final bool excludeAccountsWithErrors;
  final void Function(RealAccount account) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAccounts = ref.watch(realAccountsProvider);
    final accounts = excludeAccountsWithErrors
        ? allAccounts.where((account) => !account.hasError).toList()
        : allAccounts;

    return PlatformDropdownButton<RealAccount>(
      value: account,
      items: accounts
          .map((account) => DropdownMenuItem<RealAccount>(
                value: account,
                child: Text(account.name),
              ))
          .toList(),
      onChanged: (account) {
        if (account != null) {
          onChanged(account);
        }
      },
    );
  }
}
