import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/providers/auth_provider.dart';
import '../../stats/screens/stats_screen.dart';
import '../../stats/providers/user_stats_provider.dart';
import '../../stats/widgets/radar_chart_widget.dart';
import '../../game_launcher/screens/game_launcher_screen.dart';
import '../../game_launcher/screens/game_play_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../../core/memory/memory_bank.dart';
import '../../../core/models/game_model.dart';
import '../../../services/local_storage_service.dart';
import '../../settings/providers/language_provider.dart';
import '../../settings/providers/theme_provider.dart';
import '../widgets/home_bottom_nav.dart';
import '../../shared/widgets/game_card_widgets.dart';
import '../../profile/providers/avatar_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedCategory = 'Tümü';
  int _selectedTab = 0; // 0: Ana Sayfa, 1: Oyunlar, 2: İlerleme, 3: Ayarlar
  bool _showOnboarding = false;
  int _onboardingStep = 0;

  @override
  void initState() {
    super.initState();
    _loadOnboardingState();
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
    final isDarkMode = ref.watch(themeProvider);
    final userName = user?.displayName ?? user?.email?.split('@').first ?? 'Kullanıcı';
    
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

    final games = MemoryBank.games
        .map((g) => GameModel.fromMap(g))
        .toList();

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Üst Header
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
    );
  }

  Widget _buildOnboardingOverlay(BuildContext context, AppLanguage lang) {
    final isDarkMode = ref.watch(themeProvider);
    final isDark = isDarkMode;
    final titleColor = isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final textColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563);
    final steps = lang == AppLanguage.en
        ? const [
            {
              'title': 'Welcome!',
              'text': 'Norodakika helps you train your mind with short, focused mini games.'
            },
            {
              'title': 'Today’s Workout',
              'text': 'Use the purple button on the home screen to start your daily plan.'
            },
            {
              'title': 'Track Progress',
              'text': 'See your radar chart and daily summary on the Progress tab.'
            },
          ]
        : const [
            {
              'title': 'Hoş geldin!',
              'text': 'NöroDakika, kısa mini oyunlarla zihnini antrenman yapman için tasarlandı.'
            },
            {
              'title': 'Günün Antrenmanı',
              'text': 'Ana ekrandaki mor butondan bugün için önerilen oyun planını başlatabilirsin.'
            },
            {
              'title': 'İlerleme Takibi',
              'text': 'Alt barda İlerleme sekmesinden radar grafiği ve günlük özetini görebilirsin.'
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
                      lang == AppLanguage.en ? 'Skip' : 'Atla',
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
                                  : textColor.withOpacity(0.3),
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
                      shadowColor:
                          (isDarkMode ? const Color(0xFF818CF8) : const Color(0xFF4F46E5))
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
                          ? (lang == AppLanguage.en ? 'Next' : 'İleri')
                          : (lang == AppLanguage.en ? 'Start' : 'Başla'),
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Profil Resmi Seç',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
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
                          color: (avatar['colors'] as List<Color>)[0].withOpacity(0.3),
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
                          avatar['name'] as String,
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
        return {'icon': Icons.touch_app, 'color': Color(0xFFEF4444), 'emoji': '⚡'};
      case 'REF02':
        return {'icon': Icons.directions_run, 'color': Color(0xFF10B981), 'emoji': '🏃'};
      case 'ATT01':
        return {'icon': Icons.palette, 'color': Color(0xFF8B5CF6), 'emoji': '🎨'};
      case 'ATT02':
        return {'icon': Icons.remove, 'color': Color(0xFF06B6D4), 'emoji': '➖'};
      case 'MEM01':
        return {'icon': Icons.psychology, 'color': Color(0xFFEC4899), 'emoji': '🧠'};
      case 'LOG01':
        return {'icon': Icons.extension, 'color': Color(0xFFF59E0B), 'emoji': '🧩'};
      case 'NUM01':
        return {'icon': Icons.calculate, 'color': Color(0xFF3B82F6), 'emoji': '🔢'};
      case 'MEM02':
        return {'icon': Icons.grid_view, 'color': Color(0xFF14B8A6), 'emoji': '🎴'};
      case 'MEM03':
        return {'icon': Icons.text_fields, 'color': Color(0xFF6366F1), 'emoji': '📝'};
      case 'MEM04':
        return {'icon': Icons.repeat, 'color': Color(0xFFA855F7), 'emoji': '🔁'};
      case 'VIS02':
        return {'icon': Icons.find_in_page, 'color': Color(0xFFF97316), 'emoji': '🔍'};
      case 'LANG02':
        return {'icon': Icons.speed, 'color': Color(0xFF06B6D4), 'emoji': '💨'};
      default:
        return {'icon': Icons.sports_esports, 'color': Color(0xFF4F46E5), 'emoji': '🎮'};
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

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(isDarkMode ? 0.75 : 0.5),
      builder: (ctx) {
        final themeBg = isDarkMode
            ? const Color(0xFF1F2937)
            : Colors.white;
        final titleColor =
            isDarkMode ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
        final textColor =
            isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
        final cardBg = isDarkMode
            ? const Color(0xFF111827)
            : const Color(0xFFF9FAFB);
        final borderColor = isDarkMode
            ? const Color(0xFF374151)
            : const Color(0xFFE5E7EB);

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
                        ? Colors.black.withOpacity(0.6)
                        : Colors.black.withOpacity(0.1),
                    blurRadius: 50,
                    spreadRadius: -10,
                    offset: const Offset(0, 25),
                  ),
                  BoxShadow(
                    color: gameColor.withOpacity(isDarkMode ? 0.1 : 0.05),
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
                                gameColor.withOpacity(0.2),
                                gameColor.withOpacity(0.08),
                              ]
                            : [
                                gameColor.withOpacity(0.15),
                                gameColor.withOpacity(0.05),
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
                                gameColor.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: gameColor.withOpacity(0.4),
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
                                  color: gameColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: gameColor.withOpacity(0.3),
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
                                      '~2-3 dakika',
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
                                    ? Colors.black.withOpacity(0.3)
                                    : Colors.black.withOpacity(0.03),
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
                                      color: gameColor.withOpacity(0.15),
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
                                    'Nasıl Oynanır?',
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
                                    gameColor.withOpacity(0.85),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: gameColor.withOpacity(isDarkMode ? 0.5 : 0.4),
                                    blurRadius: 25,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 10),
                                  ),
                                  BoxShadow(
                                    color: gameColor.withOpacity(0.2),
                                    blurRadius: 15,
                                    spreadRadius: -5,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.25),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
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
                                      'Oyunu Başlat',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.3,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(0.2),
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


  Widget _buildHomeTabBody(BuildContext context, List<GameModel> games) {
    final isDarkMode = ref.watch(themeProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPrimaryCtaButton(context),
          const SizedBox(height: 24),
          _buildExpandedProgressSection(),
        ],
      ),
    );
  }

  Widget _buildGamesTabBody(BuildContext context, List<GameModel> games) {
    final isDarkMode = ref.watch(themeProvider);
    // Tüm oyunların tam grid görünümü
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tüm Oyunlar',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? const Color(0xFFF9FAFB) : const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return GridGameCard(
                gameId: game.id,
                title: game.name,
                area: game.area,
                isDarkMode: isDarkMode,
                onTap: () {
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
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryCtaButton(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          const SizedBox(height: 16),
          SizedBox(
            height: 64,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GameLauncherScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDarkMode ? const Color(0xFF1F2937) : const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor:
                    (isDarkMode ? const Color(0xFF818CF8) : const Color(0xFF4F46E5))
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
              child: Center(
                child: Text(
                  'Başla: Günün Antrenmanı',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedProgressSection() {
    final isDarkMode = ref.watch(themeProvider);
    final statsAsync = ref.watch(userStatsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'İlerleme',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? const Color(0xFFF9FAFB) : const Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 16),
        statsAsync.when(
          data: (stats) {
            final hasData = stats.values.any((value) => value > 0);
            if (!hasData) {
              return Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDarkMode
                        ? const Color(0xFF374151)
                        : const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.show_chart_rounded,
                        size: 48,
                        color: isDarkMode
                            ? Colors.grey[600]
                            : Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Henüz oyun oynamadın',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Oyun oynamaya başlayınca ilerleme grafin burada görünecek',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return RadarChartWidget(
              stats: stats,
              isDarkMode: isDarkMode,
            );
          },
          loading: () => Container(
            height: 300,
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDarkMode
                    ? const Color(0xFF374151)
                    : const Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDarkMode
                    ? const Color(0xFF374151)
                    : const Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                'Veriler yüklenemedi',
                style: GoogleFonts.poppins(
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildHeader(String userName) {
    final isDarkMode = ref.watch(themeProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Row(
          children: [
            // Profil Avatar
            GestureDetector(
              onTap: () => _showAvatarPicker(context),
              child: Consumer(
                builder: (context, ref, child) {
                  final selectedAvatar = ref.watch(avatarProvider);
                  final avatarData = AvatarData.getAvatar(selectedAvatar);
                  return Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: avatarData['colors'] as List<Color>,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (avatarData['colors'] as List<Color>)[0].withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      avatarData['icon'] as IconData,
                      color: Colors.white,
                      size: 24,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            
            // Hoş geldin mesajı
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Muhammed Sali',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          isDarkMode ? const Color(0xFFF9FAFB) : const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isDarkMode
                          ? const Color(0xFF818CF8)
                          : const Color(0xFF4F46E5))
                      .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Görev: 2/5',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color:
                            isDarkMode ? const Color(0xFFF9FAFB) : const Color(0xFF4F46E5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Sağda boş alan (karanlık mod artık Ayarlar ekranından değişiyor)
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTabBody() {
    final isDarkMode = ref.watch(themeProvider);
    final bgColor = isDarkMode ? const Color(0xFF111827) : const Color(0xFFF3F4F6);
    final cardColor = isDarkMode ? const Color(0xFF1F2937) : Colors.white;
    final titleColor = isDarkMode ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final subtitleColor = isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final appLanguage = ref.watch(languageProvider);

    return Container(
      color: bgColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ayarlar',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Uygulamayı sana göre özelleştir.',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                color: subtitleColor,
              ),
            ),
            const SizedBox(height: 24),

            // Tema
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDarkMode
                      ? const Color(0xFF374151)
                      : const Color(0xFFE5E7EB),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7F0DF2).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.dark_mode_rounded,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Karanlık Mod',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Geceleri gözünü yormayan koyu tema.',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isDarkMode,
                    activeThumbColor: const Color(0xFF4F46E5),
                    onChanged: (value) {
                      ref.read(themeProvider.notifier).setDarkMode(value);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Dil
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDarkMode
                      ? const Color(0xFF374151)
                      : const Color(0xFFE5E7EB),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFEC4899).withOpacity(isDarkMode ? 0.2 : 0.15),
                          const Color(0xFFF472B6).withOpacity(isDarkMode ? 0.15 : 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.language_rounded,
                      color: isDarkMode ? const Color(0xFFF472B6) : const Color(0xFFEC4899),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dil',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Uygulama dilini değiştir.',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFEC4899).withOpacity(isDarkMode ? 0.2 : 0.1),
                          const Color(0xFFF472B6).withOpacity(isDarkMode ? 0.15 : 0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFEC4899).withOpacity(isDarkMode ? 0.3 : 0.2),
                        width: 1,
                      ),
                    ),
                    child: DropdownButton<AppLanguage>(
                      value: appLanguage,
                      onChanged: (AppLanguage? value) async {
                        if (value != null) {
                          await ref.read(languageProvider.notifier).setLanguage(value);
                        }
                      },
                      underline: const SizedBox(),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isDarkMode ? const Color(0xFFF472B6) : const Color(0xFFEC4899),
                      ),
                      dropdownColor: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
                      items: [
                        DropdownMenuItem(
                          child: Text(
                            'Türkçe',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? const Color(0xFFF472B6) : const Color(0xFFEC4899),
                            ),
                          ),
                          value: AppLanguage.tr,
                        ),
                        DropdownMenuItem(
                          child: Text(
                            'English',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? const Color(0xFFF472B6) : const Color(0xFFEC4899),
                            ),
                          ),
                          value: AppLanguage.en,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Hesap ve İlerleme
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDarkMode
                      ? const Color(0xFF374151)
                      : const Color(0xFFE5E7EB),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: const Icon(Icons.person_rounded, color: Color(0xFF4F46E5)),
                    title: Text(
                      'Profil ve Hesap',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    subtitle: Text(
                      'Kullanıcı bilgilerini ve hedeflerini düzenle.',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: subtitleColor,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(isDarkMode: isDarkMode),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: const Icon(Icons.today_rounded, color: Color(0xFF4F46E5)),
                    title: Text(
                      'Günün Planı',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    subtitle: Text(
                      'Bugünkü antrenman kartlarını gör.',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: subtitleColor,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GameLauncherScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: const Icon(Icons.bar_chart_rounded, color: Color(0xFF4F46E5)),
                    title: Text(
                      'İlerleme ve İstatistikler',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    subtitle: Text(
                      'Radar grafiği ve detaylı performansın.',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: subtitleColor,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
                    onTap: () {
                      setState(() {
                        _selectedTab = 2;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Hakkında
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDarkMode
                      ? const Color(0xFF374151)
                      : const Color(0xFFE5E7EB),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.info_rounded,
                      color: Color(0xFF059669),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NöroDakika Hakkında',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Zihinsel becerilerini kısa, bilimsel mini oyunlarla takip et ve geliştir. Bu sürüm MVP aşamasındadır.',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            height: 1.4,
                            color: subtitleColor,
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
      ),
    );
  }

}
