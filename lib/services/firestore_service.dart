import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/models/user_model.dart';
import '../core/models/attempt_model.dart';
import '../core/memory/memory_bank.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Koleksiyon referansları
  CollectionReference get _usersCollection => _firestore.collection('users');

  // Kullanıcı verilerini getir
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Kullanıcı verilerini kaydet/güncelle
  Future<void> saveUserData(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).set(user.toJson(), SetOptions(merge: true));
    } catch (e) {
      print('Error saving user data: $e');
      throw 'Veriler kaydedilemedi.';
    }
  }

  // Attempt (Oyun denemesi) kaydet
  Future<void> saveAttempt(AttemptModel attempt) async {
    try {
      // 1. Kullanıcıyı getir
      final user = await getUserData(attempt.userId);
      if (user != null) {
        // 2. Geçmişe ekle
        final updatedHistory = [...user.history, attempt.toMap()];
        
        // 3. İstatistikleri güncelle
        final updatedStats = Map<String, double>.from(user.stats);
        final radarStats = MemoryBank.calculateRadarStats(updatedHistory);
        updatedStats.addAll(radarStats);
        
        // 4. Modeli güncelle
        final updatedUser = user.copyWith(
          history: updatedHistory,
          stats: updatedStats,
        );
        
        // 5. Firestore'a yaz
        await saveUserData(updatedUser);
        
        // Opsiyonel: Attempts'leri ayrı bir subcollection olarak da tutabiliriz
        // Bu, sorgulama esnekliği sağlar
        await _usersCollection
            .doc(attempt.userId)
            .collection('attempts')
            .add(attempt.toMap());
      }
    } catch (e) {
      print('Error saving attempt: $e');
      throw 'Oyun sonucu kaydedilemedi.';
    }
  }
  
  // Oyun zorluk seviyesini getir
  Future<double> getGameDifficulty({
    required String userId,
    required String gameId,
  }) async {
    try {
      final doc = await _usersCollection
          .doc(userId)
          .collection('game_states')
          .doc(gameId)
          .get();
      
      if (doc.exists && doc.data() != null) {
        return (doc.data() as Map<String, dynamic>)['difficulty']?.toDouble() ?? 1.0;
      }
      return 1.0;
    } catch (e) {
      print('Error getting game difficulty: $e');
      return 1.0;
    }
  }

  // Oyun zorluk seviyesini güncelle
  Future<void> updateGameDifficulty({
    required String userId,
    required String gameId,
    required double newDifficulty,
  }) async {
    try {
      await _usersCollection
          .doc(userId)
          .collection('game_states')
          .doc(gameId)
          .set({
            'difficulty': newDifficulty,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating game difficulty: $e');
    }
  }
}
