# Uygulama İkonu Kurulumu

## Gereksinimler

Uygulama ikonunu eklemek için aşağıdaki adımları izleyin:

### 1. İkon Dosyalarını Hazırlayın

`assets/icons/` klasörüne iki dosya eklemeniz gerekiyor:

- **app_icon.png** - Ana uygulama ikonu (1024x1024 px önerilir)
  - Şeffaf arka planlı PNG formatında
  - Minimum 512x512 px, önerilen 1024x1024 px

- **app_icon_foreground.png** - Adaptive icon için ön plan (1024x1024 px)
  - Android adaptive icon için kullanılır
  - İkonun merkezi kısmı (güvenli alan: 432x432 px)
  - Şeffaf arka planlı PNG formatında

### 2. İkon Tasarımı

NöroDakika için önerilen ikon tasarımı:
- **Ana öğe**: Beyin/Psikoloji ikonu (🧠)
- **Renkler**: Mor gradient (#4F46E5 - #7C3AED)
- **Stil**: Modern, minimal, yuvarlatılmış köşeler

### 3. İkonları Oluşturma

İkonları oluşturmak için:
1. Online araçlar kullanabilirsiniz (Canva, Figma, etc.)
2. Veya tasarımcıdan 1024x1024 px PNG dosyaları isteyebilirsiniz

### 4. İkonları Yerleştirme

1. `app_icon.png` dosyasını `assets/icons/` klasörüne kopyalayın
2. `app_icon_foreground.png` dosyasını `assets/icons/` klasörüne kopyalayın

### 5. İkonları Oluşturma Komutu

İkon dosyalarını ekledikten sonra terminalde şu komutu çalıştırın:

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

Bu komut:
- Android için tüm gerekli boyutlarda ikonlar oluşturur
- iOS için gerekli ikonları oluşturur
- Adaptive icon'ları yapılandırır

### 6. Test Etme

İkonları test etmek için:
```bash
flutter run
```

Uygulamayı cihazınızda veya emülatörde çalıştırdığınızda yeni ikonu görebilirsiniz.

## Notlar

- İkon dosyaları eklenmeden `flutter pub run flutter_launcher_icons` komutu çalışmayacaktır
- İkonları değiştirdikten sonra uygulamayı yeniden yüklemelisiniz
- Adaptive icon için arka plan rengi `pubspec.yaml` dosyasında `adaptive_icon_background` olarak ayarlanmıştır (#4F46E5 - mor)

