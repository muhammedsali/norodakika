# 🔊 Ses Efektleri Rehberi

## 📋 Genel Bilgiler

Oyunlara ses efektleri eklemek için `audioplayers` paketi kullanılacak. Bu rehber, ses efektlerinin nasıl ekleneceğini ve kullanılacağını açıklar.

---

## 🚀 Kurulum

### 1. Paketi Ekle

`pubspec.yaml` dosyasına `audioplayers` paketini ekleyin:

```yaml
dependencies:
  # ... mevcut paketler
  audioplayers: ^5.2.1  # Ses efektleri için
```

Sonra terminalde:
```bash
flutter pub get
```

### 2. Assets Klasörü Oluştur

Proje kök dizininde `assets/sounds/` klasörü oluşturun:

```
assets/
├── images/
├── icons/
├── games/
└── sounds/          # YENİ - Ses dosyaları buraya
    ├── correct.mp3
    ├── wrong.mp3
    ├── tap.mp3
    ├── success.mp3
    ├── game_over.mp3
    └── ...
```

### 3. pubspec.yaml'a Assets Ekle

`pubspec.yaml` dosyasında assets bölümüne ses klasörünü ekleyin:

```yaml
flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
    - assets/games/
    - assets/sounds/    # YENİ
```

---

## 🎵 Ses Dosyaları

### Gerekli Ses Efektleri

Her oyun için şu ses efektlerini hazırlayın:

1. **correct.mp3** - Doğru cevap sesi (kısa, pozitif)
2. **wrong.mp3** - Yanlış cevap sesi (kısa, negatif)
3. **tap.mp3** - Dokunma/buton sesi (çok kısa)
4. **success.mp3** - Başarılı işlem (uzun, pozitif)
5. **game_over.mp3** - Oyun bitiş sesi
6. **countdown.mp3** - Geri sayım sesi (isteğe bağlı)
7. **level_up.mp3** - Seviye atlama (isteğe bağlı)

### Ses Dosyası Özellikleri

- **Format:** MP3 veya WAV (MP3 önerilir - daha küçük)
- **Süre:** 0.1 - 2 saniye arası (kısa sesler)
- **Kalite:** 44.1 kHz, 128 kbps yeterli
- **Boyut:** Mümkün olduğunca küçük (her dosya < 100 KB)

### Ses Dosyalarını Nereden Bulabilirsiniz?

