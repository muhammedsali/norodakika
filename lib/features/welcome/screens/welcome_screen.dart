import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/memory/memory_bank.dart';
import '../../../core/models/game_model.dart';
import '../../shared/widgets/game_card_widgets.dart';
import '../../settings/providers/theme_provider.dart';
import '../../auth/screens/auth_gate_screen.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final games = MemoryBank.games
        .map((g) => GameModel.fromMap(g))
        .toList();

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NöroDakika',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode
                          ? const Color(0xFFF9FAFB)
                          : const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Zihnini geliştiren mini oyunlar',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      color: isDarkMode
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF4B5563),
                    ),
                  ),
                ],
              ),
            ),

            // Game Cards Grid
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Text(
                        'Oyunlar',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? const Color(0xFFF9FAFB)
                              : const Color(0xFF111827),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
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
                            _showLoginPrompt(context, isDarkMode);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Bottom CTA Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AuthGateScreen(),
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
                            .withOpacity(0.35),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow_rounded, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Hadi Oynayalım',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLoginPrompt(BuildContext context, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (ctx) {
        final themeBg = isDarkMode ? const Color(0xFF111827) : Colors.white;
        final titleColor =
            isDarkMode ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
        final textColor =
            isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563);

        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 420,
                  minHeight: 200,
                ),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: themeBg,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 32,
                      offset: Offset(0, 16),
                    ),
                  ],
                  border: Border.all(
                    color: isDarkMode
                        ? const Color(0xFF374151)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Giriş Yapın',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: titleColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Oyunları oynamak ve ilerlemenizi takip etmek için giriş yapmanız gerekiyor.',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14,
                                  height: 1.4,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          splashRadius: 20,
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                          icon: Icon(
                            Icons.close_rounded,
                            size: 22,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AuthGateScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'Giriş Yap / Üye Ol',
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
            ),
          ),
        );
      },
    );
  }
}
