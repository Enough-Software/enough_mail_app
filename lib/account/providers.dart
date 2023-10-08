import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'model.dart';
import 'storage.dart';

part 'providers.g.dart';

/// Retrieves the current account
@riverpod
class CurrentAccount extends _$CurrentAccount {
  @override
  Raw<Account>? build() {
    final accounts = ref.watch(allAccountsProvider);
    if (accounts.isEmpty) {
      return null;
    }

    return accounts.first;
  }
}

/// Provides all real email accounts
@Riverpod(keepAlive: true)
class RealAccounts extends _$RealAccounts {
  late AccountStorage _storage;

  @override
  List<RealAccount> build() => [];

  /// Loads the accounts from disk
  Future<void> init() async {
    _storage = const AccountStorage();
    final accounts = await _storage.loadAccounts();
    state = accounts;
  }

  /// Adds a new account
  void addAccount(RealAccount account) {
    final cleanState = state.toList()..removeWhere((a) => a.key == account.key);
    state = [...cleanState, account];
    _saveAccounts();
  }

  /// Removes the given [account]
  void removeAccount(RealAccount account) {
    state = state.where((a) => a.key != account.key).toList();
    _saveAccounts();
  }

  /// Changes the order of the accounts
  void reorderAccounts(List<RealAccount> accounts) {
    state = accounts;
    _saveAccounts();
  }

  /// Saves all data
  Future<void> save() => _saveAccounts();

  Future<void> _saveAccounts() async {
    await _storage.saveAccounts(state);
  }
}

/// Provides the unified account, if any
@Riverpod(keepAlive: true)
UnifiedAccount? unifiedAccount(UnifiedAccountRef ref) {
  final allRealAccounts = ref.watch(realAccountsProvider);
  final accounts = allRealAccounts.where((a) => !a.excludeFromUnified).toList();
  if (accounts.length <= 1) {
    return null;
  }

  return UnifiedAccount(accounts);
}

/// Provides all accounts
@Riverpod(keepAlive: true)
class AllAccounts extends _$AllAccounts {
  @override
  List<Account> build() {
    final realAccounts = ref.watch(realAccountsProvider);
    final unifiedAccount = ref.watch(unifiedAccountProvider);

    return [
      if (unifiedAccount != null) unifiedAccount,
      ...realAccounts,
    ];
  }
}
