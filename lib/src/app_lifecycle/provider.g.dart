// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appIsResumedHash() => r'2b8853b672a6faf4f961d546241be25a23bb8ebe';

/// Easy access to be notified when the app is resumed
///
/// Copied from [appIsResumed].
@ProviderFor(appIsResumed)
final appIsResumedProvider = Provider<bool>.internal(
  appIsResumed,
  name: r'appIsResumedProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appIsResumedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AppIsResumedRef = ProviderRef<bool>;
String _$appIsInactivatedHash() => r'c13bdf5ad0eec6c95c5a85d2fe88ad84f9b3792f';

/// Easy access to be notified when the app is put to the background
///
/// Copied from [appIsInactivated].
@ProviderFor(appIsInactivated)
final appIsInactivatedProvider = Provider<bool>.internal(
  appIsInactivated,
  name: r'appIsInactivatedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appIsInactivatedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AppIsInactivatedRef = ProviderRef<bool>;
String _$appLifecycleHash() => r'1a695a26a70dd1d815c73f9281063bc8b7ee98f1';

/// Allows to retrieve the current (filtered) app life cycle
///
/// Copied from [AppLifecycle].
@ProviderFor(AppLifecycle)
final appLifecycleProvider =
    NotifierProvider<AppLifecycle, AppLifecycleState>.internal(
  AppLifecycle.new,
  name: r'appLifecycleProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appLifecycleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppLifecycle = Notifier<AppLifecycleState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
