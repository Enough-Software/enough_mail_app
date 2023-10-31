import 'package:collection/collection.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../logger.dart';
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
    if (accounts.isNotEmpty) {
      ref.read(currentAccountProvider.notifier).state = accounts.first;
    }
    state = accounts;
  }

  /// Adds a new account
  void addAccount(RealAccount account) {
    final cleanState = state.toList()..removeWhere((a) => a.key == account.key);
    state = [...cleanState, account];
    if (state.length == 1) {
      ref.read(currentAccountProvider.notifier).state = account;
    }
    _saveAccounts();
  }

  /// Removes the given [account]
  void removeAccount(RealAccount account) {
    state = state.where((a) => a.key != account.key).toList();
    if (ref.read(currentAccountProvider) == account) {
      final replacement = state.isEmpty ? null : state.first;
      ref.read(currentAccountProvider.notifier).state = replacement;
    }
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
    if (ref.read(currentAccountProvider) == oldAccount) {
      ref.read(currentAccountProvider.notifier).state = newAccount;
    }
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
List<Sender> senders(SendersRef ref) {
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
  final account = UnifiedAccount(accounts);
  final currentAccount = ref.read(currentAccountProvider);
  Future.delayed(const Duration(milliseconds: 20)).then((_) {
    if (currentAccount == null || currentAccount is RealAccount) {
      ref.read(currentAccountProvider.notifier).state = account;
    }
  });

  return account;
}

/// Provides all accounts
@Riverpod(keepAlive: true)
class AllAccounts extends _$AllAccounts {
  @override
  List<Account> build() {
    final realAccounts = ref.watch(realAccountsProvider);
    final unifiedAccount = ref.watch(unifiedAccountProvider);
    logger.d('Creating all accounts');

    return [
      if (unifiedAccount != null) unifiedAccount,
      ...realAccounts,
    ];
  }
}

//// Finds an account by its email
@Riverpod(keepAlive: true)
Account? findAccountByEmail(
  FindAccountByEmailRef ref, {
  required String email,
}) {
  final key = email.toLowerCase();
  final realAccounts = ref.watch(realAccountsProvider);
  final unifiedAccount = ref.watch(unifiedAccountProvider);

  return realAccounts.firstWhereOrNull((a) => a.key == key) ??
      ((unifiedAccount?.key == key) ? unifiedAccount : null);
}

//// Finds a real account by its email
@Riverpod(keepAlive: true)
RealAccount? findRealAccountByEmail(
  FindRealAccountByEmailRef ref, {
  required String email,
}) {
  final key = email.toLowerCase();
  final realAccounts = ref.watch(realAccountsProvider);

  return realAccounts.firstWhereOrNull((a) => a.key == key);
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
final currentAccountProvider = StateProvider<Account?>((ref) => null);

/// Provides the current real account
@riverpod
RealAccount? currentRealAccount(CurrentRealAccountRef ref) {
  final realAccounts = ref.watch(realAccountsProvider);
  final providedCurrentAccount = ref.watch(currentAccountProvider);

  return providedCurrentAccount is RealAccount
      ? providedCurrentAccount
      : (providedCurrentAccount is UnifiedAccount
          ? providedCurrentAccount.accounts.first
          : (realAccounts.isNotEmpty ? realAccounts.first : null));
}
