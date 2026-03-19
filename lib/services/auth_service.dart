import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/models/user_model.dart';
import '../core/memory/memory_bank.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // google_sign_in v6.x: normal constructor, clientId gerekmez Android'de
  // Android için SHA-1/SHA-256 Firebase Console'da kayıtlı olmalı
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Mevcut kullanıcıyı al
  User? get currentUser => _auth.currentUser;

  // Stream: Kullanıcı durumu değişikliklerini dinle
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Kayıt Ol ──────────────────────────────────────────────
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // İsmi Firebase Auth profiline ekle
        await user.updateDisplayName(name);
        
        // E-posta doğrulama gönder
        await user.sendEmailVerification();

        try {
          final userModel =
              UserModel.fromJson(MemoryBank.createUserModel(user.uid));
          await _firestore
              .collection('users')
              .doc(user.uid)
              .set(userModel.toJson());
        } catch (e) {
          debugPrint('Uyarı: Profil veritabanına yazılamadı: $e');
        }
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (_auth.currentUser != null) return;
      throw 'Bir hata oluştu: $e';
    }
  }

  // ── Doğrulama E-postası Gönder ────────────────────────────
  Future<void> sendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Doğrulama e-postası gönderilemedi: $e';
    }
  }

  // ── Kullanıcıyı Yeniden Yükle (Doğrulama Kontrolü İçin) ──
  Future<void> reloadUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
      }
    } catch (e) {
      debugPrint('Kullanıcı yenileme hatası: $e');
    }
  }

  // ── Giriş Yap ─────────────────────────────────────────────
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

  // ── Google ile Giriş / Kayıt ──────────────────────────────
  Future<void> signInWithGoogle() async {
    try {
      // Google hesap seçici aç
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Kullanıcı iptal etti
      if (googleUser == null) return;

      // Token'ları al
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Firebase credential oluştur
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase'e giriş yap
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;
      if (user == null) return;

      // Firestore'da yoksa profil oluştur
      try {
        final docRef = _firestore.collection('users').doc(user.uid);
        final snapshot = await docRef.get();
        if (!snapshot.exists) {
          final userModel =
              UserModel.fromJson(MemoryBank.createUserModel(user.uid));
          await docRef.set(userModel.toJson());
        }
      } catch (e) {
        debugPrint('Uyarı: Google profil veritabanına yazılamadı: $e');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      final msg = e.toString();
      // Kullanıcı kendi iptal ettiyse sessizce geç
      if (msg.contains('sign_in_canceled') ||
          msg.contains('canceled') ||
          msg.contains('cancel')) {
        return;
      }
      throw 'Google ile giriş yapılamadı: $e';
    }
  }

  // ── Çıkış Yap ─────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  // ── Hesap Sil ─────────────────────────────────────────────
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        try {
          await _firestore.collection('users').doc(user.uid).delete();
        } catch (e) {
          debugPrint('Uyarı: Firestore veri silinemedi: $e');
        }

        await user.delete();

        try {
          await _googleSignIn.signOut();
        } catch (_) {}
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw 'Hesabınızı silmek için güvenlik nedeniyle yeniden giriş yapmalısınız.';
      }
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Hesap silinemedi: $e';
    }
  }

  // ── Hata Mesajları ────────────────────────────────────────
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Şifre çok zayıf. En az 6 karakter kullanın.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanımda.';
      case 'user-not-found':
        return 'Kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Hatalı şifre.';
      case 'invalid-email':
        return 'Geçersiz e-posta formatı.';
      case 'invalid-credential':
        return 'Geçersiz e-posta veya şifre.';
      case 'too-many-requests':
        return 'Çok fazla hatalı deneme. Lütfen bir süre bekleyin.';
      case 'network-request-failed':
        return 'İnternet bağlantısı yok. Bağlantınızı kontrol edin.';
      case 'account-exists-with-different-credential':
        return 'Bu e-posta başka bir yöntemle kayıtlı.';
      default:
        return 'Hata: ${e.message ?? e.code}';
    }
  }
}
