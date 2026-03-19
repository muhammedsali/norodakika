import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../home/screens/home_screen.dart';
import 'verify_email_screen.dart';
import '../../welcome/screens/welcome_screen.dart';

class AuthGateScreen extends ConsumerStatefulWidget {
  const AuthGateScreen({super.key});

  @override
  ConsumerState<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends ConsumerState<AuthGateScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(currentUserProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const WelcomeScreen();
        } else {
          // İsmi Firestore ile senkronize et (Eski kullanıcılar için bir kerelik)
          final authService = ref.read(authServiceProvider);
          authService.syncDisplayName(user);

          // E-posta doğrulamasını kontrol et
          if (!user.emailVerified) {
            return const VerifyEmailScreen();
          }
          
          return const HomeScreen();
        }
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Bir hata oluştu: $error'),
        ),
      ),
    );
  }
}

