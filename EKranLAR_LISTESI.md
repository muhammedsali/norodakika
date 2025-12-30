# NöroDakika - Tüm Ekranlar Listesi

## 📱 Uygulama Başlangıç Akışı

### 1. **SplashScreen** ✅ KULLANILIYOR
- **Dosya:** `lib/features/welcome/screens/splash_screen.dart`
- **Başlangıç:** `main.dart` → `MaterialApp(home: SplashScreen())`
- **Açıklama:** Uygulama açıldığında ilk gösterilen ekran. NöroDakika logosu ve animasyonlar içerir.
- **Sonraki Ekran:** `AuthGateScreen` (3 saniye sonra otomatik geçiş)

---

### 2. **AuthGateScreen** ✅ KULLANILIYOR
- **Dosya:** `lib/features/auth/screens/auth_gate_screen.dart`
- **Başlangıç:** `SplashScreen`'den `Navigator.pushReplacement` ile
- **Açıklama:** Kullanıcı kimlik doğrulama kontrolü yapar. Eğer kullanıcı giriş yapmamışsa `LoginScreen`'e, yapmışsa `HomeScreen`'e yönlendirir.
- **Sonraki Ekranlar:**
  - Kullanıcı yoksa → `LoginScreen`
  - Kullanıcı varsa → `HomeScreen` (otomatik yönlendirme)

---

## 🔐 Kimlik Doğrulama Ekranları

### 3. **LoginScreen** ✅ KULLANILIYOR
- **Dosya:** `lib/features/auth/screens/login_screen.dart`
- **Başlangıç:** `AuthGateScreen`'den (kullanıcı giriş yapmamışsa)
- **Açıklama:** Kullanıcı giriş ekranı. Email ve şifre ile giriş yapılır.
- **Sonraki Ekranlar:**
  - Başarılı giriş → `HomeScreen` (AuthGateScreen üzerinden otomatik)
  - "Kayıt ol" butonu → `RegisterScreen`

---

### 4. **RegisterScreen** ✅ KULLANILIYOR
- **Dosya:** `lib/features/auth/screens/register_screen.dart`
- **Başlangıç:** `LoginScreen`'den "Kayıt ol" butonuna tıklanınca
- **Açıklama:** Yeni kullanıcı kayıt ekranı. Email, şifre ve şifre onayı ile kayıt yapılır.
- **Sonraki Ekran:** Kayıt başarılı olunca `LoginScreen`'e geri döner (Navigator.pop)

---

## 🏠 Ana Uygulama Ekranları

### 5. **HomeScreen** ✅ KULLANILIYOR
- **Dosya:** `lib/features/home/screens/home_screen.dart`
- **Başlangıç:** `AuthGateScreen`'den (kullanıcı giriş yapmışsa)
- **Açıklama:** Ana ekran. 4 sekme içerir:
  - **Ana Sayfa (Tab 0):** Günlük plan kartı, hızlı oyun başlatma, istatistikler
  - **Oyunlar (Tab 1):** Tüm oyunların listesi
  - **İlerleme (Tab 2):** `StatsScreen` widget'ı gösterilir
  - **Ayarlar (Tab 3):** Profil, günlük plan, istatistikler linkleri
- **Navigasyon:**
  - Oyun kartına tıklama → `GamePlayScreen`
  - "Günün Antrenmanı" butonu → `GameLauncherScreen`
  - Profil linki → `ProfileScreen`
  - Günün Planı linki → `GameLauncherScreen`
- **Alt Navigasyon:** `HomeBottomNav` widget'ı ile 4 sekme arasında geçiş

---

### 6. **GameLauncherScreen** ✅ KULLANILIYOR
- **Dosya:** `lib/features/game_launcher/screens/game_launcher_screen.dart`
- **Başlangıç:** 
  - `HomeScreen`'den "Günün Antrenmanı" butonuna tıklanınca
  - `HomeScreen`'den "Günün Planı" linkine tıklanınca
- **Açıklama:** Oyun listesi ekranı. Günlük plan modunda veya tüm oyunlar modunda çalışabilir.
- **Sonraki Ekran:** Bir oyuna tıklanınca → `GamePlayScreen`

