import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:wyd_front/API/RealTime/sse_api.dart';
import 'package:wyd_front/service/util/real_time/real_time_message_handler.dart';
import 'package:wyd_front/service/util/real_time/real_time_service.dart';
import 'package:sse_channel/sse_channel.dart';

class SseService implements RealTimeService {
  StreamSubscription<MessageEvent>? _subscription;
  SseChannel? _channel;
  bool _isConnecting = false;

  final SseAPI _sseApi = SseAPI();

  @override
  Future<void> initialize() async {
    if (_subscription != null || _isConnecting) return;

    _isConnecting = true;

    try {
      _channel = SseChannel.connect(_sseApi.getStreamUri(), client: _sseApi.client);

      await _channel!.ready;

      _subscription = _channel!.stream.listen((update) {
        _onSseMessage(update);
      }, onError: (err) {
        debugPrint("SSE error: $err");
        _cleanupAndRetry();
      }, onDone: () {
        debugPrint("SSE stream closed");
        // server closed connection
        _cleanupAndRetry();
      });
      debugPrint("SSE stream established.");
    } catch (e) {
      debugPrint("Failed to establish SSE stream: $e");
      _cleanupAndRetry();
    } finally {
      _isConnecting = false;
    }
  }

  void _cleanupAndRetry() {
    _subscription?.cancel();
    _subscription = null;

    _channel?.sink.close();
    _channel = null;

    _isConnecting = false;
    _retry();
  }

  void _retry() {
    if (_subscription != null || _isConnecting) return;

    Future.delayed(const Duration(seconds: 5), () {
      debugPrint("Attempting SSE retry...");
      initialize();
    });
  }

  void _onSseMessage(MessageEvent update) {
    try {
      final data = update.data;
      if (data != null && data.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(data);
        RealTimeMessageHandler.handleUpdate(map);
      }
    } catch (e) {
      debugPrint("Failed to parse SSE event: $e");
    }
  }

  @override
  Future<void> dispose() async {
    debugPrint("FULL SHUTDOWN: Closing Channel and Subscription.");
    await _subscription?.cancel();
    _subscription = null;

    await _channel?.sink.close();
    _channel = null;
  }
}
