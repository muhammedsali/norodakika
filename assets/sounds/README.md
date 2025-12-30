# 🔊 Ses Dosyaları Klasörü

Bu klasöre oyunlarda kullanılacak ses efektlerini ekleyin.

## 📋 Gerekli Ses Dosyaları

### Zorunlu Sesler
- ✅ `correct.mp3` - Doğru cevap sesi
- ✅ `wrong.mp3` - Yanlış cevap sesi
- ✅ `tap.mp3` - Dokunma/buton sesi
- ✅ `success.mp3` - Başarılı işlem sesi
- ✅ `game_over.mp3` - Oyun bitiş sesi

### İsteğe Bağlı Sesler
- ⚪ `countdown.mp3` - Geri sayım sesi
- ⚪ `level_up.mp3` - Seviye atlama sesi

## 📐 Ses Dosyası Özellikleri

- **Format:** MP3 (önerilir) veya WAV
- **Süre:** 0.1 - 2 saniye arası
- **Kalite:** 44.1 kHz, 128 kbps
- **Boyut:** Her dosya < 100 KB (mümkünse)

## 📥 Ses Dosyalarını Nereden Bulabilirsiniz?

### Ücretsiz Kaynaklar
1. [Freesound.org](https://freesound.org) - Ücretsiz ses efektleri
2. [Zapsplat.com](https://www.zapsplat.com) - Ücretsiz ses efektleri
3. [Mixkit.co](https://mixkit.co/free-sound-effects/) - Ücretsiz ses efektleri

### Ses Editörleri
- [Audacity](https://www.audacityteam.org) - Ücretsiz ses editörü
- [GarageBand](https://www.apple.com/garageband/) - Mac için

## 💻 Kullanım

Ses dosyalarını bu klasöre ekledikten sonra, oyunlarda şu şekilde kullanabilirsiniz:

```dart
import '../../../services/audio_service.dart';

final audioService = AudioService();

// Doğru cevap
audioService.playCorrect();

// Yanlış cevap
audioService.playWrong();

// Dokunma
audioService.playTap();
```

Detaylı kullanım için `SES_EFFEKT_REHBERI.md` dosyasına bakın.

