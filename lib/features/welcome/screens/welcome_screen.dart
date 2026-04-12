import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/memory/memory_bank.dart';
import '../../settings/providers/theme_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../../core/widgets/neuron_background.dart';

// ─── Oyun Kartı Veri Modeli ───────────────────────────────
class _GameCardData {
  final IconData icon;
  final Color iconColorLight;
  final Color iconColorDark;
  final String title;
  final String subtitle;
  final Color backgroundColorLight;
  final Color backgroundColorDark;
  final Color gradientColorLight;
  final Color gradientColorDark;

  const _GameCardData({
    required this.icon,
    required this.iconColorLight,
    required this.iconColorDark,
    required this.title,
    required this.subtitle,
    required this.backgroundColorLight,
    required this.backgroundColorDark,
    required this.gradientColorLight,
    required this.gradientColorDark,
  });
}

// ─── Oyun ID'sine göre kart verisi ───────────────────────
_GameCardData _cardDataForGame(Map<String, dynamic> game) {
  switch (game['id']) {
    case 'REF01':
      return _GameCardData(
        icon: Icons.touch_app_rounded,
        iconColorLight: const Color(0xFF0d59f2),
        iconColorDark: const Color(0xFF60A5FA),
        title: game['name'],
        subtitle: 'Refleks Eğitimi',
        backgroundColorLight: const Color(0xFFDBEAFE),
        backgroundColorDark: const Color(0xFF1E3A8A).withValues(alpha: 0.3),
        gradientColorLight: const Color(0xFF0d59f2).withValues(alpha: 0.2),
        gradientColorDark: const Color(0xFF0d59f2).withValues(alpha: 0.2),
      );
    case 'REF02':
      return _GameCardData(
        icon: Icons.directions_run_rounded,
        iconColorLight: const Color(0xFF059669),
        iconColorDark: const Color(0xFF34D399),
        title: game['name'],
        subtitle: 'Refleks & Hız',
        backgroundColorLight: const Color(0xFFD1FAE5),
        backgroundColorDark: const Color(0xFF065F46).withValues(alpha: 0.3),
        gradientColorLight: const Color(0xFF10B981).withValues(alpha: 0.2),
        gradientColorDark: const Color(0xFF10B981).withValues(alpha: 0.2),
      );
    case 'ATT01':
      return _GameCardData(
        icon: Icons.palette_rounded,
        iconColorLight: const Color(0xFF9333EA),
        iconColorDark: const Color(0xFFA78BFA),
        title: game['name'],
        subtitle: 'Dikkat Eğitimi',
        backgroundColorLight: const Color(0xFFF3E8FF),
        backgroundColorDark: const Color(0xFF581C87).withValues(alpha: 0.3),
        gradientColorLight: const Color(0xFFA855F7).withValues(alpha: 0.2),
        gradientColorDark: const Color(0xFFA855F7).withValues(alpha: 0.2),
      );
    case 'ATT02':
      return _GameCardData(
        icon: Icons.center_focus_strong_rounded,
        iconColorLight: const Color(0xFF0891B2),
        iconColorDark: const Color(0xFF22D3EE),
        title: game['name'],
        subtitle: 'Odak & Görsel',
        backgroundColorLight: const Color(0xFFCFFAFE),
        backgroundColorDark: const Color(0xFF164E63).withValues(alpha: 0.3),
        gradientColorLight: const Color(0xFF06B6D4).withValues(alpha: 0.2),
        gradientColorDark: const Color(0xFF06B6D4).withValues(alpha: 0.2),
      );
    case 'MEM01':
      return _GameCardData(
        icon: Icons.psychology_rounded,
        iconColorLight: const Color(0xFFDB2777),
        iconColorDark: const Color(0xFFF472B6),
        title: game['name'],
        subtitle: 'Çalışan Bellek',
        backgroundColorLight: const Color(0xFFFCE7F3),
        backgroundColorDark: const Color(0xFF831843).withValues(alpha: 0.3),
        gradientColorLight: const Color(0xFFEC4899).withValues(alpha: 0.2),
        gradientColorDark: const Color(0xFFEC4899).withValues(alpha: 0.2),
      );
    case 'MEM02':
      return _GameCardData(
        icon: Icons.grid_view_rounded,
        iconColorLight: const Color(0xFF0D9488),
        iconColorDark: const Color(0xFF2DD4BF),
        title: game['name'],
        subtitle: 'Hafıza Eğitimi',
        backgroundColorLight: const Color(0xFFCCFBF1),
        backgroundColorDark: const Color(0xFF134E4A).withValues(alpha: 0.3),
        gradientColorLight: const Color(0xFF14B8A6).withValues(alpha: 0.2),
        gradientColorDark: const Color(0xFF14B8A6).withValues(alpha: 0.2),
      );
    case 'MEM03':
      return _GameCardData(
        icon: Icons.text_fields_rounded,
        iconColorLight: const Color(0xFF4F46E5),
        iconColorDark: const Color(0xFF818CF8),
        title: game['name'],
        subtitle: 'Dil & Hafıza',
        backgroundColorLight: const Color(0xFFE0E7FF),
        backgroundColorDark: const Color(0xFF312E81).withValues(alpha: 0.3),
        gradientColorLight: const Color(0xFF6366F1).withValues(alpha: 0.2),
        gradientColorDark: const Color(0xFF6366F1).withValues(alpha: 0.2),
      );
    case 'MEM04':
      return _GameCardData(
        icon: Icons.repeat_rounded,
        iconColorLight: const Color(0xFF9333EA),
        iconColorDark: const Color(0xFFC084FC),
        title: game['name'],
        subtitle: 'Dizi Hafızası',
        backgroundColorLight: const Color(0xFFF3E8FF),
        backgroundColorDark: const Color(0xFF581C87).withValues(alpha: 0.3),
        gradientColorLight: const Color(0xFFA855F7).withValues(alpha: 0.2),
        gradientColorDark: const Color(0xFFA855F7).withValues(alpha: 0.2),
      );
    case 'LOG01':
      return _GameCardData(
        icon: Icons.extension_rounded,
        iconColorLight: const Color(0xFFD97706),
        iconColorDark: const Color(0xFFFBBF24),
        title: game['name'],
        subtitle: 'Mantık & Görsel',
        backgroundColorLight: const Color(0xFFFEF3C7),
        backgroundColorDark: const Color(0xFF78350F).withValues(alpha: 0.3),
        gradientColorLight: const Color(0xFFF59E0B).withValues(alpha: 0.2),
        gradientColorDark: const Color(0xFFF59E0B).withValues(alpha: 0.2),
      );
    case 'NUM01':
      return _GameCardData(
        icon: Icons.calculate_rounded,
        iconColorLight: const Color(0xFF2563EB),
        iconColorDark: const Color(0xFF60A5FA),
        title: game['name'],
        subtitle: 'Sayısal Zeka',
        backgroundColorLight: const Color(0xFFDBEAFE),
        backgroundColorDark: const Color(0xFF1E3A8A).withValues(alpha: 0.3),
        gradientColorLight: const Color(0xFF3B82F6).withValues(alpha: 0.2),
        gradientColorDark: const Color(0xFF3B82F6).withValues(alpha: 0.2),
      );
    case 'VIS02':
      return _GameCardData(
        icon: Icons.search_rounded,
        iconColorLight: const Color(0xFFEA580C),
        iconColorDark: const Color(0xFFFB923C),
        title: game['name'],
        subtitle: 'Görsel Algı',
        backgroundColorLight: const Color(0xFFFFEDD5),
        backgroundColorDark: const Color(0xFF7C2D12).withValues(alpha: 0.3),
        gradientColorLight: const Color(0xFFF97316).withValues(alpha: 0.2),
        gradientColorDark: const Color(0xFFF97316).withValues(alpha: 0.2),
      );
    case 'LANG02':
      return _GameCardData(
        icon: Icons.speed_rounded,
        iconColorLight: const Color(0xFF0891B2),
        iconColorDark: const Color(0xFF22D3EE),
        title: game['name'],
        subtitle: 'Dil Becerisi',
        backgroundColorLight: const Color(0xFFCFFAFE),
        backgroundColorDark: const Color(0xFF164E63).withValues(alpha: 0.3),
        gradientColorLight: const Color(0xFF06B6D4).withValues(alpha: 0.2),
        gradientColorDark: const Color(0xFF06B6D4).withValues(alpha: 0.2),
      );
    case 'MUS01':
      return _GameCardData(
        icon: Icons.music_note_rounded,
        iconColorLight: const Color(0xFFD97706),
        iconColorDark: const Color(0xFFFBBF24),
        title: game['name'],
        subtitle: 'Ritim & Dikkat',
        backgroundColorLight: const Color(0xFFFEF3C7),
        backgroundColorDark: const Color(0xFF78350F).withValues(alpha: 0.3),
        gradientColorLight: const Color(0xFFF59E0B).withValues(alpha: 0.2),
        gradientColorDark: const Color(0xFFF59E0B).withValues(alpha: 0.2),
      );
    case 'SOC01':
      return _GameCardData(
        icon: Icons.emoji_emotions_rounded,
        iconColorLight: const Color(0xFFDB2777),
        iconColorDark: const Color(0xFFF472B6),
        title: game['name'],
        subtitle: 'Sosyal Zeka',
        backgroundColorLight: const Color(0xFFFCE7F3),
        backgroundColorDark: const Color(0xFF831843).withValues(alpha: 0.3),
        gradientColorLight: const Color(0xFFEC4899).withValues(alpha: 0.2),
        gradientColorDark: const Color(0xFFEC4899).withValues(alpha: 0.2),
      );
    case 'NAT01':
      return _GameCardData(
        icon: Icons.nature_rounded,
        iconColorLight: const Color(0xFF16A34A),
        iconColorDark: const Color(0xFF4ADE80),
        title: game['name'],
        subtitle: 'Doğa & Mantık',
        backgroundColorLight: const Color(0xFFDCFCE7),
        backgroundColorDark: const Color(0xFF14532D).withValues(alpha: 0.3),
        gradientColorLight: const Color(0xFF22C55E).withValues(alpha: 0.2),
        gradientColorDark: const Color(0xFF22C55E).withValues(alpha: 0.2),
      );
    case 'KIN01':
      return _GameCardData(
        icon: Icons.balance_rounded,
        iconColorLight: const Color(0xFF0d59f2),
        iconColorDark: const Color(0xFF60A5FA),
        title: game['name'],
        subtitle: 'Refleks & Denge',
        backgroundColorLight: const Color(0xFFDBEAFE),
        backgroundColorDark: const Color(0xFF1E3A8A).withValues(alpha: 0.3),
        gradientColorLight: const Color(0xFF0d59f2).withValues(alpha: 0.2),
        gradientColorDark: const Color(0xFF0d59f2).withValues(alpha: 0.2),
      );
    case 'SPA01':
      return _GameCardData(
        icon: Icons.account_tree_rounded,
        iconColorLight: const Color(0xFF9333EA),
        iconColorDark: const Color(0xFFA78BFA),
        title: game['name'],
        subtitle: 'Uzamsal Mantık',
        backgroundColorLight: const Color(0xFFF3E8FF),
        backgroundColorDark: const Color(0xFF581C87).withValues(alpha: 0.3),
        gradientColorLight: const Color(0xFFA855F7).withValues(alpha: 0.2),
        gradientColorDark: const Color(0xFFA855F7).withValues(alpha: 0.2),
      );
    case 'INT01':
    default:
      return _GameCardData(
        icon: Icons.self_improvement_rounded,
        iconColorLight: const Color(0xFF0891B2),
        iconColorDark: const Color(0xFF22D3EE),
        title: game['name'],
        subtitle: 'Odak & İçsel',
        backgroundColorLight: const Color(0xFFCFFAFE),
        backgroundColorDark: const Color(0xFF164E63).withValues(alpha: 0.3),
        gradientColorLight: const Color(0xFF06B6D4).withValues(alpha: 0.2),
        gradientColorDark: const Color(0xFF06B6D4).withValues(alpha: 0.2),
      );
  }
}