1. **Ücretsiz Kaynaklar:**
   - [Freesound.org](https://freesound.org) - Ücretsiz ses efektleri
   - [Zapsplat.com](https://www.zapsplat.com) - Ücretsiz ses efektleri
   - [Mixkit.co](https://mixkit.co/free-sound-effects/) - Ücretsiz ses efektleri

2. **Ücretli Kaynaklar:**
   - [AudioJungle](https://audiojungle.net)
   - [Pond5](https://www.pond5.com)

3. **Kendi Seslerinizi Oluşturun:**
   - [Audacity](https://www.audacityteam.org) - Ücretsiz ses editörü
   - [GarageBand](https://www.apple.com/garageband/) - Mac için

---

## 💻 Kod Entegrasyonu

### 1. Ses Servisi Oluştur

`lib/services/audio_service.dart` dosyası oluşturun:

```dart
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isEnabled = true; // Kullanıcı sesleri kapatabilir

  // Ses efektlerini çal
  Future<void> playSound(String soundName) async {
    if (!_isEnabled) return;
    
    try {
      await _player.play(AssetSource('sounds/$soundName'));
    } catch (e) {
      // Ses dosyası bulunamazsa sessizce geç
      print('Ses çalınamadı: $soundName - $e');
    }
  }

  // Ses efektlerini aç/kapat
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  bool get isEnabled => _isEnabled;

  // Önceden tanımlı ses efektleri
  Future<void> playCorrect() => playSound('correct.mp3');
  Future<void> playWrong() => playSound('wrong.mp3');
  Future<void> playTap() => playSound('tap.mp3');
  Future<void> playSuccess() => playSound('success.mp3');
  Future<void> playGameOver() => playSound('game_over.mp3');
  Future<void> playCountdown() => playSound('countdown.mp3');
  Future<void> playLevelUp() => playSound('level_up.mp3');

  // Dispose
  void dispose() {
    _player.dispose();
  }
}
```

### 2. Oyunlarda Kullanım

Herhangi bir oyun dosyasında (örnek: `reflex_tap_game.dart`):

```dart
import '../../../services/audio_service.dart';

class _ReflexTapGameState extends State<ReflexTapGame> {
  final AudioService _audioService = AudioService();

  void _handleCorrectAnswer() {
    // Doğru cevap
    _audioService.playCorrect();
    // ... diğer kodlar
  }

  void _handleWrongAnswer() {
    // Yanlış cevap
    _audioService.playWrong();
    // ... diğer kodlar
  }

  void _handleTap() {
    // Dokunma sesi
    _audioService.playTap();
    // ... diğer kodlar
  }

  void _onGameComplete() {
    // Oyun bitiş sesi
    _audioService.playSuccess();
    // ... diğer kodlar
  }
}
```

---

## 🎮 Oyun Bazlı Ses Kullanımı

### Reflex Tap (REF01)
- ✅ Doğru dokunma → `playCorrect()`
- ❌ Yanlış dokunma → `playWrong()`
- 👆 Her dokunma → `playTap()`
- 🎉 Oyun bitişi → `playSuccess()`

### Quick Math (NUM01)
- ✅ Doğru cevap → `playCorrect()`
- ❌ Yanlış cevap → `playWrong()`
- ⏱️ Süre bitiyor → `playCountdown()` (son 5 saniye)
- 🎉 Oyun bitişi → `playSuccess()`

### Memory Board (MEM02)
- ✅ Eşleşme bulundu → `playCorrect()`
- ❌ Yanlış eşleşme → `playWrong()`
- 🎴 Kart açılışı → `playTap()`
- 🎉 Tüm kartlar eşleşti → `playSuccess()`

### Sequence Echo (MEM04)
- ✅ Doğru sıra → `playCorrect()`
- ❌ Yanlış sıra → `playWrong()`
- 🔢 Her dokunma → `playTap()`
- 🎉 Seviye tamamlandı → `playLevelUp()`

---

## ⚙️ Gelişmiş Özellikler

### 1. Ses Seviyesi Kontrolü

```dart
class AudioService {
  double _volume = 1.0; // 0.0 - 1.0 arası

  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
    _player.setVolume(_volume);
  }

  double get volume => _volume;
}
```

### 2. Çoklu Ses Çalma

Bazı durumlarda birden fazla ses aynı anda çalabilir:

```dart
final AudioPlayer _player1 = AudioPlayer();
final AudioPlayer _player2 = AudioPlayer();

Future<void> playMultipleSounds() async {
  await Future.wait([
    _player1.play(AssetSource('sounds/correct.mp3')),
    _player2.play(AssetSource('sounds/tap.mp3')),
  ]);
}
```

### 3. Ses Önceliği

Önemli sesler (oyun bitişi) diğer sesleri kesebilir:

```dart
Future<void> playImportantSound(String soundName) async {
  await _player.stop(); // Mevcut sesi durdur
  await _player.play(AssetSource('sounds/$soundName'));
}
```

---

## 🎛️ Ayarlar Ekranı Entegrasyonu

Kullanıcıların ses efektlerini açıp kapatabilmesi için:

```dart
// lib/features/settings/providers/audio_settings_provider.dart
final audioEnabledProvider = StateNotifierProvider<AudioSettingsNotifier, bool>((ref) {
  return AudioSettingsNotifier();
});

class AudioSettingsNotifier extends StateNotifier<bool> {
  AudioSettingsNotifier() : super(true) {
    // SharedPreferences'tan yükle
    _loadSettings();
  }

  void toggle() {
    state = !state;
    AudioService().setEnabled(state);
    _saveSettings();
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('audio_enabled') ?? true;
    AudioService().setEnabled(state);
  }

  void _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('audio_enabled', state);
  }
}
```

---

## 📝 Yapılacaklar Listesi

### Kurulum
- [ ] `audioplayers` paketini `pubspec.yaml`'a ekle
- [ ] `flutter pub get` çalıştır
- [ ] `assets/sounds/` klasörü oluştur
- [ ] `pubspec.yaml`'a `assets/sounds/` ekle

### Ses Dosyaları
- [ ] `correct.mp3` - Doğru cevap sesi
- [ ] `wrong.mp3` - Yanlış cevap sesi
- [ ] `tap.mp3` - Dokunma sesi
- [ ] `success.mp3` - Başarı sesi
- [ ] `game_over.mp3` - Oyun bitiş sesi
- [ ] (İsteğe bağlı) Diğer sesler

### Kod
- [ ] `lib/services/audio_service.dart` oluştur
- [ ] Her oyuna ses efektleri ekle
- [ ] Test et

### Ayarlar (İsteğe bağlı)
- [ ] Ses açma/kapama ayarı ekle
- [ ] Ses seviyesi kontrolü ekle

---

## 🐛 Sorun Giderme

### Ses çalmıyor
1. Ses dosyasının `assets/sounds/` klasöründe olduğundan emin olun
2. `pubspec.yaml`'da `assets/sounds/` tanımlı mı kontrol edin
3. Dosya adının doğru olduğundan emin olun (büyük/küçük harf duyarlı)
4. `flutter clean` ve `flutter pub get` çalıştırın

### Ses gecikmeli çalıyor
- Ses dosyalarını küçültün (daha düşük bitrate)
- Önceden yükleme (preload) kullanın

### Çok fazla ses aynı anda çalıyor
- Ses önceliği sistemi ekleyin
- Aynı anda sadece bir ses çalacak şekilde kısıtlayın

---

## 💡 İpuçları

1. **Ses dosyalarını küçük tutun** - Uygulama boyutunu artırmamak için
2. **Kısa sesler kullanın** - Uzun sesler oyun deneyimini bozabilir
3. **Tutarlı sesler seçin** - Tüm oyunlarda benzer ses tonları kullanın
4. **Test edin** - Her oyunda ses efektlerini test edin
5. **Sessiz mod desteği** - Kullanıcıların sesleri kapatabilmesini sağlayın

---

## 📚 Referanslar

- [audioplayers paketi dokümantasyonu](https://pub.dev/packages/audioplayers)
- [Flutter assets dokümantasyonu](https://docs.flutter.dev/development/ui/assets-and-images)

---

**İyi çalışmalar! 🎵**

