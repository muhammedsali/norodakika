import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/game_model.dart';

class UnifiedGameCard extends StatelessWidget {
  final String gameId;
  final String title;
  final String subtitle;
  final bool isDarkMode;
  final VoidCallback onTap;
  final int? orderNumber;
  final int? duration;

  const UnifiedGameCard({
    super.key,
    required this.gameId,
    required this.title,
    required this.subtitle,
    required this.isDarkMode,
    required this.onTap,
    this.orderNumber,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = _getGradientColors(gameId);
    final icon = _getIcon(gameId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          splashColor: gradientColors.first.withOpacity(0.1),
          highlightColor: gradientColors.first.withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  gradientColors.first.withOpacity(isDarkMode ? 0.15 : 0.08),
                  gradientColors.last.withOpacity(isDarkMode ? 0.1 : 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: gradientColors.first.withOpacity(isDarkMode ? 0.3 : 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.first.withOpacity(isDarkMode ? 0.2 : 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors.first.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: orderNumber != null
                        ? Text(
                            '$orderNumber',
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          )
                        : Icon(
                            icon,
                            color: Colors.white,
                            size: 32,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (duration != null)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.black.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.timer_rounded,
                                    size: 14,
                                    color: gradientColors.first,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$duration sn',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDarkMode
                                          ? Colors.white.withOpacity(0.9)
                                          : const Color(0xFF374151),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      gradientColors.first.withOpacity(0.2),
                                      gradientColors.last.withOpacity(0.2),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  subtitle,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: gradientColors.first,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode
                                ? Colors.grey[400]
                                : const Color(0xFF6B7280),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors.first.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String gameId) {
    switch (gameId) {
      case 'REF01':
      case 'REF02':
        return Icons.bolt_rounded;
      case 'ATT01':
      case 'ATT02':
        return Icons.visibility_rounded;
      case 'MEM01':
      case 'MEM02':
      case 'MEM03':
        return Icons.grid_view_rounded;
      case 'NUM01':
        return Icons.calculate_rounded;
      case 'LOG01':
        return Icons.extension_rounded;
      case 'LANG02':
        return Icons.text_fields_rounded;
      default:
        return Icons.games_rounded;
    }
  }

  List<Color> _getGradientColors(String gameId) {
    switch (gameId) {
      case 'REF01':
      case 'REF02':
        return const [Color(0xFF6366F1), Color(0xFF22C55E)];
      case 'ATT01':
      case 'ATT02':
        return const [Color(0xFFF97316), Color(0xFFEC4899)];
      case 'MEM01':
      case 'MEM02':
      case 'MEM03':
        return const [Color(0xFF0EA5E9), Color(0xFF6366F1)];
      case 'NUM01':
        return const [Color(0xFFFACC15), Color(0xFFF97316)];
      case 'LOG01':
        return const [Color(0xFF22C55E), Color(0xFF0EA5E9)];
      case 'LANG02':
        return const [Color(0xFFEC4899), Color(0xFF6366F1)];
      default:
        return const [Color(0xFF6E00FF), Color(0xFF6366F1)];
    }
  }
}

class GridGameCard extends StatelessWidget {
  final String gameId;
  final String title;
  final String area;
  final bool isDarkMode;
  final VoidCallback onTap;

  const GridGameCard({
    super.key,
    required this.gameId,
    required this.title,
    required this.area,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = _getGradientColors(gameId);
    final icon = _getIcon(gameId);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        splashColor: gradientColors.first.withOpacity(0.1),
        highlightColor: gradientColors.first.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                gradientColors.first.withOpacity(isDarkMode ? 0.15 : 0.08),
                gradientColors.last.withOpacity(isDarkMode ? 0.1 : 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: gradientColors.first.withOpacity(isDarkMode ? 0.3 : 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: gradientColors.first.withOpacity(isDarkMode ? 0.2 : 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      gradientColors.first.withOpacity(0.2),
                      gradientColors.last.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  area,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: gradientColors.first,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors.first.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: 36,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
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

  IconData _getIcon(String gameId) {
    switch (gameId) {
      case 'REF01':
      case 'REF02':
        return Icons.bolt_rounded;
      case 'ATT01':
      case 'ATT02':
        return Icons.visibility_rounded;
      case 'MEM01':
      case 'MEM02':
      case 'MEM03':
        return Icons.grid_view_rounded;
      case 'NUM01':
        return Icons.calculate_rounded;
      case 'LOG01':
        return Icons.extension_rounded;
      case 'LANG02':
        return Icons.text_fields_rounded;
      default:
        return Icons.games_rounded;
    }
  }

  List<Color> _getGradientColors(String gameId) {
    switch (gameId) {
      case 'REF01':
      case 'REF02':
        return const [Color(0xFF6366F1), Color(0xFF22C55E)];
      case 'ATT01':
      case 'ATT02':
        return const [Color(0xFFF97316), Color(0xFFEC4899)];
      case 'MEM01':
      case 'MEM02':
      case 'MEM03':
        return const [Color(0xFF0EA5E9), Color(0xFF6366F1)];
      case 'NUM01':
        return const [Color(0xFFFACC15), Color(0xFFF97316)];
      case 'LOG01':
        return const [Color(0xFF22C55E), Color(0xFF0EA5E9)];
      case 'LANG02':
        return const [Color(0xFFEC4899), Color(0xFF6366F1)];
      default:
        return const [Color(0xFF6E00FF), Color(0xFF6366F1)];
    }
  }
}
