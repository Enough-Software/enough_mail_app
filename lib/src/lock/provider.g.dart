// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appLockHash() => r'f41ef0732f43fae14f10611015d2415d32463a70';

/// Checks the app life cycle and displays the lock screen if needed
///
/// Copied from [AppLock].
@ProviderFor(AppLock)
final appLockProvider = NotifierProvider<AppLock, void>.internal(
  AppLock.new,
  name: r'appLockProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appLockHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppLock = Notifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
