import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/memory/memory_bank.dart';
import '../../../core/models/game_model.dart';
import '../../game_launcher/screens/game_play_screen.dart';
import '../../settings/providers/language_provider.dart';

class GameStartModal {
  static void show({
    required BuildContext context,
    required WidgetRef ref,
    required String gameId,
    required String title,
    required String description,
    required bool isDarkMode,
  }) {
    final iconData = getGameIconData(gameId);
    final gameColor = iconData['color'] as Color;
    final emoji = iconData['emoji'] as String;
    final lang = ref.read(languageProvider);
    final s = AppStrings(lang);

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: isDarkMode ? 0.85 : 0.55),
      builder: (ctx) {
        // ─── Premium Tema Renkleri ──────────────────────────────
        final Color dialogBg = isDarkMode ? const Color(0xFF111827) : Colors.white;
        final Color titleColor = isDarkMode ? const Color(0xFFF9FAFB) : const Color(0xFF0F172A);
        final Color subtitleColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF475569);
        final Color cardBg = isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
        final Color borderColor = isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05);

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: dialogBg,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDarkMode ? 0.6 : 0.15),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
                BoxShadow(
                  color: gameColor.withValues(alpha: isDarkMode ? 0.15 : 0.1),
                  blurRadius: 30,
                  spreadRadius: -10,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ─── Header: Glassmorphism Efekti ─────────────────
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 28, 16, 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          gameColor.withValues(alpha: isDarkMode ? 0.25 : 0.12),
                          gameColor.withValues(alpha: isDarkMode ? 0.1 : 0.04),
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        // Oyun İkonu / Resmi
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: gameColor.withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Stack(
                              children: [
                                Image.asset(
                                  'assets/games/${gameId.toLowerCase()}.png',
                                  fit: BoxFit.cover,
                                  width: 72,
                                  height: 72,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: gameColor,
                                    child: Center(
                                      child: Text(emoji, style: const TextStyle(fontSize: 36)),
                                    ),
                                  ),
                                ),
                                // Parlama efekti
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white.withValues(alpha: 0.2),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: GoogleFonts.outfit(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: titleColor,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : gameColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.timer_rounded, size: 14, color: isDarkMode ? Colors.white70 : gameColor),
                                    const SizedBox(width: 6),
                                    Text(
                                      s.approxTwoThreeMinutes,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDarkMode ? Colors.white70 : gameColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Kapat Butonu
                        IconButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(ctx).pop();
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close_rounded, size: 18, color: subtitleColor),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ─── Body: Nasıl Oynanır ──────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              if (!isDarkMode)
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.auto_awesome_rounded, size: 18, color: gameColor),
                                  const SizedBox(width: 10),
                                  Text(
                                    s.howToPlay,
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: titleColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                description,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  height: 1.6,
                                  color: subtitleColor,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ─── CTA: Oyunu Başlat ────────────────────────
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            Navigator.of(ctx).pop();
                            final allGames = MemoryBank.games.map((g) => GameModel.fromMap(g)).toList();
                            final selectedGame = allGames.firstWhere((g) => g.id == gameId, orElse: () => allGames.first);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GamePlayScreen(game: selectedGame, isDarkOverride: isDarkMode),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [gameColor, gameColor.withValues(alpha: 0.8)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: gameColor.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Parlama efekti (üst kısım)
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  height: 1,
                                  child: Container(color: Colors.white.withValues(alpha: 0.3)),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 28),
                                    const SizedBox(width: 12),
                                    Text(
                                      s.startGame.toUpperCase(),
                                      style: GoogleFonts.outfit(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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

  static Map<String, dynamic> getGameIconData(String gameId) {
    switch (gameId) {
      case 'MEM01':
        return {
          'icon': Icons.grid_on,
          'color': const Color(0xFF6366F1),
          'emoji': '🧩'
        };
      case 'ATT01':
        return {
          'icon': Icons.remove_red_eye,
          'color': const Color(0xFFF59E0B),
          'emoji': '👀'
        };
      case 'SPE01':
        return {
          'icon': Icons.bolt,
          'color': const Color(0xFFEF4444),
          'emoji': '⚡'
        };
      case 'FLE01':
        return {
          'icon': Icons.psychology,
          'color': const Color(0xFF10B981),
          'emoji': '🧠'
        };
      case 'MATH01':
        return {
          'icon': Icons.calculate,
          'color': const Color(0xFF8B5CF6),
          'emoji': '🔢'
        };
      case 'LANG01':
        return {
          'icon': Icons.translate,
          'color': const Color(0xFFEC4899),
          'emoji': '🔤'
        };
      case 'LOG01':
        return {
          'icon': Icons.extension,
          'color': const Color(0xFF3B82F6),
          'emoji': '🧩'
        };
      case 'VER01':
        return {
          'icon': Icons.record_voice_over,
          'color': const Color(0xFF6366F1),
          'emoji': '🗣️'
        };
      case 'VIS01':
        return {
          'icon': Icons.visibility,
          'color': const Color(0xFFF59E0B),
          'emoji': '👁️'
        };
      case 'MUS01':
        return {
          'icon': Icons.music_note,
          'color': const Color(0xFFEC4899),
          'emoji': '🎵'
        };
      case 'SOC01':
        return {
          'icon': Icons.emoji_emotions,
          'color': const Color(0xFFEC4899),
          'emoji': '🙂'
        };
      case 'NAT01':
        return {
          'icon': Icons.nature,
          'color': const Color(0xFF10B981),
          'emoji': '🌿'
        };
      case 'KIN01':
        return {
          'icon': Icons.sports_martial_arts,
          'color': const Color(0xFF3B82F6),
          'emoji': '⚖️'
        };
      case 'SPA01':
        return {
          'icon': Icons.route,
          'color': const Color(0xFF8B5CF6),
          'emoji': '🧭'
        };
      case 'INT01':
        return {
          'icon': Icons.self_improvement,
          'color': const Color(0xFF06B6D4),
          'emoji': '🧘'
        };
      default:
        return {
          'icon': Icons.sports_esports,
          'color': const Color(0xFF4F46E5),
          'emoji': '🎮'
        };
    }
  }
}
