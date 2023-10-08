// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sourceHash() => r'31611430840b7466b5536360064e85929183dfdf';

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

abstract class _$Source extends BuildlessAsyncNotifier<MessageSource> {
  late final Account account;
  late final Mailbox? mailbox;

  Future<MessageSource> build({
    required Account account,
    Mailbox? mailbox,
  });
}

/// Provides the message source for the given account
///
/// Copied from [Source].
@ProviderFor(Source)
const sourceProvider = SourceFamily();

/// Provides the message source for the given account
///
/// Copied from [Source].
class SourceFamily extends Family<AsyncValue<MessageSource>> {
  /// Provides the message source for the given account
  ///
  /// Copied from [Source].
  const SourceFamily();

  /// Provides the message source for the given account
  ///
  /// Copied from [Source].
  SourceProvider call({
    required Account account,
    Mailbox? mailbox,
  }) {
    return SourceProvider(
      account: account,
      mailbox: mailbox,
    );
  }

  @override
  SourceProvider getProviderOverride(
    covariant SourceProvider provider,
  ) {
    return call(
      account: provider.account,
      mailbox: provider.mailbox,
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
  String? get name => r'sourceProvider';
}

/// Provides the message source for the given account
///
/// Copied from [Source].
class SourceProvider extends AsyncNotifierProviderImpl<Source, MessageSource> {
  /// Provides the message source for the given account
  ///
  /// Copied from [Source].
  SourceProvider({
    required Account account,
    Mailbox? mailbox,
  }) : this._internal(
          () => Source()
            ..account = account
            ..mailbox = mailbox,
          from: sourceProvider,
          name: r'sourceProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$sourceHash,
          dependencies: SourceFamily._dependencies,
          allTransitiveDependencies: SourceFamily._allTransitiveDependencies,
          account: account,
          mailbox: mailbox,
        );

  SourceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.account,
    required this.mailbox,
  }) : super.internal();

  final Account account;
  final Mailbox? mailbox;

  @override
  Future<MessageSource> runNotifierBuild(
    covariant Source notifier,
  ) {
    return notifier.build(
      account: account,
      mailbox: mailbox,
    );
  }

  @override
  Override overrideWith(Source Function() create) {
    return ProviderOverride(
      origin: this,
      override: SourceProvider._internal(
        () => create()
          ..account = account
          ..mailbox = mailbox,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        account: account,
        mailbox: mailbox,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<Source, MessageSource> createElement() {
    return _SourceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SourceProvider &&
        other.account == account &&
        other.mailbox == mailbox;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, account.hashCode);
    hash = _SystemHash.combine(hash, mailbox.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SourceRef on AsyncNotifierProviderRef<MessageSource> {
  /// The parameter `account` of this provider.
  Account get account;

  /// The parameter `mailbox` of this provider.
  Mailbox? get mailbox;
}

class _SourceProviderElement
    extends AsyncNotifierProviderElement<Source, MessageSource> with SourceRef {
  _SourceProviderElement(super.provider);

  @override
  Account get account => (origin as SourceProvider).account;
  @override
  Mailbox? get mailbox => (origin as SourceProvider).mailbox;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
