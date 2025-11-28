import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/memory/memory_bank.dart';
import '../../../core/models/game_model.dart';
import '../screens/game_play_screen.dart';

class GameLauncherScreen extends StatelessWidget {
  final String? gameId;

  const GameLauncherScreen({
    super.key,
    this.gameId,
  });

  @override
  Widget build(BuildContext context) {
    final games = MemoryBank.games
        .map((g) => GameModel.fromMap(g))
        .toList();

    // Eğer belirli bir oyun ID'si verilmişse, sadece onu göster
    final displayGames = gameId != null
        ? games.where((g) => g.id == gameId).toList()
        : games;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6E00FF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          gameId != null ? 'Oyun' : '7 Mini Oyun',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: displayGames.length,
          itemBuilder: (context, index) {
            final game = displayGames[index];
            return _buildGameCard(context, game);
          },
        ),
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, GameModel game) {
    // Basit görsel stil: her oyun için farklı ikon ve renk paleti
    IconData leadingIcon;
    List<Color> gradientColors;

    switch (game.id) {
      case 'REF01':
      case 'REF02':
        leadingIcon = Icons.bolt_rounded;
        gradientColors = const [Color(0xFF6366F1), Color(0xFF22C55E)];
        break;
      case 'ATT01':
      case 'ATT02':
        leadingIcon = Icons.visibility_rounded;
        gradientColors = const [Color(0xFFF97316), Color(0xFFEC4899)];
        break;
      case 'MEM01':
      case 'MEM02':
      case 'MEM03':
        leadingIcon = Icons.grid_view_rounded;
        gradientColors = const [Color(0xFF0EA5E9), Color(0xFF6366F1)];
        break;
      case 'NUM01':
        leadingIcon = Icons.calculate_rounded;
        gradientColors = const [Color(0xFFFACC15), Color(0xFFF97316)];
        break;
      case 'LOG01':
        leadingIcon = Icons.extension_rounded;
        gradientColors = const [Color(0xFF22C55E), Color(0xFF0EA5E9)];
        break;
      case 'LANG02':
        leadingIcon = Icons.text_fields_rounded;
        gradientColors = const [Color(0xFFEC4899), Color(0xFF6366F1)];
        break;
      default:
        leadingIcon = Icons.games_rounded;
        gradientColors = const [Color(0xFF6E00FF), Color(0xFF6366F1)];
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GamePlayScreen(
              game: game,
              isDarkOverride: null,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    leadingIcon,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                game.name,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                game.area,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

