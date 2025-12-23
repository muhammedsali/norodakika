import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/memory/memory_bank.dart';
import '../../../core/models/game_model.dart';
import '../../settings/providers/theme_provider.dart';
import '../../shared/widgets/game_card_widgets.dart';
import '../screens/game_play_screen.dart';

class GameLauncherScreen extends ConsumerWidget {
  final String? gameId;
  final bool isDailyPlan;

  const GameLauncherScreen({
    super.key,
    this.gameId,
    this.isDailyPlan = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    
    // Günlük plan modunda ise, günlük planı al
    List<Map<String, dynamic>> displayItems;
    if (isDailyPlan && gameId == null) {
      displayItems = MemoryBank.generateDailyPlan();
    } else {
      // Normal mod: tüm oyunları veya belirli bir oyunu göster
      final games = MemoryBank.games
          .map((g) => GameModel.fromMap(g))
          .toList();
      
      displayItems = gameId != null
          ? games.where((g) => g.id == gameId).map((g) => {
              'id': g.id,
              'duration': 30,
            }).toList()
          : games.map((g) => {
              'id': g.id,
              'duration': 30,
            }).toList();
    }

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF111827) : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : const Color(0xFF6E00FF),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isDailyPlan && gameId == null ? 'Günün Antrenmanı' : (gameId != null ? 'Oyun' : '7 Mini Oyun'),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        bottom: isDailyPlan && gameId == null ? PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(
              'Bugün için önerilen oyunlar. Her oyunu sırayla oynayarak beyin antrenmanını tamamla!',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ) : null,
      ),
      body: SafeArea(
        child: displayItems.isEmpty
            ? Center(
                child: Text(
                  'Bugün için plan yok',
                  style: GoogleFonts.poppins(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              )
            : isDailyPlan && gameId == null
                ? ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: displayItems.length,
                    itemBuilder: (context, index) {
                      final planItem = displayItems[index];
                      final itemGameId = planItem['id'] as String;
                      final duration = planItem['duration'] as int;
                      
                      final gameMap = MemoryBank.games.firstWhere(
                        (g) => g['id'] == itemGameId,
                        orElse: () => {},
                      );
                      
                      if (gameMap.isEmpty) return const SizedBox.shrink();
                      
                      final game = GameModel.fromMap(gameMap);
                      return UnifiedGameCard(
                        gameId: game.id,
                        title: game.name,
                        subtitle: game.area,
                        isDarkMode: isDarkMode,
                        orderNumber: index + 1,
                        duration: duration,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GamePlayScreen(
                                game: game,
                                isDarkOverride: isDarkMode,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: displayItems.length,
                    itemBuilder: (context, index) {
                      final planItem = displayItems[index];
                      final itemGameId = planItem['id'] as String;
                      
                      final gameMap = MemoryBank.games.firstWhere(
                        (g) => g['id'] == itemGameId,
                        orElse: () => {},
                      );
                      
                      if (gameMap.isEmpty) return const SizedBox.shrink();
                      
                      final game = GameModel.fromMap(gameMap);
                      return UnifiedGameCard(
                        gameId: game.id,
                        title: game.name,
                        subtitle: game.area,
                        isDarkMode: isDarkMode,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GamePlayScreen(
                                game: game,
                                isDarkOverride: isDarkMode,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
      ),
    );
  }

}

