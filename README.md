# NöroDakika - Bilişsel Eğitim Mobil Uygulaması

Flutter tabanlı bilişsel eğitim platformu. Unity mini oyunları ile 7 farklı bilişsel alanda gelişim sağlar.

## Özellikler

- 🧠 7 Bilişsel Kategori (Hafıza, Dikkat, Refleks, Mantık, Sayısal Zeka, Görsel Algı, Dil)
- 🎮 7 Unity Mini Oyun
- 📊 Adaptif Zorluk Sistemi (ELO benzeri)
- 📈 Radar Grafik ile İlerleme Takibi
- 📅 Günlük Plan Sistemi
- 🔥 Firebase Entegrasyonu
- 🎨 Modern Neumorphic UI

## Proje Yapısı

```
lib/
├── core/
│   ├── memory/
│   │   └── memory_bank.dart          # Tüm uygulama hafıza yapısı
│   ├── models/                       # Veri modelleri
│   ├── api/                          # API servisleri
│   └── utils/                        # Yardımcı fonksiyonlar
├── features/
│   ├── auth/                         # Kimlik doğrulama
│   ├── home/                         # Ana ekran
│   ├── daily_plan/                   # Günlük plan
│   ├── game_launcher/                # Oyun başlatıcı
│   ├── stats/                        # İstatistikler
│   └── profile/                      # Profil
├── services/
│   ├── firebase_service.dart         # Firebase işlemleri
│   └── unity_bridge_service.dart     # Unity entegrasyonu
└── main.dart                         # Uygulama giriş noktası
```

## Kurulum

1. Bağımlılıkları yükleyin:
```bash
flutter pub get
```

2. Firebase yapılandırması:
   - `firebase_options.dart` dosyasını ekleyin
   - `google-services.json` (Android) ve `GoogleService-Info.plist` (iOS) dosyalarını ekleyin

3. Unity entegrasyonu:
   - Unity build dosyalarını `unity_build/` klasörüne ekleyin
   - Native platform ayarlarını yapın

## Kullanım

Uygulama başlatıldığında:
1. Giriş/Kayıt ekranı gösterilir
2. Giriş yapıldıktan sonra ana ekran açılır
3. Günlük plan, istatistikler veya oyunlar seçilebilir
4. Oyunlar Unity üzerinden çalışır
5. Sonuçlar otomatik kaydedilir ve zorluk seviyesi güncellenir

## Geliştirme

- **Memory Bank**: Tüm sabitler ve yapılandırmalar `lib/core/memory/memory_bank.dart` içinde
- **State Management**: Riverpod kullanılıyor
- **UI**: Material 3 + Neumorphic tasarım
- **API**: RESTful API entegrasyonu

## Lisans

Bu proje özel bir projedir.
