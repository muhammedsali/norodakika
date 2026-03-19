import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../../settings/providers/theme_provider.dart';
import '../../settings/providers/language_provider.dart';

class NotificationItem {
  final String title;
  final String subtitle;
  final String timeText;
  final IconData icon;
  final Color color;
  final bool isUnread;

  NotificationItem({
    required this.title,
    required this.subtitle,
    required this.timeText,
    required this.icon,
    required this.color,
    this.isUnread = false,
  });
}

void showNotificationsSheet(BuildContext context, WidgetRef ref) {
  final isDarkMode = ref.read(themeProvider);
  final isEn = ref.read(languageProvider) == AppLanguage.en;
  
  final sheetColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
  final textColor = isDarkMode ? Colors.white : const Color(0xFF1E293B);
  final subtitleColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  
  final notificationsTitle = isEn ? 'Notifications' : 'Bildirimler';
  final newNotificationsText = isEn ? '2 New' : '2 Yeni';

  // Hayal gücü: Canlı ve dinamik görünen günlük bildirimler simülasyonu
  final notifications = [
    NotificationItem(
      title: isEn ? 'Complete your daily goal! 🎯' : 'Günlük hedefinizi tamamlayın! 🎯',
      subtitle: isEn 
          ? 'You haven\'t played any games today. Just 5 minutes is enough to maintain your cognitive skills.'
          : 'Bugün henüz hiç oyun oynamadınız. Bilişsel becerilerinizi korumak için sadece 5 dakika yeterli.',
      timeText: isEn ? 'Now' : 'Şimdi',
      icon: Icons.track_changes_rounded,
      color: const Color(0xFF3B82F6),
      isUnread: true,
    ),
    NotificationItem(
      title: isEn ? 'Your Weekly Report is Ready 📊' : 'Haftalık Raporunuz Hazır 📊',
      subtitle: isEn
          ? 'You made 12% progress in memory last week. That\'s a great achievement!'
          : 'Geçen hafta hafıza alanında %12 ilerleme kaydettiniz. Bu harika bir başarı!',
      timeText: isEn ? '2 hours ago' : 'İki saat önce',
      icon: Icons.insights_rounded,
      color: const Color(0xFF10B981),
      isUnread: true,
    ),
    NotificationItem(
      title: isEn ? 'A New Record! 🚀' : 'Yeni Bir Rekor! 🚀',
      subtitle: isEn
          ? 'You broke your own highest score in the Focus category.'
          : 'Dikkat kategorisinde kendi en yüksek skorunuzu kırdınız.',
      timeText: isEn ? 'Yesterday' : 'Dün',
      icon: Icons.emoji_events_rounded,
      color: const Color(0xFFF59E0B),
      isUnread: false,
    ),
    NotificationItem(
      title: isEn ? 'Welcome to NöroDakika! 🧠' : 'NöroDakika\'ya Hoş Geldiniz! 🧠',
      subtitle: isEn
          ? 'Are you ready to push your cognitive limits? Start your training journey now.'
          : 'Bilişsel sınırlarınızı zorlamaya hazır mısınız? Eğitim maceranıza hemen başlayın.',
      timeText: isEn ? '2 days ago' : '2 gün önce',
      icon: Icons.waving_hand_rounded,
      color: const Color(0xFF8B5CF6),
      isUnread: false,
    ),
  ];

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        builder: (context, val, child) {
          return Transform.translate(
            offset: Offset(0, 50 * (1 - val)),
            child: Opacity(
              opacity: val,
              child: child,
            ),
          );
        },
        child: DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
             return ClipRRect(
               borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
               child: BackdropFilter(
                 filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                 child: Container(
                   decoration: BoxDecoration(
                     color: sheetColor.withValues(alpha: isDarkMode ? 0.85 : 0.90),
                     borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                     border: Border.all(
                       color: Colors.white.withValues(alpha: isDarkMode ? 0.1 : 0.3),
                       width: 1.5,
                     ),
                     boxShadow: [
                       BoxShadow(
                         color: Colors.black.withValues(alpha: 0.1),
                         blurRadius: 20,
                         offset: const Offset(0, -5),
                       ),
                     ]
                   ),
                   child: Column(
                     children: [
                       // Tutamak (Drag Handle)
                       Container(
                         margin: const EdgeInsets.only(top: 12, bottom: 8),
                         width: 40,
                         height: 5,
                         decoration: BoxDecoration(
                           color: subtitleColor.withValues(alpha: 0.5),
                           borderRadius: BorderRadius.circular(10),
                         ),
                       ),
                       // Başlık
                       Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                         child: Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             Text(
                               notificationsTitle,
                               style: GoogleFonts.inter(
                                 fontSize: 22,
                                 fontWeight: FontWeight.bold,
                                 color: textColor,
                               ),
                             ),
                             Container(
                               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                               decoration: BoxDecoration(
                                 color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                                 borderRadius: BorderRadius.circular(20),
                               ),
                               child: Text(
                                 newNotificationsText,
                                 style: GoogleFonts.inter(
                                   fontSize: 12,
                                   fontWeight: FontWeight.bold,
                                   color: const Color(0xFFEF4444),
                                 ),
                               ),
                             ),
                           ],
                         ),
                       ),
                       const SizedBox(height: 8),
                       // Liste
                       Expanded(
                         child: ListView.separated(
                           controller: controller,
                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                           itemCount: notifications.length,
                           separatorBuilder: (context, index) => const SizedBox(height: 12),
                           itemBuilder: (context, index) {
                             final note = notifications[index];
                             return Container(
                               padding: const EdgeInsets.all(16),
                               decoration: BoxDecoration(
                                 color: isDarkMode ? const Color(0xFF0F172A).withValues(alpha: 0.5) : Colors.white,
                                 borderRadius: BorderRadius.circular(20),
                                 border: Border.all(
                                   color: note.isUnread 
                                     ? note.color.withValues(alpha: 0.5)
                                     : Colors.transparent,
                                 ),
                                 boxShadow: [
                                   if (!isDarkMode)
                                     BoxShadow(
                                       color: Colors.grey.withValues(alpha: 0.08),
                                       blurRadius: 10,
                                       offset: const Offset(0, 4),
                                     )
                                 ],
                               ),
                               child: Row(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Container(
                                     padding: const EdgeInsets.all(12),
                                     decoration: BoxDecoration(
                                       color: note.color.withValues(alpha: 0.15),
                                       shape: BoxShape.circle,
                                     ),
                                     child: Icon(note.icon, color: note.color, size: 24),
                                   ),
                                   const SizedBox(width: 16),
                                   Expanded(
                                     child: Column(
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       children: [
                                         Row(
                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                           children: [
                                             Expanded(
                                               child: Text(
                                                 note.title,
                                                 style: GoogleFonts.inter(
                                                   fontSize: 15,
                                                   fontWeight: note.isUnread ? FontWeight.bold : FontWeight.w600,
                                                   color: textColor,
                                                 ),
                                               ),
                                             ),
                                             if (note.isUnread)
                                               Container(
                                                 width: 8,
                                                 height: 8,
                                                 decoration: BoxDecoration(
                                                   color: note.color,
                                                   shape: BoxShape.circle,
                                                 ),
                                               )
                                           ],
                                         ),
                                         const SizedBox(height: 6),
                                         Text(
                                           note.subtitle,
                                           style: GoogleFonts.inter(
                                             fontSize: 13,
                                             fontWeight: FontWeight.w400,
                                             color: subtitleColor,
                                             height: 1.4,
                                           ),
                                         ),
                                         const SizedBox(height: 10),
                                         Text(
                                           note.timeText,
                                           style: GoogleFonts.inter(
                                             fontSize: 11,
                                             fontWeight: FontWeight.w600,
                                             color: subtitleColor.withValues(alpha: 0.7),
                                           ),
                                         ),
                                       ],
                                     ),
                                   ),
                                 ],
                               ),
                             );
                           },
                         ),
                       ),
                     ],
                   ),
                 ),
               ),
             );
          },
        ),
      );
    },
  );
}
