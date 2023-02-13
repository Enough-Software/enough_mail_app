import 'package:enough_mail_app/models/account.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';

import '../locator.dart';

class AccountSelector extends StatelessWidget {
  final RealAccount? account;
  final bool excludeAccountsWithErrors;
  final void Function(RealAccount? account) onChanged;
  const AccountSelector({
    Key? key,
    required this.onChanged,
    required this.account,
    this.excludeAccountsWithErrors = true,
  }) : super(key: key);

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
