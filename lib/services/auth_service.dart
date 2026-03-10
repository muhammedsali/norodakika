import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/models/user_model.dart';
import '../core/memory/memory_bank.dart';
import '../main.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // google_sign_in 7.x: singleton + initialize() gerekiyor
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleInitialized = false;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    if (googleServerClientId.isNotEmpty) {
      await _googleSignIn.initialize(serverClientId: googleServerClientId);
    }
    _googleInitialized = true;
  }

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
        // Not: Firestore yazma işlemi başarısız olsa bile kayıt (Auth) başarılı sayılmalı.
        // Bu yüzden burayı ayrı bir try-catch bloğuna alıyoruz.
        try {
          final userModel = UserModel.fromJson(MemoryBank.createUserModel(user.uid));
          await _firestore.collection('users').doc(user.uid).set(userModel.toJson());
        } catch (e) {
          // Firestore hatası kritik değil, kullanıcı giriş yapabilir.
          // Sadece logluyoruz.
          print('Uyarı: Profil veritabanına yazılamadı: $e');
        }
      }
    } on FirebaseAuthException catch (e) {
      // Eğer hata "email-already-in-use" ise ve kullanıcı aslında giriş yapmış durumdaysa
      // hatayı görmezden gelebiliriz ama bu durumda giriş yapmış olması beklenmez.
      // Sadece genel hata durumunda kullanıcı kontrolü yapmak daha güvenli.
      throw _handleAuthException(e);
    } catch (e) {
      // Kritik Hata Kontrolü:
      // Eğer bir hata oluştuysa (örn: network timeout) ama kullanıcı aslında oluşturulduysa,
      // işlemi başarısız saymak yerine başarılı kabul et.
      if (_auth.currentUser != null) {
        print('Register sırasında hata fırlatıldı ancak kullanıcı başarıyla oluşturulmuş: $e');
        return;
      }
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

  // Google ile giriş / kayıt
  Future<void> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();

      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return;

      // Firestore'da kullanıcı dokümanı yoksa oluştur
      try {
        final docRef = _firestore.collection('users').doc(user.uid);
        final snapshot = await docRef.get();
        if (!snapshot.exists) {
          final userModel =
              UserModel.fromJson(MemoryBank.createUserModel(user.uid));
          await docRef.set(userModel.toJson());
        }
      } catch (e) {
        // Kritik değil: kullanıcı Auth ile giriş yapmış olabilir
        print('Uyarı: Google profil veritabanına yazılamadı: $e');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return;
      }
      throw 'Google ile giriş yapılamadı: $e';
    } catch (e) {
      throw 'Google ile giriş yapılamadı: $e';
    }
  }

  // Çıkış Yap
  Future<void> logout() async {
    // Google ile giriş yapıldıysa oturumu da kapat
    try {
      await _ensureGoogleInitialized();
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  // Hesap Sil
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // First delete from Firestore
        try {
          await _firestore.collection('users').doc(user.uid).delete();
        } catch(e) {
          print('Uyarı: Firestore veri silinemedi: $e');
        }
        
        // Then delete the Firebase Auth user
        await user.delete();
        
        // Sign out from Google if needed
        try {
          await _ensureGoogleInitialized();
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
