// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(fileService)
final fileServiceProvider = FileServiceProvider._();

final class FileServiceProvider
    extends $FunctionalProvider<FileService, FileService, FileService>
    with $Provider<FileService> {
  FileServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fileServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fileServiceHash();

  @$internal
  @override
  $ProviderElement<FileService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FileService create(Ref ref) {
    return fileService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FileService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FileService>(value),
    );
  }
}

String _$fileServiceHash() => r'89b90aaeacb5961a37b3837570d37a360423c26d';
