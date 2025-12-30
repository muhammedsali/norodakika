# 📋 TRELLO KARTLARI - Kopyala Yapıştır İçin Hazır

---

## ✅ BUGÜN LİSTESİNE EKLENECEK KARTLAR

### Kart 1: 12 Mini Oyun Entegrasyonu Tamamlandı ✅
**Açıklama:**
Tüm 12 mini oyun başarıyla entegre edildi ve modernize edildi.

**Checklist:**
- [x] Reflex Tap (REF01) - Modernize edildi, level sistemi eklendi
- [x] Reflex Dash (REF02) - Modernize edildi, 3 can sistemi eklendi
- [x] Quick Math (NUM01) - Modernize edildi, level sistemi eklendi
- [x] Memory Board (MEM02) - Modernize edildi, day/night mode uyumlu
- [x] Stroop Tap (ATT01) - Modernize edildi, combo sistemi eklendi
- [x] Focus Line (ATT02) - Modernize edildi, level sistemi eklendi
- [x] N-Back Mini (MEM01) - Modernize edildi, streak tracking eklendi
- [x] Logic Puzzle (LOG01) - Modernize edildi, level sistemi eklendi
- [x] Recall Phase (MEM03) - Modernize edildi, 3 can sistemi eklendi
- [x] Word Sprint (LANG02) - Modernize edildi, combo sistemi eklendi
- [x] Sequence Echo (MEM04) - Modernize edildi, streak tracking eklendi
- [x] Odd One Out (VIS02) - Modernize edildi, accuracy tracking eklendi
- [x] GamePlayScreen switch-case yapısına tüm oyunlar eklendi
- [x] MemoryBank.games listesine tüm oyun metadataları eklendi

---

### Kart 2: Oyun Modernizasyonu Tamamlandı ✅
**Açıklama:**
Tüm oyunlar modern UI/UX, level sistemleri, combo tracking ve day/night mode desteği ile güncellendi.

**Checklist:**
- [x] Level sistemleri eklendi (gereken oyunlara)
- [x] Combo/streak tracking eklendi
- [x] 3 can sistemi eklendi
- [x] Modern UI/UX tasarımı
- [x] Day/night mode uyumluluğu
- [x] Oyun sonuçlarının onComplete ile GamePlay/Stats sistemine gönderilmesi
- [x] Oyun bitiş dialog'ları day/night mode uyumlu hale getirildi
- [x] Duplicate dialog sorunu çözüldü

---

### Kart 3: Splash Screen ve Logo Ekranları ✅
**Açıklama:**
Uygulama başlangıcında ve her oyun başlamadan önce logo ekranları eklendi.

**Checklist:**
- [x] Uygulama splash screen eklendi (NöroDakika logosu)
- [x] Oyun başlangıç logo ekranları eklendi
- [x] Logo animasyonları (fade, scale)
- [x] Day/night mode uyumlu tasarım
- [x] 3 saniye otomatik geçiş

---

### Kart 4: GameLauncher Kart Tasarımı Yenilendi ✅
**Açıklama:**
GameLauncher ekranındaki oyun kartları tamamen yenilendi.

**Checklist:**
- [x] Tam ekran gradient arka plan
- [x] Sol üstte cam efektli ikon kutusu
- [x] Altta oyun adı + açıklama
- [x] Sol altta dairesel play butonu
- [x] Day/night mode uyumlu
- [x] Glow efektleri eklendi

---

### Kart 5: HomeScreen Oyun Kartları Güncellendi ✅
**Açıklama:**
HomeScreen "Tüm Oyunlar" bölümündeki kartlar modernize edildi.

**Checklist:**
- [x] İkonlar ortalandı, büyütüldü
- [x] Tek renk yerine iki renk gradient verildi
- [x] ref01.png görseli kaldırılıp yerine ikon + gradient kullanıldı
- [x] Oyun başlatma dialog'u modernize edildi
- [x] Gradient header, büyük emoji ikon, glow efektleri

---

### Kart 6: Dil Sistemi Tamamlandı ✅
**Açıklama:**
Riverpod tabanlı dil yönetimi ve LocalStorage entegrasyonu tamamlandı.

**Checklist:**
- [x] AppLanguage enum oluşturuldu
- [x] LanguageNotifier ile Riverpod entegrasyonu
- [x] Seçilen dilin LocalStorage'a kaydedilmesi
- [x] Alt menü metinlerinin TR/EN dinamik hale getirilmesi
- [x] Onboarding metinlerinin TR/EN dinamik hale getirilmesi
- [x] Settings - dil seçimi dropdown (TR/EN)

---

### Kart 7: Mimari İyileştirmeler ✅
**Açıklama:**
Gereksiz ekranlar temizlendi ve navigasyon akışı optimize edildi.

**Checklist:**
- [x] WelcomeScreen devre dışı bırakıldı
- [x] AllGamesScreen silindi
- [x] DailyPlanScreen silindi
- [x] Gereksiz import'lar temizlendi
- [x] SplashScreen'den direkt AuthGateScreen'e geçiş

