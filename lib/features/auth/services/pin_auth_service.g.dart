// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pin_auth_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pinAuthService)
final pinAuthServiceProvider = PinAuthServiceProvider._();

final class PinAuthServiceProvider
    extends $FunctionalProvider<PinAuthService, PinAuthService, PinAuthService>
    with $Provider<PinAuthService> {
  PinAuthServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pinAuthServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pinAuthServiceHash();

  @$internal
  @override
  $ProviderElement<PinAuthService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PinAuthService create(Ref ref) {
    return pinAuthService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PinAuthService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PinAuthService>(value),
    );
  }
}

String _$pinAuthServiceHash() => r'c0906df8668c2878c8de6ee7daa4f8e8eee47a4b';
