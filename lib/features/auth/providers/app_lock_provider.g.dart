// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_lock_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BiometricSettings)
final biometricSettingsProvider = BiometricSettingsProvider._();

final class BiometricSettingsProvider
    extends $NotifierProvider<BiometricSettings, bool> {
  BiometricSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'biometricSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$biometricSettingsHash();

  @$internal
  @override
  BiometricSettings create() => BiometricSettings();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$biometricSettingsHash() => r'7c3639dcc9fddfed047295a1c7a448a1c0e89412';

abstract class _$BiometricSettings extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(AppLockedState)
final appLockedStateProvider = AppLockedStateProvider._();

final class AppLockedStateProvider
    extends $NotifierProvider<AppLockedState, bool> {
  AppLockedStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLockedStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLockedStateHash();

  @$internal
  @override
  AppLockedState create() => AppLockedState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$appLockedStateHash() => r'55eac1a9a42c50a0b71eadc5589cca1bc53d8577';

abstract class _$AppLockedState extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(HasPinState)
final hasPinStateProvider = HasPinStateProvider._();

final class HasPinStateProvider extends $NotifierProvider<HasPinState, bool> {
  HasPinStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasPinStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasPinStateHash();

  @$internal
  @override
  HasPinState create() => HasPinState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$hasPinStateHash() => r'bdab49f9a164aee7fd5cca5c5e246d08e11c39c9';

abstract class _$HasPinState extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