---

### Kart 8: İstatistikler ve İlerleme ✅
**Açıklama:**
StatsScreen erişilebilir hale getirildi ve placeholder veriler eklendi.

**Checklist:**
- [x] StatsScreen ana uygulamadan erişilebilir hale getirildi
- [x] İlerleme kısmına placeholder veriler eklendi
- [x] UI her zaman görünür durumda

---

## ⚠️ 3.12.2025 LİSTESİNE EKLENECEK KARTLAR

### Kart 9: Oyun Kartları Tasarım Birliği
**Açıklama:**
HomeScreen "Tüm Oyunlar" bölümündeki GridGameCard ve GameLauncher'daki UnifiedGameCard'ın aynı stil sistemini kullanması gerekiyor.

**Checklist:**
- [ ] GridGameCard ve UnifiedGameCard'ın gradient mantığını birleştir
- [ ] Border ve shadow değerlerini standardize et
- [ ] İkon boyutları ve konumlarını hizala
- [ ] Padding ve spacing değerlerini eşitle
- [ ] Her iki kart tipinde de aynı _getGradientColors fonksiyonunu kullan

---

### Kart 10: İkon ve Gradient Palet Standardizasyonu
**Açıklama:**
HomeScreen ve GameLauncherScreen'deki ikon ve gradient renk paletlerinin aynı mantıkla kullanılması.

**Checklist:**
- [ ] _getGradientColors fonksiyonunu shared bir yere taşı
- [ ] _getIcon fonksiyonunu shared bir yere taşı
- [ ] Her iki ekranda da aynı fonksiyonları kullan
- [ ] Renk paletlerinin tutarlılığını kontrol et
- [ ] İkon seçim mantığının aynı olduğunu doğrula

---

### Kart 11: Reflex Dash, Focus Line, Word Sprint Kart Güncellemeleri
**Açıklama:**
Bu üç oyun için kart renklerinin ve ikonlarının oyun temasına göre güncellenmesi.

**Checklist:**
- [ ] Reflex Dash (REF02) kart rengi ve ikonu kontrol et
- [ ] Focus Line (ATT02) kart rengi ve ikonu kontrol et
- [ ] Word Sprint (LANG02) kart rengi ve ikonu kontrol et
- [ ] Oyun temalarına uygun gradient renkler seç
- [ ] İkonları oyun içeriğine uygun güncelle

---

## 📅 BU HAFTA LİSTESİNE EKLENECEK KARTLAR

### Kart 12: Oyun Sonuçları API Hata Yönetimi
**Açıklama:**
API gönderim hatalarının kullanıcıya gösterilmesi ve offline durumda sonuçların local storage'a kaydedilmesi.

**Checklist:**
- [ ] API gönderim hatalarının kullanıcıya gösterilmesi
- [ ] Offline durumda sonuçların local storage'a kaydedilmesi
- [ ] Retry mekanizması ekle
- [ ] Hata mesajlarının kullanıcı dostu olması
- [ ] Network durumu kontrolü

---

### Kart 13: Tüm Oyunların Test Edilmesi
**Açıklama:**
Her oyunun farklı cihazlarda test edilmesi ve performance optimizasyonları.

**Checklist:**
- [ ] Her oyunun farklı cihazlarda test edilmesi
- [ ] Performance optimizasyonları
- [ ] Memory leak kontrolü
- [ ] FPS kontrolleri
- [ ] Battery usage analizi
- [ ] Crash raporları kontrolü

---

### Kart 14: Onboarding Overlay Tamamlanması
**Açıklama:**
İlk açılışta görünen çok adımlı kartların tamamlanması.

**Checklist:**
- [ ] Onboarding overlay'in tam implementasyonu
- [ ] Çok adımlı kart yapısı
- [ ] Skip butonu
- [ ] LocalStorage ile "gösterildi" durumu kaydetme
- [ ] Animasyonlar ve geçişler
- [ ] TR/EN dil desteği

---

### Kart 15: Unity Oyun Entegrasyonu (Ahmet)
**Açıklama:**
Unity'den 3 oyun yapılacak ve Flutter uygulamasına atılacak.

**Checklist:**
- [ ] Unity'den 3 oyun yapılacak
- [ ] Flutter uygulamasına entegrasyon
- [ ] Platform channel yapısı
- [ ] Test framework'ü

---

### Kart 16: Veritabanı Bağlantısı ve 2 Oyun Ekleme (Enes)
**Açıklama:**
Enes veritabanı bağlantısına bakacak ve 2 oyun ekleyecek.

**Checklist:**
- [ ] Veritabanı bağlantısı kontrolü
- [ ] 2 yeni oyun ekleme
- [ ] Oyun metadatalarının veritabanına kaydedilmesi

---

## 🔮 DAHA SONRA LİSTESİNE EKLENECEK KARTLAR

