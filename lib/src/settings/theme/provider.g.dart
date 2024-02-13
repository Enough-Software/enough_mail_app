// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$defaultColorSeedHash() => r'c2bdee6a44fad5bfcada3d31af099906bb24c988';

/// The default color provider
///
/// Copied from [defaultColorSeed].
@ProviderFor(defaultColorSeed)
final defaultColorSeedProvider = Provider<Color>.internal(
  defaultColorSeed,
  name: r'defaultColorSeedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$defaultColorSeedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DefaultColorSeedRef = ProviderRef<Color>;
String _$themeFinderHash() => r'484171788a33fa10e91e0f085a1c87cb4a29d8f0';

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

abstract class _$ThemeFinder extends BuildlessNotifier<ThemeSettingsData> {
  late final BuildContext context;

  ThemeSettingsData build({
    required BuildContext context,
  });
}

/// Provides the settings
///
/// Copied from [ThemeFinder].
@ProviderFor(ThemeFinder)
const themeFinderProvider = ThemeFinderFamily();

/// Provides the settings
///
/// Copied from [ThemeFinder].
class ThemeFinderFamily extends Family<ThemeSettingsData> {
  /// Provides the settings
  ///
  /// Copied from [ThemeFinder].
  const ThemeFinderFamily();

  /// Provides the settings
  ///
  /// Copied from [ThemeFinder].
  ThemeFinderProvider call({
    required BuildContext context,
  }) {
    return ThemeFinderProvider(
      context: context,
    );
  }

  @override
  ThemeFinderProvider getProviderOverride(
    covariant ThemeFinderProvider provider,
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
  String? get name => r'themeFinderProvider';
}

/// Provides the settings
///
/// Copied from [ThemeFinder].
class ThemeFinderProvider
    extends NotifierProviderImpl<ThemeFinder, ThemeSettingsData> {
  /// Provides the settings
  ///
  /// Copied from [ThemeFinder].
  ThemeFinderProvider({
    required BuildContext context,
  }) : this._internal(
          () => ThemeFinder()..context = context,
          from: themeFinderProvider,
          name: r'themeFinderProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$themeFinderHash,
          dependencies: ThemeFinderFamily._dependencies,
          allTransitiveDependencies:
              ThemeFinderFamily._allTransitiveDependencies,
          context: context,
        );

  ThemeFinderProvider._internal(
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
  ThemeSettingsData runNotifierBuild(
    covariant ThemeFinder notifier,
  ) {
    return notifier.build(
      context: context,
    );
  }

  @override
  Override overrideWith(ThemeFinder Function() create) {
    return ProviderOverride(
      origin: this,
      override: ThemeFinderProvider._internal(
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
  NotifierProviderElement<ThemeFinder, ThemeSettingsData> createElement() {
    return _ThemeFinderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ThemeFinderProvider && other.context == context;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, context.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ThemeFinderRef on NotifierProviderRef<ThemeSettingsData> {
  /// The parameter `context` of this provider.
  BuildContext get context;
}

class _ThemeFinderProviderElement
    extends NotifierProviderElement<ThemeFinder, ThemeSettingsData>
    with ThemeFinderRef {
  _ThemeFinderProviderElement(super.provider);

  @override
  BuildContext get context => (origin as ThemeFinderProvider).context;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
