import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/attempt_model.dart';
import '../core/memory/memory_bank.dart';

class LocalStorageService {
  static const String _onboardingSeenKey = 'onboarding_seen';
  static const String _languageKey = 'language_code';
  static const String _themeKey = 'is_dark_mode';
  static const String _gameHistoryKey = 'game_history';
  static const String _gameStatsKey = 'game_stats';
  static const String _gameDifficultyKey = 'game_difficulty';

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

  // Tema tercihi
  static Future<bool> getIsDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }

  static Future<void> setIsDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  // Avatar seçimi
  static const String _avatarKey = 'selected_avatar';

  Future<int> getSelectedAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_avatarKey) ?? 0;
  }

  Future<void> saveSelectedAvatar(int avatarIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_avatarKey, avatarIndex);
  }

  // Oyun geçmişini kaydet
  static Future<void> saveGameHistory(
      List<Map<String, dynamic>> history) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = jsonEncode(history);
    await prefs.setString(_gameHistoryKey, historyJson);
  }

  // Oyun geçmişini getir
  static Future<List<Map<String, dynamic>>> getGameHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_gameHistoryKey);
    if (historyJson == null) return [];
    try {
      final decoded = jsonDecode(historyJson) as List;
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      print('Error reading game history: $e');
      return [];
    }
  }

  // Attempt kaydet (local storage'a)
  static Future<void> saveAttempt(AttemptModel attempt) async {
    try {
      final history = await getGameHistory();
      history.add(attempt.toMap());
      await saveGameHistory(history);

      // Stats'ı güncelle
      final stats = MemoryBank.calculateRadarStats(history);
      await saveGameStats(stats);
    } catch (e) {
      print('Error saving attempt to local storage: $e');
    }
  }

  // Oyun istatistiklerini kaydet
  static Future<void> saveGameStats(Map<String, double> stats) async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson =
        jsonEncode(stats.map((k, v) => MapEntry(k, v.toString())));
    await prefs.setString(_gameStatsKey, statsJson);
  }

  // Oyun istatistiklerini getir
  static Future<Map<String, double>> getGameStats() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_gameStatsKey);
    if (statsJson == null) {
      return {
        'Hafıza': 0.0,
        'Dikkat': 0.0,
        'Refleks': 0.0,
        'Mantık': 0.0,
        'Sayısal Zeka': 0.0,
        'Görsel Algı': 0.0,
        'Dil': 0.0,
      };
    }
    try {
      final decoded = jsonDecode(statsJson) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, double.parse(v.toString())));
    } catch (e) {
      print('Error reading game stats: $e');
      return {
        'Hafıza': 0.0,
        'Dikkat': 0.0,
        'Refleks': 0.0,
        'Mantık': 0.0,
        'Sayısal Zeka': 0.0,
        'Görsel Algı': 0.0,
        'Dil': 0.0,
      };
    }
  }

  // Oyun zorluk seviyesini kaydet
  static Future<void> saveGameDifficulty(
      String gameId, double difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_gameDifficultyKey}_$gameId';
    await prefs.setDouble(key, difficulty);
  }

  // Oyun zorluk seviyesini getir
  static Future<double> getGameDifficulty(String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_gameDifficultyKey}_$gameId';
    return prefs.getDouble(key) ?? 1.0;
  }

  // Sahte veriler ekle (test amaçlı)
  static Future<void> addMockData() async {
    final now = DateTime.now();
    final mockAttempts = <AttemptModel>[];

    // Son 7 gün için çeşitli oyunlardan attempt'ler
    for (int day = 0; day < 7; day++) {
      final date = now.subtract(Duration(days: day));

      // Her gün 2-4 oyun oynanmış gibi göster
      final gamesPerDay = [2, 3, 4, 2, 3, 4, 3][day];

      for (int i = 0; i < gamesPerDay; i++) {
        // Her seferinde farklı timestamp için milisaniye ekle
        final hour = 10 + (i * 3); // 10:00, 13:00, 16:00, 19:00 gibi
        final minute = (day * 7 + i * 3) % 60; // Farklı dakikalar
        final second = (day * 11 + i * 5) % 60; // Farklı saniyeler
        final gameTime =
            DateTime(date.year, date.month, date.day, hour, minute, second);

        // Farklı oyunlar ve skorlar
        final gameIndex = (day * 2 + i) % MemoryBank.games.length;
        final game = MemoryBank.games[gameIndex];

        // Rastgele ama gerçekçi skorlar
        final baseScore = [
          450,
          680,
          320,
          890,
          550,
          720,
          380,
          650,
          420,
          750,
          580,
          690
        ][gameIndex];
        final scoreVariation = (day * 10 + i * 5) % 200;
        final score = (baseScore + scoreVariation).toDouble();

        final successRate =
            0.5 + (day * 0.05) + (i * 0.03); // Gün geçtikçe iyileşiyor
        final clampedSuccessRate = successRate.clamp(0.4, 0.95);

        final duration =
            [45, 60, 90, 75, 50, 80, 65, 55, 70, 85, 40, 95][gameIndex];
        final difficulty = 1.0 + (day * 0.1) + (i * 0.05);

        mockAttempts.add(AttemptModel(
          gameId: game['id'] as String,
          userId: 'guest',
          score: score,
          successRate: clampedSuccessRate,
          difficulty: difficulty.clamp(1.0, 2.5),
          duration: duration,
          timestamp: gameTime,
          area: game['area'] as String,
        ));
      }
    }

    // Mevcut history'yi al ve sahte verileri ekle
    final existingHistory = await getGameHistory();

    // Tüm yeni attempt'leri ekle (duplicate kontrolü yok, her seferinde yeni veriler)
    for (final attempt in mockAttempts) {
      existingHistory.add(attempt.toMap());
    }

    // History'yi kaydet
    await saveGameHistory(existingHistory);

    // Stats'ı güncelle
    final stats = MemoryBank.calculateRadarStats(existingHistory);
    await saveGameStats(stats);

    print(
        '✅ Sahte veriler eklendi: ${mockAttempts.length} yeni attempt (toplam: ${existingHistory.length})');
  }

  // Tüm oyun geçmişini temizle
  static Future<void> clearGameHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_gameHistoryKey);
    await prefs.remove(_gameStatsKey);
    print('✅ Oyun geçmişi temizlendi');
  }
}
