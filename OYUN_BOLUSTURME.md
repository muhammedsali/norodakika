# 🎮 Oyun Bölüştürme Rehberi

## 📋 Genel Bilgiler

- **Toplam Oyun Sayısı:** 12
- **Kişi Sayısı:** 4
- **Her Kişiye Düşen Oyun:** 3 oyun
- **Çalışma Klasörü:** `lib/features/game_launcher/widgets/`

---

## 📊 Hızlı Özet Tablo

| Kişi | Oyun ID | Oyun Adı | Dosya Adı | Kategori | Ses Efektleri |
|------|---------|----------|-----------|----------|---------------|
| **Enes** | REF01 | Reflex Tap | `reflex_tap_game.dart` | Refleks | ⏳ Beklemede |
| | ATT01 | Stroop Tap | `stroop_tap_game.dart` | Dikkat | ⏳ Beklemede |
| | MEM01 | N-Back Mini | `n_back_mini_game.dart` | Hafıza + Dikkat | ⏳ Beklemede |
| **Ahmet** | REF02 | Reflex Dash | `reflex_dash_game.dart` | Refleks | ⏳ Beklemede |
| | ATT02 | Focus Line | `focus_line_game.dart` | Dikkat + Görsel Algı | ⏳ Beklemede |
| | LOG01 | Logic Puzzle | `logic_puzzle_game.dart` | Mantık + Görsel Algı | ⏳ Beklemede |
| **Serhat** | NUM01 | Quick Math | `quick_math_game.dart` | Sayısal Zeka | ✅ Eklendi* |
| | MEM02 | Memory Board | `memory_board_game.dart` | Hafıza + Görsel Algı | ⏳ Beklemede |
| | MEM03 | Recall Phase | `recall_phase_game.dart` | Dil + Hafıza | ⏳ Beklemede |
| **Muhammed** | MEM04 | Sequence Echo | `sequence_memory_game.dart` | Hafıza + Dikkat | ⏳ Beklemede |
| | VIS02 | Odd One Out | `odd_one_out_game.dart` | Görsel Algı + Dikkat | ⏳ Beklemede |
| | LANG02 | Word Sprint | `word_sprint_game.dart` | Dil | ⏳ Beklemede |

**Not:** *QuickMath oyununda ses efektleri kodu eklendi, ancak ses dosyaları eksik olduğu için çalışmıyor. `SES_DOSYALARI_EKLEME.md` dosyasına bakın.

---

## 👥 Enes - Oyunlar

### 1. **REF01 - Reflex Tap**
- **Dosya:** `reflex_tap_game.dart`
- **Kategori:** Refleks
- **Açıklama:** Tepki süresi ölçümü + Go/No-Go mekanizması
- **Durum:** ⚠️ Düzeltilmesi gerekiyor

### 2. **ATT01 - Stroop Tap**
- **Dosya:** `stroop_tap_game.dart`
- **Kategori:** Dikkat
- **Açıklama:** Renk-kelime uyumsuzluğu ile dikkat testi
- **Durum:** ⚠️ Düzeltilmesi gerekiyor

### 3. **MEM01 - N-Back Mini**
- **Dosya:** `n_back_mini_game.dart`
- **Kategori:** Hafıza + Dikkat
- **Açıklama:** Çalışan bellek testi (1-back / 2-back)
- **Durum:** ⚠️ Düzeltilmesi gerekiyor

---

## 👥 Ahmet - Oyunlar

### 1. **REF02 - Reflex Dash**
- **Dosya:** `reflex_dash_game.dart`
- **Kategori:** Refleks
- **Açıklama:** Şeritler üzerinde kayan hedeflere hızlı tepki
- **Durum:** ⚠️ Düzeltilmesi gerekiyor

### 2. **ATT02 - Focus Line**
- **Dosya:** `focus_line_game.dart`
- **Kategori:** Dikkat + Görsel Algı
- **Açıklama:** Yatay çizgi üzerindeki hedef renk noktalara odaklanma
- **Durum:** ⚠️ Düzeltilmesi gerekiyor

