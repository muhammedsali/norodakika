import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/neuron_background.dart';
import '../models/onboarding_page_model.dart';
import '../providers/onboarding_provider.dart';
import 'welcome_screen.dart';

// ─── Onboarding Ekranı (Saf UI) ───────────────────────────
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();

  // İçerik animasyonu
  late AnimationController _contentController;
  late Animation<double> _contentFade;
  late Animation<double> _contentScale;

  // İkon pulse animasyonu
  late AnimationController _pulseController;
  late Animation<double> _pulseScale;

  // ─── Aydınlık tema renk sabitleri ─────────────────────────
  static const Color _bgColor       = Color(0xFFF0F4FF);
  static const Color _titleColor    = Color(0xFF0F172A);
  static const Color _subtitleColor = Color(0xFF475569);
  static const Color _chipBg        = Color(0xFFE8EEFF);
  static const Color _chipBorder    = Color(0xFFD1D9FF);
  static const Color _chipText      = Color(0xFF334155);
  static const Color _dotInactive   = Color(0xFFCBD5E1);
  static const Color _progressBg    = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();

    // Aydınlık tema: koyu ikonlar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // İçerik animasyon controller'ı
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _contentScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    // İkon pulse animasyonu
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _contentController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _contentController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // Sayfa değiştiğinde provider'ı güncelle ve animasyonu yenile
  void _onPageChanged(int index) {
    ref.read(onboardingProvider.notifier).changePage(index);
    _contentController.reset();
    _contentController.forward();
  }

  // PageView'ı ilerlet veya tamamlandıysa welcome'a geç
  void _next(OnboardingState state) {
    if (!state.isLastPage) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubicEmphasized,
      );
    } else {
      _goToWelcome();
    }
  }

  // Onboarding'i tamamla ve WelcomeScreen'e yönlendir
  Future<void> _goToWelcome() async {
    await ref.read(onboardingProvider.notifier).markAsSeen();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const WelcomeScreen(),
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, animation, __, child) {
          // Fade + zoom-in geçiş efekti
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutExpo,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.05, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final page = state.currentPageData;
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          // ── Sinapsis/Nöron Arka Planı (aydınlık mod) ──
          const Positioned.fill(
            child: NeuronBackground(isDarkMode: false),
          ),

          // ── Gradient blob üst sol ──
          Positioned(
            top: -size.width * 0.3,
            left: -size.width * 0.2,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeInOut,
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    page.gradientColors[0].withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Gradient blob alt sağ ──
          Positioned(
            bottom: -size.width * 0.2,
            right: -size.width * 0.2,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeInOut,
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    page.gradientColors[1].withValues(alpha: 0.2),
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
                // Üst bar
                _buildTopBar(page),

                // Sayfa içerikleri
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: state.pageCount,
                    itemBuilder: (_, index) {
                      final p = state.pages[index];
                      // Sadece aktif sayfada scale+fade animasyonu çalışsın
                      if (index == state.currentPage) {
                        return FadeTransition(
                          opacity: _contentFade,
                          child: ScaleTransition(
                            scale: _contentScale,
                            child: _buildPageContent(p, state),
                          ),
                        );
                      }
                      return _buildPageContent(p, state);
                    },
                  ),
                ),

                // Alt bar (dots + buton)
                _buildBottomBar(state, page),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Üst bar: Logo + Atla ────────────────────────────────
  Widget _buildTopBar(OnboardingPageModel page) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: page.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'NöroDakika',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _titleColor,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          // Atla butonu
          TextButton(
            onPressed: _goToWelcome,
            style: TextButton.styleFrom(
              foregroundColor: _subtitleColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
            ),
            child: Text(
              'Atla',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Alt bar: Nokta göstergesi + İleri butonu ─────────────
  Widget _buildBottomBar(OnboardingState state, OnboardingPageModel page) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Nokta indikatörleri
          Row(
            children: List.generate(state.pageCount, (i) {
              final isActive = i == state.currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOutCubic,
                margin: const EdgeInsets.only(right: 6),
                width: isActive ? 32 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isActive ? page.accentColor : _dotInactive,
                ),
              );
            }),
          ),

          // İleri / Başla butonu
          GestureDetector(
            onTap: () => _next(state),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              width: state.isLastPage ? 160 : 64,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: page.gradientColors,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: page.accentColor.withValues(alpha: 0.45),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: state.isLastPage
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Başla',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ],
                      )
                    : const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tek sayfa içeriği ────────────────────────────────────
  Widget _buildPageContent(OnboardingPageModel p, OnboardingState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),

          // Sayfa etiketi (01 — GİRİŞ vs.)
          _buildTag(p),

          const SizedBox(height: 32),

          // Pulse animasyonlu ikon kartı
          _buildIconCard(p),

          const SizedBox(height: 36),

          // Başlık (normal + gradient kısım)
          _buildTitle(p),

          const SizedBox(height: 20),

          // Alt açıklama
          Text(
            p.subtitle,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: _subtitleColor,
              height: 1.65,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 32),

          // Özellik chip'leri
          _buildChips(p),

          const Spacer(),

          // İlerleme çubuğu
          _buildProgressBar(p, state),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ─── Yardımcı widget: Etiket ──────────────────────────────
  Widget _buildTag(OnboardingPageModel p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: p.accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.accentColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        p.tag,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: p.accentColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // ─── Yardımcı widget: Pulse ikon kartı ───────────────────
  Widget _buildIconCard(OnboardingPageModel p) {
    return ScaleTransition(
      scale: _pulseScale,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              p.gradientColors[0].withValues(alpha: 0.15),
              p.gradientColors[1].withValues(alpha: 0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: p.accentColor.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
        child: Icon(p.icon, size: 52, color: p.accentColor),
      ),
    );
  }

  // ─── Yardımcı widget: Gradient başlık ────────────────────
  Widget _buildTitle(OnboardingPageModel p) {
    return RichText(
      text: TextSpan(
        text: p.title,
        style: GoogleFonts.inter(
          fontSize: 44,
          fontWeight: FontWeight.w900,
          color: _titleColor,
          height: 1.05,
          letterSpacing: -1.5,
        ),
        children: [
          TextSpan(
            text: p.highlight,
            style: GoogleFonts.inter(
              fontSize: 44,
              fontWeight: FontWeight.w900,
              foreground: Paint()
                ..shader = LinearGradient(
                  colors: p.gradientColors,
                ).createShader(
                  const Rect.fromLTWH(0, 0, 200, 60),
                ),
              height: 1.05,
              letterSpacing: -1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Yardımcı widget: Özellik chip'leri ──────────────────
  Widget _buildChips(OnboardingPageModel p) {
    return Row(
      children: p.chips.map((chip) {
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _chipBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _chipBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(chip.icon, size: 15, color: p.accentColor),
                const SizedBox(width: 7),
                Text(
                  chip.label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _chipText,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Yardımcı widget: İnce ilerleme çubuğu ───────────────
  Widget _buildProgressBar(OnboardingPageModel p, OnboardingState state) {
    final progress = (state.currentPage + 1) / state.pageCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Adım ${state.currentPage + 1} / ${state.pageCount}',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _subtitleColor.withValues(alpha: 0.6),
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: p.accentColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: _progressBg,
            valueColor: AlwaysStoppedAnimation<Color>(p.accentColor),
            minHeight: 3,
          ),
        ),
      ],
    );
  }
}
