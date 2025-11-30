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
    // Her oyun için ikon + iki renkli gradient belirle
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

    return InkWell
        (
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
      borderRadius: BorderRadius.circular(28),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.4),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sol üstte ikonlu küçük kart
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    leadingIcon,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
              const Spacer(),
              // Oyun ismi
              Text(
                game.name,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Alt açıklama satırı (bölge bilgisi)
              Text(
                game.area,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.85),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Sol altta play butonu
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.22),
                ),
                child: Center(
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      size: 18,
                      color: gradientColors.first,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

