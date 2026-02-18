import '../../features/settings/providers/language_provider.dart';

class AppStrings {
  final AppLanguage lang;

  const AppStrings(this.lang);

  bool get isEn => lang == AppLanguage.en;

  String get appName => 'Norodakika';

  // Bottom navigation
  String get navHome => isEn ? 'Home' : 'Ana Sayfa';
  String get navGames => isEn ? 'Games' : 'Oyunlar';
  String get navProgress => isEn ? 'Progress' : 'İlerleme';
  String get navSettings => isEn ? 'Settings' : 'Ayarlar';

  // Onboarding
  String get onboardingWelcomeTitle => isEn ? 'Welcome!' : 'Hoş geldin!';
  String get onboardingWelcomeText => isEn
      ? 'Norodakika helps you train your mind with short, focused mini games.'
      : 'NöroDakika, kısa mini oyunlarla zihnini antrenman yapman için tasarlandı.';
  String get onboardingDailyTitle => isEn ? 'Today\'s Workout' : 'Günün Antrenmanı';
  String get onboardingDailyText => isEn
      ? 'Use the purple button on the home screen to start your daily plan.'
      : 'Ana ekrandaki mor butondan bugün için önerilen oyun planını başlatabilirsin.';
  String get onboardingProgressTitle => isEn ? 'Track Progress' : 'İlerleme Takibi';
  String get onboardingProgressText => isEn
      ? 'See your radar chart and daily summary on the Progress tab.'
      : 'Alt barda İlerleme sekmesinden radar grafiği ve günlük özetini görebilirsin.';
  String get onboardingSkip => isEn ? 'Skip' : 'Atla';
  String get onboardingNext => isEn ? 'Next' : 'İleri';
  String get onboardingStart => isEn ? 'Start' : 'Başla';

  // Welcome
  String get welcomeSubtitle =>
      isEn ? 'Mini games that sharpen your mind' : 'Zihnini geliştiren mini oyunlar';
  String get gamesTitle => isEn ? 'Games' : 'Oyunlar';
  String get letsPlay => isEn ? 'Let\'s Play' : 'Hadi Oynayalım';
  String get loginRequiredTitle => isEn ? 'Sign in' : 'Giriş Yapın';
  String get loginRequiredText => isEn
      ? 'You need to sign in to play games and track your progress.'
      : 'Oyunları oynamak ve ilerlemenizi takip etmek için giriş yapmanız gerekiyor.';
  String get loginOrRegister => isEn ? 'Sign in / Sign up' : 'Giriş Yap / Üye Ol';

  // Splash
  String get splashTagline => isEn
      ? 'Train Your Mind, Unlock Your Potential'
      : 'Zihnini Eğit, Potansiyelini Keşfet';

  // Auth
  String get loginErrorPrefix => isEn ? 'Login error' : 'Giriş hatası';
  String get googleLoginErrorPrefix =>
      isEn ? 'Google sign-in error' : 'Google giriş hatası';
  String get platformTitle =>
      isEn ? 'Cognitive Training Platform' : 'Bilişsel Eğitim Platformu';
  String get emailLabel => isEn ? 'Email' : 'E-posta';
  String get passwordLabel => isEn ? 'Password' : 'Şifre';
  String get emailRequired => isEn ? 'Email is required' : 'E-posta gerekli';
  String get emailInvalid =>
      isEn ? 'Enter a valid email' : 'Geçerli bir e-posta girin';
  String get passwordRequired => isEn ? 'Password is required' : 'Şifre gerekli';
  String get passwordMinLength => isEn
      ? 'Password must be at least 6 characters'
      : 'Şifre en az 6 karakter olmalı';
  String get loginButton => isEn ? 'Sign In' : 'Giriş Yap';
  String get googleSignUp =>
      isEn ? 'Sign up with Google' : 'Google ile üye ol';
  String get googleSignIn =>
      isEn ? 'Sign in with Google' : 'Google ile giriş yap';
  String get noAccountRegister =>
      isEn ? 'No account? Sign up' : 'Hesabın yok mu? Kayıt ol';

