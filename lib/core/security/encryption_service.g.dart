// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'encryption_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(encryptionService)
final encryptionServiceProvider = EncryptionServiceProvider._();

final class EncryptionServiceProvider
    extends
        $FunctionalProvider<
          EncryptionService,
          EncryptionService,
          EncryptionService
        >
    with $Provider<EncryptionService> {
  EncryptionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'encryptionServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$encryptionServiceHash();

  @$internal
  @override
  $ProviderElement<EncryptionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EncryptionService create(Ref ref) {
    return encryptionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EncryptionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EncryptionService>(value),
    );
  }
}

String _$encryptionServiceHash() => r'c4b4c8874fdf768c9d0be60c3e38ed1adfed44ce';
