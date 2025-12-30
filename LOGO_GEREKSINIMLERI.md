# NöroDakika - Logo Gereksinimleri Rehberi

## 📋 Genel Gereksinimler

Tüm logo dosyaları **PNG formatında** ve **şeffaf arka planlı** olmalıdır.

---

## 🎯 1. Uygulama İkonu (App Icon)

### Dosya: `assets/icons/app_icon.png`

**Çözünürlük:** 
- **Minimum:** 512x512 px
- **Önerilen:** 1024x1024 px
- **Format:** PNG (şeffaf arka plan)

**Tasarım Notları:**
- Logo, ikonun merkezinde olmalı
- Kenarlarda en az %10 boşluk bırakılmalı (güvenli alan)
- Basit ve net tasarım (küçük boyutlarda da okunabilir olmalı)
- Renkler: Mor gradient (#4F46E5 - #7C3AED) veya proje renklerine uygun

**Kullanım:**
- iOS ve Android için tüm boyutlarda otomatik oluşturulur
- `flutter_launcher_icons` paketi ile işlenir

---

## 🎯 2. Android Adaptive Icon (Ön Plan)

### Dosya: `assets/icons/app_icon_foreground.png`

**Çözünürlük:** 
- **1024x1024 px** (zorunlu)
- **Format:** PNG (şeffaf arka plan)

**Tasarım Notları:**
- Android adaptive icon için kullanılır
- **Güvenli alan:** Merkez 432x432 px (kenarlardan %20 boşluk)
- Önemli içerik bu güvenli alan içinde olmalı
- Kenarlar kesilebilir, bu yüzden önemli detaylar merkeze konulmalı
- Arka plan rengi: `#4F46E5` (pubspec.yaml'da tanımlı)

**Kullanım:**
- Android 8.0+ için adaptive icon oluşturur
- Arka plan rengi otomatik eklenir

---

## 🎯 3. Splash Screen Logo

### Dosya: `assets/images/logo_splash.png` (veya `logo.png`)

**Çözünürlük:**
- **Önerilen:** 512x512 px veya 1024x1024 px
- **Format:** PNG (şeffaf arka plan)

**Tasarım Notları:**
- Splash screen'de gösterilecek ana logo
- Büyük ve net görünmeli
- Gradient arka plan üzerinde görünecek
- Şu anda splash screen'de Icon widget kullanılıyor, bunu gerçek logo ile değiştirebilirsiniz

**Alternatif Boyutlar (isteğe bağlı):**
- `logo_splash@2x.png` - 1024x1024 px (yüksek DPI ekranlar için)
- `logo_splash@3x.png` - 1536x1536 px (çok yüksek DPI ekranlar için)

---

## 🎯 4. Uygulama İçi Logo (İsteğe Bağlı)

### Dosya: `assets/images/logo.png`

**Çözünürlük:**
- **Önerilen:** 512x512 px
- **Format:** PNG (şeffaf arka plan)

**Kullanım:**
- Uygulama içinde header, profil ekranı vb. yerlerde kullanılabilir
- Farklı boyutlarda kullanım için SVG formatı da tercih edilebilir

**Alternatif Boyutlar:**
- `logo_small.png` - 128x128 px (küçük yerler için)
- `logo_medium.png` - 256x256 px (orta boy yerler için)
- `logo_large.png` - 512x512 px (büyük yerler için)

---

## 📁 Dosya Yerleştirme

Tüm logo dosyalarını şu klasörlere yerleştirin:

```
assets/
├── icons/
│   ├── app_icon.png              # Ana uygulama ikonu (1024x1024)
│   └── app_icon_foreground.png  # Android adaptive icon (1024x1024)
└── images/
    ├── logo.png                  # Uygulama içi logo (512x512)
    └── logo_splash.png           # Splash screen logo (512x512 veya 1024x1024)
```

---

## 🚀 Kurulum Adımları

### 1. Logo Dosyalarını Hazırlayın
Yukarıdaki gereksinimlere göre logo dosyalarınızı hazırlayın.

### 2. Dosyaları Yerleştirin
Logo dosyalarını `assets/icons/` ve `assets/images/` klasörlerine kopyalayın.

### 3. App Icon'ları Oluşturun
Terminalde şu komutu çalıştırın:

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

Bu komut:
- Android için tüm gerekli boyutlarda ikonlar oluşturur (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- iOS için gerekli ikonları oluşturur
- Adaptive icon'ları yapılandırır

### 4. Splash Screen'i Güncelleyin (İsteğe Bağlı)
Eğer splash screen'de gerçek logo görseli kullanmak isterseniz, `lib/features/welcome/screens/splash_screen.dart` dosyasını güncelleyin.

---

## 📐 Boyut Özeti

| Kullanım | Dosya Adı | Çözünürlük | Format | Zorunlu |
|----------|-----------|------------|--------|---------|
| App Icon | `app_icon.png` | 1024x1024 px | PNG (şeffaf) | ✅ Evet |
| Adaptive Icon | `app_icon_foreground.png` | 1024x1024 px | PNG (şeffaf) | ✅ Evet |
| Splash Logo | `logo_splash.png` | 512x512 px | PNG (şeffaf) | ⚠️ İsteğe bağlı |
| Uygulama İçi | `logo.png` | 512x512 px | PNG (şeffaf) | ⚠️ İsteğe bağlı |

---

## 🎨 Tasarım Önerileri

1. **Basitlik:** Küçük boyutlarda da net görünmeli
2. **Renkler:** Proje renklerine uygun (Mor: #4F46E5, #7C3AED)
3. **Güvenli Alan:** Önemli içerik merkezde, kenarlarda boşluk
4. **Kontrast:** Hem açık hem koyu arka planlarda görünür olmalı
5. **Test:** Farklı boyutlarda test edin (özellikle 48x48 px gibi küçük boyutlarda)

---

## ✅ Kontrol Listesi

- [ ] `app_icon.png` (1024x1024) hazırlandı
- [ ] `app_icon_foreground.png` (1024x1024) hazırlandı
- [ ] Dosyalar `assets/icons/` klasörüne yerleştirildi
- [ ] `flutter pub run flutter_launcher_icons` komutu çalıştırıldı
- [ ] Uygulama test edildi ve ikonlar görünüyor
- [ ] (İsteğe bağlı) Splash screen logo eklendi
- [ ] (İsteğe bağlı) Uygulama içi logo eklendi

---

## 📝 Notlar

- **App Icon ve Adaptive Icon zorunludur** - Uygulama mağazalarına yüklemek için gereklidir
- **Splash Screen ve uygulama içi logolar isteğe bağlıdır** - Şu anda kod Icon widget kullanıyor
- İkonları değiştirdikten sonra uygulamayı **tamamen kaldırıp yeniden yüklemelisiniz** (hot reload yeterli olmayabilir)
- Android'de adaptive icon arka plan rengi `pubspec.yaml` dosyasında `adaptive_icon_background: "#4F46E5"` olarak ayarlanmıştır

---

## 🆘 Sorun Giderme

**İkonlar görünmüyor:**
- Uygulamayı tamamen kaldırıp yeniden yükleyin
- `flutter clean` ve `flutter pub get` komutlarını çalıştırın
- Dosya yollarının doğru olduğundan emin olun

**Adaptive icon çalışmıyor:**
- `app_icon_foreground.png` dosyasının 1024x1024 px olduğundan emin olun
- Şeffaf arka planlı olduğundan emin olun
- `pubspec.yaml` dosyasındaki yapılandırmayı kontrol edin

