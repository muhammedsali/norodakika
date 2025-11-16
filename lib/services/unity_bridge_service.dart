import 'dart:async';
import 'package:flutter/services.dart';
import '../core/memory/memory_bank.dart';

class UnityBridgeService {
  static const MethodChannel _channel = MethodChannel(MemoryBank.unityChannels['sendMessageToUnity']!);
  static const EventChannel _eventChannel = EventChannel(MemoryBank.unityChannels['onUnityMessage']!);

  static StreamSubscription? _unityMessageSubscription;

  // Unity'ye mesaj gönder
  static Future<void> sendMessageToUnity({
    required String gameId,
    required double difficulty,
  }) async {
    try {
      await _channel.invokeMethod('launchGame', {
        'gameId': gameId,
        'difficulty': difficulty,
      });
    } catch (e) {
      print('Unity mesaj gönderme hatası: $e');
    }
  }

  // Unity'den gelen mesajları dinle
  static Stream<Map<String, dynamic>>? getUnityMessages() {
    try {
      return _eventChannel.receiveBroadcastStream().map((event) {
        if (event is Map) {
          return Map<String, dynamic>.from(event);
        }
        return {};
      });
    } catch (e) {
      print('Unity mesaj dinleme hatası: $e');
      return null;
    }
  }

  // Oyunu başlat
  static Future<void> launchGame({
    required String gameId,
    required double difficulty,
    required Function(Map<String, dynamic>) onGameComplete,
  }) async {
    // Unity mesajlarını dinle
    final stream = getUnityMessages();
    if (stream != null) {
      _unityMessageSubscription?.cancel();
      _unityMessageSubscription = stream.listen((message) {
        if (message['type'] == 'gameComplete') {
          onGameComplete(message);
          _unityMessageSubscription?.cancel();
        }
      });
    }

    // Unity'ye oyun başlatma komutu gönder
    await sendMessageToUnity(gameId: gameId, difficulty: difficulty);
  }

  // Temizlik
  static void dispose() {
    _unityMessageSubscription?.cancel();
    _unityMessageSubscription = null;
  }
}

