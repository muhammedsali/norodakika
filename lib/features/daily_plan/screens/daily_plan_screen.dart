import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/memory/memory_bank.dart';
import '../../../core/models/game_model.dart';
import '../../settings/providers/theme_provider.dart';
import '../../game_launcher/screens/game_launcher_screen.dart';

class DailyPlanScreen extends ConsumerWidget {
  const DailyPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyPlan = MemoryBank.generateDailyPlan();
    final isDarkMode = ref.watch(themeProvider);

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
          'Bugünkü Plan',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: SafeArea(
        child: dailyPlan.isEmpty
            ? Center(
                child: Text(
                  'Bugün için plan yok',
                  style: GoogleFonts.poppins(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: dailyPlan.length,
                itemBuilder: (context, index) {
                  final planItem = dailyPlan[index];
                  final gameId = planItem['id'] as String;
                  final duration = planItem['duration'] as int;
                  
                  // Oyun bilgisini bul
                  final gameMap = MemoryBank.games.firstWhere(
                    (g) => g['id'] == gameId,
                    orElse: () => {},
                  );
                  
                  if (gameMap.isEmpty) return const SizedBox.shrink();
                  
                  final game = GameModel.fromMap(gameMap);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameLauncherScreen(
                              gameId: gameId,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFF6E00FF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.play_circle_outline,
                                color: Color(0xFF6E00FF),
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    game.name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: isDarkMode ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${duration} saniye • ${game.area}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