  // Register
  String get registerTitle => isEn ? 'Sign Up' : 'Kayıt Ol';
  String get confirmPasswordLabel =>
      isEn ? 'Confirm Password' : 'Şifre Tekrar';
  String get confirmPasswordRequired =>
      isEn ? 'Confirmation is required' : 'Şifre tekrarı gerekli';
  String get passwordsDontMatch =>
      isEn ? 'Passwords do not match' : 'Şifreler eşleşmiyor';
  String get registerSuccessSnack => isEn
      ? 'Registration successful! Signing you in...'
      : 'Kayıt başarılı! Giriş yapılıyor...';

  // Stats
  String get statsTitle => isEn ? 'Progress' : 'İlerleme';
  String get statsSubtitle =>
      isEn ? 'Cognitive performance analysis' : 'Bilişsel performans analizi';
  String get filterDay => isEn ? 'Day' : 'Gün';
  String get filterWeek => isEn ? 'Week' : 'Hafta';
  String get filterMonth => isEn ? 'Month' : 'Ay';
  String get summaryToday => isEn ? 'Today summary' : 'Bugün özeti';
  String get summaryWeek => isEn ? 'This week summary' : 'Bu hafta özeti';
  String get summaryMonth => isEn ? 'This month summary' : 'Bu ay özeti';
  String gamesAndMinutes(int gamesCount, int totalMinutes) => isEn
      ? '$gamesCount games, about $totalMinutes min'
      : '$gamesCount oyun, yaklaşık $totalMinutes dk';
  String get noGamesToday =>
      isEn ? 'You haven\'t played today yet' : 'Bugün henüz oyun oynamadın';
  String get noGamesWeek =>
      isEn ? 'You haven\'t played this week yet' : 'Bu hafta henüz oyun oynamadın';
  String get noGamesMonth =>
      isEn ? 'You haven\'t played this month yet' : 'Bu ay henüz oyun oynamadın';
  String get noDataForPeriod =>
      isEn ? 'No data for the selected period' : 'Seçilen dönemde veri yok';

  // Profile
  String get profileTitle => isEn ? 'Profile' : 'Profil';
  String get userFallback => isEn ? 'User' : 'Kullanıcı';
  String get levelBeginner => isEn ? 'Level: Beginner' : 'Seviye: Başlangıç';
  String get generalInfo => isEn ? 'General Info' : 'Genel Bilgiler';
  String get totalSessions => isEn ? 'Total sessions' : 'Toplam oturum';
  String get dailyGoal => isEn ? 'Daily goal' : 'Günlük hedef';
  String get logout => isEn ? 'Sign Out' : 'Çıkış Yap';

  // Game launcher
  String get todaysWorkout => isEn ? 'Today\'s Workout' : 'Günün Antrenmanı';
  String get gameTitle => isEn ? 'Game' : 'Oyun';
  String get sevenMiniGames => isEn ? '7 Mini Games' : '7 Mini Oyun';
  String get dailyPlanDescription => isEn
      ? 'Recommended games for today. Play each one in order to complete your brain workout!'
      : 'Bugün için önerilen oyunlar. Her oyunu sırayla oynayarak beyin antrenmanını tamamla!';
  String get noPlanToday => isEn ? 'No plan for today' : 'Bugün için plan yok';

  // Settings (Home -> Settings tab)
  String get settingsTitle => isEn ? 'Settings' : 'Ayarlar';
  String get settingsSubtitle => isEn
      ? 'Customize the app to your preferences.'
      : 'Uygulamayı sana göre özelleştir.';
  String get darkModeTitle => isEn ? 'Dark Mode' : 'Karanlık Mod';
  String get darkModeSubtitle => isEn
      ? 'A darker theme that\'s easier on your eyes at night.'
      : 'Geceleri gözünü yormayan koyu tema.';
  String get languageTitle => isEn ? 'Language' : 'Dil';
  String get languageSubtitle => isEn
      ? 'Change the app language.'
      : 'Uygulama dilini değiştir.';
  String get languageTurkish => isEn ? 'Turkish' : 'Türkçe';
  String get languageEnglish => 'English';
  String get accountSectionTitle => isEn ? 'Account & Progress' : 'Hesap ve İlerleme';
  String get profileAndAccountTitle => isEn ? 'Profile & Account' : 'Profil ve Hesap';
  String get profileAndAccountSubtitle => isEn
      ? 'Edit your user info and goals.'
      : 'Kullanıcı bilgilerini ve hedeflerini düzenle.';
  String get dayPlanTitle => isEn ? 'Daily Plan' : 'Günün Planı';
  String get dayPlanSubtitle => isEn
      ? 'See today\'s workout cards.'
      : 'Bugünkü antrenman kartlarını gör.';
  String get progressAndStatsTitle => isEn ? 'Progress & Stats' : 'İlerleme ve İstatistikler';
  String get progressAndStatsSubtitle => isEn
      ? 'Radar chart and detailed performance.'
      : 'Radar grafiği ve detaylı performansın.';
  String get aboutTitle => isEn ? 'About Norodakika' : 'NöroDakika Hakkında';
  String get aboutText => isEn
      ? 'Track and improve your cognitive skills with short, science-based mini games. This version is an MVP.'
      : 'Zihinsel becerilerini kısa, bilimsel mini oyunlarla takip et ve geliştir. Bu sürüm MVP aşamasındadır.';

