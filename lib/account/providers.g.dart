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
String _$findAccountByEmailHash() =>
    r'd098fc64ea914fb4ba974196600a1386546c4e70';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

//// Finds an account by its email
///
/// Copied from [findAccountByEmail].
@ProviderFor(findAccountByEmail)
const findAccountByEmailProvider = FindAccountByEmailFamily();

//// Finds an account by its email
///
/// Copied from [findAccountByEmail].
class FindAccountByEmailFamily extends Family<Account> {
  //// Finds an account by its email
  ///
  /// Copied from [findAccountByEmail].
  const FindAccountByEmailFamily();

  //// Finds an account by its email
  ///
  /// Copied from [findAccountByEmail].
  FindAccountByEmailProvider call({
    required String email,
  }) {
    return FindAccountByEmailProvider(
      email: email,
    );
  }

  @override
  FindAccountByEmailProvider getProviderOverride(
    covariant FindAccountByEmailProvider provider,
  ) {
    return call(
      email: provider.email,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'findAccountByEmailProvider';
}

//// Finds an account by its email
///
/// Copied from [findAccountByEmail].
class FindAccountByEmailProvider extends Provider<Account> {
  //// Finds an account by its email
  ///
  /// Copied from [findAccountByEmail].
  FindAccountByEmailProvider({
    required String email,
  }) : this._internal(
          (ref) => findAccountByEmail(
            ref as FindAccountByEmailRef,
            email: email,
          ),
          from: findAccountByEmailProvider,
          name: r'findAccountByEmailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$findAccountByEmailHash,
          dependencies: FindAccountByEmailFamily._dependencies,
          allTransitiveDependencies:
              FindAccountByEmailFamily._allTransitiveDependencies,
          email: email,
        );

  FindAccountByEmailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.email,
  }) : super.internal();

  final String email;

  @override
  Override overrideWith(
    Account Function(FindAccountByEmailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FindAccountByEmailProvider._internal(
        (ref) => create(ref as FindAccountByEmailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        email: email,
      ),
    );
  }

  @override
  ProviderElement<Account> createElement() {
    return _FindAccountByEmailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FindAccountByEmailProvider && other.email == email;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, email.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin FindAccountByEmailRef on ProviderRef<Account> {
  /// The parameter `email` of this provider.
  String get email;
}

class _FindAccountByEmailProviderElement extends ProviderElement<Account>
    with FindAccountByEmailRef {
  _FindAccountByEmailProviderElement(super.provider);

  @override
  String get email => (origin as FindAccountByEmailProvider).email;
}

String _$findRealAccountByEmailHash() =>
    r'5738473cdcb5e7c531051904276d03d20dfe7f1e';

//// Finds a real account by its email
///
/// Copied from [findRealAccountByEmail].
@ProviderFor(findRealAccountByEmail)
const findRealAccountByEmailProvider = FindRealAccountByEmailFamily();

//// Finds a real account by its email
///
/// Copied from [findRealAccountByEmail].
class FindRealAccountByEmailFamily extends Family<RealAccount> {
  //// Finds a real account by its email
  ///
  /// Copied from [findRealAccountByEmail].
  const FindRealAccountByEmailFamily();

  //// Finds a real account by its email
  ///
  /// Copied from [findRealAccountByEmail].
  FindRealAccountByEmailProvider call({
    required String email,
  }) {
    return FindRealAccountByEmailProvider(
      email: email,
    );
  }

  @override
  FindRealAccountByEmailProvider getProviderOverride(
    covariant FindRealAccountByEmailProvider provider,
  ) {
    return call(
      email: provider.email,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'findRealAccountByEmailProvider';
}

//// Finds a real account by its email
///
/// Copied from [findRealAccountByEmail].
class FindRealAccountByEmailProvider extends Provider<RealAccount> {
  //// Finds a real account by its email
  ///
  /// Copied from [findRealAccountByEmail].
  FindRealAccountByEmailProvider({
    required String email,
  }) : this._internal(
          (ref) => findRealAccountByEmail(
            ref as FindRealAccountByEmailRef,
            email: email,
          ),
          from: findRealAccountByEmailProvider,
          name: r'findRealAccountByEmailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$findRealAccountByEmailHash,
          dependencies: FindRealAccountByEmailFamily._dependencies,
          allTransitiveDependencies:
              FindRealAccountByEmailFamily._allTransitiveDependencies,
          email: email,
        );

  FindRealAccountByEmailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.email,
  }) : super.internal();

  final String email;

  @override
  Override overrideWith(
    RealAccount Function(FindRealAccountByEmailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FindRealAccountByEmailProvider._internal(
        (ref) => create(ref as FindRealAccountByEmailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        email: email,
      ),
    );
  }

  @override
  ProviderElement<RealAccount> createElement() {
    return _FindRealAccountByEmailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FindRealAccountByEmailProvider && other.email == email;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, email.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin FindRealAccountByEmailRef on ProviderRef<RealAccount> {
  /// The parameter `email` of this provider.
  String get email;
}

class _FindRealAccountByEmailProviderElement
    extends ProviderElement<RealAccount> with FindRealAccountByEmailRef {
  _FindRealAccountByEmailProviderElement(super.provider);

  @override
  String get email => (origin as FindRealAccountByEmailProvider).email;
}

String _$hasAccountWithErrorHash() =>
    r'df9f05a11751823686a4b6dc985e5cae0224a07f'; //// Checks if there is at least one real account with a login error
///
/// Copied from [hasAccountWithError].
@ProviderFor(hasAccountWithError)
final hasAccountWithErrorProvider = Provider<bool>.internal(
  hasAccountWithError,
  name: r'hasAccountWithErrorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasAccountWithErrorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HasAccountWithErrorRef = ProviderRef<bool>;
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
