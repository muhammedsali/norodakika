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

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedCategory = 'Tümü';

  @override
  Widget build(BuildContext context) {
    final userEmail = ref.watch(currentUserProvider);
    final userName = userEmail?.split('@').first ?? 'Kullanıcı';
    
    // Kategorileri filtrele
    final filteredGames = _selectedCategory == 'Tümü'
        ? MemoryBank.games
        : MemoryBank.games.where((g) {
            final game = GameModel.fromMap(g);
            return game.name == _selectedCategory || 
                   game.area.contains(_selectedCategory);
          }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF191022),
      body: SafeArea(
        child: Column(
          children: [
            // Üst Header
            _buildHeader(userName),
            
            // Kategoriler
            _buildCategoriesSection(),
            
            // Oyun Kartları
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildGamesGrid(filteredGames),
              ),
            ),
            
            // Günün Antrenmanı Butonu
            _buildDailyWorkoutButton(),
            
            // Alt Navigasyon
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String userName) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Profil Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF7F0DF2).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF7F0DF2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Hoş geldin mesajı
          Expanded(
            child: Text(
              'Hoş geldin, $userName!',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          
          // Ayarlar butonu
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
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
          height: 32,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = _selectedCategory == category;
              
              return Padding(
                padding: const EdgeInsets.only(right: 12),
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
                          ? const Color(0xFF7F0DF2).withOpacity(0.2)
                          : const Color(0xFF7F0DF2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
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
          color: const Color(0xFF7F0DF2).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
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
                  color: const Color(0xFF7F0DF2).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  iconData,
                  color: const Color(0xFF7F0DF2),
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
          color: const Color(0xFF7F0DF2),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7F0DF2).withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 4,
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
      decoration: BoxDecoration(
        color: const Color(0xFF191022).withOpacity(0.8),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Ana Sayfa', true, () {}),
          _buildNavItem(Icons.bar_chart, 'İstatistik', false, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StatsScreen(),
              ),
            );
          }),
          _buildNavItem(Icons.emoji_events, 'Sıralama', false, () {
            // TODO: Sıralama ekranı eklenecek
          }),
          _buildNavItem(Icons.person, 'Profil', false, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );
          }),
        ],
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
                  ? const Color(0xFF7F0DF2)
                  : Colors.white60,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF7F0DF2)
                    : Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
