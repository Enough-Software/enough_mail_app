import 'package:enough_mail_app/models/account.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';

import '../locator.dart';

class AccountSelector extends StatelessWidget {
  final Account? account;
  final bool excludeAccountsWithErrors;
  final void Function(Account? account) onChanged;
  const AccountSelector({
    Key? key,
    required this.onChanged,
    required this.account,
    this.excludeAccountsWithErrors = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accounts = excludeAccountsWithErrors
        ? locator<MailService>().accountsWithoutErrors
        : locator<MailService>().accounts;
    return PlatformDropdownButton<Account>(
      value: account,
      items: accounts
          .map((account) => DropdownMenuItem<Account>(
                value: account,
                child: Text(account.name),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}
