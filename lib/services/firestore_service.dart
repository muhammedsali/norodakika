import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/models/user_model.dart';
import '../core/models/attempt_model.dart';
import '../core/memory/memory_bank.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _usersCollection => _firestore.collection('users');

  // ── Kullanıcı verilerini getir (tek seferlik) ──────────────
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('getUserData hatası: $e');
      return null;
    }
  }

  // ── Kullanıcı verisini stream olarak dinle (realtime) ──────
  Stream<UserModel?> watchUserData(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        try {
          return UserModel.fromJson(doc.data() as Map<String, dynamic>);
        } catch (e) {
          debugPrint('watchUserData parse hatası: $e');
          return null;
        }
      }
      return null;
    });
  }

  // ── Kullanıcı verilerini kaydet/güncelle ───────────────────
  Future<void> saveUserData(UserModel user) async {
    try {
      await _usersCollection
          .doc(user.uid)
          .set(user.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('saveUserData hatası: $e');
      throw 'Veriler kaydedilemedi.';
    }
  }

  // ── Oyun denemesini kaydet ─────────────────────────────────
  // FieldValue.arrayUnion kullanarak race condition önlenir
  Future<void> saveAttempt(AttemptModel attempt) async {
    try {
      final userDoc = _usersCollection.doc(attempt.userId);
      final attemptMap = attempt.toMap();

      // 1. Attempts subcollection'a kaydet (hızlı yol)
      await userDoc.collection('attempts').add(attemptMap);

      // 2. Ana user dokümanını güncelle — atomik işlem
      // Önce dokümanı oku, sonra istatistikleri hesapla
      final snapshot = await userDoc.get();

      if (!snapshot.exists) {
        // Kullanıcı dokümanı yoksa oluştur (Google Sign-In edge case)
        final newUser = UserModel.fromJson(
          MemoryBank.createUserModel(attempt.userId),
        );
        final updatedUser = newUser.copyWith(
          history: [attemptMap],
          stats: MemoryBank.calculateRadarStats([attemptMap]),
        );
        await userDoc.set(updatedUser.toJson());
        return;
      }

      final userData = UserModel.fromJson(
        snapshot.data() as Map<String, dynamic>,
      );

      // Mevcut history'ye ekle
      final updatedHistory = [...userData.history, attemptMap];

      // Radar istatistiklerini yeniden hesapla
      final newStats = MemoryBank.calculateRadarStats(updatedHistory);

      // Firestore'a yaz (merge ile güvenli)
      await userDoc.update({
        'history': FieldValue.arrayUnion([attemptMap]),
        'stats': newStats,
      });
    } catch (e) {
      debugPrint('saveAttempt hatası: $e');
      throw 'Oyun sonucu kaydedilemedi: $e';
    }
  }

  // ── Oyun zorluk seviyesini getir ──────────────────────────
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
        return (doc.data() as Map<String, dynamic>)['difficulty']
                ?.toDouble() ??
            1.0;
      }
      return 1.0;
    } catch (e) {
      debugPrint('getGameDifficulty hatası: $e');
      return 1.0;
    }
  }

  // ── Oyun zorluk seviyesini güncelle ───────────────────────
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
      debugPrint('updateGameDifficulty hatası: $e');
    }
  }

  // ── Son N oyun geçmişini getir (Subcollection'dan) ────────
  Future<List<Map<String, dynamic>>> getRecentAttempts({
    required String userId,
    int limit = 50,
  }) async {
    try {
      final snapshot = await _usersCollection
          .doc(userId)
          .collection('attempts')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => doc.data())
          .toList();
    } catch (e) {
      debugPrint('getRecentAttempts hatası: $e');
      return [];
    }
  }

  // ── Tüm Kullanıcıları Küresel Sıralama İçin Getir ────────
  Future<List<Map<String, dynamic>>> getLeaderboardUsers() async {
    try {
      final snapshot = await _usersCollection.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        data['uid'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('getLeaderboardUsers hatası: $e');
      return [];
    }
  }
}
