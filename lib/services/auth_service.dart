import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/models/user_model.dart';
import '../core/memory/memory_bank.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mevcut kullanıcıyı al
  User? get currentUser => _auth.currentUser;

  // Stream: Kullanıcı durumu değişikliklerini dinle
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Kayıt Ol
  Future<void> register({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Auth ile kullanıcı oluştur
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // 2. Firestore'da kullanıcı dokümanı oluştur
        final userModel = UserModel.fromJson(MemoryBank.createUserModel(user.uid));
        // Email'i de modele ekleyelim (UserModel'de email alanı varsa)
        // Şimdilik sadece UID ile oluşturuyoruz, gerekirse UserModel güncellenmeli
        
        await _firestore.collection('users').doc(user.uid).set(userModel.toJson());
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Bir hata oluştu: $e';
    }
  }

  // Giriş Yap
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Giriş yapılamadı: $e';
    }
  }

  // Çıkış Yap
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Hata Mesajları
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Şifre çok zayıf.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanımda.';
      case 'user-not-found':
        return 'Kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Hatalı şifre.';
      case 'invalid-email':
        return 'Geçersiz e-posta formatı.';
      default:
        return 'Bir hata oluştu: ${e.message}';
    }
  }
}
