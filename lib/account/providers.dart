import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/account.dart';

part 'providers.g.dart';

/// Retrieves the list of real accounts
@Riverpod(keepAlive: true)
List<RealAccount> realAccounts(RealAccountsRef ref) {
  throw UnimplementedError();
}

/// Retrieves the current account
@riverpod
Raw<Account?> currentAccount(CurrentAccountRef ref) {
  throw UnimplementedError();
}