### 3. **LOG01 - Logic Puzzle**
- **Dosya:** `logic_puzzle_game.dart`
- **Kategori:** Mantık + Görsel Algı
- **Açıklama:** Mantık dizisi çözme + görsel algı
- **Durum:** ⚠️ Düzeltilmesi gerekiyor

---

## 👥 Serhat - Oyunlar

### 1. **NUM01 - Quick Math**
- **Dosya:** `quick_math_game.dart`
- **Kategori:** Sayısal Zeka
- **Açıklama:** Zaman baskılı mental aritmetik
- **Durum:** ✅ Ses efektleri eklendi (ses dosyaları eksik)
- **Ses Efektleri:** Doğru cevap, yanlış cevap, seviye atlama, oyun bitiş

### 2. **MEM02 - Memory Board**
- **Dosya:** `memory_board_game.dart`
- **Kategori:** Hafıza + Görsel Algı
- **Açıklama:** Kart eşleştirme + görsel hafıza
- **Durum:** ⚠️ Düzeltilmesi gerekiyor

### 3. **MEM03 - Recall Phase**
- **Dosya:** `recall_phase_game.dart`
- **Kategori:** Dil + Hafıza
- **Açıklama:** Kelime gösterim ve hatırlama testi
- **Durum:** ⚠️ Düzeltilmesi gerekiyor

---

## 👥 Muhammed - Oyunlar

### 1. **MEM04 - Sequence Echo**
- **Dosya:** `sequence_memory_game.dart`
- **Kategori:** Hafıza + Dikkat
- **Açıklama:** Gösterilen hücre sırasını aynen tekrar et
- **Durum:** ⚠️ Düzeltilmesi gerekiyor

### 2. **VIS02 - Odd One Out**
- **Dosya:** `odd_one_out_game.dart`
- **Kategori:** Görsel Algı + Dikkat
- **Açıklama:** Farklı kartı hızlıca bulma oyunu
- **Durum:** ⚠️ Düzeltilmesi gerekiyor

### 3. **LANG02 - Word Sprint**
- **Dosya:** `word_sprint_game.dart`
- **Kategori:** Dil
- **Açıklama:** Gerçek ve uydurma kelimeleri ayırt etme oyunu
- **Durum:** ⚠️ Düzeltilmesi gerekiyor

---

## 🔧 Nasıl Çalışılacak?

### 1. **Dosya Yapısını Anlama**

Her oyun dosyası bir Flutter widget'ıdır ve şu yapıya sahiptir:

```dart
class OyunAdiGame extends StatefulWidget {
  final void Function(Map<String, dynamic>) onComplete;
  final bool isPaused; // Bazı oyunlarda var, bazılarında yok

  const OyunAdiGame({
    super.key,
    required this.onComplete,
    this.isPaused, // Opsiyonel
  });

  @override
  State<OyunAdiGame> createState() => _OyunAdiGameState();
}
```

### 2. **Oyunun Çalışma Mantığı**

Her oyun şu adımları takip etmelidir:

1. **Oyun Başlatma:** `initState()` içinde oyun başlar
2. **Oyun Döngüsü:** Timer veya Ticker ile sürekli güncelleme
3. **Kullanıcı Etkileşimi:** GestureDetector, InkWell, vb. ile input al
4. **Skor Hesaplama:** Doğru/yanlış cevaplara göre skor hesapla
5. **Oyun Bitirme:** `onComplete` callback'ini çağır

### 3. **onComplete Callback Formatı**

Oyun bittiğinde şu formatta veri gönderilmeli:

```dart
widget.onComplete({
  'score': double,           // Oyun skoru (0-100 arası önerilir)
  'successRate': double,     // Başarı oranı (0.0-1.0 arası)
  'duration': int,           // Oyun süresi (saniye)
  'totalAttempts': int,      // Toplam deneme sayısı
  'correctAttempts': int,    // Doğru deneme sayısı
  'wrongAttempts': int,      // Yanlış deneme sayısı
});
```

