import 'package:audioplayers/audioplayers.dart';

/// Ses efektleri servisi
/// Oyunlarda kullanılacak ses efektlerini yönetir
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isEnabled = true; // Kullanıcı sesleri kapatabilir

  /// Ses efektlerini çal
  /// [soundName] - assets/sounds/ klasöründeki dosya adı (örn: "correct.mp3")
  Future<void> playSound(String soundName) async {
    if (!_isEnabled) return;
    
    try {
      await _player.play(AssetSource('sounds/$soundName'));
    } catch (e) {
      // Ses dosyası bulunamazsa uyarı ver (debug için)
      print('⚠️ Ses çalınamadı: $soundName');
      print('   Hata: $e');
      print('   Çözüm: assets/sounds/ klasörüne $soundName dosyasını ekleyin');
    }
  }

  /// Ses efektlerini aç/kapat
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Ses efektlerinin açık olup olmadığını kontrol et
  bool get isEnabled => _isEnabled;

  // ========== Önceden tanımlı ses efektleri ==========

  /// Doğru cevap sesi
  Future<void> playCorrect() => playSound('correct.mp3');

  /// Yanlış cevap sesi
  Future<void> playWrong() => playSound('wrong.mp3');

  /// Dokunma/buton sesi
  Future<void> playTap() => playSound('tap.mp3');

  /// Başarılı işlem sesi
  Future<void> playSuccess() => playSound('success.mp3');

  /// Oyun bitiş sesi
  Future<void> playGameOver() => playSound('game_over.mp3');

  /// Geri sayım sesi
  Future<void> playCountdown() => playSound('countdown.mp3');

  /// Seviye atlama sesi
  Future<void> playLevelUp() => playSound('level_up.mp3');

  /// Dispose - Uygulama kapanırken çağrılmalı
  void dispose() {
    _player.dispose();
  }
}

