// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appLockHash() => r'b00935864580ba0f3313c1a0710b8c9ca49df467';

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

abstract class _$AppLock extends BuildlessNotifier<void> {
  late final BuildContext context;

  void build({
    required BuildContext context,
  });
}

/// Checks the app life cycle and displays the lock screen if needed
///
/// Copied from [AppLock].
@ProviderFor(AppLock)
const appLockProvider = AppLockFamily();

/// Checks the app life cycle and displays the lock screen if needed
///
/// Copied from [AppLock].
class AppLockFamily extends Family<void> {
  /// Checks the app life cycle and displays the lock screen if needed
  ///
  /// Copied from [AppLock].
  const AppLockFamily();

  /// Checks the app life cycle and displays the lock screen if needed
  ///
  /// Copied from [AppLock].
  AppLockProvider call({
    required BuildContext context,
  }) {
    return AppLockProvider(
      context: context,
    );
  }

  @override
  AppLockProvider getProviderOverride(
    covariant AppLockProvider provider,
  ) {
    return call(
      context: provider.context,
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
  String? get name => r'appLockProvider';
}

/// Checks the app life cycle and displays the lock screen if needed
///
/// Copied from [AppLock].
class AppLockProvider extends NotifierProviderImpl<AppLock, void> {
  /// Checks the app life cycle and displays the lock screen if needed
  ///
  /// Copied from [AppLock].
  AppLockProvider({
    required BuildContext context,
  }) : this._internal(
          () => AppLock()..context = context,
          from: appLockProvider,
          name: r'appLockProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$appLockHash,
          dependencies: AppLockFamily._dependencies,
          allTransitiveDependencies: AppLockFamily._allTransitiveDependencies,
          context: context,
        );

  AppLockProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.context,
  }) : super.internal();

  final BuildContext context;

  @override
  void runNotifierBuild(
    covariant AppLock notifier,
  ) {
    return notifier.build(
      context: context,
    );
  }

  @override
  Override overrideWith(AppLock Function() create) {
    return ProviderOverride(
      origin: this,
      override: AppLockProvider._internal(
        () => create()..context = context,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        context: context,
      ),
    );
  }

  @override
  NotifierProviderElement<AppLock, void> createElement() {
    return _AppLockProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AppLockProvider && other.context == context;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, context.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AppLockRef on NotifierProviderRef<void> {
  /// The parameter `context` of this provider.
  BuildContext get context;
}

class _AppLockProviderElement extends NotifierProviderElement<AppLock, void>
    with AppLockRef {
  _AppLockProviderElement(super.provider);

  @override
  BuildContext get context => (origin as AppLockProvider).context;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
