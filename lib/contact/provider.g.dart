// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactsLoaderHash() => r'2205f8a929faafca4bbffe075c2e3f2961194cbb';

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

/// Loads the contacts for the given [account]
///
/// Copied from [contactsLoader].
@ProviderFor(contactsLoader)
const contactsLoaderProvider = ContactsLoaderFamily();

/// Loads the contacts for the given [account]
///
/// Copied from [contactsLoader].
class ContactsLoaderFamily extends Family<AsyncValue<ContactManager>> {
  /// Loads the contacts for the given [account]
  ///
  /// Copied from [contactsLoader].
  const ContactsLoaderFamily();

  /// Loads the contacts for the given [account]
  ///
  /// Copied from [contactsLoader].
  ContactsLoaderProvider call({
    required RealAccount account,
  }) {
    return ContactsLoaderProvider(
      account: account,
    );
  }

  @override
  ContactsLoaderProvider getProviderOverride(
    covariant ContactsLoaderProvider provider,
  ) {
    return call(
      account: provider.account,
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
  String? get name => r'contactsLoaderProvider';
}

/// Loads the contacts for the given [account]
///
/// Copied from [contactsLoader].
class ContactsLoaderProvider extends FutureProvider<ContactManager> {
  /// Loads the contacts for the given [account]
  ///
  /// Copied from [contactsLoader].
  ContactsLoaderProvider({
    required RealAccount account,
  }) : this._internal(
          (ref) => contactsLoader(
            ref as ContactsLoaderRef,
            account: account,
          ),
          from: contactsLoaderProvider,
          name: r'contactsLoaderProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$contactsLoaderHash,
          dependencies: ContactsLoaderFamily._dependencies,
          allTransitiveDependencies:
              ContactsLoaderFamily._allTransitiveDependencies,
          account: account,
        );

  ContactsLoaderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.account,
  }) : super.internal();

  final RealAccount account;

  @override
  Override overrideWith(
    FutureOr<ContactManager> Function(ContactsLoaderRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContactsLoaderProvider._internal(
        (ref) => create(ref as ContactsLoaderRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        account: account,
      ),
    );
  }

  @override
  FutureProviderElement<ContactManager> createElement() {
    return _ContactsLoaderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContactsLoaderProvider && other.account == account;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, account.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ContactsLoaderRef on FutureProviderRef<ContactManager> {
  /// The parameter `account` of this provider.
  RealAccount get account;
}

class _ContactsLoaderProviderElement
    extends FutureProviderElement<ContactManager> with ContactsLoaderRef {
  _ContactsLoaderProviderElement(super.provider);

  @override
  RealAccount get account => (origin as ContactsLoaderProvider).account;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
