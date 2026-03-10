import 'package:flutter/material.dart';
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
    return Container(
      height: 95,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode
              ? const Color(0xFF1F2937) // Dark capsule
              : const Color(0xFFE5E7EB), // Light capsule
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(Icons.home_rounded, 0),
            _navItem(Icons.extension_rounded, 1),
            _navItem(Icons.bar_chart_rounded, 2),
            _navItem(Icons.person_rounded, 3),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    final bool isActive = selectedTab == index;

    return GestureDetector(
      onTap: () => onTabSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive
              ? (isDarkMode ? const Color(0xFF374151) : Colors.white)
              : Colors.transparent,
        ),
        child: Icon(
          icon,
          color: isActive
              ? const Color(0xFF2563EB) // Mavi aktif icon
              : const Color(0xFF94A3B8), // Pasif icon
          size: 24,
        ),
      ),
    );
  }
}
