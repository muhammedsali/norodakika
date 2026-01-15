# 🚀 NöroDakika Projesi - Teknoloji Çalışma Listesi

Bu doküman, projede kullanılan tüm teknolojiler için detaylı bir çalışma planı içerir. Her teknoloji için öğrenme kaynakları, pratik projeler ve geliştirme önerileri bulunmaktadır.

---

## 📋 İçindekiler

1. [Flutter & Dart](#1-flutter--dart)
2. [Riverpod State Management](#2-riverpod-state-management)
3. [Firebase](#3-firebase)
4. [HTTP & API İşlemleri](#4-http--api-işlemleri)
5. [Local Storage](#5-local-storage)
6. [UI/UX & Grafikler](#6-uiux--grafikler)
7. [Ses İşlemleri](#7-ses-işlemleri)
8. [Material Design 3](#8-material-design-3)
9. [Android Native Entegrasyonu](#9-android-native-entegrasyonu)
10. [Genel Geliştirme Pratikleri](#10-genel-geliştirme-pratikleri)

---

## 1. Flutter & Dart

### 🎯 Öğrenme Hedefleri
- Dart programlama dilinin temelleri
- Flutter widget sistemi
- Stateful vs Stateless widgets
- BuildContext ve Widget lifecycle
- Navigation ve routing
- Async/await ve Future işlemleri

### 📚 Öğrenme Kaynakları
- [ ] **Flutter Resmi Dokümantasyonu** - https://flutter.dev/docs
- [ ] **Dart Resmi Dokümantasyonu** - https://dart.dev/guides
- [ ] **Flutter Codelabs** - https://codelabs.developers.google.com/?cat=Flutter
- [ ] **Flutter YouTube Kanalı** - https://www.youtube.com/c/flutterdev
- [ ] **DartPad** - https://dartpad.dev/ (Online kod deneme)

### 🛠️ Pratik Projeler
- [ ] **Basit Hesap Makinesi** - StatefulWidget kullanarak
- [ ] **Todo List Uygulaması** - CRUD işlemleri ile
- [ ] **Hava Durumu Uygulaması** - API çağrıları ve async işlemler
- [ ] **Not Defteri** - Local storage ile veri saklama
- [ ] **Profil Sayfası** - Form validasyonu ve kullanıcı girişi

### 📝 Projede Kullanım Örnekleri
- `lib/main.dart` - Uygulama başlatma ve tema yönetimi
- `lib/features/*/screens/` - Ekran widget'ları
- `lib/features/*/widgets/` - Özel widget'lar

### ✅ Kontrol Listesi
- [ ] Dart syntax ve temel kavramlar (variables, functions, classes)
- [ ] Flutter widget tree yapısı
- [ ] Hot reload ve hot restart kullanımı
- [ ] Debugging teknikleri
- [ ] Performance optimizasyonu

---

## 2. Riverpod State Management

### 🎯 Öğrenme Hedefleri
- Provider, StateNotifier, StreamProvider kavramları
- ref.watch, ref.read, ref.listen kullanımı
- StateNotifier ile state yönetimi
- AsyncValue ile async state handling
- Provider dependency injection

### 📚 Öğrenme Kaynakları
- [ ] **Riverpod Resmi Dokümantasyonu** - https://riverpod.dev/
- [ ] **Riverpod YouTube Videoları** - Resmi kanal
- [ ] **Flutter Riverpod Tutorial** - Medium makaleleri
- [ ] **Provider vs Riverpod Karşılaştırması** - Blog yazıları

### 🛠️ Pratik Projeler
- [ ] **Counter App** - Basit state yönetimi
- [ ] **Shopping Cart** - StateNotifier ile karmaşık state
- [ ] **Weather App** - StreamProvider ile real-time data
- [ ] **Authentication Flow** - AsyncValue ile loading/error states
- [ ] **Todo App** - CRUD işlemleri ile state management

### 📝 Projede Kullanım Örnekleri
- `lib/features/auth/providers/auth_provider.dart` - Auth state yönetimi
- `lib/features/settings/providers/theme_provider.dart` - Tema state'i
- `lib/features/stats/providers/user_stats_provider.dart` - İstatistik state'i

### ✅ Kontrol Listesi
- [ ] Provider oluşturma ve kullanma
- [ ] StateNotifier ile state güncelleme
- [ ] StreamProvider ile real-time data
- [ ] AsyncValue ile loading/error handling
- [ ] Provider test etme

---

## 3. Firebase

### 🎯 Öğrenme Hedefleri
- Firebase Core kurulumu
- Firebase Authentication (Email/Password)
- Cloud Firestore veritabanı
- Firestore CRUD işlemleri
- Real-time listeners
- Security rules

### 📚 Öğrenme Kaynakları
- [ ] **Firebase Resmi Dokümantasyonu** - https://firebase.google.com/docs
- [ ] **FlutterFire Dokümantasyonu** - https://firebase.flutter.dev/
- [ ] **Firebase YouTube Kanalı** - https://www.youtube.com/user/Firebase
- [ ] **Firebase Console** - https://console.firebase.google.com/

### 🛠️ Pratik Projeler
- [ ] **Authentication App** - Email/Password ile giriş
- [ ] **Chat App** - Firestore real-time messaging
- [ ] **Blog App** - Firestore CRUD işlemleri
- [ ] **Social Media Feed** - Firestore queries ve pagination
- [ ] **User Profile** - Firestore document management

### 📝 Projede Kullanım Örnekleri
- `lib/services/auth_service.dart` - Firebase Auth entegrasyonu
- `lib/services/firestore_service.dart` - Firestore işlemleri
- `lib/firebase_options.dart` - Firebase konfigürasyonu

### ✅ Kontrol Listesi
- [ ] Firebase projesi oluşturma
- [ ] Firebase Authentication kurulumu
- [ ] Firestore database kurulumu
- [ ] Firestore security rules yazma
- [ ] Real-time listeners kullanma
- [ ] Error handling ve offline support

---

## 4. HTTP & API İşlemleri

### 🎯 Öğrenme Hedefleri
- HTTP metodları (GET, POST, PUT, DELETE)
- Dio vs http paketi karşılaştırması
- Request/Response handling
- Error handling
- Interceptors ve middleware
- API service pattern

### 📚 Öğrenme Kaynakları
- [ ] **Dio Paketi Dokümantasyonu** - https://pub.dev/packages/dio
- [ ] **HTTP Paketi Dokümantasyonu** - https://pub.dev/packages/http
- [ ] **REST API Best Practices** - Blog yazıları
- [ ] **JSON Serialization** - Dart json_serializable

### 🛠️ Pratik Projeler
- [ ] **News App** - REST API ile haber çekme
- [ ] **Weather App** - API ile hava durumu
- [ ] **GitHub API Client** - GitHub API kullanımı
- [ ] **API Wrapper** - Custom API service oluşturma
- [ ] **Error Handling Demo** - Try-catch ve error states

### 📝 Projede Kullanım Örnekleri
- `lib/core/api/api_service.dart` - API servis yapısı
- `pubspec.yaml` - http ve dio paketleri

### ✅ Kontrol Listesi
- [ ] HTTP request gönderme
- [ ] JSON parsing ve serialization
- [ ] Error handling
- [ ] Loading states yönetimi
- [ ] API interceptors kullanma

---

## 5. Local Storage

### 🎯 Öğrenme Hedefleri
- SharedPreferences kullanımı
- Key-value storage
- Async storage işlemleri
- Data persistence
- Storage best practices

### 📚 Öğrenme Kaynakları
- [ ] **SharedPreferences Dokümantasyonu** - https://pub.dev/packages/shared_preferences
- [ ] **Flutter Storage Options** - Blog karşılaştırmaları
- [ ] **Data Persistence Patterns** - Medium makaleleri

### 🛠️ Pratik Projeler
- [ ] **Settings App** - Kullanıcı tercihlerini kaydetme
- [ ] **Offline Todo App** - Local storage ile veri saklama
- [ ] **Cache Manager** - API response caching
- [ ] **User Preferences** - Tema, dil gibi ayarlar

### 📝 Projede Kullanım Örnekleri
- `lib/services/local_storage_service.dart` - Tüm local storage işlemleri
- Onboarding durumu, tema, dil tercihleri

### ✅ Kontrol Listesi
- [ ] SharedPreferences ile veri kaydetme
- [ ] SharedPreferences ile veri okuma
- [ ] Complex data structures (JSON) kaydetme
- [ ] Storage cleanup ve migration
- [ ] Error handling

---

## 6. UI/UX & Grafikler

### 🎯 Öğrenme Hedefleri
- fl_chart kütüphanesi
- Radar chart, line chart, bar chart
- Custom paint ve animations
- Responsive design
- Material Design principles

### 📚 Öğrenme Kaynakları
- [ ] **fl_chart Dokümantasyonu** - https://pub.dev/packages/fl_chart
- [ ] **Google Fonts** - https://fonts.google.com/
- [ ] **Material Design 3** - https://m3.material.io/
- [ ] **Flutter UI Best Practices** - Blog yazıları

### 🛠️ Pratik Projeler
- [ ] **Dashboard App** - Çeşitli grafikler ile
- [ ] **Fitness Tracker** - Progress charts
- [ ] **Analytics App** - Data visualization
- [ ] **Custom Charts** - fl_chart ile özel grafikler
- [ ] **Animated UI** - Animations ve transitions

### 📝 Projede Kullanım Örnekleri
- `lib/features/stats/widgets/radar_chart_widget.dart` - Radar chart implementasyonu
- `lib/features/stats/screens/stats_screen.dart` - Grafik ekranı
- Google Fonts kullanımı

### ✅ Kontrol Listesi
- [ ] fl_chart ile radar chart oluşturma
- [ ] Line chart ve bar chart
- [ ] Google Fonts entegrasyonu
- [ ] Custom animations
- [ ] Responsive design principles

---

## 7. Ses İşlemleri

### 🎯 Öğrenme Hedefleri
- audioplayers paketi
- Asset audio playback
- Audio state management
- Sound effects ve background music
- Audio permissions

### 📚 Öğrenme Kaynakları
- [ ] **audioplayers Dokümantasyonu** - https://pub.dev/packages/audioplayers
- [ ] **Flutter Audio Guide** - Blog yazıları
- [ ] **Audio Format Best Practices** - MP3, WAV karşılaştırması

### 🛠️ Pratik Projeler
- [ ] **Music Player** - Basit müzik çalıcı
- [ ] **Sound Board** - Ses efektleri uygulaması
- [ ] **Game with Sounds** - Oyun ses efektleri
- [ ] **Audio Recorder** - Ses kaydetme (farklı paket)

### 📝 Projede Kullanım Örnekleri
- `lib/services/audio_service.dart` - Ses servisi implementasyonu
- Oyunlarda ses efektleri kullanımı

### ✅ Kontrol Listesi
- [ ] Asset audio çalma
- [ ] Audio state yönetimi
- [ ] Multiple audio instances
- [ ] Audio permissions (Android/iOS)
- [ ] Error handling

---

## 8. Material Design 3

### 🎯 Öğrenme Hedefleri
- Material 3 design system
- ColorScheme ve theming
- Typography ve spacing
- Component library
- Dark mode support

### 📚 Öğrenme Kaynakları
- [ ] **Material Design 3** - https://m3.material.io/
- [ ] **Flutter Material 3** - https://docs.flutter.dev/ui/design/material
- [ ] **Material You** - Google'ın tasarım sistemi
- [ ] **ColorScheme Generator** - Material Design tools

### 🛠️ Pratik Projeler
- [ ] **Theme Switcher App** - Light/Dark mode
- [ ] **Material 3 Components** - Tüm component'leri deneme
- [ ] **Custom Theme** - Kendi tema oluşturma
- [ ] **Design System** - Consistent UI components

### 📝 Projede Kullanım Örnekleri
- `lib/main.dart` - Material 3 tema konfigürasyonu
- `lib/features/settings/providers/theme_provider.dart` - Tema yönetimi

### ✅ Kontrol Listesi
- [ ] Material 3 tema oluşturma
- [ ] ColorScheme kullanımı
- [ ] Dark mode implementasyonu
- [ ] Material 3 components kullanımı
- [ ] Custom theming

---

## 9. Android Native Entegrasyonu

### 🎯 Öğrenme Hedefleri
- Android proje yapısı
- Gradle build system
- AndroidManifest.xml
- Native platform channels
- Android permissions

### 📚 Öğrenme Kaynakları
- [ ] **Flutter Android Setup** - https://docs.flutter.dev/deployment/android
- [ ] **Gradle Dokümantasyonu** - https://gradle.org/
- [ ] **Android Developer Guide** - https://developer.android.com/
- [ ] **Platform Channels** - Flutter docs

### 🛠️ Pratik Projeler
- [ ] **Native Module Integration** - Platform channel kullanımı
- [ ] **Android Permissions** - Permission handling
- [ ] **Build Configuration** - Gradle ayarları
- [ ] **App Signing** - Release build oluşturma

### 📝 Projede Kullanım Örnekleri
- `android/` klasörü - Android proje yapısı
- `android/app/build.gradle` - Build konfigürasyonu
- `android/app/src/main/AndroidManifest.xml` - Manifest dosyası

### ✅ Kontrol Listesi
- [ ] Android proje yapısını anlama
- [ ] Gradle build system
- [ ] AndroidManifest.xml yapılandırma
- [ ] Permissions yönetimi
- [ ] Release build oluşturma

---

## 10. Genel Geliştirme Pratikleri

### 🎯 Öğrenme Hedefleri
- Clean Architecture
- SOLID principles
- Code organization
- Testing (Unit, Widget, Integration)
- Version control (Git)
- Code review practices

### 📚 Öğrenme Kaynakları
- [ ] **Clean Architecture** - Robert C. Martin
- [ ] **Flutter Testing** - https://docs.flutter.dev/testing
- [ ] **Git Best Practices** - Atlassian Git tutorials
- [ ] **Code Review Guide** - Google's guide

### 🛠️ Pratik Projeler
- [ ] **Clean Architecture App** - Katmanlı mimari
- [ ] **Test Coverage** - %80+ test coverage
- [ ] **CI/CD Pipeline** - GitHub Actions
- [ ] **Code Documentation** - Dartdoc kullanımı

### 📝 Projede Kullanım Örnekleri
- `lib/core/` - Core katmanı (models, utils, memory)
- `lib/features/` - Feature-based organization
- `lib/services/` - Service layer

### ✅ Kontrol Listesi
- [ ] Clean Architecture principles
- [ ] Unit test yazma
- [ ] Widget test yazma
- [ ] Integration test yazma
- [ ] Git workflow (branching, commits)
- [ ] Code documentation

---

## 📅 Önerilen Çalışma Planı

### Hafta 1-2: Temel Flutter & Dart
- Flutter kurulumu ve ilk uygulama
- Dart temelleri
- Widget sistemi
- Navigation

### Hafta 3-4: State Management & Firebase
- Riverpod öğrenme
- Firebase kurulumu
- Authentication implementasyonu
- Firestore CRUD işlemleri

### Hafta 5-6: UI/UX & Grafikler
- Material Design 3
- fl_chart kullanımı
- Custom widgets
- Animations

### Hafta 7-8: Advanced Topics
- HTTP/API işlemleri
- Local storage
- Audio işlemleri
- Testing

### Hafta 9+: Proje Geliştirme
- Kendi projelerini geliştirme
- Best practices uygulama
- Code review ve refactoring

---

## 🎯 Öğrenme Kaynakları Özeti

### Resmi Dokümantasyonlar
- Flutter: https://flutter.dev/docs
- Dart: https://dart.dev/guides
- Firebase: https://firebase.google.com/docs
- Riverpod: https://riverpod.dev/

### Video Eğitimler
- Flutter YouTube Kanalı
- Firebase YouTube Kanalı
- Udemy Flutter kursları
- YouTube Flutter tutorial kanalları

### Topluluk Kaynakları
- Flutter Dev Discord
- Stack Overflow
- Reddit r/FlutterDev
- Medium Flutter makaleleri

### Pratik Yapma Platformları
- DartPad - Online Dart editor
- Flutter Playground
- GitHub - Open source projeleri inceleme
- LeetCode - Algoritma pratiği

---

## 💡 İpuçları

1. **Pratik Yap**: Her teknolojiyi öğrendikten sonra küçük projeler yap
2. **Kod Oku**: Projedeki mevcut kodu incele ve anlamaya çalış
3. **Dokümantasyon**: Resmi dokümantasyonları mutlaka oku
4. **Topluluk**: Flutter topluluğuna katıl ve sorular sor
5. **Proje Yap**: Öğrendiklerini kendi projelerinde kullan
6. **Code Review**: Kendi kodunu gözden geçir ve iyileştir
7. **Test Yaz**: Her özellik için test yazmayı alışkanlık haline getir

---

## 📊 İlerleme Takibi

Her teknoloji için kendi ilerlemeni takip edebilirsin:

- [ ] Başlangıç seviyesi - Temel kavramları öğrendim
- [ ] Orta seviye - Projelerde kullanabiliyorum
- [ ] İleri seviye - Karmaşık problemleri çözebiliyorum
- [ ] Uzman seviye - Başkalarına öğretebiliyorum

---

**Başarılar! 🚀**

Bu çalışma listesi ile projede kullanılan tüm teknolojileri sistematik bir şekilde öğrenebilir ve kendini geliştirebilirsin.
