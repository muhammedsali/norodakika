import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../core/models/user_model.dart';

// İsteğe bağlı özel kullanıcı ismi
final customNameProvider = FutureProvider<String?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('custom_display_name');
});

// Firebase Auth servis sağlayıcısı
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Firestore servis sağlayıcısı
final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

// Mevcut kullanıcı (Firebase Auth stream)
final currentUserProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Kullanıcı verileri - Stream (Firestore realtime)
// Kullanıcı giriş yaptığında otomatik güncellenecek
final userDataProvider = StreamProvider<UserModel?>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final user = userAsync.value;

  if (user == null) {
    return Stream.value(null);
  }

  return ref.watch(firestoreServiceProvider).watchUserData(user.uid);
});

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  AuthNotifier(this.ref) : super(const AsyncValue.data(null));
  final Ref ref;

  Future<void> updateCustomName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_display_name', newName);
    ref.invalidate(customNameProvider);
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      await updateCustomName(name);
      await ref.read(authServiceProvider).register(
            name: name,
            email: email,
            password: password,
          );
      
      final user = ref.read(authServiceProvider).currentUser;
      if (user != null) {
        await ref.read(authServiceProvider).syncDisplayName(user);
      }
      
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
      await ref.read(authServiceProvider).login(
            email: email,
            password: password,
          );
      
      final user = ref.read(authServiceProvider).currentUser;
      if (user != null) {
        await ref.read(authServiceProvider).syncDisplayName(user);
      }

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
      
      final user = ref.read(authServiceProvider).currentUser;
      if (user != null) {
        await ref.read(authServiceProvider).syncDisplayName(user);
      }

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await ref.read(authServiceProvider).logout();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  return AuthNotifier(ref);
});
