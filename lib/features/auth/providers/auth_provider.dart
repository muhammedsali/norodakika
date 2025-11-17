import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/local_storage_service.dart';
import '../../../core/models/user_model.dart';
import '../../../core/memory/memory_bank.dart';

final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, String?>((ref) {
  return CurrentUserNotifier();
});

class CurrentUserNotifier extends StateNotifier<String?> {
  CurrentUserNotifier() : super(null) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await LocalStorageService.getCurrentUser();
    state = user;
  }

  void setUser(String? email) {
    state = email;
  }
}

final userDataProvider = FutureProvider.family<UserModel?, String>((ref, email) async {
  return await LocalStorageService.getUserData(email);
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
      await LocalStorageService.saveUser(email, password);
      
      // Kullanıcı modelini oluştur
      final userModel = UserModel.fromJson(MemoryBank.createUserModel(email));
      await LocalStorageService.saveUserData(userModel);
      
      ref.read(currentUserProvider.notifier).setUser(email);
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
      final success = await LocalStorageService.login(email, password);
      if (success) {
        ref.read(currentUserProvider.notifier).setUser(email);
        state = const AsyncValue.data(null);
      } else {
        state = AsyncValue.error('Geçersiz e-posta veya şifre', StackTrace.current);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> logout() async {
    await LocalStorageService.logout();
    ref.read(currentUserProvider.notifier).setUser(null);
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  return AuthNotifier(ref);
});

