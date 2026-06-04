// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Messages)
final messagesProvider = MessagesFamily._();

final class MessagesProvider
    extends $AsyncNotifierProvider<Messages, List<MessageModel>> {
  MessagesProvider._({
    required MessagesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'messagesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$messagesHash();

  @override
  String toString() {
    return r'messagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Messages create() => Messages();

  @override
  bool operator ==(Object other) {
    return other is MessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$messagesHash() => r'551e7a3a85417dca7302b6df348ac1f3a480301e';

final class MessagesFamily extends $Family
    with
        $ClassFamilyOverride<
          Messages,
          AsyncValue<List<MessageModel>>,
          List<MessageModel>,
          FutureOr<List<MessageModel>>,
          String
        > {
  MessagesFamily._()
    : super(
        retry: null,
        name: r'messagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MessagesProvider call(String chatId) =>
      MessagesProvider._(argument: chatId, from: this);

  @override
  String toString() => r'messagesProvider';
}

abstract class _$Messages extends $AsyncNotifier<List<MessageModel>> {
  late final _$args = ref.$arg as String;
  String get chatId => _$args;

  FutureOr<List<MessageModel>> build(String chatId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<MessageModel>>, List<MessageModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<MessageModel>>, List<MessageModel>>,
              AsyncValue<List<MessageModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
