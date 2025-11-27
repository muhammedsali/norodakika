import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../settings/providers/language_provider.dart';

class HomeBottomNav extends StatelessWidget {
  final int selectedTab;
  final bool isDarkMode;
  final AppLanguage language;
  final ValueChanged<int> onTabSelected;

  const HomeBottomNav({
    super.key,
    required this.selectedTab,
    required this.isDarkMode,
    required this.language,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final homeLabel = language == AppLanguage.en ? 'Home' : 'Ana Sayfa';
    final gamesLabel = language == AppLanguage.en ? 'Games' : 'Oyunlar';
    final progressLabel = language == AppLanguage.en ? 'Progress' : 'İlerleme';
    final settingsLabel = language == AppLanguage.en ? 'Settings' : 'Ayarlar';

    return Container(
      height: 80,
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: isDarkMode
              ? Border.all(
                  color: const Color(0xFF4B5563),
                  width: 1,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_rounded, homeLabel, selectedTab == 0, () {
              onTabSelected(0);
            }),
            _buildNavItem(Icons.category_rounded, gamesLabel, selectedTab == 1, () {
              onTabSelected(1);
            }),
            _buildNavItem(Icons.bar_chart_rounded, progressLabel, selectedTab == 2, () {
              onTabSelected(2);
            }),
            _buildNavItem(Icons.settings_rounded, settingsLabel, selectedTab == 3, () {
              onTabSelected(3);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, bool isSelected, VoidCallback onTap) {
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
                  ? const Color(0xFF4F46E5)
                  : (isDarkMode ? Colors.white70 : const Color(0xFF4B5563)),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF4F46E5)
                    : (isDarkMode ? Colors.white70 : const Color(0xFF4B5563)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
