import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'websocket_service.dart';
import '../../features/auth/providers/auth_provider.dart';

part 'websocket_manager.g.dart';

@Riverpod(keepAlive: true)
class WebSocketManager extends _$WebSocketManager {
  @override
  void build() {
    // Listen to authentication state changes
    ref.listen<bool>(authProvider, (previous, isAuthenticated) {
      final wsService = ref.read(webSocketServiceProvider);
      if (isAuthenticated) {
        wsService.connect();
      } else {
        wsService.disconnect();
      }
    });
  }

  void sendMessage(Map<String, dynamic> payload) {
    ref.read(webSocketServiceProvider).send(payload);
  }
}
