
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/neuron_background.dart';
import '../../../services/local_storage_service.dart';
import 'welcome_screen.dart';

// ─── Onboarding Sayfa Verisi ───────────────────────────────
class _PageData {
  final IconData icon;
  final String tag;
  final String title;
  final String highlight; // Başlıktaki renkli kısım
  final String subtitle;
  final List<Color> gradientColors;
  final Color accentColor;
  final List<_FeatureChip> chips;

  const _PageData({
    required this.icon,
    required this.tag,
    required this.title,
    required this.highlight,
    required this.subtitle,
    required this.gradientColors,
    required this.accentColor,
    required this.chips,
  });
}

class _FeatureChip {
  final IconData icon;
  final String label;
  const _FeatureChip(this.icon, this.label);
}

// ─── Ana Widget ───────────────────────────────────────────
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // İçerik animasyonu için controller
  late AnimationController _contentController;
  late Animation<double> _contentFade;
  late Animation<double> _contentScale;

  // İkon pulse animasyonu
  late AnimationController _pulseController;
  late Animation<double> _pulseScale;


  // ─── Aydınlık tema renk sabitleri ──────────────────────
  static const Color _bgColor       = Color(0xFFF0F4FF);
  static const Color _titleColor    = Color(0xFF0F172A);
  static const Color _subtitleColor = Color(0xFF475569);
  static const Color _chipBg        = Color(0xFFE8EEFF);
  static const Color _chipBorder    = Color(0xFFD1D9FF);
  static const Color _chipText      = Color(0xFF334155);
  static const Color _dotInactive   = Color(0xFFCBD5E1);
  static const Color _progressBg    = Color(0xFFE2E8F0);

  static const List<_PageData> _pages = [
    _PageData(
      icon: Icons.psychology_rounded,
      tag: '01 — GİRİŞ',
      title: 'Beynini Her\nGün ',
      highlight: 'Eğit',
      subtitle:
          'Günde sadece 3 dakika ayır ve bilişsel gücünü üst seviyeye taşı. Küçük adımlar büyük fark yaratır.',
      gradientColors: [Color(0xFF0D59F2), Color(0xFF7C3AED)],
      accentColor: Color(0xFF0D59F2),
      chips: [
        _FeatureChip(Icons.timer_rounded, '3 dakika/gün'),
        _FeatureChip(Icons.bolt_rounded, 'Hızlı gelişim'),
      ],
    ),
    _PageData(
      icon: Icons.speed_rounded,
      tag: '02 — OYUNLAR',
      title: 'Hız. Odak.\n',
      highlight: 'Hafıza.',
      subtitle:
          '7 farklı bilişsel alanda 17+ mini oyun seni bekliyor. Sınırlarını zorla ve her gün daha iyi ol.',
      gradientColors: [Color(0xFF059669), Color(0xFF0891B2)],
      accentColor: Color(0xFF059669),
      chips: [
        _FeatureChip(Icons.games_rounded, '17+ oyun'),
        _FeatureChip(Icons.category_rounded, '7 kategori'),
      ],
    ),
    _PageData(
      icon: Icons.trending_up_rounded,
      tag: '03 — İLERLEME',
      title: 'Gelişimini\n',
      highlight: 'Takip Et',
      subtitle:
          'Radar grafiği ve istatistiklerle bilişsel skorlarını görsel olarak izle. Hangi alanda güçlüsün, keşfet.',
      gradientColors: [Color(0xFF9333EA), Color(0xFFEC4899)],
      accentColor: Color(0xFF9333EA),
      chips: [
        _FeatureChip(Icons.bar_chart_rounded, 'Detaylı istatistik'),
        _FeatureChip(Icons.radar, 'Radar grafik'),
      ],
    ),
    _PageData(
      icon: Icons.rocket_launch_rounded,
      tag: '04 — BAŞLA',
      title: 'Hazır mısın?\n',
      highlight: 'Haydi!',
      subtitle:
          'NöroDakika ile beyin antrenmanına hemen başlayabilirsin. Giriş yap veya üye ol, ücretsiz.',
      gradientColors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
      accentColor: Color(0xFFF59E0B),
      chips: [
        _FeatureChip(Icons.lock_open_rounded, 'Ücretsiz'),
        _FeatureChip(Icons.cloud_sync_rounded, 'Bulut kayıt'),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Status bar'ı şeffaf yap (aydınlık tema — koyu ikonlar)
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

    // İkon için sürekli pulse animasyonu
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

  // Sayfa değiştiğinde animasyonu yeniden başlat
  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    _contentController.reset();
    _contentController.forward();
  }

  // İleri butonu
  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        // Daha akıcı ve modern bir eğri
        curve: Curves.easeInOutCubicEmphasized,
      );
    } else {
      _goToWelcome();
    }
  }

  // Welcome ekranına geçiş (scale + fade animasyonu)
  Future<void> _goToWelcome() async {
    await LocalStorageService.setOnboardingSeen();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const WelcomeScreen(),
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, animation, __, child) {
          // Fade + Scale birlikte (zoom-in etkisi)
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
    final page = _pages[_currentPage];
    final size = MediaQuery.sizeOf(context);
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          // ── Sinapsis/Nöron Arka Planı (aydınlık mod) ──
          const Positioned.fill(
            child: NeuronBackground(isDarkMode: false),
          ),

          // ── Animasyonlu gradient blob (üst sol) ──
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

          // ── Animasyonlu gradient blob (alt sağ) ──
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

          // ── Sayfa İçeriği ──
          SafeArea(
            child: Column(
              children: [
                // --- Üst Bar (logo + atla) ---
                Padding(
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(
                              color: Color(0xFFCBD5E1),
                            ),
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
                ),

                // --- PageView içerik ---
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _pages.length,
                    itemBuilder: (_, index) {
                      final p = _pages[index];
                      // Sadece aktif sayfada animasyon çalışsın
                      if (index == _currentPage) {
                        return FadeTransition(
                          opacity: _contentFade,
                          child: ScaleTransition(
                            scale: _contentScale,
                            child: _buildPageContent(p, size),
                          ),
                        );
                      }
                      return _buildPageContent(p, size);
                    },
                  ),
                ),

                // --- Alt bar (dots + buton) ---
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(28, 0, 28, 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Nokta indikatörleri
                      Row(
                        children: List.generate(_pages.length, (i) {
                          final isActive = i == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOutCubic,
                            margin: const EdgeInsets.only(right: 6),
                            width: isActive ? 32 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: isActive
                                  ? page.accentColor
                                  : _dotInactive,
                            ),
                          );
                        }),
                      ),

                      // İleri / Başla butonu
                      GestureDetector(
                        onTap: _next,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic,
                          width: isLastPage ? 160 : 64,
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
                            child: isLastPage
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tek sayfa içeriği ────────────────────────────────────
  Widget _buildPageContent(_PageData p, Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),

          // Küçük etiket (sayfa numarası)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: p.accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: p.accentColor.withValues(alpha: 0.3),
              ),
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
          ),

          const SizedBox(height: 32),

          // Büyük ikon — gradient çerçeveli kart
          ScaleTransition(
            scale: _pulseScale,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: [
                    p.gradientColors[0].withValues(alpha: 0.2),
                    p.gradientColors[1].withValues(alpha: 0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: p.accentColor.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: Icon(
                p.icon,
                size: 52,
                color: p.accentColor,
              ),
            ),
          ),

          const SizedBox(height: 36),

          // Ana başlık (normal + renkli kısım)
          RichText(
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
          ),

          const SizedBox(height: 20),

          // Alt açıklama metni
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
          Row(
            children: p.chips.map((chip) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _chipBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _chipBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(chip.icon,
                          size: 15,
                          color: p.accentColor),
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
          ),

          const Spacer(),

          // Sayfa ilerleme çubuğu (ince)
          _buildProgressBar(p),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ─── İnce ilerleme çubuğu ─────────────────────────────────
  Widget _buildProgressBar(_PageData p) {
    final progress = (_currentPage + 1) / _pages.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Adım ${_currentPage + 1} / ${_pages.length}',
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            height: 3,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: _progressBg,
              valueColor: AlwaysStoppedAnimation<Color>(p.accentColor),
              minHeight: 3,
            ),
          ),
        ),
      ],
    );
  }
}
