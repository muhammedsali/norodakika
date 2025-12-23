import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/firestore_service.dart';
import '../../auth/providers/auth_provider.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final userStatsProvider = StreamProvider<Map<String, double>>((ref) async* {
  final user = ref.watch(currentUserProvider).value;
  
  // Sahte veri - Demo amaçlı
  yield {
    'Refleks': 75.0,
    'Dikkat': 62.0,
    'Hafıza': 88.0,
    'Sayısal': 54.0,
    'Mantık': 70.0,
    'Dil': 45.0,
  };
  
  if (user == null) {
    return;
  }

  final firestoreService = ref.watch(firestoreServiceProvider);
  
  yield* Stream.periodic(const Duration(seconds: 2), (_) async {
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
    // Gerçek veri yoksa sahte veriyi göster
    return {
      'Refleks': 75.0,
      'Dikkat': 62.0,
      'Hafıza': 88.0,
      'Sayısal': 54.0,
      'Mantık': 70.0,
      'Dil': 45.0,
    };
  }).asyncMap((future) => future);
});
