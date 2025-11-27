import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/user_model.dart';
import '../core/models/attempt_model.dart';
import '../core/memory/memory_bank.dart';

class LocalStorageService {
  static const String _userKey = 'current_user';
  static const String _userDataKey = 'user_data';
  static const String _attemptsKey = 'attempts';
  static const String _gameDifficultiesKey = 'game_difficulties';
  static const String _onboardingSeenKey = 'onboarding_seen';
  static const String _languageKey = 'language_code';

  // Kullanıcı işlemleri
  static Future<void> saveUser(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, email);
    // Şifre güvenliği için hash'lenmeli, şimdilik basit tutuyoruz
    await prefs.setString('${_userKey}_password', password);
  }

  static Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey);
  }

  static Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString(_userKey);
    final savedPassword = prefs.getString('${_userKey}_password');
    
    if (savedEmail == email && savedPassword == password) {
      return true;
    }
    return false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove('${_userKey}_password');
  }

  // Kullanıcı verilerini getir
  static Future<UserModel?> getUserData(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final userDataJson = prefs.getString('${_userDataKey}_$email');
    
    if (userDataJson != null) {
      final data = jsonDecode(userDataJson) as Map<String, dynamic>;
      return UserModel.fromJson(data);
    }
    
    // Yeni kullanıcı için varsayılan model oluştur
    final newUser = UserModel.fromJson(MemoryBank.createUserModel(email));
    await saveUserData(newUser);
    return newUser;
  }

  // Kullanıcı verilerini kaydet
  static Future<void> saveUserData(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = user.uid;
    await prefs.setString('${_userDataKey}_$userEmail', jsonEncode(user.toJson()));
  }

  // Attempt kaydet
  static Future<void> saveAttempt(AttemptModel attempt) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Attempt listesini getir
    final attemptsJson = prefs.getString('${_attemptsKey}_${attempt.userId}') ?? '[]';
    final List<dynamic> attempts = jsonDecode(attemptsJson);
    attempts.add(attempt.toMap());
    await prefs.setString('${_attemptsKey}_${attempt.userId}', jsonEncode(attempts));

    // Kullanıcı verilerini güncelle
    final user = await getUserData(attempt.userId);
    if (user != null) {
      final updatedHistory = [...user.history, attempt.toMap()];
      
      // Stats'ı güncelle
      final updatedStats = Map<String, double>.from(user.stats);
      final radarStats = MemoryBank.calculateRadarStats(updatedHistory);
      updatedStats.addAll(radarStats);
      
      final updatedUser = user.copyWith(
        history: updatedHistory,
        stats: updatedStats,
      );
      await saveUserData(updatedUser);
    }
  }

  // Geçmişi getir
  static Future<List<Map<String, dynamic>>> getHistory(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final attemptsJson = prefs.getString('${_attemptsKey}_$userId') ?? '[]';
    return List<Map<String, dynamic>>.from(jsonDecode(attemptsJson));
  }

  // Oyun zorluk seviyesini getir
  static Future<double> getGameDifficulty({
    required String userId,
    required String gameId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_gameDifficultiesKey}_${userId}_$gameId';
    return prefs.getDouble(key) ?? 1.0;
  }

  // Oyun zorluk seviyesini güncelle
  static Future<void> updateGameDifficulty({
    required String userId,
    required String gameId,
    required double newDifficulty,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_gameDifficultiesKey}_${userId}_$gameId';
    await prefs.setDouble(key, newDifficulty);
  }

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

