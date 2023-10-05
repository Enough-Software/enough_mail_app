// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$realAccountsHash() => r'8203d71da59bfb83b1ca5a4948b23f3b3d6c4428';

/// Retrieves the list of real accounts
///
/// Copied from [realAccounts].
@ProviderFor(realAccounts)
final realAccountsProvider = Provider<List<RealAccount>>.internal(
  realAccounts,
  name: r'realAccountsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$realAccountsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RealAccountsRef = ProviderRef<List<RealAccount>>;
String _$currentAccountHash() => r'0fb8b802c624f8d611d1f30b0871a9d34c6632cd';

/// Retrieves the current account
///
/// Copied from [currentAccount].
@ProviderFor(currentAccount)
final currentAccountProvider = AutoDisposeProvider<Account?>.internal(
  currentAccount,
  name: r'currentAccountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentAccountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentAccountRef = AutoDisposeProviderRef<Account?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
