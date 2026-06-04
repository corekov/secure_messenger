import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';
import 'package:flutter/foundation.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../storage/secure_storage_service.dart';

part 'websocket_service.g.dart';

class WebSocketService {
  final SecureStorageService _storage;
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  bool _isConnected = false;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  final List<Map<String, dynamic>> _offlineQueue = [];

  static const int _maxReconnectAttempts = 10;
  static final String _apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: (defaultTargetPlatform == TargetPlatform.android && !kIsWeb)
        ? 'http://10.0.2.2:8080/api/v1'
        : 'http://localhost:8080/api/v1',
  );

  static final String _wsUrl = String.fromEnvironment(
    'WS_URL',
    defaultValue: _apiUrl.startsWith('https')
        ? '${_apiUrl.replaceFirst('https', 'wss')}/ws'
        : '${_apiUrl.replaceFirst('http', 'ws')}/ws',
  );

  WebSocketService(this._storage);

  Future<void> connect() async {
    if (_isConnected) return;

    try {
      final token = await _storage.getAccessToken();
      if (token == null) {
        throw Exception('No auth token available for WebSocket');
      }

      // Connect with token in headers (or modify URL if backend requires query param)
      _channel = WebSocketChannel.connect(
        Uri.parse('$_wsUrl?token=$token'), // Common pattern for WS auth
      );

      _isConnected = true;
      _reconnectAttempts = 0;
      developer.log(
        'WebSocket connected successfully',
        name: 'WebSocketService',
      );

      _flushQueue();

      _subscription = _channel!.stream.listen(
        (message) {
          try {
            final decoded =
                jsonDecode(message as String) as Map<String, dynamic>;
            _messageController.add(decoded);
          } catch (e) {
            developer.log(
              'Failed to decode WS message',
              error: e,
              name: 'WebSocketService',
            );
          }
        },
        onDone: () {
          developer.log(
            'WebSocket connection closed',
            name: 'WebSocketService',
          );
          _handleDisconnect();
        },
        onError: (error) {
          developer.log(
            'WebSocket error',
            error: error,
            name: 'WebSocketService',
          );
          _handleDisconnect();
        },
      );
    } catch (e) {
      developer.log(
        'WebSocket connection failed',
        error: e,
        name: 'WebSocketService',
      );
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    _isConnected = false;
    _cleanUp();
    _attemptReconnect();
  }

  void _attemptReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      developer.log(
        'Max reconnect attempts reached. Giving up.',
        name: 'WebSocketService',
      );
      return;
    }

    final backoffDuration = Duration(
      milliseconds: min(10000, 1000 * pow(2, _reconnectAttempts)).toInt(),
    );

    _reconnectAttempts++;
    developer.log(
      'Reconnecting in ${backoffDuration.inSeconds} seconds (Attempt $_reconnectAttempts)',
      name: 'WebSocketService',
    );

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(backoffDuration, connect);
  }

  void send(Map<String, dynamic> data) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(jsonEncode(data));
    } else {
      developer.log(
        'Cannot send message, WebSocket disconnected. Queuing message.',
        name: 'WebSocketService',
      );
      _offlineQueue.add(data);
    }
  }

  void _flushQueue() {
    if (_offlineQueue.isNotEmpty) {
      developer.log(
        'Flushing ${_offlineQueue.length} queued messages.',
        name: 'WebSocketService',
      );
      while (_offlineQueue.isNotEmpty && _isConnected && _channel != null) {
        final data = _offlineQueue.removeAt(0);
        _channel!.sink.add(jsonEncode(data));
      }
    }
  }

  void _cleanUp() {
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _cleanUp();
    _isConnected = false;
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}

@Riverpod(keepAlive: true)
WebSocketService webSocketService(Ref ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  final service = WebSocketService(storage);

  ref.onDispose(() {
    service.dispose();
  });

  return service;
}
