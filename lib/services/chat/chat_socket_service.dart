import 'dart:async';
import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';


class ChatSocketService {
  final String baseUrl;
  StompClient? _client;
  StreamController<Map<String, dynamic>>? _controller;

  ChatSocketService(this.baseUrl);

  Stream<Map<String, dynamic>>? get stream => _controller?.stream;

  bool get isConnected => _client?.connected ?? false;

  Future<void> connect({required int conversationId}) async {
    await disconnect();
    _controller = StreamController<Map<String, dynamic>>.broadcast();

    final wsUrl = _buildWsUrl(baseUrl);
    final topic = '/topic/chat/conversations/$conversationId';

    _client = StompClient(
      config: StompConfig(
        url: wsUrl,
        onConnect: (StompFrame frame) {
          _client?.subscribe(
            destination: topic,
            callback: (frame) {
              if (frame.body == null) return;
              try {
                final data = jsonDecode(frame.body!);
                if (data is Map<String, dynamic>) {
                  _controller?.add(data);
                }
              } catch (_) {}
            },
          );
        },
        onWebSocketError: (dynamic error) {
          _controller?.addError(error);
        },
        onStompError: (frame) {
          _controller?.addError(frame.body ?? 'stomp-error');
        },
        reconnectDelay: const Duration(seconds: 3),
      ),
    );

    _client?.activate();
  }

  Future<void> disconnect() async {
    await _controller?.close();
    _controller = null;
    if (_client != null) {
      _client?.deactivate();
      _client = null;
    }
  }

  Future<void> send({
    required int conversationId,
    required Map<String, dynamic> body,
  }) async {
    final payload = jsonEncode(body);
    final destination = '/app/chat/messages';
    if (_client?.connected == true) {
      _client?.send(destination: destination, body: payload);
    }
  }

  String _buildWsUrl(String raw) {
    final uri = Uri.parse(raw);
    final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
    final path = uri.path.endsWith('/') ? '${uri.path}ws' : '${uri.path}/ws';
    return Uri(
      scheme: scheme,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
      path: path,
    ).toString();
  }
}
