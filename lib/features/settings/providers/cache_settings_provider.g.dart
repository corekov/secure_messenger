// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CacheSettings)
final cacheSettingsProvider = CacheSettingsProvider._();

final class CacheSettingsProvider
    extends $NotifierProvider<CacheSettings, int> {
  CacheSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cacheSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cacheSettingsHash();

  @$internal
  @override
  CacheSettings create() => CacheSettings();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$cacheSettingsHash() => r'9c7349bd2c57272011825e632f967a6652ffe99d';

abstract class _$CacheSettings extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
