import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Ses efektleri servisi
/// Oyunlarda kullanılacak ses efektlerini yönetir
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal() {
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
  }

  // BGM (Arka plan müziği) için sürekli oynatıcı
  final AudioPlayer _bgmPlayer = AudioPlayer();
  
  bool _isSoundEnabled = true;
  bool _isMusicEnabled = true;

  /// Ses efektlerini çal
  /// [soundName] - assets/sounds/ klasöründeki dosya adı (örn: "correct.wav")
  Future<void> playSound(String soundName) async {
    if (!_isSoundEnabled) return;
    
    try {
      // Her efekt için yeni bir oynatıcı oluştur (çakışmaları engellemek için)
      final player = AudioPlayer();
      await player.play(AssetSource('sounds/$soundName'));
      // Oynatma bitince temizle
      player.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.completed || state == PlayerState.stopped) {
          player.dispose();
        }
      });
    } catch (e) {
      debugPrint('⚠️ Ses çalınamadı: $soundName');
      debugPrint('   Hata: $e');
    }
  }

  /// Arka plan müziği çal
  Future<void> playMusic(String musicName) async {
    if (!_isMusicEnabled) return;
    try {
      await _bgmPlayer.play(AssetSource('sounds/$musicName'));
    } catch (e) {
      debugPrint('⚠️ Müzik çalınamadı: $musicName');
    }
  }

  /// Arka plan müziğini durdur
  Future<void> stopMusic() async {
    await _bgmPlayer.stop();
  }

  void setSoundEnabled(bool enabled) {
    _isSoundEnabled = enabled;
  }

  void setMusicEnabled(bool enabled) {
    _isMusicEnabled = enabled;
    if (!enabled) {
      stopMusic();
    }
  }

  bool get isSoundEnabled => _isSoundEnabled;
  bool get isMusicEnabled => _isMusicEnabled;

  // ========== Önceden tanımlı ses efektleri ==========

  /// Doğru cevap sesi
  Future<void> playCorrect() => playSound('correct.wav');

  /// Yanlış cevap sesi
  Future<void> playWrong() => playSound('wrong.wav');

  /// Dokunma/buton sesi
  Future<void> playTap() => playSound('tap.wav');

  /// Başarılı işlem sesi
  Future<void> playSuccess() => playSound('success.wav');

  /// Oyun bitiş sesi
  Future<void> playGameOver() => playSound('game_over.wav');

  /// Geri sayım sesi
  Future<void> playCountdown() => playSound('countdown.wav');

  /// Seviye atlama sesi
  Future<void> playLevelUp() => playSound('level_up.wav');

  /// Dispose - Uygulama kapanırken çağrılmalı
  void dispose() {
    _bgmPlayer.dispose();
  }
}
