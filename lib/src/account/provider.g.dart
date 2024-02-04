// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sendersHash() => r'7d45f5bd244bb17ed18983d9eac9a6170dfde855';

/// Generates a list of senders for composing a new message
///
/// Copied from [senders].
@ProviderFor(senders)
final sendersProvider = AutoDisposeProvider<List<Sender>>.internal(
  senders,
  name: r'sendersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$sendersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SendersRef = AutoDisposeProviderRef<List<Sender>>;
String _$unifiedAccountHash() => r'5380f681599f9354b8ecd0cbda4c40dedd9de535';

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
    r'692760656b2f9223f3ef929e040c413f2dd4c571';

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
class FindAccountByEmailFamily extends Family<Account?> {
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
class FindAccountByEmailProvider extends Provider<Account?> {
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
    Account? Function(FindAccountByEmailRef provider) create,
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
  ProviderElement<Account?> createElement() {
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

mixin FindAccountByEmailRef on ProviderRef<Account?> {
  /// The parameter `email` of this provider.
  String get email;
}

class _FindAccountByEmailProviderElement extends ProviderElement<Account?>
    with FindAccountByEmailRef {
  _FindAccountByEmailProviderElement(super.provider);

  @override
  String get email => (origin as FindAccountByEmailProvider).email;
}

String _$findRealAccountByEmailHash() =>
    r'4fbe9680f101417c67bc9eebda553005f78d77c1';

//// Finds a real account by its email
///
/// Copied from [findRealAccountByEmail].
@ProviderFor(findRealAccountByEmail)
const findRealAccountByEmailProvider = FindRealAccountByEmailFamily();

//// Finds a real account by its email
///
/// Copied from [findRealAccountByEmail].
class FindRealAccountByEmailFamily extends Family<RealAccount?> {
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
class FindRealAccountByEmailProvider extends Provider<RealAccount?> {
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
    RealAccount? Function(FindRealAccountByEmailRef provider) create,
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
  ProviderElement<RealAccount?> createElement() {
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

mixin FindRealAccountByEmailRef on ProviderRef<RealAccount?> {
  /// The parameter `email` of this provider.
  String get email;
}

class _FindRealAccountByEmailProviderElement
    extends ProviderElement<RealAccount?> with FindRealAccountByEmailRef {
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
String _$currentRealAccountHash() =>
    r'dd79b65ff2ea824e117c4f13416c6b6993fa4a86';

/// Provides the current real account
///
/// Copied from [currentRealAccount].
@ProviderFor(currentRealAccount)
final currentRealAccountProvider = AutoDisposeProvider<RealAccount?>.internal(
  currentRealAccount,
  name: r'currentRealAccountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentRealAccountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentRealAccountRef = AutoDisposeProviderRef<RealAccount?>;
String _$realAccountsHash() => r'cf98cca42c7239746aea0af704cbf02a96108a7f';

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
String _$allAccountsHash() => r'72f9626b7f40dfa85b19cbc7a694494a13b9638f';

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
