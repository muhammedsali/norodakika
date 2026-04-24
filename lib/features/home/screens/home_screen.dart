import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../auth/providers/auth_provider.dart';
import '../../stats/screens/stats_screen.dart';
import '../../stats/providers/user_stats_provider.dart';
import '../../leaderboard/screens/leaderboard_sheet.dart';

import '../../../core/memory/memory_bank.dart';
import '../../../core/models/game_model.dart';
import '../../../services/local_storage_service.dart';
import '../../settings/providers/language_provider.dart';
import '../../settings/providers/theme_provider.dart';
import '../../settings/screens/settings_screen.dart';
import '../../../core/i18n/app_strings.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/game_start_modal.dart';
import '../../profile/providers/avatar_provider.dart';
import '../../../core/widgets/neuron_background.dart';

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
  final ScrollController _homeScrollController = ScrollController();
  final ScrollController _gamesScrollController = ScrollController();
  final ScrollController _statsScrollController = ScrollController();
  final ScrollController _settingsScrollController = ScrollController();
  String _gamesQuery = '';
  String _gamesFilter = 'all';

  // --- YENİ TASARIM RENKLERİ ---
  static const Color stitchBgLight = Color(0xFFF0F2F5);
  static const Color stitchPrimary = Color(0xFF0D59F2);

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
    _homeScrollController.dispose();
    _gamesScrollController.dispose();
    _statsScrollController.dispose();
    _settingsScrollController.dispose();
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

  // YENİ TASARIM: Premium Card Yardımcısı
  BoxDecoration _getNeuDecoration(
      {required bool isDarkMode, bool isCircle = false}) {
    final bgColor = isDarkMode
        ? const Color(0xFF1E293B).withValues(alpha: 0.7)
        : Colors.white.withValues(alpha: 0.9);
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.05);

    return BoxDecoration(
      color: bgColor,
      shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: isCircle ? null : BorderRadius.circular(24),
      border: Border.all(color: borderColor, width: 1.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.05),
          offset: const Offset(0, 8),
          blurRadius: 24,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;
    final appLanguage = ref.watch(languageProvider);
    final s = AppStrings(appLanguage);
    final isDarkMode = ref.watch(themeProvider);
    final customName = ref.watch(customNameProvider).value;
    final userName = customName ??
        user?.displayName ??
        user?.email?.split('@').first ??
        s.userFallback;

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

    // TASARIM: Neumorphic arka plan rengi
    final bgColor = isDarkMode ? const Color(0xFF0F172A) : stitchBgLight;

    return Scaffold(
      extendBody: true,
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // YENİ BÜYÜK GÜNCELLEME: Hareketli Sinapsis Arka Planı
          Positioned.fill(
            child: NeuronBackground(isDarkMode: isDarkMode),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // 1. SABİT HEADER (Sekme değiştikçe yazılar değişir ama yeri kaymaz)
                _buildUnifiedHeader(userName, isDarkMode, s),

                // 2. DEĞİŞEN İÇERİK (IndexedStack sayfalar arası geçişi hızlandırır)
                Expanded(
                  child: IndexedStack(
                    index: _selectedTab,
                    children: [
                      _buildHomeTabBody(context, games),
                      _buildGamesTabBody(context, games),
                      StatsScreen(controller: _statsScrollController),
                      _buildSettingsTabBody(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Telegram tarzı: Alt barın üstünde aşağıya doğru saydamlaşan gradient fade
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      bgColor,
                      bgColor.withValues(alpha: 0.8),
                      bgColor.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
          ),
          if (_showOnboarding) _buildOnboardingOverlay(context, appLanguage),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: HomeBottomNav(
            selectedTab: _selectedTab,
            isDarkMode: isDarkMode,
            language: appLanguage,
            onTabSelected: (index) {
              // Sekmeye geçmeden önce scroll'u sıfırla ki kullanıcı geçiş anında "zıplama" görmesin
              if (index == 0 && _homeScrollController.hasClients) {
                _homeScrollController.jumpTo(0);
              } else if (index == 1 && _gamesScrollController.hasClients) {
                _gamesScrollController.jumpTo(0);
              } else if (index == 2 && _statsScrollController.hasClients) {
                _statsScrollController.jumpTo(0);
              } else if (index == 3 && _settingsScrollController.hasClients) {
                _settingsScrollController.jumpTo(0);
              }

              setState(() {
                _selectedTab = index;
              });
            },
          ),
        ),
      ),
    );
  }

  // YENİ: BİRLEŞTİRİLMİŞ SABİT HEADER
  Widget _buildUnifiedHeader(String userName, bool isDarkMode, AppStrings s) {
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);

    String topText = "";
    String bottomText = "";

    if (_selectedTab == 0) {
      topText = s.homeHello;
      bottomText = userName;
    } else if (_selectedTab == 1) {
      topText = s.homeDiscover;
      bottomText = s.homeAllGames;
    } else if (_selectedTab == 2) {
      topText = s.statsTitle.toUpperCase();
      bottomText = s.statsSubtitle;
    } else {
      bottomText = s.settingsTitle;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: Row(
        children: [
          if (_selectedTab == 0) ...[
            GestureDetector(
              onTap: () => _showAvatarPicker(context),
              child: Consumer(
                builder: (context, ref, child) {
                  final selectedAvatar = ref.watch(avatarProvider);
                  final avatarData = AvatarData.getAvatar(selectedAvatar);
                  return Container(
                    width: 44,
                    height: 44,
                    decoration: _getNeuDecoration(
                            isDarkMode: isDarkMode, isCircle: true)
                        .copyWith(
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5), width: 2),
                    ),
                    child: ClipOval(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: avatarData['colors'] as List<Color>,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Icon(avatarData['icon'] as IconData,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topText,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                    color: subtitleColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  bottomText,
                  style: GoogleFonts.inter(
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
          if (_selectedTab == 0)
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF818CF8), Color(0xFF4F46E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: IconButton(
                    onPressed: () => showLeaderboardSheet(context, ref),
                    icon: const Icon(Icons.emoji_events_rounded,
                        color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHomeTabBody(BuildContext context, List<GameModel> games) {
    final isDarkMode = ref.watch(themeProvider);
    final appLanguage = ref.watch(languageProvider);
    final s = AppStrings(appLanguage);

    // Kullanıcının en zayıf olduğu yetenek alanını bulup o alana yönelik oyun öneren zeki kurgu
    GameModel getRecommendedGame() {
      final stats = ref.watch(userStatsProvider).value;

      if (stats != null && stats.isNotEmpty) {
        final entries = stats.entries.toList();
        if (entries.isNotEmpty) {
          entries.sort((a, b) => (a.value as num).compareTo(b.value as num));
          final weakestArea = entries.first.key;

          // Bu yetenek alanına ait oyunları bul
          final candidateGames =
              games.where((g) => g.area == weakestArea).toList();
          if (candidateGames.isNotEmpty) {
            // Rebuild'lerde oyunun sürekli değişmesini (flicker) engellemek için gün tabanlı sabit seçim
            final daySeed = DateTime.now().day + DateTime.now().month;
            return candidateGames[daySeed % candidateGames.length];
          }
        }
      }

      // Kullanıcının hiç verisi yoksa veya hesaplanamadıysa bugünün oyununu rastgele seç
      final daySeed = DateTime.now().day + DateTime.now().year;
      return games[daySeed % games.length];
    }

    final recommendedGame = getRecommendedGame();

    final completedTodayAsync = ref.watch(todayGameCountProvider);
    final completedToday = completedTodayAsync.value ?? 0;

    // Günde en az 5 oyun oynamasını hedefleyelim
    const plannedToday = 5;

    // Progress en fazla 1.0 (yani %100) olabilir, sınırlandıralım
    double dailyProgress = completedToday / plannedToday;
    if (dailyProgress > 1.0) dailyProgress = 1.0;

    return SingleChildScrollView(
      controller: _homeScrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel(s.homeDailyProgress.toUpperCase(), isDarkMode),
          const SizedBox(height: 12),
          _buildDailyProgressCard(
            isDarkMode: isDarkMode,
            completedToday: completedToday,
            plannedToday: plannedToday,
            progress: dailyProgress,
            s: s,
            onViewDetails: () {
              setState(() {
                _selectedTab = 2;
              });
            },
          ),
          const SizedBox(height: 32),
          _buildSectionLabel(s.homeUpNext.toUpperCase(), isDarkMode),
          const SizedBox(height: 12),
          _buildUpNextCard(
            context: context,
            isDarkMode: isDarkMode,
            game: recommendedGame,
            s: s,
          ),
          const SizedBox(height: 32),
          _buildSectionLabel(s.homeInsights.toUpperCase(), isDarkMode),
          const SizedBox(height: 12),
          _buildCognitiveScoreCard(isDarkMode: isDarkMode, s: s),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text, bool isDarkMode) {
    final c = isDarkMode ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          color: c,
        ),
      ),
    );
  }

  Widget _buildDailyProgressCard({
    required bool isDarkMode,
    required int completedToday,
    required int plannedToday,
    required double progress,
    required AppStrings s,
    required VoidCallback onViewDetails,
  }) {
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _getNeuDecoration(isDarkMode: isDarkMode),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.homeDailyGoalTitle,
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: titleColor),
              ),
              const SizedBox(height: 4),
              Text(
                s.dailyGoalCompleted(completedToday, plannedToday),
                style: GoogleFonts.inter(fontSize: 12, color: subtitleColor),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: onViewDetails,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration:
                      _getNeuDecoration(isDarkMode: isDarkMode).copyWith(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    s.homeViewDetails.toUpperCase(),
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: stitchPrimary),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor:
                      isDarkMode ? const Color(0xFF334155) : Colors.white,
                  strokeCap: StrokeCap.round,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(stitchPrimary),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: titleColor),
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
    required AppStrings s,
  }) {
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      decoration: _getNeuDecoration(isDarkMode: isDarkMode).copyWith(
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              color: stitchPrimary.withValues(alpha: 0.1),
            ),
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(
                'assets/games/${game.id.toLowerCase()}.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.psychology_outlined,
                      size: 40, color: stitchPrimary.withValues(alpha: 0.5));
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(game.name,
                              style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: titleColor)),
                          const SizedBox(height: 2),
                          Text(
                            game.description.isNotEmpty
                                ? game.description
                                : game.area,
                            style: GoogleFonts.inter(
                                fontSize: 11, color: subtitleColor),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer_outlined,
                              size: 10, color: stitchPrimary),
                          const SizedBox(width: 4),
                          Text('2 ${s.homeMinutesShort}',
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF475569))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 40,
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
                    label: Text(s.homeStartTraining,
                        style: GoogleFonts.inter(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: stitchPrimary,
                      foregroundColor: Colors.white,
                      elevation: 10,
                      shadowColor: stitchPrimary.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
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

  Widget _buildCognitiveScoreCard(
      {required bool isDarkMode, required AppStrings s}) {
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final statsAsync = ref.watch(userStatsProvider);

    return statsAsync.when(
      data: (stats) {
        final memory = (stats['Hafıza'] ?? 0).toDouble();
        final focus = (stats['Dikkat'] ?? 0).toDouble();
        final speed = (stats['Refleks'] ?? 0).toDouble();
        final total = memory + focus + speed;
        final globalPts = (total * 10).round();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: _getNeuDecoration(isDarkMode: isDarkMode),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(s.cognitiveScore,
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: titleColor)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        const Icon(Icons.trending_up,
                            size: 12, color: Color(0xFF16A34A)),
                        const SizedBox(width: 4),
                        Text('+12%',
                            style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF16A34A))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5), width: 3),
                      color:
                          isDarkMode ? const Color(0xFF1E293B) : stitchBgLight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('$globalPts',
                            style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: titleColor)),
                        Text(s.globalPts,
                            style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: [
                        _buildMiniInsightBar(s.memoryArea, memory.round(),
                            stitchPrimary, isDarkMode),
                        const SizedBox(height: 12),
                        _buildMiniInsightBar(s.focusArea, focus.round(),
                            const Color(0xFF60A5FA), isDarkMode),
                        const SizedBox(height: 12),
                        _buildMiniInsightBar(s.speedArea, speed.round(),
                            const Color(0xFF818CF8), isDarkMode),
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
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B)),
            ),
            Text(
              value.toString(),
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF0F172A)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: 6,
            backgroundColor:
                isDarkMode ? const Color(0xFF334155) : Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildGamesTabBody(BuildContext context, List<GameModel> games) {
    final isDarkMode = ref.watch(themeProvider);
    final appLanguage = ref.watch(languageProvider);
    final s = AppStrings(appLanguage);

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
      controller: _gamesScrollController,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGamesSearchBar(isDarkMode, s),
          const SizedBox(height: 14),
          _buildGamesFilterChips(isDarkMode, s),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets
                .zero, // MediaQuery padding'inin otomatik eklenmesini engelle
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

  Widget _buildGamesSearchBar(bool isDarkMode, AppStrings s) {
    final hint = isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF9CA3AF);
    final text = isDarkMode ? const Color(0xFFF9FAFB) : const Color(0xFF111827);

    return Container(
      decoration: _getNeuDecoration(isDarkMode: isDarkMode),
      child: TextField(
        controller: _gamesSearchController,
        style: GoogleFonts.inter(fontSize: 13, color: text),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search_rounded, color: hint),
          hintText: s.gamesSearchHint,
          hintStyle: GoogleFonts.inter(fontSize: 13, color: hint),
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
          accentColor: stitchPrimary,
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
    final inactiveBg = isDarkMode ? const Color(0xFF1F2937) : stitchBgLight;
    const activeText = Colors.white;
    final inactiveText = accentColor;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _gamesFilter = filterKey;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.fastOutSlowIn,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: isActive ? activeBg : inactiveBg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: accentColor.withValues(
                  alpha: isActive ? 0.0 : (isDarkMode ? 0.55 : 0.45)),
              width: 1.2,
            ),
            boxShadow: isActive
                ? []
                : [
                    BoxShadow(
                      color: isDarkMode
                          ? Colors.black.withValues(alpha: 0.2)
                          : const Color(0xFFD1D9E6).withValues(alpha: 0.5),
                      blurRadius: 10,
                      offset: const Offset(4, 4),
                    ),
                  ],
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
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
        return const Color(0xFF7C3AED);
      case 'logical':
        return const Color(0xFF2563EB);
      case 'visual':
        return const Color(0xFF0EA5E9);
      case 'bodily':
        return const Color(0xFFF97316);
      case 'musical':
        return const Color(0xFFEC4899);
      case 'social':
        return const Color(0xFF10B981);
      case 'intrapersonal':
        return const Color(0xFF14B8A6);
      case 'naturalist':
        return const Color(0xFF22C55E);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Widget _buildStitchGameCard({
    required BuildContext context,
    required GameModel game,
    required bool isDarkMode,
  }) {
    final titleColor =
        isDarkMode ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final subtitleColor =
        isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    final iconData = GameStartModal.getGameIconData(game.id);
    final icon = iconData['icon'] as IconData;
    final lang = ref.watch(languageProvider);
    final s = AppStrings(lang);
    final intelligenceKey = game.intelligence;
    final intelLabel = s.intelligenceLabel(intelligenceKey);
    final intelColor = _getIntelligenceColor(intelligenceKey);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          HapticFeedback.lightImpact();
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
          padding: const EdgeInsets.all(12),
          decoration: _getNeuDecoration(isDarkMode: isDarkMode),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color:
                        intelColor.withValues(alpha: isDarkMode ? 0.25 : 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                intelColor.withValues(alpha: 0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Icon(icon, color: intelColor, size: 42),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                game.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.category_rounded, size: 12, color: intelColor),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      intelLabel,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: intelColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                game.area,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: subtitleColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTabBody() {
    return SettingsScreen(controller: _settingsScrollController);
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
      {'title': s.onboardingWelcomeTitle, 'text': s.onboardingWelcomeText},
      {'title': s.onboardingDailyTitle, 'text': s.onboardingDailyText},
      {'title': s.onboardingProgressTitle, 'text': s.onboardingProgressText},
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
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () async {
                      setState(() {
                        _showOnboarding = false;
                      });
                      await LocalStorageService.setOnboardingSeen();
                    },
                    child: Text(s.onboardingSkip,
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: textColor)),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text('Norodakika',
                          style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textColor)),
                      const SizedBox(height: 12),
                      Text(current['title'] as String,
                          style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: titleColor)),
                      const SizedBox(height: 16),
                      Text(current['text'] as String,
                          style: GoogleFonts.inter(
                              fontSize: 15, height: 1.6, color: textColor)),
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
                                  ? stitchPrimary
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
                      backgroundColor: stitchPrimary,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: stitchPrimary.withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999)),
                    ),
                    child: Text(
                      _onboardingStep < steps.length - 1
                          ? s.onboardingNext
                          : s.onboardingStart,
                      style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.w600),
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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                        color: isDarkMode ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 20),
                Text(s.chooseAvatarTitle,
                    style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? Colors.white
                            : const Color(0xFF111827))),
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
                              end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          boxShadow: [
                            BoxShadow(
                                color: (avatar['colors'] as List<Color>)[0]
                                    .withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4))
                          ],
                        ),
                        child: Center(
                          child: Icon(avatar['icon'] as IconData,
                              color: Colors.white, size: 40),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _showGameStartSheet({
    required BuildContext context,
    required String gameId,
    required String title,
    required String description,
    required bool isDarkMode,
  }) {
    GameStartModal.show(
      context: context,
      ref: ref,
      gameId: gameId,
      title: title,
      description: description,
      isDarkMode: isDarkMode,
    );
  }
}
