import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/firebase_service.dart';
import '../../../core/models/user_model.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

final userDataProvider = FutureProvider.family<UserModel?, String>((ref, uid) async {
  return await FirebaseService.getUserData(uid);
});

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  AuthNotifier() : super(const AsyncValue.data(null));

  Future<void> register({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      await FirebaseService.registerWithEmail(
        email: email,
        password: password,
      );
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
      await FirebaseService.loginWithEmail(
        email: email,
        password: password,
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> logout() async {
    await FirebaseService.logout();
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  return AuthNotifier();
});