### 4. **Kontrol Edilmesi Gerekenler**

Her oyun için şunları kontrol edin:

- ✅ Oyun başlıyor mu?
- ✅ Timer/Ticker düzgün çalışıyor mu?
- ✅ Kullanıcı input'ları alınıyor mu?
- ✅ Skor doğru hesaplanıyor mu?
- ✅ Oyun bitince `onComplete` çağrılıyor mu?
- ✅ Pause/resume çalışıyor mu? (varsa)
- ✅ Hata durumları handle ediliyor mu?
- ✅ UI responsive mi? (farklı ekran boyutları)

### 5. **Oyun Entegrasyonu**

Oyunlar `game_play_screen.dart` dosyasında switch-case ile çağrılıyor:

```dart
case 'REF01':
  return ReflexTapGame(
    key: ValueKey('reflex_$_runId'),
    onComplete: _onGameComplete,
    isPaused: _isPaused,
  );
```

Eğer oyununuzda `isPaused` parametresi yoksa, sadece `onComplete` gönderin.

### 6. **Test Etme**

1. Uygulamayı çalıştırın: `flutter run`
2. Ana ekrandan oyunlar sekmesine gidin
3. Oyununuzu seçin ve oynayın
4. Hataları kontrol edin:
   - Console'da hata var mı?
   - Oyun başlıyor mu?
   - Skor hesaplanıyor mu?
   - Oyun bitince sonuç ekranı geliyor mu?

---

## 🔊 Ses Efektleri Ekleme

### ⚠️ ÖNEMLİ: Ses Dosyaları Eksik!

**Şu anda `assets/sounds/` klasöründe ses dosyaları yok!** Bu yüzden ses efektleri çalışmıyor.

**Çözüm:** `SES_DOSYALARI_EKLEME.md` dosyasına bakın ve ses dosyalarını ekleyin.

### 1. **Ses Servisini Kullanma**

Her oyun dosyasında ses efektleri ekleyebilirsiniz:

```dart
import '../../../services/audio_service.dart';

class _OyunAdiGameState extends State<OyunAdiGame> {
  final AudioService _audioService = AudioService();

  void _handleCorrectAnswer() {
    _audioService.playCorrect(); // ✅ Doğru cevap sesi
    // ... diğer kodlar
  }

  void _handleWrongAnswer() {
    _audioService.playWrong(); // ❌ Yanlış cevap sesi
    // ... diğer kodlar
  }

  void _handleTap() {
    _audioService.playTap(); // 👆 Dokunma sesi
    // ... diğer kodlar
  }

  void _onGameComplete() {
    _audioService.playSuccess(); // 🎉 Başarı sesi
    // ... diğer kodlar
  }
}
```

### 2. **Mevcut Ses Efektleri**

`AudioService` içinde şu ses efektleri hazır:

- `playCorrect()` - Doğru cevap sesi
- `playWrong()` - Yanlış cevap sesi
- `playTap()` - Dokunma/buton sesi
- `playSuccess()` - Başarılı işlem sesi
- `playGameOver()` - Oyun bitiş sesi
- `playCountdown()` - Geri sayım sesi
- `playLevelUp()` - Seviye atlama sesi

### 3. **Özel Ses Efektleri**

Eğer oyununuza özel ses efektleri eklemek isterseniz:

1. Ses dosyasını `assets/sounds/` klasörüne ekleyin (örn: `my_custom_sound.mp3`)
2. Oyun kodunda kullanın:

```dart
_audioService.playSound('my_custom_sound.mp3');
```

### 4. **Ses Dosyalarını Nereden Bulabilirsiniz?**

