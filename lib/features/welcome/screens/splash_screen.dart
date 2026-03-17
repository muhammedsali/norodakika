import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../services/local_storage_service.dart';
import '../../settings/providers/language_provider.dart';
import 'onboarding_screen.dart';
import 'welcome_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();

    // 2.5 saniye sonra onboarding kontrol et
    Timer(const Duration(milliseconds: 2500), () async {
      if (!mounted) return;
      final hasSeen = await LocalStorageService.hasSeenOnboarding();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              hasSeen ? const WelcomeScreen() : const OnboardingScreen(),
          transitionsBuilder: (_, anim, __, child) {
            return FadeTransition(opacity: anim, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6);
    final lang = ref.watch(languageProvider);
    final s = AppStrings(lang);

    return Scaffold(
      backgroundColor: bgColor,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF111827),
                        const Color(0xFF1F2937),
                      ]
                    : [
                        const Color(0xFFF3F4F6),
                        Colors.white,
                      ],
              ),
            ),
            child: Center(
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo container
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow efekti
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4F46E5)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 50,
                                  spreadRadius: 15,
                                ),
                              ],
                            ),
                          ),
                          // Ana logo
                          Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF4F46E5),
                                  Color(0xFF7C3AED),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(48),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4F46E5)
                                      .withValues(alpha: 0.5),
                                  blurRadius: 30,
                                  spreadRadius: 8,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.psychology,
                              size: 100,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      // Uygulama adı
                      Text(
                        s.appName,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? const Color(0xFFF9FAFB)
                              : const Color(0xFF111827),
                          letterSpacing: -1.5,
                          shadows: [
                            Shadow(
                              color: const Color(0xFF4F46E5)
                                  .withValues(alpha: 0.3),
                              blurRadius: 25,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Tagline
                      Text(
                        s.splashTagline,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          color: isDark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 64),
                      // Yükleniyor göstergesi
                      const SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
