import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/firestore_service.dart';
import '../../auth/providers/auth_provider.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final userStatsProvider = StreamProvider<Map<String, double>>((ref) async* {
  final user = ref.watch(currentUserProvider).value;
  
  if (user == null) {
    yield {
      'Refleks': 0.0,
      'Dikkat': 0.0,
      'Hafıza': 0.0,
      'Sayısal': 0.0,
      'Mantık': 0.0,
      'Dil': 0.0,
    };
    return;
  }

  final firestoreService = ref.watch(firestoreServiceProvider);
  
  yield* Stream.periodic(const Duration(seconds: 2), (_) async {
    final userData = await firestoreService.getUserData(user.uid);
    if (userData != null && userData.stats.isNotEmpty) {
      return {
        'Refleks': userData.stats['Refleks'] ?? 0.0,
        'Dikkat': userData.stats['Dikkat'] ?? 0.0,
        'Hafıza': userData.stats['Hafıza'] ?? 0.0,
        'Sayısal': userData.stats['Sayısal'] ?? 0.0,
        'Mantık': userData.stats['Mantık'] ?? 0.0,
        'Dil': userData.stats['Dil'] ?? 0.0,
      };
    }
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
