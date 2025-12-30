# NöroDakika - Bilişsel Eğitim Mobil Uygulaması

Flutter tabanlı bilişsel eğitim platformu. 12 farklı mini oyun ile 7 bilişsel alanda gelişim sağlar.

## Özellikler

- 🧠 7 Bilişsel Kategori (Hafıza, Dikkat, Refleks, Mantık, Sayısal Zeka, Görsel Algı, Dil)
- 🎮 12 Flutter Mini Oyun (Reflex Tap, Reflex Dash, Stroop Tap, Focus Line, N-Back Mini, Logic Puzzle, Quick Math, Memory Board, Recall Phase, Sequence Echo, Odd One Out, Word Sprint)
- 📊 Adaptif Zorluk Sistemi (ELO benzeri)
- 📈 Radar Grafik ile İlerleme Takibi (fl_chart)
- 📅 Günlük Plan Sistemi
- 🔥 Firebase Entegrasyonu (Authentication, Cloud Firestore)
- 🎨 Modern Material 3 UI (Google Fonts)
- 🔐 Kimlik Doğrulama (Email/Şifre)
- 💾 Local Storage (SharedPreferences)

## Proje Yapısı

```
lib/
├── core/
│   ├── memory/
│   │   ├── memory_bank.dart          # Tüm uygulama hafıza yapısı
│   │   └── project_memory_bank.md    # Proje dokümantasyonu
│   ├── models/                       # Veri modelleri
│   │   ├── user_model.dart
│   │   ├── game_model.dart
│   │   └── attempt_model.dart
│   ├── api/
│   │   └── api_service.dart          # API servisleri
│   ├── config/                       # Yapılandırma dosyaları
│   └── utils/
│       └── constants.dart            # Sabitler
├── features/
│   ├── auth/                         # Kimlik doğrulama
│   │   ├── providers/
│   │   │   └── auth_provider.dart
│   │   └── screens/
│   │       ├── auth_gate_screen.dart
│   │       ├── login_screen.dart
│   │       └── register_screen.dart
│   ├── welcome/                      # Hoş geldin ekranları
│   │   └── screens/
│   │       ├── splash_screen.dart
│   │       └── welcome_screen.dart
│   ├── home/                         # Ana ekran
│   │   ├── screens/
│   │   │   └── home_screen.dart
│   │   └── widgets/
│   │       └── home_bottom_nav.dart
│   ├── daily_plan/                   # Günlük plan
│   │   └── screens/
│   ├── game_launcher/                # Oyun başlatıcı
│   │   ├── screens/
│   │   │   ├── game_launcher_screen.dart
│   │   │   └── game_play_screen.dart
│   │   └── widgets/                  # 12 mini oyun widget'ı
│   │       ├── reflex_tap_game.dart
│   │       ├── reflex_dash_game.dart
│   │       ├── stroop_tap_game.dart
│   │       ├── focus_line_game.dart
│   │       ├── n_back_mini_game.dart
│   │       ├── logic_puzzle_game.dart
│   │       ├── quick_math_game.dart
│   │       ├── memory_board_game.dart
│   │       ├── recall_phase_game.dart
│   │       ├── sequence_memory_game.dart
│   │       ├── odd_one_out_game.dart
│   │       └── word_sprint_game.dart
│   ├── stats/                        # İstatistikler
│   │   ├── providers/
│   │   │   └── user_stats_provider.dart
│   │   ├── screens/
│   │   │   └── stats_screen.dart
│   │   └── widgets/
│   │       └── radar_chart_widget.dart
│   ├── profile/                      # Profil
│   │   ├── providers/
│   │   │   └── avatar_provider.dart
│   │   └── screens/
│   │       └── profile_screen.dart
│   ├── settings/                     # Ayarlar
│   │   └── providers/
│   │       ├── theme_provider.dart
│   │       └── language_provider.dart
│   └── shared/                       # Paylaşılan widget'lar
│       └── widgets/
│           └── game_card_widgets.dart
├── services/
│   ├── auth_service.dart             # Kimlik doğrulama servisi
│   ├── firestore_service.dart         # Firestore işlemleri
│   └── local_storage_service.dart     # Local storage işlemleri
├── firebase_options.dart              # Firebase yapılandırması
└── main.dart                          # Uygulama giriş noktası
```

## Kurulum

1. Bağımlılıkları yükleyin:
```bash
flutter pub get
```

2. Firebase yapılandırması:
   - `firebase_options.dart` dosyası projede mevcut
   - `google-services.json` (Android) ve `GoogleService-Info.plist` (iOS) dosyalarını Firebase Console'dan indirip ilgili klasörlere ekleyin
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

3. Assets yapılandırması:
   - `assets/images/` klasörüne görselleri ekleyin
   - `assets/icons/` klasörüne ikonları ekleyin
   - `assets/games/` klasörüne oyun görsellerini ekleyin

## Kullanım

Uygulama başlatıldığında:
1. **Splash Screen** gösterilir (3 saniye)
2. **Auth Gate Screen** ile kullanıcı kontrolü yapılır
3. Giriş yapılmamışsa **Login/Register** ekranları gösterilir
4. Giriş yapıldıktan sonra **Ana Ekran (Home)** açılır
5. Ana ekranda 4 sekme bulunur:
   - **Ana Sayfa**: Günlük plan kartı, hızlı oyun başlatma, istatistikler
   - **Oyunlar**: Tüm oyunların listesi
   - **İlerleme**: Radar grafik ile istatistikler
   - **Ayarlar**: Profil, günlük plan, istatistikler linkleri
6. Oyunlar Flutter widget'ları olarak çalışır
7. Sonuçlar otomatik olarak Firestore'a kaydedilir ve zorluk seviyesi güncellenir

## Geliştirme

### Teknoloji Stack

- **Framework**: Flutter 3.0+
- **State Management**: Riverpod (flutter_riverpod ^2.5.1)
- **UI**: Material 3 + Google Fonts
- **Backend**: Firebase (Authentication, Cloud Firestore)
- **Local Storage**: SharedPreferences
- **Charts**: fl_chart
- **HTTP**: dio, http

### Önemli Dosyalar

- **Memory Bank**: Tüm sabitler ve yapılandırmalar `lib/core/memory/memory_bank.dart` içinde
- **Oyunlar**: Tüm mini oyunlar `lib/features/game_launcher/widgets/` klasöründe
- **State Management**: Riverpod providers `lib/features/*/providers/` klasörlerinde
- **Services**: Firebase ve local storage servisleri `lib/services/` klasöründe

### Oyun Listesi

1. **Reflex Tap** (REF01) - Tepki süresi ölçümü
2. **Reflex Dash** (REF02) - Şeritler üzerinde kayan hedeflere tepki
3. **Stroop Tap** (ATT01) - Renk-kelime uyumsuzluğu testi
4. **Focus Line** (ATT02) - Yatay çizgi üzerindeki hedef renk noktalara odaklanma
5. **N-Back Mini** (MEM01) - Çalışan bellek testi
6. **Logic Puzzle** (LOG01) - Mantık dizisi çözme
7. **Quick Math** (NUM01) - Zaman baskılı mental aritmetik
8. **Memory Board** (MEM02) - Kart eşleştirme
9. **Recall Phase** (MEM03) - Kelime hatırlama testi
10. **Sequence Echo** (MEM04) - Hücre sırasını tekrar etme
11. **Odd One Out** (VIS02) - Farklı kartı bulma
12. **Word Sprint** (LANG02) - Gerçek ve uydurma kelimeleri ayırt etme

## Lisans

Bu proje özel bir projedir.
