import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';

import '../account/model.dart';
import '../locator.dart';
import '../services/mail_service.dart';

class AccountSelector extends StatelessWidget {
  const AccountSelector({
    super.key,
    required this.onChanged,
    required this.account,
    this.excludeAccountsWithErrors = true,
  });
  final RealAccount? account;
  final bool excludeAccountsWithErrors;
  final void Function(RealAccount? account) onChanged;

  @override
  Widget build(BuildContext context) {
    final accounts = List<RealAccount>.from(
      (excludeAccountsWithErrors
              ? locator<MailService>().accountsWithoutErrors
              : locator<MailService>().accounts)
          .whereType<RealAccount>(),
    );
    return PlatformDropdownButton<RealAccount>(
      value: account,
      items: accounts
          .map((account) => DropdownMenuItem<RealAccount>(
                value: account,
                child: Text(account.name),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}