- [Freesound.org](https://freesound.org) - Ücretsiz ses efektleri
- [Zapsplat.com](https://www.zapsplat.com) - Ücretsiz ses efektleri
- [Mixkit.co](https://mixkit.co/free-sound-effects/) - Ücretsiz ses efektleri

**Detaylı bilgi için:** 
- `SES_EFFEKT_REHBERI.md` - Ses efektleri detaylı rehberi
- `SES_DOSYALARI_EKLEME.md` - Ses dosyalarını nasıl ekleyeceğiniz

### 5. **Örnek: QuickMath Oyununda Ses Efektleri**

QuickMath oyununa ses efektleri eklenmiştir (örnek olarak):

```dart
// Doğru cevap
_audioService.playCorrect();

// Yanlış cevap
_audioService.playWrong();

// Seviye atlama
_audioService.playLevelUp();

// Oyun bitişi
_audioService.playGameOver();
```

**Not:** Ses dosyaları eklendikten sonra çalışacaktır.

---

## 🎨 Oyun Özelleştirmeleri

### 1. **UI/UX İyileştirmeleri**

Kendi oyunlarınızda şunları yapabilirsiniz:

- ✅ **Renkler:** Oyununuzun renk paletini değiştirebilirsiniz
- ✅ **Animasyonlar:** Daha akıcı animasyonlar ekleyebilirsiniz
- ✅ **Görseller:** Oyun kartlarına, butonlara görsel ekleyebilirsiniz
- ✅ **Fontlar:** Google Fonts ile farklı fontlar kullanabilirsiniz
- ✅ **Haptic Feedback:** Titreşim efektleri ekleyebilirsiniz

### 2. **Oyun Mekaniği Değişiklikleri**

- ✅ **Zorluk Seviyeleri:** Oyun zorluğunu ayarlayabilirsiniz
- ✅ **Süre:** Oyun süresini değiştirebilirsiniz
- ✅ **Skor Sistemi:** Skor hesaplama mantığını özelleştirebilirsiniz
- ✅ **Yeni Özellikler:** Oyununuza yeni mekanikler ekleyebilirsiniz

### 3. **Haptic Feedback (Titreşim)**

Oyunlarda titreşim eklemek için:

```dart
import 'package:flutter/services.dart';

// Hafif titreşim
HapticFeedback.lightImpact();

// Orta titreşim
HapticFeedback.mediumImpact();

// Güçlü titreşim
HapticFeedback.heavyImpact();

// Seçim titreşimi
HapticFeedback.selectionClick();
```

**Kullanım örnekleri:**
- Doğru cevap → `HapticFeedback.lightImpact()`
- Yanlış cevap → `HapticFeedback.mediumImpact()`
- Oyun bitişi → `HapticFeedback.heavyImpact()`
- Buton tıklama → `HapticFeedback.selectionClick()`

### 4. **Animasyonlar**

Daha iyi animasyonlar için:

```dart
// Animation Controller
late AnimationController _controller;
late Animation<double> _animation;

@override
void initState() {
  super.initState();
  _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 300),
  );
  _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );
  _controller.forward();
}

// Kullanım
AnimatedBuilder(
  animation: _animation,
  builder: (context, child) {
    return Opacity(
      opacity: _animation.value,
      child: Transform.scale(
        scale: _animation.value,
        child: child,
      ),
    );
  },
  child: YourWidget(),
);
```

### 5. **Görsel İyileştirmeler**

- **Gradient Arka Planlar:** Oyun ekranına gradient ekleyin
- **Gölge Efektleri:** BoxShadow ile derinlik ekleyin
- **Border Radius:** Yuvarlatılmış köşeler için BorderRadius kullanın
- **Gradient Butonlar:** LinearGradient ile renkli butonlar oluşturun

### 6. **Performans İyileştirmeleri**

- ✅ Gereksiz `setState()` çağrılarını azaltın
- ✅ Timer'ları düzgün iptal edin (`dispose()` içinde)
- ✅ Büyük widget tree'leri `const` yapın
- ✅ ListView yerine ListView.builder kullanın (çok öğe varsa)

---

## 📋 Her Kişinin Yapabilecekleri Özet

### ✅ Yapabilecekleriniz

1. **Hata Düzeltme:** Oyununuzdaki hataları tespit edip düzeltin
2. **Ses Efektleri:** Oyununuza ses efektleri ekleyin
3. **UI İyileştirme:** Renkler, animasyonlar, görseller ekleyin
4. **Oyun Mekaniği:** Zorluk, süre, skor sistemi değiştirin
5. **Yeni Özellikler:** Oyununuza yeni mekanikler ekleyin
6. **Performans:** Oyunun performansını optimize edin

### ❌ Yapmamanız Gerekenler

1. **Diğer Kişilerin Oyunları:** Sadece kendi oyunlarınızla ilgilenin
2. **Ana Yapı:** `game_play_screen.dart` gibi ana dosyaları değiştirmeyin
3. **onComplete Formatı:** `onComplete` callback formatını değiştirmeyin
4. **Oyun ID'leri:** Oyun ID'lerini değiştirmeyin (REF01, ATT01, vb.)

---

## 📝 Yapılacaklar Listesi (Her Kişi İçin)

### Enes
- [ ] `reflex_tap_game.dart` - Hataları tespit et ve düzelt
- [ ] `stroop_tap_game.dart` - Hataları tespit et ve düzelt
- [ ] `n_back_mini_game.dart` - Hataları tespit et ve düzelt
- [ ] Ses efektleri ekle (doğru/yanlış/dokunma sesleri)
- [ ] UI/UX iyileştirmeleri yap (renkler, animasyonlar)
- [ ] Haptic feedback ekle (titreşim efektleri)

### Ahmet
- [ ] `reflex_dash_game.dart` - Hataları tespit et ve düzelt
- [ ] `focus_line_game.dart` - Hataları tespit et ve düzelt
- [ ] `logic_puzzle_game.dart` - Hataları tespit et ve düzelt
- [ ] Ses efektleri ekle (doğru/yanlış/dokunma sesleri)
- [ ] UI/UX iyileştirmeleri yap (renkler, animasyonlar)
- [ ] Haptic feedback ekle (titreşim efektleri)

### Serhat
- [x] `quick_math_game.dart` - Ses efektleri eklendi ✅
- [ ] `quick_math_game.dart` - Hataları tespit et ve düzelt
- [ ] `memory_board_game.dart` - Hataları tespit et ve düzelt
- [ ] `recall_phase_game.dart` - Hataları tespit et ve düzelt
- [ ] `memory_board_game.dart` - Ses efektleri ekle
- [ ] `recall_phase_game.dart` - Ses efektleri ekle
- [ ] UI/UX iyileştirmeleri yap (renkler, animasyonlar)
- [ ] Haptic feedback ekle (titreşim efektleri)

### Muhammed
- [ ] `sequence_memory_game.dart` - Hataları tespit et ve düzelt
- [ ] `odd_one_out_game.dart` - Hataları tespit et ve düzelt
- [ ] `word_sprint_game.dart` - Hataları tespit et ve düzelt
- [ ] Ses efektleri ekle (doğru/yanlış/dokunma sesleri)
- [ ] UI/UX iyileştirmeleri yap (renkler, animasyonlar)
- [ ] Haptic feedback ekle (titreşim efektleri)

---

## 🐛 Yaygın Hatalar ve Çözümleri

### 1. **onComplete çağrılmıyor**
- Oyun bitiş koşulunu kontrol edin
- Timer'ların düzgün iptal edildiğinden emin olun

### 2. **Skor hesaplanmıyor**
- `setState()` kullanıldığından emin olun
- Skor değişkenlerinin doğru güncellendiğini kontrol edin

### 3. **Oyun başlamıyor**
- `initState()` içinde oyun başlatma kodunu kontrol edin
- Timer/Ticker'ın başlatıldığından emin olun

### 4. **UI güncellenmiyor**
- `setState()` kullanıldığından emin olun
- Widget tree'nin doğru yapılandırıldığını kontrol edin

### 5. **Pause/Resume çalışmıyor**
- `didUpdateWidget` metodunu kontrol edin
- Timer'ların pause/resume durumunu handle edin

---

## 📚 Referans Dosyalar

- **Oyun entegrasyonu:** `lib/features/game_launcher/screens/game_play_screen.dart`
- **Oyun modelleri:** `lib/core/models/game_model.dart`
- **Oyun listesi:** `lib/core/memory/memory_bank.dart`
- **İyi çalışan örnek:** `reflex_tap_game.dart` veya `quick_math_game.dart` (eğer çalışıyorsa)

---

## 💡 İpuçları

1. **Önce oyunu oynayın** - Hataları görmek için oyunu çalıştırın
2. **Console logları kontrol edin** - Hata mesajlarını okuyun
3. **Breakpoint kullanın** - Debug modda çalıştırıp adım adım ilerleyin
4. **Diğer oyunlara bakın** - Çalışan oyunları referans alın
5. **Küçük değişiklikler yapın** - Her değişiklikten sonra test edin

---

## ✅ Tamamlandıktan Sonra

1. Oyunu test edin (baştan sona)
2. Hataları düzeltin
3. Kod yorumlarını ekleyin (gerekirse)
4. Diğer ekip üyelerine bildirin
5. Git'e commit edin

---

---

## 🚀 Hızlı Başlangıç Rehberi

### Adım 1: Oyununuzu Açın
```bash
# Örnek: Enes için
lib/features/game_launcher/widgets/reflex_tap_game.dart
```

### Adım 2: Ses Efektleri Ekleyin
```dart
import '../../../services/audio_service.dart';

final _audioService = AudioService();

// Doğru cevap
_audioService.playCorrect();

// Yanlış cevap
_audioService.playWrong();
```

**⚠️ ÖNEMLİ:** Ses dosyalarını `assets/sounds/` klasörüne eklemeyi unutmayın!
Detaylar için: `SES_DOSYALARI_EKLEME.md`

### Adım 3: Haptic Feedback Ekleyin
```dart
import 'package:flutter/services.dart';

HapticFeedback.lightImpact(); // Doğru cevap için
HapticFeedback.mediumImpact(); // Yanlış cevap için
```

### Adım 4: Test Edin
```bash
flutter run
```

### Adım 5: Git'e Commit Edin
```bash
git add lib/features/game_launcher/widgets/your_game.dart
git commit -m "feat: [Oyun Adı] - Ses efektleri ve iyileştirmeler eklendi"
```

---

## 📚 Yardımcı Dosyalar

- **`SES_EFFEKT_REHBERI.md`** - Ses efektleri detaylı rehberi
- **`SES_DOSYALARI_EKLEME.md`** - ⚠️ Ses dosyalarını nasıl ekleyeceğiniz (ÖNEMLİ!)
- **`assets/sounds/README.md`** - Ses dosyaları hakkında bilgi
- **`lib/services/audio_service.dart`** - Ses servisi kodu

## ⚠️ ÖNEMLİ NOTLAR

### Ses Dosyaları Eksik!

1. **Ses dosyalarını ekleyin:** `assets/sounds/` klasörüne ses dosyalarını ekleyin
   - `correct.mp3`, `wrong.mp3`, `tap.mp3`, `success.mp3`, `game_over.mp3`
   - Detaylar için: `SES_DOSYALARI_EKLEME.md`

2. **Uygulamayı yeniden başlatın:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

3. **Test edin:** QuickMath oyununu açıp ses efektlerini test edin

### Ses Efektleri Durumu

- ✅ **QuickMath (NUM01):** Ses efektleri eklendi (kod hazır, ses dosyaları eksik)
- ⏳ **Diğer oyunlar:** Ses efektleri henüz eklenmedi

---

**İyi çalışmalar! 🚀**

