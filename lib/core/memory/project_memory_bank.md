# NÖRODAKİKA - PROJE HAFIZA BANKASI

## 📋 PROJE ÖZETİ
Flutter tabanlı bilişsel eğitim mobil uygulaması. Flutter ile geliştirilmiş mini oyunlar ile 7 farklı bilişsel alanda gelişim sağlar.

Kısa teknik özet:
- UI: Flutter (Material 3)
- State: Riverpod 2.x
- Auth/DB: Firebase Auth + Cloud Firestore
- Guest mod: Local storage (SharedPreferences)
- Oyunlar: Flutter widget tabanlı mini oyunlar (Unity yok)

---

## ✅ YAPILAN İŞLER

### 🏗️ Proje Yapısı
- [x] Flutter proje yapısı oluşturuldu (lib klasörü ve alt klasörler)
- [x] pubspec.yaml dosyası oluşturuldu (gerekli paketlerle)
- [x] .gitignore dosyası oluşturuldu
- [x] README.md dosyası oluşturuldu

### 💾 Core Yapı
- [x] Memory Bank dosyası oluşturuldu (lib/core/memory/memory_bank.dart)
  - [x] 7 Bilişsel kategori tanımlandı
  - [x] 7 Mini oyun listesi oluşturuldu
  - [x] Kullanıcı model oluşturma fonksiyonu
  - [x] Adaptif zorluk sistemi (ELO benzeri)
  - [x] Günlük plan üretimi
  - [x] API endpoint hafızası
  - [x] Radar grafik stat hesaplama
- [x] Constants dosyası oluşturuldu (lib/core/utils/constants.dart)

### 📦 Modeller
- [x] UserModel oluşturuldu (JSON entegrasyonlu)
- [x] GameModel oluşturuldu
- [x] AttemptModel oluşturuldu

### � Paketler (pubspec.yaml)
- Riverpod: flutter_riverpod
- Firebase: firebase_core, firebase_auth, cloud_firestore
- Google Sign-In: google_sign_in
- HTTP: http, dio
- UI: google_fonts, fl_chart, font_awesome_flutter
- Utils: shared_preferences, intl, uuid
- Audio: audioplayers

### � Servisler
- [x] LocalStorageService oluşturuldu
  - [x] Yerel ayarlar (dil, tema, onboarding)
  - [x] Guest mod için attempt/geçmiş saklama
  - [x] Oyun zorluk seviyesi yönetimi (yerel)
- [x] AuthService oluşturuldu (Firebase Auth)
- [x] FirestoreService oluşturuldu (Firebase Firestore)
- [x] ApiService oluşturuldu
  - [x] Register endpoint
  - [x] Login endpoint
  - [x] Attempt submit endpoint
  - [x] History get endpoint
  - [x] Stats get endpoint
  - [x] Daily plan get endpoint

### 🎮 Oyunlar (Flutter)
- [x] ReflexTapGame oluşturuldu (REF01)
  - [x] Go/No-Go mekanizması
  - [x] Tepki süresi ölçümü
  - [x] Skor sistemi
- [x] ReflexDashGame oluşturuldu (REF02)
- [x] StroopTapGame oluşturuldu (ATT01)
- [x] FocusLineGame oluşturuldu (ATT02)
- [x] NBackMiniGame oluşturuldu (MEM01)
- [x] LogicPuzzleGame oluşturuldu (LOG01)
- [x] QuickMathGame oluşturuldu (NUM01)
  - [x] Zaman baskılı matematik
  - [x] Çoktan seçmeli sorular
  - [x] Skor sistemi
- [x] MemoryBoardGame oluşturuldu (MEM02)
  - [x] Kart eşleştirme
  - [x] Görsel hafıza testi
  - [x] Skor sistemi
- [x] RecallPhaseGame oluşturuldu (MEM03)
- [x] SequenceMemoryGame oluşturuldu (MEM04)
- [x] OddOneOutGame oluşturuldu (VIS02)
- [x] WordSprintGame oluşturuldu (LANG02)

