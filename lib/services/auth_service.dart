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
