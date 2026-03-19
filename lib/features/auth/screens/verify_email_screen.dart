import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../providers/auth_provider.dart';
import '../../settings/providers/language_provider.dart';
import '../../shared/widgets/radial_gradient_container.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Her 5 saniyede bir doğrulamayı kontrol et
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _checkEmailVerified());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerified() async {
    final authService = ref.read(authServiceProvider);
    await authService.reloadUser();
    
    if (authService.currentUser?.emailVerified ?? false) {
      _timer?.cancel();
      // Auth provider'ı yenile ki AuthGate güncellensin
      ref.invalidate(currentUserProvider);
    }
  }

  Future<void> _resendEmail() async {
    try {
      await ref.read(authServiceProvider).sendVerificationEmail();
      if (mounted) {
        final lang = ref.read(languageProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(lang == AppLanguage.tr 
              ? 'Doğrulama e-postası tekrar gönderildi.' 
              : 'Verification email resent.'))
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      backgroundColor: const Color(0xFF221B26),
      body: Stack(
        children: [
          const Positioned(
            top: -100,
            right: -100,
            child: RadialGradientContainer(
              width: 300,
              height: 300,
              startColor: Color(0x43B379DF),
              endColor: Color(0x00FFFFFF),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.mark_email_read_rounded,
                      size: 100,
                      color: Color(0xFFB379DF),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      lang == AppLanguage.tr ? 'E-postanı Doğrula' : 'Verify Email',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      lang == AppLanguage.tr 
                          ? '${user?.email} adresine bir doğrulama e-postası gönderdik. Devam etmek için lütfen e-postandaki linke tıkla.'
                          : 'We sent a verification email to ${user?.email}. Please click the link in the email to continue.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton(
                      onPressed: _checkEmailVerified,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB379DF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        lang == AppLanguage.tr ? 'Doğruladım' : "I've Verified",
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _resendEmail,
                      child: Text(
                        lang == AppLanguage.tr ? 'E-postayı Tekrar Gönder' : 'Resend Email',
                        style: GoogleFonts.inter(color: Colors.white54),
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextButton(
                      onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
                      child: Text(
                        lang == AppLanguage.tr ? 'Çıkış Yap' : 'Logout',
                        style: GoogleFonts.inter(color: const Color(0xFFD25A63)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
