import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _onboardingSeenKey = 'onboarding_seen';
  static const String _languageKey = 'language_code';

  // İlk açılış onboarding durumunu getir
  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingSeenKey) ?? false;
  }

  // İlk açılış onboarding durumunu kaydet
  static Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingSeenKey, true);
  }

  // Uygulama dili
  static Future<String> getLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'tr';
  }

  static Future<void> setLanguageCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, code);
  }
}

