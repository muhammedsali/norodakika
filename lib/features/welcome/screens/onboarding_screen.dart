import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/local_storage_service.dart';
import 'welcome_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final List<_OnboardingData> _pages = const <_OnboardingData>[
    _OnboardingData(
      icon: Icons.psychology_rounded,
      title: 'Beynini Her\nGün Eğit',
      subtitle:
          'Günde sadece 3 dakika ayır ve bilişsel gücünü üst seviyeye taşı.',
      accent: Color(0xFF1E1E2F),
      dot: Color(0xFF6C63FF),
    ),
    _OnboardingData(
      icon: Icons.speed_rounded,
      title: 'Hız. Odak.\nHafıza.',
      subtitle:
          '7 farklı bilişsel alanda kendini test et ve sınırlarını zorla.',
      accent: Color(0xFF1A2A3A),
      dot: Color(0xFF00C9A7),
    ),
    _OnboardingData(
      icon: Icons.trending_up_rounded,
      title: 'Gelişimini\nTakip Et',
      subtitle:
          'Radar grafiği ile skorlarını ve gelişimini görsel olarak izle.',
      accent: Color(0xFF2A1E2F),
      dot: Color(0xFFFF6B6B),
    ),
    _OnboardingData(
      icon: Icons.rocket_launch_rounded,
      title: 'Hazır mısın?\nHaydi Başla!',
      subtitle:
          'NöroDakika ile beyin antrenmanına hemen başlayabilirsin.\nGiriş yap veya üye ol.',
      accent: Color(0xFF1A1F2A),
      dot: Color(0xFFF59E0B),
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnim =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    _slideController.forward();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _goToWelcome();
    }
  }

  Future<void> _goToWelcome() async {
    await LocalStorageService.setOnboardingSeen();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const WelcomeScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _OnboardingData page = _pages[_currentPage];
    final Size size = MediaQuery.sizeOf(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      color: page.accent,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              // ── Dekoratif daire - üst sağ ──
              Positioned(
                top: -size.height * 0.12,
                right: -size.width * 0.25,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: size.width * 0.75,
                  height: size.width * 0.75,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: page.dot.withValues(alpha: 0.12),
                  ),
                ),
              ),
              // ── Dekoratif daire - alt sol ──
              Positioned(
                bottom: -size.height * 0.08,
                left: -size.width * 0.2,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: size.width * 0.55,
                  height: size.width * 0.55,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: page.dot.withValues(alpha: 0.07),
                  ),
                ),
              ),

              // ── Atla butonu ──
              Positioned(
                top: 16,
                right: 20,
                child: TextButton(
                  onPressed: _goToWelcome,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white.withValues(alpha: 0.6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Atla',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              // ── Ana İçerik ──
              Column(
                children: <Widget>[
                  const Spacer(flex: 2),

                  Expanded(
                    flex: 5,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      itemCount: _pages.length,
                      itemBuilder: (BuildContext _, int index) {
                        final _OnboardingData p = _pages[index];
                        return FadeTransition(
                          opacity: index == _currentPage
                              ? _fadeAnim
                              : const AlwaysStoppedAnimation<double>(1),
                          child: SlideTransition(
                            position: index == _currentPage
                                ? _slideAnim
                                : const AlwaysStoppedAnimation<Offset>(
                                    Offset.zero),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  // İkon
                                  Icon(
                                    p.icon,
                                    size: 72,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 32),

                                  // Başlık
                                  Text(
                                    p.title,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 48,
                                      fontWeight: FontWeight.w800,
                                      height: 1.05,
                                      letterSpacing: -1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Alt başlık
                                  Text(
                                    p.subtitle,
                                    style: GoogleFonts.poppins(
                                      color:
                                          Colors.white.withValues(alpha: 0.7),
                                      fontSize: 16,
                                      height: 1.6,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const Spacer(),

                  // ── Dots + Buton ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        // Nokta indikatörleri
                        Row(
                          children:
                              List<Widget>.generate(_pages.length, (int i) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(right: 8),
                              width: i == _currentPage ? 28 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: i == _currentPage
                                    ? page.dot
                                    : Colors.white.withValues(alpha: 0.25),
                              ),
                            );
                          }),
                        ),

                        // İleri / Başla butonu
                        GestureDetector(
                          onTap: _next,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: page.dot,
                              shape: BoxShape.circle,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: page.dot.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                _currentPage == _pages.length - 1
                                    ? Icons.check_rounded
                                    : Icons.arrow_forward_ios_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Data modeli ───────────────────────────────
class _OnboardingData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final Color dot;

  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.dot,
  });
}