### 🎨 UI Ekranları
- [x] AuthGateScreen - Giriş kontrolü
- [x] LoginScreen - Giriş ekranı (Material 3 + Neumorphic tasarım)
- [x] RegisterScreen - Kayıt ekranı
- [x] HomeScreen - Ana ekran (3 ana kart)
- [x] GameLauncherScreen - Günlük plan ve oyun listesi
- [x] StatsScreen - Radar grafik ile istatistikler
- [x] GamePlayScreen - Flutter oyun oynama ekranı
- [x] ProfileScreen - Kullanıcı profili

### 🌍 Dil (i18n) / Localization
- [x] Dil yönetimi eklendi (Riverpod)
  - [x] `AppLanguage` (tr/en) enum
  - [x] `languageProvider` + `LocalStorageService` ile kalıcı dil
- [x] Merkezi metin katmanı eklendi: `AppStrings`
  - [x] TR/EN metinleri tek noktadan yönetim
  - [x] Stats kategorileri için display çevirisi (`categoryLabel`)
- [x] Root rebuild: dil değişince tüm uygulama güncellensin diye `main.dart` tepe widget `languageProvider` izler

### 🔄 State Management
- [x] AuthProvider oluşturuldu (Riverpod)
  - [x] currentUserProvider (StreamProvider<User?>)
  - [x] userDataProvider (FutureProvider<UserModel?>)
  - [x] authNotifierProvider (StateNotifierProvider<AuthNotifier, AsyncValue<void>>)

### 🤖 Android Yapılandırması
- [x] Android proje yapısı oluşturuldu
- [x] AndroidManifest.xml oluşturuldu
- [x] MainActivity.kt oluşturuldu
- [x] build.gradle dosyaları oluşturuldu
- [x] settings.gradle oluşturuldu
- [x] gradle.properties oluşturuldu
- [x] gradle-wrapper.properties oluşturuldu
- [x] Resource dosyaları oluşturuldu (styles.xml, launch_background.xml)
- [x] Android Gradle Plugin: 8.6.0
- [x] Kotlin: 2.1.0
- [x] Google Services plugin: 4.3.15 (FlutterFire)
- [x] NDK sorunu çözüldü (NDK satırı kaldırıldı)

### 🐛 Hata Düzeltmeleri
- [x] whenError metodu hatası düzeltildi (when kullanıldı)
- [x] textStyle parametresi hatası düzeltildi (RadarChartTitle)
- [x] Türkçe karakter hatası düzeltildi (NöroDakikaApp → NorodakikaApp)
- [x] CardTheme hatası düzeltildi (CardThemeData kullanıldı)
- [x] AttemptModel.toJson() hatası düzeltildi (toMap() kullanıldı)
- [x] Kullanılmayan import'lar temizlendi
- [x] Unity referansları kaldırıldı

### 🔄 Mimari Değişiklikler
- [x] Unity entegrasyonu kaldırıldı
- [x] Firebase entegrasyonu eklendi (Auth + Firestore)
- [x] Local Storage (SharedPreferences) sadeleştirildi
  - [x] Yerel ayarlar: tema, dil, onboarding gibi durumlar
- [x] Kullanıcı verileri / attempt history / stats Firestore tarafına taşındı
- [x] Flutter oyunları kullanılıyor (Unity yok)

### 📁 Klasör Yapısı
- [x] assets/images/ klasörü oluşturuldu
- [x] assets/icons/ klasörü oluşturuldu
- [x] Tüm feature klasörleri oluşturuldu
- [x] Oyun widget'ları klasörü oluşturuldu (lib/features/game_launcher/widgets/)

---

## 🚧 YAPILACAK İŞLER

### 🎮 Oyunlar
- [ ] Oyunların skor/difficulty parametrelerini standartlaştırma (tüm oyunlar aynı result sözleşmesini kullansın)
- [ ] Oyun içi “pause/resume” ve erişilebilirlik iyileştirmeleri

