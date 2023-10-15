import 'package:collection/collection.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/sender.dart';
import 'model.dart';
import 'storage.dart';

part 'provider.g.dart';

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

  /// Updates the given [oldAccount] with the given [newAccount]
  void replaceAccount({
    required RealAccount oldAccount,
    required RealAccount newAccount,
    bool save = true,
  }) {
    final index = state.indexWhere((a) => a.key == oldAccount.key);
    if (index == -1) {
      throw StateError('account not found for ${oldAccount.key}');
    }
    final newState = state.toList()..[index] = newAccount;
    state = newState;
    if (save) {
      _saveAccounts();
    }
  }

  /// Changes the order of the accounts
  void reorderAccounts(List<RealAccount> accounts) {
    state = accounts;
    _saveAccounts();
  }

  /// Saves all data
  Future<void> updateMailAccount(RealAccount account, MailAccount mailAccount) {
    account.mailAccount = mailAccount;

    return _saveAccounts();
  }

  /// Saves all data
  Future<void> save() => _saveAccounts();

  Future<void> _saveAccounts() async {
    await _storage.saveAccounts(state);
  }
}

/// Generates a list of senders for composing a new message
@riverpod
List<Sender> Senders(SendersRef ref) {
  final accounts = ref.watch(realAccountsProvider);
  final senders = <Sender>[];
  for (final account in accounts) {
    senders.add(Sender(account.fromAddress, account));
    for (final alias in account.aliases) {
      senders.add(Sender(alias, account));
    }
  }

  return senders;
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

//// Finds an account by its email
@Riverpod(keepAlive: true)
Account findAccountByEmail(
  FindAccountByEmailRef ref, {
  required String email,
}) {
  final key = email.toLowerCase();
  final realAccounts = ref.watch(realAccountsProvider);
  final unifiedAccount = ref.watch(unifiedAccountProvider);

  final account = realAccounts.firstWhereOrNull((a) => a.key == key) ??
      ((unifiedAccount?.key == key) ? unifiedAccount : null);
  if (account == null) {
    throw StateError('account not found for $email');
  }

  return account;
}

//// Finds a real account by its email
@Riverpod(keepAlive: true)
RealAccount findRealAccountByEmail(
  FindRealAccountByEmailRef ref, {
  required String email,
}) {
  final key = email.toLowerCase();
  final realAccounts = ref.watch(realAccountsProvider);

  return realAccounts.firstWhere((a) => a.key == key);
}

//// Checks if there is at least one real account with a login error
@Riverpod(keepAlive: true)
bool hasAccountWithError(
  HasAccountWithErrorRef ref,
) {
  final realAccounts = ref.watch(realAccountsProvider);

  return realAccounts.any((a) => a.hasError);
}

/// Provides the locally current active account
@riverpod
Account? currentAccount(CurrentAccountRef ref) => null;
