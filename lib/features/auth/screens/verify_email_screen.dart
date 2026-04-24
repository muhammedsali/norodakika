import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/neuron_background.dart';
import '../providers/auth_provider.dart';
import '../../settings/providers/language_provider.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  bool _isSending = false;
  bool _isChecking = false;

  // Zıplayan ikon animasyonu
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;

  // ─── Tema renkleri ─────────────────────────────────────────
  static const Color _bgColor = Color(0xFFF0F4FF);
  static const Color _titleColor = Color(0xFF0F172A);
  static const Color _subColor = Color(0xFF475569);
  static const Color _primaryStart = Color(0xFF0D59F2);
  static const Color _primaryEnd = Color(0xFF7C3AED);
  static const Color _cardBg = Color(0xFFFFFFFF);
  static const Color _cardBorder = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();

    // Aydınlık tema: koyu status bar ikonları
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // Zıplama animasyonu
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _bounceAnim = Tween<double>(begin: 0, end: -12).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    // Her 5 saniyede otomatik kontrol
    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkEmailVerified(silent: true),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bounceController.dispose();
    super.dispose();
  }

  // ─── E-posta doğrulamasını kontrol et ─────────────────────
  Future<void> _checkEmailVerified({bool silent = false}) async {
    if (!silent) setState(() => _isChecking = true);

    final authService = ref.read(authServiceProvider);
    await authService.reloadUser();

    if (authService.currentUser?.emailVerified ?? false) {
      _timer?.cancel();
      // Auth gate'i yenile
      ref.invalidate(currentUserProvider);
    } else if (!silent && mounted) {
      // Kullanıcı butona bastı ama henüz doğrulanmamış
      setState(() => _isChecking = false);
      final lang = ref.read(languageProvider);
      _showSnackBar(
        lang == AppLanguage.tr
            ? 'Henüz doğrulanmamış. Lütfen e-postanı kontrol et.'
            : 'Not verified yet. Please check your email.',
        isError: true,
      );
    }

    if (!silent && mounted) setState(() => _isChecking = false);
  }

  // ─── Yeniden doğrulama e-postası gönder ──────────────────
  Future<void> _resendEmail() async {
    if (_isSending) return;
    setState(() => _isSending = true);

    try {
      await ref.read(authServiceProvider).sendVerificationEmail();
      if (mounted) {
        final lang = ref.read(languageProvider);
        _showSnackBar(
          lang == AppLanguage.tr
              ? 'Doğrulama e-postası tekrar gönderildi.'
              : 'Verification email resent.',
        );
      }
    } catch (e) {
      if (mounted) _showSnackBar(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  // ─── Snackbar yardımcısı ──────────────────────────────────
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor:
            isError ? const Color(0xFFEF4444) : const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final user = ref.watch(currentUserProvider).value;
    final size = MediaQuery.sizeOf(context);

    final isTr = lang == AppLanguage.tr;

    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          // ── Nöron arka planı (aydınlık) ──
          const Positioned.fill(
            child: NeuronBackground(isDarkMode: false),
          ),

          // ── Gradient blob üst sağ ──
          Positioned(
            top: -size.width * 0.25,
            right: -size.width * 0.2,
            child: Container(
              width: size.width * 0.75,
              height: size.width * 0.75,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x330D59F2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Gradient blob alt sol ──
          Positioned(
            bottom: -size.width * 0.2,
            left: -size.width * 0.2,
            child: Container(
              width: size.width * 0.65,
              height: size.width * 0.65,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x257C3AED),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Ana içerik ──
          SafeArea(
            child: Column(
              children: [
                // Üst bar: geri butonu
                _buildTopBar(isTr),

                // Ortadaki kart içeriği
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Zıplayan ikon
                          _buildBouncingIcon(),

                          const SizedBox(height: 36),

                          // Glassmorphism kart
                          _buildInfoCard(user?.email, isTr),

                          const SizedBox(height: 28),

                          // Doğruladım butonu
                          _buildPrimaryButton(isTr),

                          const SizedBox(height: 14),

                          // Yeniden gönder
                          _buildResendButton(isTr),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Üst bar ─────────────────────────────────────────────
  Widget _buildTopBar(bool isTr) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Geri / Çıkış butonu
          IconButton(
            onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
            icon: const Icon(Icons.logout_rounded, size: 22),
            color: _subColor,
            tooltip: isTr ? 'Çıkış Yap' : 'Logout',
          ),
          // Logo
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_primaryStart, _primaryEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    const Icon(Icons.psychology, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                'NöroDakika',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _titleColor,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Zıplayan e-posta ikonu ───────────────────────────────
  Widget _buildBouncingIcon() {
    return AnimatedBuilder(
      animation: _bounceAnim,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _bounceAnim.value),
        child: child,
      ),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36),
          gradient: const LinearGradient(
            colors: [
              Color(0x220D59F2),
              Color(0x227C3AED),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: const Color(0xFF0D59F2).withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0D59F2).withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: const Icon(
          Icons.mark_email_read_rounded,
          size: 60,
          color: Color(0xFF0D59F2),
        ),
      ),
    );
  }

  // ─── Açıklama kartı ──────────────────────────────────────
  Widget _buildInfoCard(String? email, bool isTr) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBg.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _cardBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Başlık
          Text(
            isTr ? 'E-postanı Doğrula' : 'Verify Your Email',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: _titleColor,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 14),

          // E-posta adresi rozeti
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEEF2FF), Color(0xFFF5F3FF)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD1D9FF)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.email_rounded,
                    size: 15, color: Color(0xFF0D59F2)),
                const SizedBox(width: 7),
                Text(
                  email ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0D59F2),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Açıklama
          Text(
            isTr
                ? 'Bu adrese bir doğrulama bağlantısı gönderdik. '
                    'Lütfen e-postanı kontrol et ve linke tıkla.'
                : 'We sent a verification link to this address. '
                    'Please check your email and click the link.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: _subColor,
              height: 1.65,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 16),

          // İpucu kutusu
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: const Color(0xFFFBBF24).withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.tips_and_updates_rounded,
                    size: 18, color: Color(0xFFD97706)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isTr
                        ? 'E-posta gelmezse spam klasörünü kontrol et.'
                        : 'If you don\'t see it, check your spam folder.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF92400E),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Ana buton (Doğruladım) ───────────────────────────────
  Widget _buildPrimaryButton(bool isTr) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_primaryStart, _primaryEnd],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _primaryStart.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isChecking ? null : () => _checkEmailVerified(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: _isChecking
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.verified_rounded, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      isTr ? 'Doğruladım' : "I've Verified",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ─── Yeniden gönder butonu ────────────────────────────────
  Widget _buildResendButton(bool isTr) {
    return TextButton(
      onPressed: _isSending ? null : _resendEmail,
      style: TextButton.styleFrom(
        foregroundColor: _subColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: _cardBorder),
        ),
      ),
      child: _isSending
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.refresh_rounded, size: 16),
                const SizedBox(width: 8),
                Text(
                  isTr ? 'E-postayı Tekrar Gönder' : 'Resend Email',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}
