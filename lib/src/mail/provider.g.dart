// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mailboxTreeHash() => r'2feafc0f0d00b8c4547b6408363a522539e85853';

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

String _$findMailboxHash() => r'fb113e28a8bb6904dbdd07a73898bc198afb2dda';

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
class FindMailboxProvider extends AutoDisposeFutureProvider<Mailbox?> {
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
  AutoDisposeFutureProviderElement<Mailbox?> createElement() {
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

mixin FindMailboxRef on AutoDisposeFutureProviderRef<Mailbox?> {
  /// The parameter `account` of this provider.
  Account get account;

  /// The parameter `encodedMailboxPath` of this provider.
  String get encodedMailboxPath;
}

class _FindMailboxProviderElement
    extends AutoDisposeFutureProviderElement<Mailbox?> with FindMailboxRef {
  _FindMailboxProviderElement(super.provider);

  @override
  Account get account => (origin as FindMailboxProvider).account;
  @override
  String get encodedMailboxPath =>
      (origin as FindMailboxProvider).encodedMailboxPath;
}

String _$mailSearchHash() => r'12e814bd6c0f53f6209dd0f68edf09a0ec769c8b';

/// Carries out a search for mail messages
///
/// Copied from [mailSearch].
@ProviderFor(mailSearch)
const mailSearchProvider = MailSearchFamily();

/// Carries out a search for mail messages
///
/// Copied from [mailSearch].
class MailSearchFamily extends Family<AsyncValue<MessageSource>> {
  /// Carries out a search for mail messages
  ///
  /// Copied from [mailSearch].
  const MailSearchFamily();

  /// Carries out a search for mail messages
  ///
  /// Copied from [mailSearch].
  MailSearchProvider call({
    required AppLocalizations localizations,
    required MailSearch search,
  }) {
    return MailSearchProvider(
      localizations: localizations,
      search: search,
    );
  }

  @override
  MailSearchProvider getProviderOverride(
    covariant MailSearchProvider provider,
  ) {
    return call(
      localizations: provider.localizations,
      search: provider.search,
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
  String? get name => r'mailSearchProvider';
}

/// Carries out a search for mail messages
///
/// Copied from [mailSearch].
class MailSearchProvider extends AutoDisposeFutureProvider<MessageSource> {
  /// Carries out a search for mail messages
  ///
  /// Copied from [mailSearch].
  MailSearchProvider({
    required AppLocalizations localizations,
    required MailSearch search,
  }) : this._internal(
          (ref) => mailSearch(
            ref as MailSearchRef,
            localizations: localizations,
            search: search,
          ),
          from: mailSearchProvider,
          name: r'mailSearchProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mailSearchHash,
          dependencies: MailSearchFamily._dependencies,
          allTransitiveDependencies:
              MailSearchFamily._allTransitiveDependencies,
          localizations: localizations,
          search: search,
        );

  MailSearchProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.localizations,
    required this.search,
  }) : super.internal();

  final AppLocalizations localizations;
  final MailSearch search;

  @override
  Override overrideWith(
    FutureOr<MessageSource> Function(MailSearchRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MailSearchProvider._internal(
        (ref) => create(ref as MailSearchRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        localizations: localizations,
        search: search,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<MessageSource> createElement() {
    return _MailSearchProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MailSearchProvider &&
        other.localizations == localizations &&
        other.search == search;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, localizations.hashCode);
    hash = _SystemHash.combine(hash, search.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MailSearchRef on AutoDisposeFutureProviderRef<MessageSource> {
  /// The parameter `localizations` of this provider.
  AppLocalizations get localizations;

  /// The parameter `search` of this provider.
  MailSearch get search;
}

class _MailSearchProviderElement
    extends AutoDisposeFutureProviderElement<MessageSource> with MailSearchRef {
  _MailSearchProviderElement(super.provider);

  @override
  AppLocalizations get localizations =>
      (origin as MailSearchProvider).localizations;
  @override
  MailSearch get search => (origin as MailSearchProvider).search;
}

String _$singleMessageLoaderHash() =>
    r'ec18c48ee5c6ad77cb303cfea02e959979b4c9ce';

/// Loads the message source for the given payload
///
/// Copied from [singleMessageLoader].
@ProviderFor(singleMessageLoader)
const singleMessageLoaderProvider = SingleMessageLoaderFamily();

/// Loads the message source for the given payload
///
/// Copied from [singleMessageLoader].
class SingleMessageLoaderFamily extends Family<AsyncValue<Message>> {
  /// Loads the message source for the given payload
  ///
  /// Copied from [singleMessageLoader].
  const SingleMessageLoaderFamily();

  /// Loads the message source for the given payload
  ///
  /// Copied from [singleMessageLoader].
  SingleMessageLoaderProvider call({
    required MailNotificationPayload payload,
  }) {
    return SingleMessageLoaderProvider(
      payload: payload,
    );
  }

  @override
  SingleMessageLoaderProvider getProviderOverride(
    covariant SingleMessageLoaderProvider provider,
  ) {
    return call(
      payload: provider.payload,
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
  String? get name => r'singleMessageLoaderProvider';
}

/// Loads the message source for the given payload
///
/// Copied from [singleMessageLoader].
class SingleMessageLoaderProvider extends AutoDisposeFutureProvider<Message> {
  /// Loads the message source for the given payload
  ///
  /// Copied from [singleMessageLoader].
  SingleMessageLoaderProvider({
    required MailNotificationPayload payload,
  }) : this._internal(
          (ref) => singleMessageLoader(
            ref as SingleMessageLoaderRef,
            payload: payload,
          ),
          from: singleMessageLoaderProvider,
          name: r'singleMessageLoaderProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$singleMessageLoaderHash,
          dependencies: SingleMessageLoaderFamily._dependencies,
          allTransitiveDependencies:
              SingleMessageLoaderFamily._allTransitiveDependencies,
          payload: payload,
        );

  SingleMessageLoaderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.payload,
  }) : super.internal();

  final MailNotificationPayload payload;

  @override
  Override overrideWith(
    FutureOr<Message> Function(SingleMessageLoaderRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SingleMessageLoaderProvider._internal(
        (ref) => create(ref as SingleMessageLoaderRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        payload: payload,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Message> createElement() {
    return _SingleMessageLoaderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SingleMessageLoaderProvider && other.payload == payload;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, payload.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SingleMessageLoaderRef on AutoDisposeFutureProviderRef<Message> {
  /// The parameter `payload` of this provider.
  MailNotificationPayload get payload;
}

class _SingleMessageLoaderProviderElement
    extends AutoDisposeFutureProviderElement<Message>
    with SingleMessageLoaderRef {
  _SingleMessageLoaderProviderElement(super.provider);

  @override
  MailNotificationPayload get payload =>
      (origin as SingleMessageLoaderProvider).payload;
}

String _$firstTimeMailClientSourceHash() =>
    r'ae11f3a5ed5cb6329488bd3f9ac3569ac8ad1f36';

/// Provides mail clients
///
/// Copied from [firstTimeMailClientSource].
@ProviderFor(firstTimeMailClientSource)
const firstTimeMailClientSourceProvider = FirstTimeMailClientSourceFamily();

/// Provides mail clients
///
/// Copied from [firstTimeMailClientSource].
class FirstTimeMailClientSourceFamily
    extends Family<AsyncValue<ConnectedAccount?>> {
  /// Provides mail clients
  ///
  /// Copied from [firstTimeMailClientSource].
  const FirstTimeMailClientSourceFamily();

  /// Provides mail clients
  ///
  /// Copied from [firstTimeMailClientSource].
  FirstTimeMailClientSourceProvider call({
    required RealAccount account,
    Mailbox? mailbox,
  }) {
    return FirstTimeMailClientSourceProvider(
      account: account,
      mailbox: mailbox,
    );
  }

  @override
  FirstTimeMailClientSourceProvider getProviderOverride(
    covariant FirstTimeMailClientSourceProvider provider,
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
  String? get name => r'firstTimeMailClientSourceProvider';
}

/// Provides mail clients
///
/// Copied from [firstTimeMailClientSource].
class FirstTimeMailClientSourceProvider
    extends AutoDisposeFutureProvider<ConnectedAccount?> {
  /// Provides mail clients
  ///
  /// Copied from [firstTimeMailClientSource].
  FirstTimeMailClientSourceProvider({
    required RealAccount account,
    Mailbox? mailbox,
  }) : this._internal(
          (ref) => firstTimeMailClientSource(
            ref as FirstTimeMailClientSourceRef,
            account: account,
            mailbox: mailbox,
          ),
          from: firstTimeMailClientSourceProvider,
          name: r'firstTimeMailClientSourceProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$firstTimeMailClientSourceHash,
          dependencies: FirstTimeMailClientSourceFamily._dependencies,
          allTransitiveDependencies:
              FirstTimeMailClientSourceFamily._allTransitiveDependencies,
          account: account,
          mailbox: mailbox,
        );

  FirstTimeMailClientSourceProvider._internal(
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
  Override overrideWith(
    FutureOr<ConnectedAccount?> Function(FirstTimeMailClientSourceRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FirstTimeMailClientSourceProvider._internal(
        (ref) => create(ref as FirstTimeMailClientSourceRef),
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
  AutoDisposeFutureProviderElement<ConnectedAccount?> createElement() {
    return _FirstTimeMailClientSourceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FirstTimeMailClientSourceProvider &&
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

mixin FirstTimeMailClientSourceRef
    on AutoDisposeFutureProviderRef<ConnectedAccount?> {
  /// The parameter `account` of this provider.
  RealAccount get account;

  /// The parameter `mailbox` of this provider.
  Mailbox? get mailbox;
}

class _FirstTimeMailClientSourceProviderElement
    extends AutoDisposeFutureProviderElement<ConnectedAccount?>
    with FirstTimeMailClientSourceRef {
  _FirstTimeMailClientSourceProviderElement(super.provider);

  @override
  RealAccount get account =>
      (origin as FirstTimeMailClientSourceProvider).account;
  @override
  Mailbox? get mailbox => (origin as FirstTimeMailClientSourceProvider).mailbox;
}

String _$mailtoHash() => r'392c1cf4d13bff03113b564193f1f1b21099cdac';

/// Creates a new [MessageBuilder] based on the given [mailtoUri] uri
///
/// Copied from [mailto].
@ProviderFor(mailto)
const mailtoProvider = MailtoFamily();

/// Creates a new [MessageBuilder] based on the given [mailtoUri] uri
///
/// Copied from [mailto].
class MailtoFamily extends Family<MessageBuilder> {
  /// Creates a new [MessageBuilder] based on the given [mailtoUri] uri
  ///
  /// Copied from [mailto].
  const MailtoFamily();

  /// Creates a new [MessageBuilder] based on the given [mailtoUri] uri
  ///
  /// Copied from [mailto].
  MailtoProvider call({
    required Uri mailtoUri,
    required MimeMessage originatingMessage,
  }) {
    return MailtoProvider(
      mailtoUri: mailtoUri,
      originatingMessage: originatingMessage,
    );
  }

  @override
  MailtoProvider getProviderOverride(
    covariant MailtoProvider provider,
  ) {
    return call(
      mailtoUri: provider.mailtoUri,
      originatingMessage: provider.originatingMessage,
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
  String? get name => r'mailtoProvider';
}

/// Creates a new [MessageBuilder] based on the given [mailtoUri] uri
///
/// Copied from [mailto].
class MailtoProvider extends AutoDisposeProvider<MessageBuilder> {
  /// Creates a new [MessageBuilder] based on the given [mailtoUri] uri
  ///
  /// Copied from [mailto].
  MailtoProvider({
    required Uri mailtoUri,
    required MimeMessage originatingMessage,
  }) : this._internal(
          (ref) => mailto(
            ref as MailtoRef,
            mailtoUri: mailtoUri,
            originatingMessage: originatingMessage,
          ),
          from: mailtoProvider,
          name: r'mailtoProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mailtoHash,
          dependencies: MailtoFamily._dependencies,
          allTransitiveDependencies: MailtoFamily._allTransitiveDependencies,
          mailtoUri: mailtoUri,
          originatingMessage: originatingMessage,
        );

  MailtoProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.mailtoUri,
    required this.originatingMessage,
  }) : super.internal();

  final Uri mailtoUri;
  final MimeMessage originatingMessage;

  @override
  Override overrideWith(
    MessageBuilder Function(MailtoRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MailtoProvider._internal(
        (ref) => create(ref as MailtoRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        mailtoUri: mailtoUri,
        originatingMessage: originatingMessage,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<MessageBuilder> createElement() {
    return _MailtoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MailtoProvider &&
        other.mailtoUri == mailtoUri &&
        other.originatingMessage == originatingMessage;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, mailtoUri.hashCode);
    hash = _SystemHash.combine(hash, originatingMessage.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MailtoRef on AutoDisposeProviderRef<MessageBuilder> {
  /// The parameter `mailtoUri` of this provider.
  Uri get mailtoUri;

  /// The parameter `originatingMessage` of this provider.
  MimeMessage get originatingMessage;
}

class _MailtoProviderElement extends AutoDisposeProviderElement<MessageBuilder>
    with MailtoRef {
  _MailtoProviderElement(super.provider);

  @override
  Uri get mailtoUri => (origin as MailtoProvider).mailtoUri;
  @override
  MimeMessage get originatingMessage =>
      (origin as MailtoProvider).originatingMessage;
}

String _$sourceHash() => r'd4e787d804ab333fbd5079af8a66fc5222bdef45';

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

String _$unifiedSourceHash() => r'9b128c1a2afaa51fa11e0810a9e6ecddfc6c53fd';

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

String _$realSourceHash() => r'b47b7d957d62f73be40a5e8666d7f5c76209e502';

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

String _$realMimeSourceHash() => r'4c50962bb20d8eacf3a69062ae2a656627393dcb';

abstract class _$RealMimeSource
    extends BuildlessAsyncNotifier<AsyncMimeSource> {
  late final RealAccount account;
  late final Mailbox? mailbox;

  Future<AsyncMimeSource> build({
    required RealAccount account,
    Mailbox? mailbox,
  });
}

/// Provides the message source for the given account
///
/// Copied from [RealMimeSource].
@ProviderFor(RealMimeSource)
const realMimeSourceProvider = RealMimeSourceFamily();

/// Provides the message source for the given account
///
/// Copied from [RealMimeSource].
class RealMimeSourceFamily extends Family<AsyncValue<AsyncMimeSource>> {
  /// Provides the message source for the given account
  ///
  /// Copied from [RealMimeSource].
  const RealMimeSourceFamily();

  /// Provides the message source for the given account
  ///
  /// Copied from [RealMimeSource].
  RealMimeSourceProvider call({
    required RealAccount account,
    Mailbox? mailbox,
  }) {
    return RealMimeSourceProvider(
      account: account,
      mailbox: mailbox,
    );
  }

  @override
  RealMimeSourceProvider getProviderOverride(
    covariant RealMimeSourceProvider provider,
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
  String? get name => r'realMimeSourceProvider';
}

/// Provides the message source for the given account
///
/// Copied from [RealMimeSource].
class RealMimeSourceProvider
    extends AsyncNotifierProviderImpl<RealMimeSource, AsyncMimeSource> {
  /// Provides the message source for the given account
  ///
  /// Copied from [RealMimeSource].
  RealMimeSourceProvider({
    required RealAccount account,
    Mailbox? mailbox,
  }) : this._internal(
          () => RealMimeSource()
            ..account = account
            ..mailbox = mailbox,
          from: realMimeSourceProvider,
          name: r'realMimeSourceProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$realMimeSourceHash,
          dependencies: RealMimeSourceFamily._dependencies,
          allTransitiveDependencies:
              RealMimeSourceFamily._allTransitiveDependencies,
          account: account,
          mailbox: mailbox,
        );

  RealMimeSourceProvider._internal(
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
  Future<AsyncMimeSource> runNotifierBuild(
    covariant RealMimeSource notifier,
  ) {
    return notifier.build(
      account: account,
      mailbox: mailbox,
    );
  }

  @override
  Override overrideWith(RealMimeSource Function() create) {
    return ProviderOverride(
      origin: this,
      override: RealMimeSourceProvider._internal(
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
  AsyncNotifierProviderElement<RealMimeSource, AsyncMimeSource>
      createElement() {
    return _RealMimeSourceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RealMimeSourceProvider &&
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

mixin RealMimeSourceRef on AsyncNotifierProviderRef<AsyncMimeSource> {
  /// The parameter `account` of this provider.
  RealAccount get account;

  /// The parameter `mailbox` of this provider.
  Mailbox? get mailbox;
}

class _RealMimeSourceProviderElement
    extends AsyncNotifierProviderElement<RealMimeSource, AsyncMimeSource>
    with RealMimeSourceRef {
  _RealMimeSourceProviderElement(super.provider);

  @override
  RealAccount get account => (origin as RealMimeSourceProvider).account;
  @override
  Mailbox? get mailbox => (origin as RealMimeSourceProvider).mailbox;
}

String _$mailClientSourceHash() => r'6245fdaddaceb72c43b94b988b7e6dfd5966c8ab';

abstract class _$MailClientSource extends BuildlessNotifier<MailClient> {
  late final RealAccount account;
  late final Mailbox? mailbox;

  MailClient build({
    required RealAccount account,
    Mailbox? mailbox,
  });
}

/// Provides mail clients
///
/// Expects [Mailbox] to be `null` for the inbox.
///
/// Copied from [MailClientSource].
@ProviderFor(MailClientSource)
const mailClientSourceProvider = MailClientSourceFamily();

/// Provides mail clients
///
/// Expects [Mailbox] to be `null` for the inbox.
///
/// Copied from [MailClientSource].
class MailClientSourceFamily extends Family<MailClient> {
  /// Provides mail clients
  ///
  /// Expects [Mailbox] to be `null` for the inbox.
  ///
  /// Copied from [MailClientSource].
  const MailClientSourceFamily();

  /// Provides mail clients
  ///
  /// Expects [Mailbox] to be `null` for the inbox.
  ///
  /// Copied from [MailClientSource].
  MailClientSourceProvider call({
    required RealAccount account,
    Mailbox? mailbox,
  }) {
    return MailClientSourceProvider(
      account: account,
      mailbox: mailbox,
    );
  }

  @override
  MailClientSourceProvider getProviderOverride(
    covariant MailClientSourceProvider provider,
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
  String? get name => r'mailClientSourceProvider';
}

/// Provides mail clients
///
/// Expects [Mailbox] to be `null` for the inbox.
///
/// Copied from [MailClientSource].
class MailClientSourceProvider
    extends NotifierProviderImpl<MailClientSource, MailClient> {
  /// Provides mail clients
  ///
  /// Expects [Mailbox] to be `null` for the inbox.
  ///
  /// Copied from [MailClientSource].
  MailClientSourceProvider({
    required RealAccount account,
    Mailbox? mailbox,
  }) : this._internal(
          () => MailClientSource()
            ..account = account
            ..mailbox = mailbox,
          from: mailClientSourceProvider,
          name: r'mailClientSourceProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mailClientSourceHash,
          dependencies: MailClientSourceFamily._dependencies,
          allTransitiveDependencies:
              MailClientSourceFamily._allTransitiveDependencies,
          account: account,
          mailbox: mailbox,
        );

  MailClientSourceProvider._internal(
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
  MailClient runNotifierBuild(
    covariant MailClientSource notifier,
  ) {
    return notifier.build(
      account: account,
      mailbox: mailbox,
    );
  }

  @override
  Override overrideWith(MailClientSource Function() create) {
    return ProviderOverride(
      origin: this,
      override: MailClientSourceProvider._internal(
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
  NotifierProviderElement<MailClientSource, MailClient> createElement() {
    return _MailClientSourceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MailClientSourceProvider &&
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

mixin MailClientSourceRef on NotifierProviderRef<MailClient> {
  /// The parameter `account` of this provider.
  RealAccount get account;

  /// The parameter `mailbox` of this provider.
  Mailbox? get mailbox;
}

class _MailClientSourceProviderElement
    extends NotifierProviderElement<MailClientSource, MailClient>
    with MailClientSourceRef {
  _MailClientSourceProviderElement(super.provider);

  @override
  RealAccount get account => (origin as MailClientSourceProvider).account;
  @override
  Mailbox? get mailbox => (origin as MailClientSourceProvider).mailbox;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