### Kart 17: Oyun İçi İstatistiklerin Detaylandırılması
**Açıklama:**
Ortalama tepki süresi, combo istatistikleri ve oyun bazlı detaylı istatistikler.

**Checklist:**
- [ ] Ortalama tepki süresi gösterimi
- [ ] Combo istatistikleri detaylandırma
- [ ] Oyun bazlı detaylı istatistikler
- [ ] Grafik gösterimleri
- [ ] Karşılaştırma modları

---

### Kart 18: İstatistik Ekranı Filtreleri
**Açıklama:**
İstatistik ekranında gün/hafta/ay filtreleri eklenmesi.

**Checklist:**
- [ ] Gün filtresi
- [ ] Hafta filtresi
- [ ] Ay filtresi
- [ ] Filtre UI tasarımı
- [ ] Filtreleme mantığı

---

### Kart 19: Profil Ekranı Geliştirmeleri
**Açıklama:**
Avatar seçimi iyileştirmeleri, kullanıcı istatistikleri özeti ve başarı rozetleri.

**Checklist:**
- [ ] Avatar seçimi iyileştirmeleri
- [ ] Kullanıcı istatistikleri özeti
- [ ] Başarı rozetleri
- [ ] Profil görselleştirmeleri

---

### Kart 20: "Günün Oyunu" Özelliği
**Açıklama:**
HomeScreen banner + GameLauncher entegrasyonu ile günlük rotasyon sistemi.

**Checklist:**
- [ ] HomeScreen banner tasarımı
- [ ] GameLauncher entegrasyonu
- [ ] Günlük rotasyon sistemi
- [ ] Backend entegrasyonu

---

### Kart 21: Kullanıcı Özelleştirmeleri (23.12.25)
**Açıklama:**
Panel renkleri, tema seçimi genişletilmesi ve özel avatar yükleme.

**Checklist:**
- [ ] Panel renkleri seçimi
- [ ] Tema seçimi genişletilmesi
- [ ] Özel avatar yükleme
- [ ] Kullanıcı tercihleri kaydetme

---

### Kart 22: İstatistik Düzenlemeleri (23.12.25)
**Açıklama:**
Yeni grafik türleri, export özelliği ve karşılaştırma modları.

**Checklist:**
- [ ] Yeni grafik türleri
- [ ] Export özelliği (PDF, CSV)
- [ ] Karşılaştırma modları
- [ ] İstatistik paylaşımı

---

### Kart 23: Unity Eğitimi (Ahmet)
**Açıklama:**
Ahmet diğer grup üyelerine (Enes, Serhat, Muhammed) Unity'den oyun yapmayı gösterecek.

**Checklist:**
- [ ] Unity eğitim içeriği hazırlama
- [ ] Eğitim seansları planlama
- [ ] Pratik örnekler

---

## 📊 GÖSTERİLECEKLER LİSTESİNE EKLENECEK KARTLAR

### Kart 24: GameLauncher Kart Tasarımı
**Açıklama:**
_buildGameCard tamamen yenilendi. Tam ekran gradient arka plan, sol üstte cam efektli ikon kutusu, altta oyun adı + açıklama ve sol altta dairesel play butonu.

**Durum:** ✅ Tamamlandı

---

### Kart 25: HomeScreen "Tüm Oyunlar" Kartları
**Açıklama:**
İkonlar ortalandı, büyütüldü, tek renk yerine iki renk gradient verildi. ref01.png görseli tamamen kaldırılıp yerine ikon + gradient kullanıldı.

**Durum:** ✅ Tamamlandı

---

### Kart 26: Dil Sistemi
**Açıklama:**
AppLanguage enum ve LanguageNotifier ile Riverpod tabanlı dil yönetimi. Seçilen dilin LocalStorage'a kaydedilmesi. Alt menü ve onboarding metinlerinin TR/EN dinamik hale getirilmesi.

**Durum:** ✅ Tamamlandı

---

### Kart 27: Profil & Ayarlar Ekranı
**Açıklama:**
Dark/light moda uygun modern tasarım. Profil ekranı IsDarkMode parametresiyle HomeScreen temasıyla senkron. Ayarlarda dil kartının tema kartının hemen altına alınması.

**Durum:** ✅ Tamamlandı

---

### Kart 28: Oyun Entegrasyonları
**Açıklama:**
ReflexDashGame, FocusLineGame, WordSprintGame widget'larının yazılması. GamePlayScreen içinde ilgili gameId'lere göre bu widget'ların açılması. MemoryBank'te oyun alanı, açıklama ve ID'lerin tanımlanması.

**Durum:** ✅ Tamamlandı (12 oyun)

---

## 📝 NOTLAR

- Tüm kartlar Trello'ya kopyala-yapıştır yapılabilir formatta hazırlandı
- Checklist item'ları kopyalanabilir
- Her kart bağımsız olarak Trello'ya eklenebilir
- Kart açıklamaları ve checklist'ler detaylı şekilde hazırlandı

