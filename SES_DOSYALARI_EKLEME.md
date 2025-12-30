# 🔊 Ses Dosyalarını Ekleme Rehberi

## ⚠️ ÖNEMLİ: Ses Dosyaları Eksik!

Şu anda `assets/sounds/` klasöründe ses dosyaları yok. Bu yüzden oyunlarda ses çalmıyor.

## 🚀 Hızlı Çözüm

### 1. Ses Dosyalarını İndirin veya Oluşturun

Aşağıdaki ses dosyalarını hazırlayın:

- ✅ `correct.mp3` - Doğru cevap sesi (kısa, pozitif)
- ✅ `wrong.mp3` - Yanlış cevap sesi (kısa, negatif)
- ✅ `tap.mp3` - Dokunma/buton sesi (çok kısa)
- ✅ `success.mp3` - Başarılı işlem sesi
- ✅ `game_over.mp3` - Oyun bitiş sesi
- ⚪ `countdown.mp3` - Geri sayım sesi (isteğe bağlı)
- ⚪ `level_up.mp3` - Seviye atlama sesi (isteğe bağlı)

### 2. Ses Dosyalarını Klasöre Ekleyin

Ses dosyalarını şu klasöre kopyalayın:
```
assets/sounds/
```

### 3. Uygulamayı Yeniden Başlatın

```bash
flutter clean
flutter pub get
flutter run
```

## 📥 Ses Dosyalarını Nereden Bulabilirsiniz?

### Ücretsiz Kaynaklar

1. **[Freesound.org](https://freesound.org)**
   - Arama: "correct sound", "wrong sound", "button click"
   - Ücretsiz kayıt gerekir
   - Creative Commons lisanslı

2. **[Zapsplat.com](https://www.zapsplat.com)**
   - Arama: "correct", "wrong", "click"
   - Ücretsiz kayıt gerekir
   - Ticari kullanım için lisans gerekir

3. **[Mixkit.co](https://mixkit.co/free-sound-effects/)**
   - Direkt indirme
   - Ücretsiz, lisans gerekmez

4. **[Pixabay](https://pixabay.com/sound-effects/)**
   - Ücretsiz
   - Ticari kullanım için lisans gerekmez

### Önerilen Sesler

- **correct.mp3**: "success", "correct", "ding", "chime"
- **wrong.mp3**: "error", "wrong", "buzz", "fail"
- **tap.mp3**: "click", "tap", "button", "pop"
- **success.mp3**: "victory", "win", "achievement"
- **game_over.mp3**: "game over", "lose", "fail"

## 🎵 Ses Dosyası Özellikleri

- **Format:** MP3 (önerilir) veya WAV
- **Süre:** 0.1 - 2 saniye arası (kısa sesler)
- **Kalite:** 44.1 kHz, 128 kbps yeterli
- **Boyut:** Her dosya < 100 KB (mümkünse)

## 🔧 Ses Dosyalarını Düzenleme

Eğer ses dosyalarını düzenlemek isterseniz:

1. **[Audacity](https://www.audacityteam.org)** - Ücretsiz ses editörü
   - Ses dosyasını açın
   - Gereksiz kısımları kesin
   - Ses seviyesini ayarlayın
   - MP3 olarak export edin

2. **[GarageBand](https://www.apple.com/garageband/)** - Mac için
   - Basit ses düzenleme

## ✅ Test Etme

Ses dosyalarını ekledikten sonra:

1. Uygulamayı çalıştırın: `flutter run`
2. Quick Math oyununu açın
3. Doğru cevap verin → `correct.mp3` çalmalı
4. Yanlış cevap verin → `wrong.mp3` çalmalı
5. Seviye atlayın → `level_up.mp3` çalmalı (varsa)
6. Oyun bitince → `game_over.mp3` çalmalı

## 🐛 Sorun Giderme

### Ses çalmıyor

1. **Dosya yolu kontrolü:**
   - Dosyalar `assets/sounds/` klasöründe mi?
   - Dosya adları doğru mu? (büyük/küçük harf duyarlı)

2. **pubspec.yaml kontrolü:**
   ```yaml
   assets:
     - assets/sounds/
   ```

3. **Uygulamayı yeniden başlatın:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

4. **Console logları kontrol edin:**
   - Eğer ses dosyası bulunamazsa, console'da uyarı görürsünüz
   - `⚠️ Ses çalınamadı: correct.mp3` gibi mesajlar

### Ses gecikmeli çalıyor

- Ses dosyalarını küçültün (daha düşük bitrate)
- Dosya boyutunu azaltın

## 📝 Notlar

- Ses dosyaları olmadan da oyunlar çalışır, sadece ses çalmaz
- Ses dosyalarını ekledikten sonra `flutter clean` yapmanız önerilir
- Her oyun için aynı ses dosyaları kullanılır (paylaşımlı)

---

**Ses dosyalarını ekledikten sonra oyunlarda ses efektleri çalacaktır! 🎵**