### 🌐 Backend API (Opsiyonel)
- [ ] Backend API sunucusu kurulacak
- [ ] API endpoint'leri implement edilecek:
  - [ ] POST /auth/register
  - [ ] POST /auth/login
  - [ ] POST /attempt
  - [ ] GET /daily-plan
  - [ ] GET /history
  - [ ] GET /stats
- [ ] API authentication/authorization yapılacak
- [ ] API dokümantasyonu yazılacak

### 🎨 UI/UX İyileştirmeleri
- [ ] Oyun kartları için görseller eklenecek
- [x] Animasyonlar eklenecek
- [x] Loading state'leri iyileştirilecek
- [ ] Error handling UI'ları eklenecek
- [x] Empty state'ler eklenecek
- [x] Splash screen oluşturulacak
- [ ] App icon tasarlanacak
- [x] Oyun sonu ekranları iyileştirilecek

### 📊 İstatistikler ve Analitik
- [x] Detaylı istatistik ekranları eklenecek
- [x] Geçmiş performans grafikleri eklenecek
- [x] Kategori bazlı analizler eklenecek
- [x] Kullanıcı ilerleme takibi iyileştirilecek
- [ ] Haftalık/aylık raporlar

### 🔔 Bildirimler
- [ ] Push notification servisi kurulacak
- [ ] Günlük hatırlatma bildirimleri eklenecek
- [ ] Başarı bildirimleri eklenecek
- [ ] Local notification sistemi

### ⚙️ Ayarlar
- [x] Ayarlar ekranı oluşturulacak
- [ ] Bildirim ayarları
- [ ] Ses ayarları
- [x] Tema ayarları (dark mode)
- [x] Dil seçenekleri
- [x] Veri sıfırlama
- [x] Hesap silme

### 💾 Veri Yönetimi
- [ ] Veri export/import özelliği
- [ ] Cloud backup (opsiyonel)
- [ ] Veri şifreleme iyileştirmeleri
- [ ] Veri temizleme araçları

### 🧪 Testler
- [ ] Unit testler yazılacak
- [ ] Widget testleri yazılacak
- [ ] Integration testleri yazılacak
- [ ] Oyun testleri yazılacak

### 📱 Platform Özellikleri
- [ ] iOS yapılandırması yapılacak
- [ ] Android permissions yönetimi
- [ ] Deep linking yapılandırılacak
- [ ] App store listing hazırlanacak

### 🔐 Güvenlik
- [ ] Şifre hash'leme (bcrypt)
- [ ] API key'ler environment variable'lara taşınacak
- [ ] Sensitive data encryption
- [ ] Biometric authentication (opsiyonel)

### 📈 Performans
- [ ] Code splitting
- [ ] Image optimization
- [ ] Lazy loading
- [ ] Cache stratejisi
- [ ] Oyun performans optimizasyonları

### 📝 Dokümantasyon
- [ ] API dokümantasyonu
- [ ] Kod dokümantasyonu
- [ ] Kullanıcı kılavuzu
- [ ] Geliştirici kılavuzu
- [ ] Oyun kuralları dokümantasyonu

---

## 🎯 ÖNCELİKLİ YAPILACAKLAR (Sırayla)

1. **Oyun İyileştirmeleri** - Skor/difficulty standardizasyonu ve oyun içi UX
2. **UI İyileştirmeleri** - Kullanıcı deneyimi için kritik
3. **Ayarlar Ekranı** - Temel özellikler
4. **Testler** - Kalite güvencesi için
5. **iOS Yapılandırması** - Platform desteği

---

## 📌 NOTLAR

