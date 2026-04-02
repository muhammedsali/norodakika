import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/i18n/app_strings.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/screens/profile_screen.dart';
import '../../../services/local_storage_service.dart';

import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/sound_provider.dart';
import '../../../services/notification_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final language = ref.watch(languageProvider);
    final notificationsEnabled = ref.watch(notificationProvider);
    final soundSettings = ref.watch(soundSettingsProvider);
    final s = AppStrings(language);

    final cardColor = isDarkMode ? const Color(0xFF111827) : Colors.white;
    final titleColor =
        isDarkMode ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final subtitleColor =
        isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final dividerColor =
        isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: Colors.transparent, // 1. Değişiklik: Arka plan şeffaf
      body: SafeArea(
        bottom: false, // SafeArea'nın alttan menüyü itmesini engelledik
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              20, 20, 20, 120), // 2. Değişiklik: Alt padding eklendi
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Appearance Section
              _buildSectionTitle(s.darkModeTitle, titleColor),
              const SizedBox(height: 12),
              _buildSettingCard(
                context,
                cardColor: cardColor,
                child: _buildToggleTile(
                  icon: Icons.dark_mode_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  title: s.darkModeTitle,
                  subtitle: s.darkModeSubtitle,
                  value: isDarkMode,
                  onChanged: (value) {
                    ref.read(themeProvider.notifier).toggleTheme();
                  },
                  titleColor: titleColor,
                  subtitleColor: subtitleColor,
                ),
              ),
              const SizedBox(height: 24),

              // Language Section
              _buildSectionTitle(s.languageTitle, titleColor),
              const SizedBox(height: 12),
              _buildSettingCard(
                context,
                cardColor: cardColor,
                child: _buildLanguageTile(
                  context,
                  language: language,
                  s: s,
                  titleColor: titleColor,
                  subtitleColor: subtitleColor,
                  onTap: () => _showLanguageDialog(context, ref, s, language),
                ),
              ),
              const SizedBox(height: 24),

              // Sound & Notifications Section
              _buildSectionTitle(s.soundTitle, titleColor),
              const SizedBox(height: 12),
              _buildSettingCard(
                context,
                cardColor: cardColor,
                child: Column(
                  children: [
                    _buildToggleTile(
                      icon: Icons.music_note_rounded,
                      iconColor: const Color(0xFF6366F1),
                      title: 'Müzik',
                      subtitle: 'Oyun içi arka plan müziği',
                      value: soundSettings.isMusicEnabled,
                      onChanged: (value) {
                        ref.read(soundSettingsProvider.notifier).toggleMusic();
                      },
                      titleColor: titleColor,
                      subtitleColor: subtitleColor,
                    ),
                    Divider(height: 1, color: dividerColor, indent: 56),
                    _buildToggleTile(
                      icon: Icons.volume_up_rounded,
                      iconColor: const Color(0xFF10B981),
                      title: s.soundTitle,
                      subtitle: s.soundSubtitle,
                      value: soundSettings.isSoundEnabled,
                      onChanged: (value) {
                        ref.read(soundSettingsProvider.notifier).toggleSound();
                      },
                      titleColor: titleColor,
                      subtitleColor: subtitleColor,
                    ),
                    Divider(height: 1, color: dividerColor, indent: 56),
                    _buildToggleTile(
                      icon: Icons.notifications_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      title: s.notificationTitle,
                      subtitle: s.notificationSubtitle,
                      value: notificationsEnabled,
                      onChanged: (value) async {
                        await ref.read(notificationProvider.notifier).toggle();
                        if (value) {
                          NotificationService.showLocalNotification(
                            title: 'Bildirimler Aktif!',
                            body: 'NöroDakika bildirimlerini artık alacaksınız.',
                          );
                        }
                      },
                      titleColor: titleColor,
                      subtitleColor: subtitleColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Account Section
              _buildSectionTitle(s.accountSectionTitle, titleColor),
              const SizedBox(height: 12),
              _buildSettingCard(
                context,
                cardColor: cardColor,
                child: Column(
                  children: [
                    _buildNavigationTile(
                      icon: Icons.person_rounded,
                      iconColor: const Color(0xFF3B82F6),
                      title: s.profileAndAccountTitle,
                      subtitle: s.profileAndAccountSubtitle,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProfileScreen(isDarkMode: isDarkMode),
                          ),
                        );
                      },
                      titleColor: titleColor,
                      subtitleColor: subtitleColor,
                    ),

                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Data Management Section
              _buildSectionTitle(s.clearDataTitle, titleColor),
              const SizedBox(height: 12),
              _buildSettingCard(
                context,
                cardColor: cardColor,
                child: Column(
                  children: [
                    _buildActionTile(
                      icon: Icons.delete_outline_rounded,
                      iconColor: const Color(0xFFEF4444),
                      title: s.clearDataTitle,
                      subtitle: s.clearDataSubtitle,
                      onTap: () => _showClearDataDialog(context, ref, s),
                      titleColor: titleColor,
                      subtitleColor: subtitleColor,
                      isDestructive: false,
                    ),
                    Divider(height: 1, color: dividerColor, indent: 56),
                    _buildActionTile(
                      icon: Icons.logout_rounded,
                      iconColor: const Color(0xFFF97316),
                      title: s.logout,
                      subtitle: '',
                      onTap: () => _showLogoutDialog(context, ref, s),
                      titleColor: titleColor,
                      subtitleColor: subtitleColor,
                      isDestructive: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // About Section
              _buildSectionTitle(s.aboutTitle, titleColor),
              const SizedBox(height: 12),
              _buildSettingCard(
                context,
                cardColor: cardColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        s.aboutText,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          color: subtitleColor,
                          height: 1.5,
                        ),
                      ),
                    ),
                    Divider(height: 1, color: dividerColor),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            s.versionTitle,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              color: subtitleColor,
                            ),
                          ),
                          Text(
                            '1.0.0',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: titleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: color.withAlpha(153),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required Widget child,
    required Color cardColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF6E00FF),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(
    BuildContext context, {
    required AppLanguage language,
    required AppStrings s,
    required Color titleColor,
    required Color subtitleColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.language_rounded,
                color: Color(0xFF10B981),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.languageTitle,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s.languageSubtitle,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF6E00FF).withAlpha(26),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                language == AppLanguage.tr
                    ? s.languageTurkish
                    : s.languageEnglish,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6E00FF),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: subtitleColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: titleColor,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: subtitleColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color titleColor,
    required Color subtitleColor,
    required bool isDestructive,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color:
                          isDestructive ? const Color(0xFFEF4444) : titleColor,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    AppStrings s,
    AppLanguage currentLanguage,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF111827) : Colors.white;
    final titleColor =
        isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.languageTitle,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 20),
                _buildLanguageOption(
                  context,
                  language: AppLanguage.tr,
                  title: s.languageTurkish,
                  isSelected: currentLanguage == AppLanguage.tr,
                  onTap: () {
                    ref
                        .read(languageProvider.notifier)
                        .setLanguage(AppLanguage.tr);
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 12),
                _buildLanguageOption(
                  context,
                  language: AppLanguage.en,
                  title: s.languageEnglish,
                  isSelected: currentLanguage == AppLanguage.en,
                  onTap: () {
                    ref
                        .read(languageProvider.notifier)
                        .setLanguage(AppLanguage.en);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required AppLanguage language,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor =
        isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6E00FF).withAlpha(26)
              : (isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: const Color(0xFF6E00FF), width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF6E00FF) : titleColor,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_rounded,
                color: Color(0xFF6E00FF),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref, AppStrings s) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor =
        isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          s.clearDataTitle,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
        content: Text(
          s.clearDataConfirm,
          style: GoogleFonts.spaceGrotesk(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: GoogleFonts.spaceGrotesk(),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await LocalStorageService.clearGameHistory();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(s.clearDataSuccess),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text(
              'Temizle',
              style: GoogleFonts.spaceGrotesk(
                color: const Color(0xFFEF4444),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref, AppStrings s) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor =
        isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          s.logout,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
        content: Text(
          'Çıkış yapmak istediğinize emin misiniz?',
          style: GoogleFonts.spaceGrotesk(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: GoogleFonts.spaceGrotesk(),
            ),
          ),
          TextButton(
            onPressed: () async {
              final authState = ref.read(authNotifierProvider);
              if (authState.isLoading) return;

              Navigator.pop(context); // Dialogu kapat
              await ref.read(authNotifierProvider.notifier).logout();
            },
            child: Text(
              s.logout,
              style: GoogleFonts.spaceGrotesk(
                color: const Color(0xFFEF4444),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
