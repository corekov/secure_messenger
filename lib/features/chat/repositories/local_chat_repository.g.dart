// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_chat_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(localChatRepository)
final localChatRepositoryProvider = LocalChatRepositoryProvider._();

final class LocalChatRepositoryProvider
    extends
        $FunctionalProvider<
          LocalChatRepository,
          LocalChatRepository,
          LocalChatRepository
        >
    with $Provider<LocalChatRepository> {
  LocalChatRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localChatRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localChatRepositoryHash();

  @$internal
  @override
  $ProviderElement<LocalChatRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocalChatRepository create(Ref ref) {
    return localChatRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalChatRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalChatRepository>(value),
    );
  }
}

String _$localChatRepositoryHash() =>
    r'97bda3d231d5f3fd4346e5ae83449ce8c6e9e5e3';
