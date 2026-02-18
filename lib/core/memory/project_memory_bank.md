# NÖRODAKİKA - PROJE HAFIZA BANKASI

## 📋 PROJE ÖZETİ
Flutter tabanlı bilişsel eğitim mobil uygulaması. Flutter ile geliştirilmiş mini oyunlar ile 7 farklı bilişsel alanda gelişim sağlar.

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

### 🔌 Servisler
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
- [x] QuickMathGame oluşturuldu (NUM01)
  - [x] Zaman baskılı matematik
  - [x] Çoktan seçmeli sorular
  - [x] Skor sistemi
- [x] MemoryBoardGame oluşturuldu (MEM02)
  - [x] Kart eşleştirme
  - [x] Görsel hafıza testi
  - [x] Skor sistemi
- [ ] StroopTapGame (ATT01) - Yakında eklenecek
- [ ] NBackMiniGame (MEM01) - Yakında eklenecek
- [ ] LogicPuzzleGame (LOG01) - Yakında eklenecek
- [ ] RecallPhaseGame (MEM03) - Yakında eklenecek

### 🎨 UI Ekranları
- [x] AuthGateScreen - Giriş kontrolü
- [x] LoginScreen - Giriş ekranı (Material 3 + Neumorphic tasarım)
- [x] RegisterScreen - Kayıt ekranı
- [x] HomeScreen - Ana ekran (3 ana kart)
- [x] DailyPlanScreen - Günlük plan görüntüleme
- [x] StatsScreen - Radar grafik ile istatistikler
- [x] GameLauncherScreen - 7 mini oyun listesi
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
  - [x] CurrentUserProvider (StateNotifier)
  - [x] UserDataProvider
  - [x] AuthNotifier (register, login, logout)

### 🤖 Android Yapılandırması
- [x] Android proje yapısı oluşturuldu
- [x] AndroidManifest.xml oluşturuldu
- [x] MainActivity.kt oluşturuldu
- [x] build.gradle dosyaları oluşturuldu
- [x] settings.gradle oluşturuldu
- [x] gradle.properties oluşturuldu
- [x] gradle-wrapper.properties oluşturuldu
- [x] Resource dosyaları oluşturuldu (styles.xml, launch_background.xml)
- [x] Gradle sürümü güncellendi (8.4 → 8.7)
- [x] Android Gradle Plugin güncellendi (8.1.0 → 8.6.0)
- [x] Kotlin sürümü güncellendi (1.9.22 → 2.1.0)
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

### 🎮 Kalan Oyunlar
- [ ] StroopTapGame (ATT01) - Renk-kelime uyumsuzluğu testi
- [ ] NBackMiniGame (MEM01) - Çalışan bellek testi (1-back / 2-back)
- [ ] LogicPuzzleGame (LOG01) - Mantık dizisi çözme
- [ ] RecallPhaseGame (MEM03) - Kelime hatırlama testi

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
- [ ] Animasyonlar eklenecek
- [ ] Loading state'leri iyileştirilecek
- [ ] Error handling UI'ları eklenecek
- [ ] Empty state'ler eklenecek
- [ ] Splash screen oluşturulacak
- [ ] App icon tasarlanacak
- [ ] Oyun sonu ekranları iyileştirilecek

### 📊 İstatistikler ve Analitik
- [ ] Detaylı istatistik ekranları eklenecek
- [ ] Geçmiş performans grafikleri eklenecek
- [ ] Kategori bazlı analizler eklenecek
- [ ] Kullanıcı ilerleme takibi iyileştirilecek
- [ ] Haftalık/aylık raporlar

### 🔔 Bildirimler
- [ ] Push notification servisi kurulacak
- [ ] Günlük hatırlatma bildirimleri eklenecek
- [ ] Başarı bildirimleri eklenecek
- [ ] Local notification sistemi

### ⚙️ Ayarlar
- [ ] Ayarlar ekranı oluşturulacak
- [ ] Bildirim ayarları
- [ ] Ses ayarları
- [ ] Tema ayarları (dark mode)
- [ ] Dil seçenekleri
- [ ] Veri sıfırlama
- [ ] Hesap silme

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

1. **Kalan Oyunlar** - 4 oyun daha eklenmeli
2. **UI İyileştirmeleri** - Kullanıcı deneyimi için kritik
3. **Ayarlar Ekranı** - Temel özellikler
4. **Testler** - Kalite güvencesi için
5. **iOS Yapılandırması** - Platform desteği

---

## 📌 NOTLAR

- Proje Flutter 3.38.1 ile geliştirildi
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

---

## 🔗 ÖNEMLİ DOSYALAR

- `lib/core/memory/memory_bank.dart` - Tüm uygulama sabitleri
- `lib/main.dart` - Uygulama giriş noktası
- `lib/core/i18n/app_strings.dart` - Uygulama metinleri (TR/EN)
- `lib/services/local_storage_service.dart` - Local storage işlemleri
- `lib/services/auth_service.dart` - Firebase Auth işlemleri
- `lib/services/firestore_service.dart` - Firestore veri işlemleri
- `lib/features/settings/providers/language_provider.dart` - Dil yönetimi (Riverpod)
- `lib/features/game_launcher/widgets/` - Oyun widget'ları
- `lib/features/auth/providers/auth_provider.dart` - Auth state management
- `pubspec.yaml` - Bağımlılıklar

---

## 📊 MEVCUT DURUM

### ✅ Tamamlanan
- Proje yapısı
- Temel UI ekranları
- 3 oyun (Reflex Tap, Quick Math, Memory Board)
- Local storage sistemi
- Firebase Auth sistemi
- Firestore veri altyapısı
- İstatistik ekranı
- Android yapılandırması
- TR/EN dil desteği (AppStrings + languageProvider)

### 🚧 Devam Eden
- Kalan 4 oyunun geliştirilmesi
- UI iyileştirmeleri

### 📅 Planlanan
- iOS yapılandırması
- Ayarlar ekranı
- Bildirimler
- Testler

---

*Son güncelleme: 2026-02-13*
