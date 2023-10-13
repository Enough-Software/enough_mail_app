// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mailboxTreeHash() => r'b1ccb0f9abb23fa230f80618370e187d21b10fac';

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

//// Loads the mailbox tree for the given account
///
/// Copied from [mailboxTree].
@ProviderFor(mailboxTree)
const mailboxTreeProvider = MailboxTreeFamily();

//// Loads the mailbox tree for the given account
///
/// Copied from [mailboxTree].
class MailboxTreeFamily extends Family<AsyncValue<Tree<Mailbox?>>> {
  //// Loads the mailbox tree for the given account
  ///
  /// Copied from [mailboxTree].
  const MailboxTreeFamily();

  //// Loads the mailbox tree for the given account
  ///
  /// Copied from [mailboxTree].
  MailboxTreeProvider call({
    required Account account,
  }) {
    return MailboxTreeProvider(
      account: account,
    );
  }

  @override
  MailboxTreeProvider getProviderOverride(
    covariant MailboxTreeProvider provider,
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
  String? get name => r'mailboxTreeProvider';
}

//// Loads the mailbox tree for the given account
///
/// Copied from [mailboxTree].
class MailboxTreeProvider extends FutureProvider<Tree<Mailbox?>> {
  //// Loads the mailbox tree for the given account
  ///
  /// Copied from [mailboxTree].
  MailboxTreeProvider({
    required Account account,
  }) : this._internal(
          (ref) => mailboxTree(
            ref as MailboxTreeRef,
            account: account,
          ),
          from: mailboxTreeProvider,
          name: r'mailboxTreeProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mailboxTreeHash,
          dependencies: MailboxTreeFamily._dependencies,
          allTransitiveDependencies:
              MailboxTreeFamily._allTransitiveDependencies,
          account: account,
        );

  MailboxTreeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.account,
  }) : super.internal();

  final Account account;

  @override
  Override overrideWith(
    FutureOr<Tree<Mailbox?>> Function(MailboxTreeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MailboxTreeProvider._internal(
        (ref) => create(ref as MailboxTreeRef),
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
  FutureProviderElement<Tree<Mailbox?>> createElement() {
    return _MailboxTreeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MailboxTreeProvider && other.account == account;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, account.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MailboxTreeRef on FutureProviderRef<Tree<Mailbox?>> {
  /// The parameter `account` of this provider.
  Account get account;
}

class _MailboxTreeProviderElement extends FutureProviderElement<Tree<Mailbox?>>
    with MailboxTreeRef {
  _MailboxTreeProviderElement(super.provider);

  @override
  Account get account => (origin as MailboxTreeProvider).account;
}

String _$findMailboxHash() => r'cf69ac27d256f03c561fcc130eacc4348974ac09';

//// Loads the mailbox tree for the given account
///
/// Copied from [findMailbox].
@ProviderFor(findMailbox)
const findMailboxProvider = FindMailboxFamily();

//// Loads the mailbox tree for the given account
///
/// Copied from [findMailbox].
class FindMailboxFamily extends Family<AsyncValue<Mailbox?>> {
  //// Loads the mailbox tree for the given account
  ///
  /// Copied from [findMailbox].
  const FindMailboxFamily();

  //// Loads the mailbox tree for the given account
  ///
  /// Copied from [findMailbox].
  FindMailboxProvider call({
    required Account account,
    required String encodedMailboxPath,
  }) {
    return FindMailboxProvider(
      account: account,
      encodedMailboxPath: encodedMailboxPath,
    );
  }

  @override
  FindMailboxProvider getProviderOverride(
    covariant FindMailboxProvider provider,
  ) {
    return call(
      account: provider.account,
      encodedMailboxPath: provider.encodedMailboxPath,
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
  String? get name => r'findMailboxProvider';
}

//// Loads the mailbox tree for the given account
///
/// Copied from [findMailbox].
class FindMailboxProvider extends FutureProvider<Mailbox?> {
  //// Loads the mailbox tree for the given account
  ///
  /// Copied from [findMailbox].
  FindMailboxProvider({
    required Account account,
    required String encodedMailboxPath,
  }) : this._internal(
          (ref) => findMailbox(
            ref as FindMailboxRef,
            account: account,
            encodedMailboxPath: encodedMailboxPath,
          ),
          from: findMailboxProvider,
          name: r'findMailboxProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$findMailboxHash,
          dependencies: FindMailboxFamily._dependencies,
          allTransitiveDependencies:
              FindMailboxFamily._allTransitiveDependencies,
          account: account,
          encodedMailboxPath: encodedMailboxPath,
        );

  FindMailboxProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.account,
    required this.encodedMailboxPath,
  }) : super.internal();

  final Account account;
  final String encodedMailboxPath;

  @override
  Override overrideWith(
    FutureOr<Mailbox?> Function(FindMailboxRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FindMailboxProvider._internal(
        (ref) => create(ref as FindMailboxRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        account: account,
        encodedMailboxPath: encodedMailboxPath,
      ),
    );
  }

  @override
  FutureProviderElement<Mailbox?> createElement() {
    return _FindMailboxProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FindMailboxProvider &&
        other.account == account &&
        other.encodedMailboxPath == encodedMailboxPath;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, account.hashCode);
    hash = _SystemHash.combine(hash, encodedMailboxPath.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin FindMailboxRef on FutureProviderRef<Mailbox?> {
  /// The parameter `account` of this provider.
  Account get account;

  /// The parameter `encodedMailboxPath` of this provider.
  String get encodedMailboxPath;
}

class _FindMailboxProviderElement extends FutureProviderElement<Mailbox?>
    with FindMailboxRef {
  _FindMailboxProviderElement(super.provider);

  @override
  Account get account => (origin as FindMailboxProvider).account;
  @override
  String get encodedMailboxPath =>
      (origin as FindMailboxProvider).encodedMailboxPath;
}

String _$sourceHash() => r'ed4bfa87f9547328583d2c849f27a43200a6df1f';

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

String _$unifiedSourceHash() => r'de509cae0ff4f5d7d917b94a192edc45cd7fc398';

abstract class _$UnifiedSource
    extends BuildlessAsyncNotifier<MultipleMessageSource> {
  late final UnifiedAccount account;
  late final Mailbox? mailbox;

  Future<MultipleMessageSource> build({
    required UnifiedAccount account,
    Mailbox? mailbox,
  });
}

/// Provides the message source for the given account
///
/// Copied from [UnifiedSource].
@ProviderFor(UnifiedSource)
const unifiedSourceProvider = UnifiedSourceFamily();

/// Provides the message source for the given account
///
/// Copied from [UnifiedSource].
class UnifiedSourceFamily extends Family<AsyncValue<MultipleMessageSource>> {
  /// Provides the message source for the given account
  ///
  /// Copied from [UnifiedSource].
  const UnifiedSourceFamily();

  /// Provides the message source for the given account
  ///
  /// Copied from [UnifiedSource].
  UnifiedSourceProvider call({
    required UnifiedAccount account,
    Mailbox? mailbox,
  }) {
    return UnifiedSourceProvider(
      account: account,
      mailbox: mailbox,
    );
  }

  @override
  UnifiedSourceProvider getProviderOverride(
    covariant UnifiedSourceProvider provider,
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
  String? get name => r'unifiedSourceProvider';
}

/// Provides the message source for the given account
///
/// Copied from [UnifiedSource].
class UnifiedSourceProvider
    extends AsyncNotifierProviderImpl<UnifiedSource, MultipleMessageSource> {
  /// Provides the message source for the given account
  ///
  /// Copied from [UnifiedSource].
  UnifiedSourceProvider({
    required UnifiedAccount account,
    Mailbox? mailbox,
  }) : this._internal(
          () => UnifiedSource()
            ..account = account
            ..mailbox = mailbox,
          from: unifiedSourceProvider,
          name: r'unifiedSourceProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$unifiedSourceHash,
          dependencies: UnifiedSourceFamily._dependencies,
          allTransitiveDependencies:
              UnifiedSourceFamily._allTransitiveDependencies,
          account: account,
          mailbox: mailbox,
        );

  UnifiedSourceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.account,
    required this.mailbox,
  }) : super.internal();

  final UnifiedAccount account;
  final Mailbox? mailbox;

  @override
  Future<MultipleMessageSource> runNotifierBuild(
    covariant UnifiedSource notifier,
  ) {
    return notifier.build(
      account: account,
      mailbox: mailbox,
    );
  }

  @override
  Override overrideWith(UnifiedSource Function() create) {
    return ProviderOverride(
      origin: this,
      override: UnifiedSourceProvider._internal(
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
  AsyncNotifierProviderElement<UnifiedSource, MultipleMessageSource>
      createElement() {
    return _UnifiedSourceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UnifiedSourceProvider &&
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

mixin UnifiedSourceRef on AsyncNotifierProviderRef<MultipleMessageSource> {
  /// The parameter `account` of this provider.
  UnifiedAccount get account;

  /// The parameter `mailbox` of this provider.
  Mailbox? get mailbox;
}

class _UnifiedSourceProviderElement
    extends AsyncNotifierProviderElement<UnifiedSource, MultipleMessageSource>
    with UnifiedSourceRef {
  _UnifiedSourceProviderElement(super.provider);

  @override
  UnifiedAccount get account => (origin as UnifiedSourceProvider).account;
  @override
  Mailbox? get mailbox => (origin as UnifiedSourceProvider).mailbox;
}

String _$realSourceHash() => r'463138cc3fd08bab9e850e7591385610bf33bfb2';

abstract class _$RealSource
    extends BuildlessAsyncNotifier<MailboxMessageSource> {
  late final RealAccount account;
  late final Mailbox? mailbox;

  Future<MailboxMessageSource> build({
    required RealAccount account,
    Mailbox? mailbox,
  });
}

/// Provides the message source for the given account
///
/// Copied from [RealSource].
@ProviderFor(RealSource)
const realSourceProvider = RealSourceFamily();

/// Provides the message source for the given account
///
/// Copied from [RealSource].
class RealSourceFamily extends Family<AsyncValue<MailboxMessageSource>> {
  /// Provides the message source for the given account
  ///
  /// Copied from [RealSource].
  const RealSourceFamily();

  /// Provides the message source for the given account
  ///
  /// Copied from [RealSource].
  RealSourceProvider call({
    required RealAccount account,
    Mailbox? mailbox,
  }) {
    return RealSourceProvider(
      account: account,
      mailbox: mailbox,
    );
  }

  @override
  RealSourceProvider getProviderOverride(
    covariant RealSourceProvider provider,
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
  String? get name => r'realSourceProvider';
}

/// Provides the message source for the given account
///
/// Copied from [RealSource].
class RealSourceProvider
    extends AsyncNotifierProviderImpl<RealSource, MailboxMessageSource> {
  /// Provides the message source for the given account
  ///
  /// Copied from [RealSource].
  RealSourceProvider({
    required RealAccount account,
    Mailbox? mailbox,
  }) : this._internal(
          () => RealSource()
            ..account = account
            ..mailbox = mailbox,
          from: realSourceProvider,
          name: r'realSourceProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$realSourceHash,
          dependencies: RealSourceFamily._dependencies,
          allTransitiveDependencies:
              RealSourceFamily._allTransitiveDependencies,
          account: account,
          mailbox: mailbox,
        );

  RealSourceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.account,
    required this.mailbox,
  }) : super.internal();

  final RealAccount account;
  final Mailbox? mailbox;

  @override
  Future<MailboxMessageSource> runNotifierBuild(
    covariant RealSource notifier,
  ) {
    return notifier.build(
      account: account,
      mailbox: mailbox,
    );
  }

  @override
  Override overrideWith(RealSource Function() create) {
    return ProviderOverride(
      origin: this,
      override: RealSourceProvider._internal(
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
  AsyncNotifierProviderElement<RealSource, MailboxMessageSource>
      createElement() {
    return _RealSourceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RealSourceProvider &&
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

mixin RealSourceRef on AsyncNotifierProviderRef<MailboxMessageSource> {
  /// The parameter `account` of this provider.
  RealAccount get account;

  /// The parameter `mailbox` of this provider.
  Mailbox? get mailbox;
}

class _RealSourceProviderElement
    extends AsyncNotifierProviderElement<RealSource, MailboxMessageSource>
    with RealSourceRef {
  _RealSourceProviderElement(super.provider);

  @override
  RealAccount get account => (origin as RealSourceProvider).account;
  @override
  Mailbox? get mailbox => (origin as RealSourceProvider).mailbox;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
