import 'dart:convert';
import 'package:http/http.dart' as http;
import '../memory/memory_bank.dart';
import '../models/attempt_model.dart';

class ApiService {
  static const String baseUrl = 'https://api.norodakika.com'; // TODO: Gerçek API URL'i

  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String uid,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl${MemoryBank.api['register']}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'uid': uid,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Kayıt başarısız: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl${MemoryBank.api['login']}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Giriş başarısız: ${response.statusCode}');
    }
  }

  static Future<void> submitAttempt(AttemptModel attempt) async {
    final response = await http.post(
      Uri.parse('$baseUrl${MemoryBank.api['attempt']}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(attempt.toMap()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Attempt gönderimi başarısız: ${response.statusCode}');
    }
  }

  static Future<List<Map<String, dynamic>>> getHistory(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl${MemoryBank.api['history']}?userId=$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Geçmiş verisi alınamadı: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> getStats(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl${MemoryBank.api['stats']}?userId=$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('İstatistik verisi alınamadı: ${response.statusCode}');
    }
  }

  static Future<List<Map<String, dynamic>>> getDailyPlan(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl${MemoryBank.api['dailyPlan']}?userId=$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      // API'den gelmezse MemoryBank'tan üret
      return MemoryBank.generateDailyPlan();
    }
  }
}