  // Home - misc dialogs
  String get chooseAvatarTitle => isEn ? 'Choose Profile Picture' : 'Profil Resmi Seç';
  String get howToPlay => isEn ? 'How to Play?' : 'Nasıl Oynanır?';
  String get startGame => isEn ? 'Start Game' : 'Oyunu Başlat';
  String get approxTwoThreeMinutes => isEn ? '~2-3 minutes' : '~2-3 dakika';

  // Home - main UI
  String get startTodaysWorkout => isEn ? 'Start: Today\'s Workout' : 'Başla: Günün Antrenmanı';
  String get progressSectionTitle => isEn ? 'Progress' : 'İlerleme';
  String get noGamesYetTitle => isEn ? 'You haven\'t played yet' : 'Henüz oyun oynamadın';
  String get noGamesYetSubtitle => isEn
      ? 'Once you start playing, your progress chart will appear here.'
      : 'Oyun oynamaya başlayınca ilerleme grafin burada görünecek';
  String get statsLoadFailed => isEn ? 'Failed to load data' : 'Veriler yüklenemedi';
  String taskProgressLabel(int current, int total) =>
      isEn ? 'Task: $current/$total' : 'Görev: $current/$total';

  String avatarLabel(String avatarNameTr) {
    if (!isEn) return avatarNameTr;
    switch (avatarNameTr) {
      case 'Varsayılan':
        return 'Default';
      case 'Roket':
        return 'Rocket';
      case 'Beyin':
        return 'Brain';
      case 'Yıldız':
        return 'Star';
      case 'Kalp':
        return 'Heart';
      case 'Kupa':
        return 'Trophy';
      default:
        return avatarNameTr;
    }
  }

  // Game play
  String get gameCompleted => isEn ? 'Game completed' : 'Oyun tamamlandı';
  String get successRate => isEn ? 'Success rate' : 'Başarı oranı';
  String durationSeconds(int seconds) => isEn ? 'Time: $seconds s' : 'Süre: $seconds sn';
  String get backToHome => isEn ? 'Back to home' : 'Ana ekrana dön';
  String get exitGameTitle => isEn ? 'Do you want to exit the game?' : 'Oyundan çıkmak istiyor musun?';
  String get exitGameText => isEn
      ? 'Your progress is saved (if available), but you will end this game now.'
      : 'İlerleyişin kaydedildi (varsa) fakat bu oyunu şimdi sonlandıracaksın.';
  String get comingSoon => isEn ? 'This game will be added soon!' : 'Bu oyun yakında eklenecek!';

  // Generic
  String errorPrefix(Object error) => isEn ? 'Error: $error' : 'Hata: $error';

  String categoryLabel(String categoryTr) {
    if (!isEn) return categoryTr;
    switch (categoryTr) {
      case 'Hafıza':
        return 'Memory';
      case 'Dikkat':
        return 'Attention';
      case 'Refleks':
        return 'Reflex';
      case 'Mantık':
        return 'Logic';
      case 'Sayısal':
      case 'Sayısal Zeka':
        return 'Numerical';
      case 'Görsel':
      case 'Görsel Algı':
        return 'Visual';
      case 'Dil':
        return 'Language';
      default:
        return categoryTr;
    }
  }
}
