// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$unifiedAccountHash() => r'e59dc865d2ef074d5da9cdc4d228551153ef0a53';

/// Provides the unified account, if any
///
/// Copied from [unifiedAccount].
@ProviderFor(unifiedAccount)
final unifiedAccountProvider = Provider<UnifiedAccount?>.internal(
  unifiedAccount,
  name: r'unifiedAccountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unifiedAccountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UnifiedAccountRef = ProviderRef<UnifiedAccount?>;
String _$realAccountsHash() => r'3ff51534497e5e36a7b0e0f19dc0e5fb09cfdcfe';

/// Provides all real email accounts
///
/// Copied from [RealAccounts].
@ProviderFor(RealAccounts)
final realAccountsProvider =
    NotifierProvider<RealAccounts, List<RealAccount>>.internal(
  RealAccounts.new,
  name: r'realAccountsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$realAccountsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RealAccounts = Notifier<List<RealAccount>>;
String _$allAccountsHash() => r'e97a4caa8ae7cdc52f6a1d9e7a4f7fcaf4f21da4';

/// Provides all accounts
///
/// Copied from [AllAccounts].
@ProviderFor(AllAccounts)
final allAccountsProvider =
    NotifierProvider<AllAccounts, List<Account>>.internal(
  AllAccounts.new,
  name: r'allAccountsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allAccountsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AllAccounts = Notifier<List<Account>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
