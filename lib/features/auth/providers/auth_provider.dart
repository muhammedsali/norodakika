import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../core/models/user_model.dart';

// Firebase Auth servis sağlayıcısı
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Firestore servis sağlayıcısı
final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

// Mevcut kullanıcı ID'si (Firebase Auth'dan gelir)
final currentUserProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Kullanıcı verileri (Firestore'dan gelir)
final userDataProvider = FutureProvider<UserModel?>((ref) async {
  final user = ref.watch(currentUserProvider).value;
  if (user != null) {
    return ref.watch(firestoreServiceProvider).getUserData(user.uid);
  }
  return null;
});

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  AuthNotifier(this.ref) : super(const AsyncValue.data(null));
  final Ref ref;

  Future<void> register({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(authServiceProvider).register(email: email, password: password);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(authServiceProvider).login(email: email, password: password);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> logout() async {
    await ref.read(authServiceProvider).logout();
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  return AuthNotifier(ref);
});