---

### 7. **GamePlayScreen** ✅ KULLANILIYOR
- **Dosya:** `lib/features/game_launcher/screens/game_play_screen.dart`
- **Başlangıç:** 
  - `GameLauncherScreen`'den bir oyuna tıklanınca
  - `HomeScreen`'den bir oyun kartına tıklanınca
- **Açıklama:** Oyun oynama ekranı. Oyun başlamadan önce logo gösterir, sonra ilgili oyun widget'ını gösterir. Oyun bitince sonuç dialog'u gösterir.
- **İçerik:** 12 farklı mini oyun widget'ı:
  - ReflexTapGame
  - ReflexDashGame
  - QuickMathGame
  - MemoryBoardGame
  - StroopTapGame
  - FocusLineGame
  - NBackMiniGame
  - LogicPuzzleGame
  - RecallPhaseGame
  - WordSprintGame
  - SequenceMemoryGame
  - OddOneOutGame

---

### 8. **StatsScreen** ✅ KULLANILIYOR
- **Dosya:** `lib/features/stats/screens/stats_screen.dart`
- **Başlangıç:** 
  - `HomeScreen`'in "İlerleme" sekmesinde (Tab 2) widget olarak gösterilir
  - `HomeScreen`'in "Ayarlar" sekmesinden "İlerleme ve İstatistikler" linkine tıklanınca (navigasyon ile)
- **Açıklama:** Kullanıcı istatistikleri ve ilerleme ekranı. Radar grafik, özet kartlar ve oyun bazlı istatistikler gösterir.

---

### 9. **ProfileScreen** ✅ KULLANILIYOR
- **Dosya:** `lib/features/profile/screens/profile_screen.dart`
- **Başlangıç:** `HomeScreen`'in "Ayarlar" sekmesinden "Profil" linkine tıklanınca
- **Açıklama:** Kullanıcı profil ekranı. Avatar, kullanıcı bilgileri ve çıkış yapma butonu içerir.

---

## ❌ KULLANILMAYAN EKRANLAR

### 10. **WelcomeScreen** ❌ DEVRE DIŞI BIRAKILDI
- **Dosya:** `lib/features/welcome/screens/welcome_screen.dart`
- **Durum:** Tanımlı ama artık kullanılmıyor
- **Açıklama:** Hoş geldin ekranı. SplashScreen'den direkt AuthGateScreen'e geçiş yapıldığı için devre dışı bırakıldı.
- **Not:** Dosya mevcut ama navigasyon akışından çıkarıldı.

---

## 📊 Özet

### ✅ Kullanılan Ekranlar (9 adet):
1. SplashScreen
2. AuthGateScreen
3. LoginScreen
4. RegisterScreen
5. HomeScreen
6. GameLauncherScreen
7. GamePlayScreen
8. StatsScreen
9. ProfileScreen

### ❌ Kullanılmayan/Devre Dışı Ekranlar (1 adet):
1. WelcomeScreen (devre dışı bırakıldı - SplashScreen'den direkt AuthGateScreen'e geçiş yapılıyor)

---

## 🔄 Navigation Akış Şeması

```
SplashScreen (3 saniye)
    ↓
AuthGateScreen
    ├─→ LoginScreen → RegisterScreen
    └─→ HomeScreen (giriş yapılmışsa)
            ├─→ GameLauncherScreen → GamePlayScreen
            ├─→ GamePlayScreen (direkt)
            ├─→ StatsScreen (tab veya navigasyon)
            └─→ ProfileScreen
```

---

## 📝 Notlar

- `StatsScreen` hem tab olarak hem de navigasyon ile açılabiliyor
- `GameLauncherScreen` hem günlük plan modunda hem de tüm oyunlar modunda çalışabiliyor
- `GamePlayScreen` içinde oyun başlamadan önce logo ekranı gösteriliyor
- `WelcomeScreen` devre dışı bırakıldı - SplashScreen'den direkt AuthGateScreen'e geçiş yapılıyor
- `AllGamesScreen` ve `DailyPlanScreen` silindi

