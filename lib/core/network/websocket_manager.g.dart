// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'websocket_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WebSocketManager)
final webSocketManagerProvider = WebSocketManagerProvider._();

final class WebSocketManagerProvider
    extends $NotifierProvider<WebSocketManager, void> {
  WebSocketManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'webSocketManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$webSocketManagerHash();

  @$internal
  @override
  WebSocketManager create() => WebSocketManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$webSocketManagerHash() => r'a1be92353dccf365bfef20aa22c668c1ae9da0bf';

abstract class _$WebSocketManager extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
