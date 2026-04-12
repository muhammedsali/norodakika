import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/firestore_service.dart';
import '../../../services/local_storage_service.dart';
import '../../auth/providers/auth_provider.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final userStatsProvider = StreamProvider<Map<String, double>>((ref) async* {
  final user = ref.watch(currentUserProvider).value;
  
  // Başlangıçta 0 verisi gönder
  yield {
    'Refleks': 0.0,
    'Dikkat': 0.0,
    'Hafıza': 0.0,
    'Sayısal': 0.0,
    'Mantık': 0.0,
    'Dil': 0.0,
  };
  
  if (user == null) {
    return;
  }

  final firestoreService = ref.watch(firestoreServiceProvider);
  
  yield* Stream.periodic(const Duration(seconds: 2), (_) async {
    try {
      final userData = await firestoreService.getUserData(user.uid);
      if (userData != null && userData.stats.isNotEmpty) {
        final hasRealData = userData.stats.values.any((value) => value > 0);
        if (hasRealData) {
          return {
            'Refleks': userData.stats['Refleks'] ?? 0.0,
            'Dikkat': userData.stats['Dikkat'] ?? 0.0,
            'Hafıza': userData.stats['Hafıza'] ?? 0.0,
            'Sayısal': userData.stats['Sayısal'] ?? 0.0,
            'Mantık': userData.stats['Mantık'] ?? 0.0,
            'Dil': userData.stats['Dil'] ?? 0.0,
          };
        }
      }
    } catch (e) {
      debugPrint('Firestore stats okuma hatası: $e');
    }
    
    // Firestore verisi gelmediyse LocalStorage'a bak
    try {
      final localStats = await LocalStorageService.getGameStats();
      if (localStats.values.any((v) => v > 0)) {
        return localStats;
      }
    } catch (e) {
      debugPrint('Local stats okuma hatası: $e');
    }

    // Gerçek veri yoksa 0 göster
    return {
      'Refleks': 0.0,
      'Dikkat': 0.0,
      'Hafıza': 0.0,
      'Sayısal': 0.0,
      'Mantık': 0.0,
      'Dil': 0.0,
    };
  }).asyncMap((future) => future);
});

final todayGameCountProvider = StreamProvider<int>((ref) async* {
  final user = ref.watch(currentUserProvider).value;

  if (user == null) {
    // Giriş yapılmadıysa en azından lokal veriyi kontrol et
    final localHistory = await LocalStorageService.getGameHistory();
    // compute offline count
    final count = _calculateTodayGames(localHistory);
    yield count;
    return;
  }

  final firestoreService = ref.watch(firestoreServiceProvider);

  yield* Stream.periodic(const Duration(seconds: 2), (_) async {
    List<dynamic> history = [];
    try {
      final userData = await firestoreService.getUserData(user.uid);
      if (userData != null) {
        history = userData.history;
      }
    } catch (e) {
      // sessizce geçilecek
    }

    if (history.isEmpty) {
      try {
        history = await LocalStorageService.getGameHistory();
      } catch (e) {
        // sessizce geç
      }
    }

    return _calculateTodayGames(history);
  }).asyncMap((future) => future);
});

int _calculateTodayGames(List<dynamic> history) {
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  int count = 0;

  for (var h in history) {
    if (h is Map && h['timestamp'] != null) {
      try {
        DateTime ts;
        final rawTime = h['timestamp'];

        if (rawTime is DateTime) {
          ts = rawTime;
        } else if (rawTime.runtimeType.toString() == 'Timestamp') {
          ts = (rawTime as dynamic).toDate();
        } else {
          ts = DateTime.parse(rawTime.toString());
        }

        if (ts.isAfter(todayStart.subtract(const Duration(seconds: 1))) &&
            ts.isBefore(now.add(const Duration(days: 1)))) {
          count++;
        }
      } catch (_) {}
    }
  }
  return count;
}