- Flutter SDK versiyonu: pubspec env'e göre Dart >=3.0.0 <4.0.0 (kesin Flutter versiyonu bu dosyada sabitlenmiyor)
- Riverpod state management kullanılıyor
- Material 3 + Neumorphic tasarım dili
- Clean Architecture light versiyonu uygulanıyor
- Tüm sabitler Memory Bank'ta tutuluyor
- Adaptif zorluk sistemi ELO benzeri algoritma kullanıyor
- **Firebase (Auth + Firestore) kullanılıyor**
- **Flutter oyunları kullanılıyor - Unity yok**
- Local Storage (SharedPreferences) sadece yerel ayarlar için kullanılıyor (dil/tema/onboarding)
- Veriler hem cihazda (bazı cache/ayarlar) hem de kullanıcı giriş yaptıysa Firestore'da saklanır
- Dil sistemi `intl`/ARB değil; `AppStrings` üzerinden TR/EN metinleri yönetiliyor
- Firebase init: `main.dart` içinde `Firebase.initializeApp(...)`
- `firebase_options.dart` dosyası repoda gitignore kapsamında olabilir (FlutterFire generate çıktısı)
- Google Sign-In: `GOOGLE_SERVER_CLIENT_ID` environment value olarak bekleniyor (main.dart -> `googleServerClientId`)

---

## 🧠 Çoklu Zeka Kuramı (Gardner) - Oyun Eşleştirme

Bu projede yayın/ürün kontrolü için her zeka türü en az 1 oyunla ilişkilendirildi.

- **Sözel/Dilsel Zeka**: Word Sprint (`LANG02`)
- **Mantıksal/Matematiksel Zeka**: Quick Math (`NUM01`), Logic Puzzle (`LOG01`)
- **Görsel/Uzamsal Zeka**: Route Builder (`SPA01`), Odd One Out (`VIS02`)
- **Bedensel/Kinestetik Zeka**: Balance Tap (`KIN01`)
- **Müziksel/Ritmik Zeka**: Rhythm Match (`MUS01`)
- **Sosyal/İlişkisel (Interpersonal) Zeka**: Emotion Mirror (`SOC01`)
- **İçsel/Öz-farkındalık (Intrapersonal) Zeka**: Focus Check-In (`INT01`)
- **Doğacı (Naturalist) Zeka**: Nature Sort (`NAT01`)

---

## 🔗 ÖNEMLİ DOSYALAR

- `lib/core/memory/memory_bank.dart` - Tüm uygulama sabitleri
- `lib/main.dart` - Uygulama giriş noktası
- `lib/core/i18n/app_strings.dart` - Uygulama metinleri (TR/EN)
- `lib/core/api/api_service.dart` - Opsiyonel backend API client (baseUrl placeholder)
- `lib/services/local_storage_service.dart` - Local storage işlemleri
- `lib/services/auth_service.dart` - Firebase Auth işlemleri
- `lib/services/firestore_service.dart` - Firestore veri işlemleri
- `lib/features/settings/providers/language_provider.dart` - Dil yönetimi (Riverpod)
- `lib/features/settings/providers/theme_provider.dart` - Tema yönetimi (Riverpod)
- `lib/features/game_launcher/widgets/` - Oyun widget'ları
- `lib/features/game_launcher/screens/game_play_screen.dart` - Oyun başlatma + attempt kaydı akışı
- `lib/features/auth/providers/auth_provider.dart` - Auth state management
- `pubspec.yaml` - Bağımlılıklar

---

## 📊 MEVCUT DURUM

### ✅ Tamamlanan
- Proje yapısı
- Temel UI ekranları
- Flutter mini oyunları (MemoryBank + game widgets altında)
- Yeni oyunlar eklendi ve entegre edildi: MUS01, SOC01, NAT01, KIN01, SPA01, INT01 (GamePlayScreen switch-case + Home ikon eşlemesi)
- Local storage sistemi
- Firebase Auth sistemi
- Firestore veri altyapısı
- İstatistik ekranı
- Android yapılandırması
- TR/EN dil desteği (AppStrings + languageProvider)
- **Ayarlar ekranı (SettingsScreen)** - Tema, dil, ses/bildirim ayarları, profil bağlantıları, çıkış/veri temizleme

### 🚧 Devam Eden
- Oyun iyileştirmeleri ve dengeleme (difficulty/result standardizasyonu)
- UI iyileştirmeleri

### 📅 Planlanan
- iOS yapılandırması
- Bildirimler (push notification entegrasyonu)
- Testler

---

*Son güncelleme: 2026-03-10*
