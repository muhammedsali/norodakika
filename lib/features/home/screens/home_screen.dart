import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/providers/auth_provider.dart';
import '../../daily_plan/screens/daily_plan_screen.dart';
import '../../stats/screens/stats_screen.dart';
import '../../game_launcher/screens/game_launcher_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../../core/memory/memory_bank.dart';
import '../../../core/models/game_model.dart';
import 'all_games_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedCategory = 'Tümü';
  bool _isDarkMode = false;
  int _selectedTab = 0; // 0: Ana Sayfa, 1: Oyunlar

  @override
  Widget build(BuildContext context) {
    final userEmail = ref.watch(currentUserProvider);
    final userName = userEmail?.split('@').first ?? 'Kullanıcı';
    
    final games = MemoryBank.games
        .map((g) => GameModel.fromMap(g))
        .toList();

    return Scaffold(
      backgroundColor:
          _isDarkMode ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            // Üst Header
            _buildHeader(userName),
            
            Expanded(
              child: _selectedTab == 0
                  ? _buildHomeTabBody(context, games)
                  : _buildGamesTabBody(context, games),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: _buildBottomNav(),
      ),
    );
  }

  void _showGameStartSheet({
    required BuildContext context,
    required String gameId,
    required String title,
    required String description,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final themeBg =
            _isDarkMode ? const Color(0xFF111827) : Colors.white;
        final titleColor =
            _isDarkMode ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
        final textColor =
            _isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563);

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: themeBg,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nasıl oynanır?',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GameLauncherScreen(gameId: gameId),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: Text(
                      'Oyunu Başlat',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAllGamesCard(BuildContext context, GameModel game) {
    return InkWell(
      onTap: () {
        _showGameStartSheet(
          context: context,
          gameId: game.id,
          title: game.name,
          description: game.description.isNotEmpty
              ? game.description
              : game.area,
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isDarkMode ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                _isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              game.name,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color:
                    _isDarkMode ? const Color(0xFFF9FAFB) : const Color(0xFF111827),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              game.area,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                color:
                    _isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Icon(
                Icons.play_arrow_rounded,
                color: const Color(0xFF818CF8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTabBody(BuildContext context, List<GameModel> games) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPrimaryCtaButton(context),
          const SizedBox(height: 24),
          _buildProgressSection(),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mini Oyunlar',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color:
                      _isDarkMode ? const Color(0xFFF9FAFB) : const Color(0xFF111827),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllGamesScreen(),
                    ),
                  );
                },
                child: Text(
                  'Tüm oyunlar',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF4F46E5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildMiniGamesGrid(context, games),
        ],
      ),
    );
  }

  Widget _buildGamesTabBody(BuildContext context, List<GameModel> games) {
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
              color: _isDarkMode ? const Color(0xFFF9FAFB) : const Color(0xFF111827),
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
              return _buildAllGamesCard(context, game);
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildPrimaryCtaButton(BuildContext context) {
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
                    builder: (context) => const DailyPlanScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isDarkMode ? const Color(0xFF1F2937) : const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor:
                    (_isDarkMode ? const Color(0xFF818CF8) : const Color(0xFF4F46E5))
                        .withOpacity(0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                  side: _isDarkMode
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

  Widget _buildProgressSection() {
    // Şimdilik sabit %40; ileride gerçek verilere bağlanabilir
    const progress = 0.4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            color:
                _isDarkMode ? const Color(0xFF1F2937) : Colors.grey[300],
            borderRadius: BorderRadius.circular(999),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF818CF8),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Bugünkü hedefinin %40ını tamamladın!',
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            color:
                _isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniGamesGrid(BuildContext context, List<GameModel> games) {
    // HTML tasarımdaki gibi 4 statik mini oyun kartı göster
    final miniGames = [
      {
        'id': 'MEM02',
        'title': 'Hafıza Matrisi',
        'subtitle': 'Kısa süreli hafızanı zorla ve güçlendir.',
        'icon': Icons.grid_view_rounded,
      },
      {
        'id': 'LOG01',
        'title': 'Mantık Işıkları',
        'subtitle': 'Işık desenleriyle mantık bulmacalarını çöz.',
        'icon': Icons.lightbulb_outline,
      },
      {
        'id': 'ATT01',
        'title': 'Odak Akışı',
        'subtitle': 'Dikkat ve konsantrasyon süreni artır.',
        'icon': Icons.center_focus_strong,
      },
      {
        'id': 'MEM01',
        'title': 'Desen Yolu',
        'subtitle': 'Karmaşık görsel desenleri tanı ve tamamla.',
        'icon': Icons.timeline,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: miniGames.length,
      itemBuilder: (context, index) {
        final item = miniGames[index];

        return InkWell(
          onTap: () {
            _showGameStartSheet(
              context: context,
              gameId: item['id'] as String,
              title: item['title'] as String,
              description: item['subtitle'] as String,
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isDarkMode
                  ? const Color(0xFF1F2937)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isDarkMode
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF818CF8).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: const Color(0xFF4F46E5),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  item['title'] as String,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color:
                        _isDarkMode ? const Color(0xFFF9FAFB) : const Color(0xFF111827),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  item['subtitle'] as String,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    color:
                        _isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(String userName) {
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF10B981)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Hoş geldin mesajı
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cortex Kullanıcısı',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          _isDarkMode ? const Color(0xFFF9FAFB) : const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (_isDarkMode
                              ? const Color(0xFF818CF8)
                              : const Color(0xFF4F46E5))
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Görev: 2/5',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color:
                            _isDarkMode ? const Color(0xFFF9FAFB) : const Color(0xFF4F46E5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Gece/Gündüz modu butonu
            IconButton(
              icon: Icon(
                _isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color:
                    _isDarkMode ? Colors.white : const Color(0xFF4B5563),
              ),
              onPressed: () {
                setState(() {
                  _isDarkMode = !_isDarkMode;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    final categories = ['Tümü', 'Reflex Tap', 'N-Back Mini', 'Stroop Tap', 'Hızlı Matematik'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Kategoriler',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = _selectedCategory == category;
              
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF7F0DF2)
                          : const Color(0xFF1F1630),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFB47CFF)
                            : const Color(0xFF7F0DF2).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGamesGrid(List<Map<String, dynamic>> games) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75, // Daha küçük değer = daha yüksek kartlar
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = GameModel.fromMap(games[index]);
        return _buildGameCard(game);
      },
    );
  }

  Widget _buildGameCard(GameModel game) {
    IconData iconData;
    String subtitle;
    String displayName;
    
    switch (game.id) {
      case 'REF01':
        iconData = Icons.touch_app;
        subtitle = 'Reflekslerini test et';
        displayName = 'Reflex Tap';
        break;
      case 'MEM01':
        iconData = Icons.memory;
        subtitle = 'Hafızanı güçlendir';
        displayName = 'N-Back Mini';
        break;
      case 'ATT01':
        iconData = Icons.palette;
        subtitle = 'Odaklanma becerisi';
        displayName = 'Stroop Tap';
        break;
      case 'NUM01':
        iconData = Icons.calculate;
        subtitle = 'Sayısal zeka';
        displayName = 'Hızlı Matematik';
        break;
      default:
        iconData = Icons.games;
        subtitle = game.description;
        displayName = game.name;
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameLauncherScreen(gameId: game.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1F1630),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF7F0DF2).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7F0DF2).withOpacity(0.2),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // İkon
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7F0DF2), Color(0xFF00E0FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  iconData,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Başlık ve Alt Başlık
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayName,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      subtitle,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: Colors.white60,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildDailyWorkoutButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7F0DF2), Color(0xFF00E0FF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7F0DF2).withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DailyPlanScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Center(
              child: Text(
                'Başla: Günün Antrenmanı',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _isDarkMode ? const Color(0xFF111827) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_rounded, 'Ana Sayfa', _selectedTab == 0, () {
              setState(() {
                _selectedTab = 0;
              });
            }),
            _buildNavItem(Icons.category_rounded, 'Oyunlar', _selectedTab == 1, () {
              setState(() {
                _selectedTab = 1;
              });
            }),
            _buildNavItem(Icons.bar_chart_rounded, 'İlerleme', false, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatsScreen(),
                ),
              );
            }),
            _buildNavItem(Icons.settings_rounded, 'Ayarlar', false, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF4F46E5)
                  : (_isDarkMode ? Colors.white70 : const Color(0xFF4B5563)),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF4F46E5)
                    : (_isDarkMode ? Colors.white70 : const Color(0xFF4B5563)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
