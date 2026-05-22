// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatList)
final chatListProvider = ChatListProvider._();

final class ChatListProvider
    extends $AsyncNotifierProvider<ChatList, List<ChatModel>> {
  ChatListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatListHash();

  @$internal
  @override
  ChatList create() => ChatList();
}

String _$chatListHash() => r'2ec02785c448a3f52d20c725f998ea46b88e69c5';

abstract class _$ChatList extends $AsyncNotifier<List<ChatModel>> {
  FutureOr<List<ChatModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<ChatModel>>, List<ChatModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ChatModel>>, List<ChatModel>>,
              AsyncValue<List<ChatModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
