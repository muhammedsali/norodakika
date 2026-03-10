import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/providers/auth_provider.dart';
import '../../stats/screens/stats_screen.dart';
import '../../stats/providers/user_stats_provider.dart';
import '../../game_launcher/screens/game_play_screen.dart';
import '../../../core/memory/memory_bank.dart';
import '../../../core/models/game_model.dart';
import '../../../services/local_storage_service.dart';
import '../../settings/providers/language_provider.dart';
import '../../settings/providers/theme_provider.dart';
import '../../settings/screens/settings_screen.dart';
import '../../../core/i18n/app_strings.dart';
import '../widgets/home_bottom_nav.dart';
import '../../profile/providers/avatar_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedTab = 0; // 0: Ana Sayfa, 1: Oyunlar, 2: İlerleme, 3: Ayarlar
  bool _showOnboarding = false;
  int _onboardingStep = 0;
  final TextEditingController _gamesSearchController = TextEditingController();
  String _gamesQuery = '';
  String _gamesFilter = 'all';

  static const _intelligenceKeys = <String>[
    'verbal',
    'logical',
    'visual',
    'bodily',
    'musical',
    'social',
    'intrapersonal',
    'naturalist',
  ];

  @override
  void initState() {
    super.initState();
    _loadOnboardingState();
    _gamesSearchController.addListener(() {
      final next = _gamesSearchController.text;
      if (next != _gamesQuery) {
        setState(() {
          _gamesQuery = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _gamesSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadOnboardingState() async {
    final seen = await LocalStorageService.hasSeenOnboarding();
    if (!seen && mounted) {
      setState(() {
        _showOnboarding = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;
    final appLanguage = ref.watch(languageProvider);
    final s = AppStrings(appLanguage);
    final isDarkMode = ref.watch(themeProvider);
    final userName =
        user?.displayName ?? user?.email?.split('@').first ?? s.userFallback;

    // Sistem status bar ikonlarını tema ile uyumlu yap
    final overlayStyle = isDarkMode
        ? const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          )
        : const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          );
    SystemChrome.setSystemUIOverlayStyle(overlayStyle);

    final games = MemoryBank.games.map((g) => GameModel.fromMap(g)).toList();

    // TASARIM: Arka plan hafif mavi/gri tonlu
    final bgColor =
        isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF4F6F8);

    return Scaffold(
      extendBody: true, // Ekranın menünün arkasına inmesini sağlar
      backgroundColor: bgColor,
      body: Stack(
        children: [
          SafeArea(
            bottom:
                false, // Menü arkasına kayması için alt güvenli alanı iptal ettik
            child: Column(
              children: [
                // Üst Header
                if (_selectedTab != 0 && _selectedTab != 1)
                  _buildHeader(userName),

                Expanded(
                  child: () {
                    if (_selectedTab == 0) {
                      return _buildHomeTabBody(context, games);
                    } else if (_selectedTab == 1) {
                      return _buildGamesTabBody(context, games);
                    } else if (_selectedTab == 2) {
                      // İlerleme sekmesi: İstatistik ekranı
                      return const StatsScreen();
                    } else {
                      return _buildSettingsTabBody();
                    }
                  }(),
                ),
              ],
            ),
          ),
          if (_showOnboarding) _buildOnboardingOverlay(context, appLanguage),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          // Menüyü hafif yukarı kaldırdık ve dış çerçevesindeki o sert arka planı attık
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: HomeBottomNav(
            selectedTab: _selectedTab,
            isDarkMode: isDarkMode,
            language: appLanguage,
            onTabSelected: (index) {
              setState(() {
                _selectedTab = index;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTabBody(BuildContext context, List<GameModel> games) {
    final isDarkMode = ref.watch(themeProvider);
    final appLanguage = ref.watch(languageProvider);
    final s = AppStrings(appLanguage);
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;
    final userName =
        user?.displayName ?? user?.email?.split('@').first ?? s.userFallback;

    final quickMath = games.where((g) => g.id == 'NUM01').isNotEmpty
        ? games.firstWhere((g) => g.id == 'NUM01')
        : games.first;

    const completedToday = 2;
    const plannedToday = 3;
    final dailyProgress =
        plannedToday == 0 ? 0.0 : completedToday / plannedToday;

    return SingleChildScrollView(
      // Alt menünün arkasında kalmaması için alt padding'i 120 yaptık
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHomeWelcomeHeader(userName: userName, isDarkMode: isDarkMode),
          const SizedBox(height: 32),
          _buildSectionLabel('DAILY PROGRESS', isDarkMode),
          const SizedBox(height: 12),
          _buildDailyProgressCard(
            isDarkMode: isDarkMode,
            completedToday: completedToday,
            plannedToday: plannedToday,
            progress: dailyProgress,
            onViewDetails: () {
              setState(() {
                _selectedTab = 2;
              });
            },
          ),
          const SizedBox(height: 32),
          _buildSectionLabel('UP NEXT', isDarkMode),
          const SizedBox(height: 12),
          _buildUpNextCard(
            context: context,
            isDarkMode: isDarkMode,
            game: quickMath,
          ),
          const SizedBox(height: 32),
          _buildSectionLabel('INSIGHTS', isDarkMode),
          const SizedBox(height: 12),
          _buildCognitiveScoreCard(isDarkMode: isDarkMode),
        ],
      ),
    );
  }

  // EKSİK OLAN VE GERİ EKLENEN FONKSİYON BURASI!
  Widget _buildHomeWelcomeHeader({
    required String userName,
    required bool isDarkMode,
  }) {
    final titleColor =
        isDarkMode ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final subtitleColor =
        isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final lang = ref.watch(languageProvider);
    final s = AppStrings(lang);

    return Row(
      children: [
        GestureDetector(
          onTap: () => _showAvatarPicker(context),
          child: Consumer(
            builder: (context, ref, child) {
              final selectedAvatar = ref.watch(avatarProvider);
              final avatarData = AvatarData.getAvatar(selectedAvatar);
              return Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: avatarData['colors'] as List<Color>,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  avatarData['icon'] as IconData,
                  color: Colors.white,
                  size: 22,
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.homeWelcomeBack,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: subtitleColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                userName,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDarkMode ? 0.18 : 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
                spreadRadius: -8,
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications_none_rounded,
              color: titleColor,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  // TASARIM: Başlıklar küçük, büyük harf ve aralıklı
  Widget _buildSectionLabel(String text, bool isDarkMode) {
    final c = isDarkMode ? const Color(0xFF64748B) : const Color(0xFF64748B);
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: c,
      ),
    );
  }

  Widget _buildDailyProgressCard({
    required bool isDarkMode,
    required int completedToday,
    required int plannedToday,
    required double progress,
    required VoidCallback onViewDetails,
  }) {
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final blue = const Color(0xFF2563EB); // Tasarımdaki mavi

    return Container(
      padding: const EdgeInsets.all(24), // TASARIM: Geniş iç boşluk
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28), // Daha yuvarlak köşeler
        boxShadow: [
          // TASARIM: Yumuşak ve geniş gölge
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Goal',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$completedToday of $plannedToday games completed today',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: subtitleColor,
                ),
              ),
              const SizedBox(height: 16),
              // View Details butonu (Pill şeklinde)
              InkWell(
                onTap: onViewDetails,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: blue.withValues(alpha: 0.1), // Hafif mavi arka plan
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'VIEW DETAILS',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: blue,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Yuvarlak İlerleme Çubuğu
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: isDarkMode
                      ? const Color(0xFF334155)
                      : const Color(0xFFF1F5F9),
                  strokeCap: StrokeCap.round,
                  valueColor: AlwaysStoppedAnimation<Color>(blue),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpNextCard({
    required BuildContext context,
    required bool isDarkMode,
    required GameModel game,
  }) {
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final blue = const Color(0xFF2563EB);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Görsel Placeholder
          Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isDarkMode
                  ? const Color(0xFF334155)
                  : const Color(0xFFF1F5F9),
            ),
            child: const Center(
              child: Icon(Icons.image_outlined,
                  size: 32, color: Color(0xFF94A3B8)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.name,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      game.description.isNotEmpty
                          ? game.description
                          : 'Boost your mental arithmetic\nspeed.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: subtitleColor,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              // Sağdaki dk uyarısı
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF334155)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: isDarkMode
                          ? Colors.transparent
                          : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Text(
                      '2',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: blue,
                      ),
                    ),
                    Text(
                      'MIN',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Mavi Ana Buton
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () {
                _showGameStartSheet(
                  context: context,
                  gameId: game.id,
                  title: game.name,
                  description: game.description.isNotEmpty
                      ? game.description
                      : game.area,
                  isDarkMode: isDarkMode,
                );
              },
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: Text(
                'Start Training',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: blue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCognitiveScoreCard({required bool isDarkMode}) {
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;

    final statsAsync = ref.watch(userStatsProvider);

    return statsAsync.when(
      data: (stats) {
        final memory = (stats['Hafıza'] ?? 0).toDouble();
        final focus = (stats['Dikkat'] ?? 0).toDouble();
        final speed = (stats['Refleks'] ?? 0).toDouble();
        final total = memory + focus + speed;
        final globalPts = (total * 10).round();

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.04),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cognitive Score',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '+12%',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  // Sol Taraftaki Büyük Puan
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$globalPts',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'GLOBAL PTS',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Sağ Taraftaki Bar Grafikleri
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        _buildMiniInsightBar('MEMORY', memory.round(),
                            const Color(0xFF2563EB), isDarkMode),
                        const SizedBox(height: 12),
                        _buildMiniInsightBar('FOCUS', focus.round(),
                            const Color(0xFFF97316), isDarkMode),
                        const SizedBox(height: 12),
                        _buildMiniInsightBar('SPEED', speed.round(),
                            const Color(0xFF14B8A6), isDarkMode),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildMiniInsightBar(
      String label, int value, Color color, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDarkMode
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
            Text(
              value.toString(),
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: 6, // Tasarımdaki ince barlar
            backgroundColor:
                isDarkMode ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildOnboardingOverlay(BuildContext context, AppLanguage lang) {
    final isDarkMode = ref.watch(themeProvider);
    final isDark = isDarkMode;
    final titleColor =
        isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final textColor =
        isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563);
    final s = AppStrings(lang);
    final steps = [
      {
        'title': s.onboardingWelcomeTitle,
        'text': s.onboardingWelcomeText,
      },
      {
        'title': s.onboardingDailyTitle,
        'text': s.onboardingDailyText,
      },
      {
        'title': s.onboardingProgressTitle,
        'text': s.onboardingProgressText,
      },
    ];

    final current = steps[_onboardingStep.clamp(0, steps.length - 1)];

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [Color(0xFF020617), Color(0xFF111827)]
                : const [Color(0xFFEEF2FF), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Skip
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () async {
                      setState(() {
                        _showOnboarding = false;
                      });
                      await LocalStorageService.setOnboardingSeen();
                    },
                    child: Text(
                      s.onboardingSkip,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Norodakika',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        current['title'] as String,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        current['text'] as String,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          height: 1.6,
                          color: textColor,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(steps.length, (index) {
                          final isActive = index == _onboardingStep;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isActive ? 18 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFF4F46E5)
                                  : textColor.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // Bottom primary button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_onboardingStep < steps.length - 1) {
                        setState(() {
                          _onboardingStep++;
                        });
                      } else {
                        setState(() {
                          _showOnboarding = false;
                        });
                        await LocalStorageService.setOnboardingSeen();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: (isDarkMode
                              ? const Color(0xFF818CF8)
                              : const Color(0xFF4F46E5))
                          .withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                        side: isDarkMode
                            ? const BorderSide(
                                color: Color(0xFF818CF8),
                                width: 1.2,
                              )
                            : BorderSide.none,
                      ),
                    ),
                    child: Text(
                      _onboardingStep < steps.length - 1
                          ? s.onboardingNext
                          : s.onboardingStart,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAvatarPicker(BuildContext context) {
    final isDarkMode = ref.read(themeProvider);
    final lang = ref.read(languageProvider);
    final s = AppStrings(lang);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              s.chooseAvatarTitle,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: AvatarData.avatars.length,
              itemBuilder: (context, index) {
                final avatar = AvatarData.avatars[index];
                final isSelected = ref.watch(avatarProvider) == index;
                return GestureDetector(
                  onTap: () {
                    ref.read(avatarProvider.notifier).setAvatar(index);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: avatar['colors'] as List<Color>,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected
                          ? Border.all(
                              color: Colors.white,
                              width: 3,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: (avatar['colors'] as List<Color>)[0]
                              .withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          avatar['icon'] as IconData,
                          color: Colors.white,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          s.avatarLabel(avatar['name'] as String),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getGameIconData(String gameId) {
    switch (gameId) {
      case 'REF01':
        return {
          'icon': Icons.touch_app,
          'color': const Color(0xFFEF4444),
          'emoji': '⚡'
        };
      case 'REF02':
        return {
          'icon': Icons.directions_run,
          'color': const Color(0xFF10B981),
          'emoji': '🏃'
        };
      case 'ATT01':
        return {
          'icon': Icons.palette,
          'color': const Color(0xFF8B5CF6),
          'emoji': '🎨'
        };
      case 'ATT02':
        return {
          'icon': Icons.remove,
          'color': const Color(0xFF06B6D4),
          'emoji': '➖'
        };
      case 'MEM01':
        return {
          'icon': Icons.psychology,
          'color': const Color(0xFFEC4899),
          'emoji': '🧠'
        };
      case 'LOG01':
        return {
          'icon': Icons.extension,
          'color': const Color(0xFFF59E0B),
          'emoji': '🧩'
        };
      case 'NUM01':
        return {
          'icon': Icons.calculate,
          'color': const Color(0xFF3B82F6),
          'emoji': '🔢'
        };
      case 'MEM02':
        return {
          'icon': Icons.grid_view,
          'color': const Color(0xFF14B8A6),
          'emoji': '🎴'
        };
      case 'MEM03':
        return {
          'icon': Icons.text_fields,
          'color': const Color(0xFF6366F1),
          'emoji': '📝'
        };
      case 'MEM04':
        return {
          'icon': Icons.repeat,
          'color': const Color(0xFFA855F7),
          'emoji': '🔁'
        };
      case 'VIS02':
        return {
          'icon': Icons.find_in_page,
          'color': const Color(0xFFF97316),
          'emoji': '🔍'
        };
      case 'LANG02':
        return {
          'icon': Icons.speed,
          'color': const Color(0xFF06B6D4),
          'emoji': '💨'
        };
      case 'MUS01':
        return {
          'icon': Icons.music_note,
          'color': const Color(0xFFF59E0B),
          'emoji': '🎵'
        };
      case 'SOC01':
        return {
          'icon': Icons.emoji_emotions,
          'color': const Color(0xFFEC4899),
          'emoji': '🙂'
        };
      case 'NAT01':
        return {
          'icon': Icons.nature,
          'color': const Color(0xFF10B981),
          'emoji': '🌿'
        };
      case 'KIN01':
        return {
          'icon': Icons.sports_martial_arts,
          'color': const Color(0xFF3B82F6),
          'emoji': '⚖️'
        };
      case 'SPA01':
        return {
          'icon': Icons.route,
          'color': const Color(0xFF8B5CF6),
          'emoji': '🧭'
        };
      case 'INT01':
        return {
          'icon': Icons.self_improvement,
          'color': const Color(0xFF06B6D4),
          'emoji': '🧘'
        };
      default:
        return {
          'icon': Icons.sports_esports,
          'color': const Color(0xFF4F46E5),
          'emoji': '🎮'
        };
    }
  }

  void _showGameStartSheet({
    required BuildContext context,
    required String gameId,
    required String title,
    required String description,
    required bool isDarkMode,
  }) {
    final iconData = _getGameIconData(gameId);
    final gameColor = iconData['color'] as Color;
    final emoji = iconData['emoji'] as String;
    final lang = ref.read(languageProvider);
    final s = AppStrings(lang);

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: isDarkMode ? 0.75 : 0.5),
      builder: (ctx) {
        final themeBg = isDarkMode ? const Color(0xFF1F2937) : Colors.white;
        final titleColor =
            isDarkMode ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
        final textColor =
            isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
        final cardBg =
            isDarkMode ? const Color(0xFF111827) : const Color(0xFFF9FAFB);
        final borderColor =
            isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB);

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              decoration: BoxDecoration(
                color: themeBg,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: borderColor,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black.withValues(alpha: 0.6)
                        : Colors.black.withValues(alpha: 0.1),
                    blurRadius: 50,
                    spreadRadius: -10,
                    offset: const Offset(0, 25),
                  ),
                  BoxShadow(
                    color: gameColor.withValues(alpha: isDarkMode ? 0.1 : 0.05),
                    blurRadius: 30,
                    spreadRadius: 0,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with gradient
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 24, 16, 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDarkMode
                            ? [
                                gameColor.withValues(alpha: 0.2),
                                gameColor.withValues(alpha: 0.08),
                              ]
                            : [
                                gameColor.withValues(alpha: 0.15),
                                gameColor.withValues(alpha: 0.05),
                              ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Game icon
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                gameColor,
                                gameColor.withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: gameColor.withValues(alpha: 0.4),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Title and badge
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: titleColor,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: gameColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: gameColor.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.timer_outlined,
                                      size: 14,
                                      color: gameColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      s.approxTwoThreeMinutes,
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: gameColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Close button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.of(ctx).pop(),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? const Color(0xFF374151)
                                    : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 20,
                                color: textColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Description card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: borderColor,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDarkMode
                                    ? Colors.black.withValues(alpha: 0.3)
                                    : Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                spreadRadius: 0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: gameColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.info_outline_rounded,
                                      size: 16,
                                      color: gameColor,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    s.howToPlay,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: titleColor,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                description,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14,
                                  height: 1.65,
                                  color: textColor,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Start button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(ctx).pop();
                              final allGames = MemoryBank.games
                                  .map((g) => GameModel.fromMap(g))
                                  .toList();
                              final selectedGame = allGames.firstWhere(
                                (g) => g.id == gameId,
                                orElse: () => allGames.first,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => GamePlayScreen(
                                    game: selectedGame,
                                    isDarkOverride: isDarkMode,
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: double.infinity,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    gameColor,
                                    gameColor.withValues(alpha: 0.85),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: gameColor.withValues(
                                        alpha: isDarkMode ? 0.5 : 0.4),
                                    blurRadius: 25,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 10),
                                  ),
                                  BoxShadow(
                                    color: gameColor.withValues(alpha: 0.2),
                                    blurRadius: 15,
                                    spreadRadius: -5,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.25),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Text(
                                      s.startGame,
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.3,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.2),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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
          ),
        );
      },
    );
  }

  Widget _buildGamesTabBody(BuildContext context, List<GameModel> games) {
    final isDarkMode = ref.watch(themeProvider);
    final appLanguage = ref.watch(languageProvider);
    final s = AppStrings(appLanguage);
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;
    final userName =
        user?.displayName ?? user?.email?.split('@').first ?? s.userFallback;

    final filteredGames = games.where((g) {
      final intelligenceKey = g.intelligence;
      final matchesFilter =
          _gamesFilter == 'all' || intelligenceKey == _gamesFilter;
      if (!matchesFilter) return false;
      if (_gamesQuery.trim().isEmpty) return true;
      final q = _gamesQuery.toLowerCase().trim();
      return g.name.toLowerCase().contains(q) ||
          g.area.toLowerCase().contains(q) ||
          g.description.toLowerCase().contains(q);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGamesTabHeader(userName, isDarkMode, s),
          const SizedBox(height: 16),
          _buildGamesSearchBar(isDarkMode, s),
          const SizedBox(height: 14),
          _buildGamesFilterChips(isDarkMode, s),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.86,
            ),
            itemCount: filteredGames.length,
            itemBuilder: (context, index) {
              final game = filteredGames[index];
              return _buildStitchGameCard(
                context: context,
                game: game,
                isDarkMode: isDarkMode,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGamesTabHeader(String userName, bool isDarkMode, AppStrings s) {
    final titleColor =
        isDarkMode ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final subtitleColor =
        isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    return Row(
      children: [
        GestureDetector(
          onTap: () => _showAvatarPicker(context),
          child: Consumer(
            builder: (context, ref, child) {
              final selectedAvatar = ref.watch(avatarProvider);
              final avatarData = AvatarData.getAvatar(selectedAvatar);
              return Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: avatarData['colors'] as List<Color>,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  avatarData['icon'] as IconData,
                  color: Colors.white,
                  size: 22,
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.appName,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${s.dailyGoal}: 85%',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDarkMode ? 0.18 : 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
                spreadRadius: -8,
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications_none_rounded,
              color: titleColor,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGamesSearchBar(bool isDarkMode, AppStrings s) {
    final bg = isDarkMode ? const Color(0xFF1F2937) : Colors.white;
    final hint = isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF9CA3AF);
    final text = isDarkMode ? const Color(0xFFF9FAFB) : const Color(0xFF111827);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.18 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
            spreadRadius: -10,
          ),
        ],
      ),
      child: TextField(
        controller: _gamesSearchController,
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: text,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search_rounded, color: hint),
          hintText: s.gamesSearchHint,
          hintStyle: GoogleFonts.poppins(fontSize: 13, color: hint),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildGamesFilterChips(bool isDarkMode, AppStrings s) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildGamesChip(
          filterKey: 'all',
          label: s.gamesChipAll,
          isDarkMode: isDarkMode,
          accentColor: const Color(0xFF2563EB),
        ),
        ..._intelligenceKeys.map((key) {
          return _buildGamesChip(
            filterKey: key,
            label: s.intelligenceLabel(key),
            isDarkMode: isDarkMode,
            accentColor: _getIntelligenceColor(key),
          );
        }),
      ],
    );
  }

  Widget _buildGamesChip({
    required String filterKey,
    required String label,
    required bool isDarkMode,
    required Color accentColor,
  }) {
    final isActive = _gamesFilter == filterKey;
    final activeBg = accentColor;
    final inactiveBg = isDarkMode ? const Color(0xFF1F2937) : Colors.white;
    final activeText = Colors.white;
    final inactiveText = accentColor;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {
          setState(() {
            _gamesFilter = filterKey;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: isActive ? activeBg : inactiveBg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: accentColor.withValues(
                  alpha: isActive ? 0.0 : (isDarkMode ? 0.55 : 0.45)),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDarkMode ? 0.18 : 0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
                spreadRadius: -12,
              ),
            ],
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? activeText : inactiveText,
            ),
          ),
        ),
      ),
    );
  }

  Color _getIntelligenceColor(String intelligenceKey) {
    switch (intelligenceKey) {
      case 'verbal':
        return const Color(0xFF7C3AED); // purple
      case 'logical':
        return const Color(0xFF2563EB); // blue
      case 'visual':
        return const Color(0xFF0EA5E9); // sky
      case 'bodily':
        return const Color(0xFFF97316); // orange
      case 'musical':
        return const Color(0xFFEC4899); // pink
      case 'social':
        return const Color(0xFF10B981); // emerald
      case 'intrapersonal':
        return const Color(0xFF14B8A6); // teal
      case 'naturalist':
        return const Color(0xFF22C55E); // green
      default:
        return const Color(0xFF6B7280); // gray
    }
  }

  Widget _buildStitchGameCard({
    required BuildContext context,
    required GameModel game,
    required bool isDarkMode,
  }) {
    final cardBg = isDarkMode ? const Color(0xFF1F2937) : Colors.white;
    final titleColor =
        isDarkMode ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final subtitleColor =
        isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    final iconData = _getGameIconData(game.id);
    final icon = iconData['icon'] as IconData;
    final lang = ref.watch(languageProvider);
    final s = AppStrings(lang);
    final intelligenceKey = game.intelligence;
    final intelLabel = s.intelligenceLabel(intelligenceKey).toUpperCase();
    final intelColor = _getIntelligenceColor(intelligenceKey);

    final tagBg = intelColor.withValues(alpha: isDarkMode ? 0.22 : 0.18);
    final bottomText = game.area;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          _showGameStartSheet(
            context: context,
            gameId: game.id,
            title: game.name,
            description:
                game.description.isNotEmpty ? game.description : game.area,
            isDarkMode: isDarkMode,
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDarkMode ? 0.18 : 0.08),
                blurRadius: 22,
                offset: const Offset(0, 10),
                spreadRadius: -12,
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: intelColor.withValues(alpha: isDarkMode ? 0.22 : 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: intelColor, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                game.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tagBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  intelLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: intelColor,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                bottomText,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // BURASINI DA TASARIMA GÖRE GÜNCELLEDİM
  Widget _buildHeader(String userName) {
    final isDarkMode = ref.watch(themeProvider);
    final lang = ref.watch(languageProvider);
    final s = AppStrings(lang);

    final titleColor =
        isDarkMode ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final subtitleColor =
        isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _showAvatarPicker(context),
              child: Consumer(
                builder: (context, ref, child) {
                  final selectedAvatar = ref.watch(avatarProvider);
                  final avatarData = AvatarData.getAvatar(selectedAvatar);
                  return Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: avatarData['colors'] as List<Color>,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      avatarData['icon'] as IconData,
                      color: Colors.white,
                      size: 22,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.homeWelcomeBack,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: subtitleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    userName,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withValues(alpha: isDarkMode ? 0.18 : 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                    spreadRadius: -8,
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.notifications_none_rounded,
                  color: titleColor,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTabBody() {
    return const SettingsScreen();
  }
}
