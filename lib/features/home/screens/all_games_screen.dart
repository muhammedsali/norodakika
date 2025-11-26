import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/memory/memory_bank.dart';
import '../../../core/models/game_model.dart';
import '../../game_launcher/screens/game_launcher_screen.dart';

class AllGamesScreen extends StatelessWidget {
  const AllGamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final games = MemoryBank.games
        .map((g) => GameModel.fromMap(g))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF090712),
      appBar: AppBar(
        backgroundColor: const Color(0xFF090712),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Tüm Mini Oyunlar',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: games.length,
          itemBuilder: (context, index) {
            final game = games[index];
            return _AllGamesCard(game: game);
          },
        ),
      ),
    );
  }
}

class _AllGamesCard extends StatelessWidget {
  final GameModel game;

  const _AllGamesCard({required this.game});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameLauncherScreen(gameId: game.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1F1630),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF7F0DF2).withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              game.name,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              game.area,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                color: Colors.white70,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Icon(
                Icons.play_arrow_rounded,
                color: const Color(0xFF00E0FF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