// ─── Welcome Screen ────────────────────────────────────────
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  static const Color _primaryColor = Color(0xFF0d59f2);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDarkMode = ref.watch(themeProvider);

    final Color textColor =
        isDarkMode ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final Color secondaryTextColor =
        isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
    ));

    const games = MemoryBank.games;
    final cards = games.map((g) => _cardDataForGame(g)).toList();

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF0F2F5),
      body: Stack(
        children: [
          // ── YENİ: Hareketli Sinapsis Arka Planı ──
          Positioned.fill(
            child: NeuronBackground(isDarkMode: isDarkMode),
          ),
          
          SafeArea(
            child: Stack(
              children: [
                // ── Kaydırılabilir içerik ──
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 160),
                  child: Column(
                    children: [
                      // Header (Logo & Info)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: _GlassContainer(
                          isDarkMode: isDarkMode,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _primaryColor,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _primaryColor.withValues(alpha: 0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.psychology, color: Colors.white, size: 24),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'NöroDakika',
                                    style: GoogleFonts.inter(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: textColor,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(Icons.info_outline_rounded, color: secondaryTextColor, size: 24),
                            ],
                          ),
                        ),
                      ),

                      // Büyük Başlık
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                        child: Column(
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Zihnini geliştiren \n',
                                style: GoogleFonts.inter(
                                  color: textColor,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                  letterSpacing: -1.0,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'mini oyunlar',
                                    style: GoogleFonts.inter(color: _primaryColor),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Günde sadece birkaç dakika ayırarak odaklanma ve hafızanı güçlendir.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: secondaryTextColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // İstatistik Rozetleri
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _StatBadge(label: '${games.length} Oyun', icon: Icons.games_rounded, isDark: isDarkMode),
                                _StatBadge(label: '7 Kategori', icon: Icons.category_rounded, isDark: isDarkMode),
                                _StatBadge(label: '~3 Dakika', icon: Icons.timer_rounded, isDark: isDarkMode),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Oyun Kartları Grid (Showcase)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.82,
                            ),
                            itemCount: cards.length > 6 ? 6 : cards.length,
                            itemBuilder: (context, index) => _GameCard(
                              card: cards[index],
                              isDarkMode: isDarkMode,
                              textColor: textColor,
                              secondaryTextColor: secondaryTextColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Alt Footer & CTA
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 30),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          (isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF0F2F5)).withValues(alpha: 0.0),
                          (isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF0F2F5)).withValues(alpha: 0.9),
                          isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF0F2F5),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: _primaryColor.withValues(alpha: 0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () => _navigateToAuth(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Giriş Yap / Üye Ol',
                                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.arrow_forward_rounded),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAuth(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}

// ─── Yardımcı Widget'lar ───────────────────────────────────

class _GlassContainer extends StatelessWidget {
  final Widget child;
  final bool isDarkMode;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const _GlassContainer({
    required this.child,
    required this.isDarkMode,
    this.padding,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isDarkMode 
            ? Colors.white.withValues(alpha: 0.08) 
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isDarkMode 
              ? Colors.white.withValues(alpha: 0.12) 
              : Colors.black.withValues(alpha: 0.05),
          width: 1.5,
        ),
      ),
      child: child,
    );
  }
}

class _GameCard extends StatelessWidget {
  final _GameCardData card;
  final bool isDarkMode;
  final Color textColor;
  final Color secondaryTextColor;

  const _GameCard({
    required this.card,
    required this.isDarkMode,
    required this.textColor,
    required this.secondaryTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
      isDarkMode: isDarkMode,
      padding: const EdgeInsets.all(16),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: (isDarkMode ? card.backgroundColorDark : card.backgroundColorLight).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            (isDarkMode ? card.gradientColorDark : card.gradientColorLight).withValues(alpha: 0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(
                      card.icon,
                      size: 48,
                      color: isDarkMode ? card.iconColorDark : card.iconColorLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            card.title,
            style: GoogleFonts.inter(color: textColor, fontSize: 15, fontWeight: FontWeight.w800, height: 1.1),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            card.subtitle,
            style: GoogleFonts.inter(color: secondaryTextColor, fontSize: 12, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDark;

  const _StatBadge({required this.label, required this.icon, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF0d59f2)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}
