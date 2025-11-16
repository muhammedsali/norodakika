import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/models/user_model.dart';
import '../core/models/attempt_model.dart';
import '../core/memory/memory_bank.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Kullanıcı işlemleri
  static Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Kullanıcı modelini oluştur ve Firestore'a kaydet
    if (credential.user != null) {
      final userModel = MemoryBank.createUserModel(credential.user!.uid);
      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userModel);
    }

    return credential;
  }

  static Future<UserCredential> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }

  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Kullanıcı verilerini getir
  static Future<UserModel?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  // Kullanıcı verilerini güncelle
  static Future<void> updateUserData(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(
          user.toFirestore(),
          SetOptions(merge: true),
        );
  }

  // Attempt kaydet
  static Future<void> saveAttempt(AttemptModel attempt) async {
    await _firestore.collection('attempts').add(attempt.toMap());

    // Kullanıcının history'sine ekle
    final userDoc = _firestore.collection('users').doc(attempt.userId);
    final userData = await userDoc.get();
    
    if (userData.exists) {
      final user = UserModel.fromFirestore(userData);
      final updatedHistory = [...user.history, attempt.toMap()];
      
      // Stats'ı güncelle
      final updatedStats = Map<String, double>.from(user.stats);
      final radarStats = MemoryBank.calculateRadarStats(updatedHistory);
      updatedStats.addAll(radarStats);
      
      await userDoc.update({
        'history': updatedHistory,
        'stats': updatedStats,
      });
    }
  }

  // Zorluk seviyesini güncelle
  static Future<void> updateGameDifficulty({
    required String userId,
    required String gameId,
    required double newDifficulty,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('games')
        .doc(gameId)
        .set({
      'difficulty': newDifficulty,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Oyun zorluk seviyesini getir
  static Future<double> getGameDifficulty({
    required String userId,
    required String gameId,
  }) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('games')
        .doc(gameId)
        .get();
    
    if (doc.exists && doc.data() != null) {
      return (doc.data()!['difficulty'] as num?)?.toDouble() ?? 1.0;
    }
    return 1.0; // Varsayılan zorluk
  }

  // Günlük planı kaydet
  static Future<void> saveDailyPlan({
    required String userId,
    required List<Map<String, dynamic>> plan,
  }) async {
    await _firestore.collection('users').doc(userId).update({
      'dailyPlan': plan,
      'dailyPlanUpdatedAt': FieldValue.serverTimestamp(),
    });
  }
}

