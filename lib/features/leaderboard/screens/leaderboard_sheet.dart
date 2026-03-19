import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

import '../../settings/providers/theme_provider.dart';
import '../../settings/providers/language_provider.dart';
import '../../stats/providers/user_stats_provider.dart' hide firestoreServiceProvider;
import '../../auth/providers/auth_provider.dart';

class LeaderboardUser {
  final String id;
  final String name;
  final int score;
  final String avatarUrl;

  LeaderboardUser({
    required this.id,
    required this.name,
    required this.score,
    required this.avatarUrl,
  });
}

final globalLeaderboardProvider = FutureProvider.autoDispose<List<LeaderboardUser>>((ref) async {
  final firestore = ref.read(firestoreServiceProvider);
  final usersData = await firestore.getLeaderboardUsers();

  final firebaseUser = ref.read(currentUserProvider).value;
  final myUid = firebaseUser?.uid ?? 'me';
  final isEn = ref.read(languageProvider) == AppLanguage.en;

  // Gerçek veritabanındaki kullanıcıları dönüştür
  List<LeaderboardUser> users = [];
  for (var data in usersData) {
    final uid = data['uid'] ?? 'guest';
    final name = data['displayName'] ?? (data['email'] != null ? data['email'].split('@')[0] : 'Kullanıcı');
    final avatar = data['photoURL'] ?? 'assets/icons/app_icon.png';

    // Stats tabanlı skor hesaplaması
    final stats = data['stats'] ?? {};
    final memory = (stats['Hafıza'] ?? 0.0).toDouble();
    final focus = (stats['Dikkat'] ?? 0.0).toDouble();
    final speed = (stats['Refleks'] ?? 0.0).toDouble();
    int score = ((memory + focus + speed) * 12.5).round();

    users.add(LeaderboardUser(id: uid, name: name, score: score, avatarUrl: avatar));
  }

  // Eğer nedense (güvenlik kuralı vs) hiç veri gelmemişse veya şu anki kullanıcı yepyeni ise:
  // Mevcut kullanıcının Firestore'da olup olmadığını kontrol et.
  final amIInList = users.any((u) => u.id == myUid);
  
  if (!amIInList && myUid != 'me') {
    // Current user explicitly calculation
    final customName = ref.read(customNameProvider).value;
    final fallBackName = isEn ? 'You' : 'Sen';
    final userName = customName ?? (firebaseUser?.displayName ?? (firebaseUser?.email?.split('@')[0] ?? fallBackName));
    
    final myStats = ref.read(userStatsProvider).value ?? {};
    final myMemory = (myStats['Hafıza'] ?? 0.0).toDouble();
    final myFocus = (myStats['Dikkat'] ?? 0.0).toDouble();
    final mySpeed = (myStats['Refleks'] ?? 0.0).toDouble();
    final myScore = ((myMemory + myFocus + mySpeed) * 12.5).round();
    
    users.add(LeaderboardUser(id: myUid, name: userName, score: myScore, avatarUrl: 'assets/icons/app_icon.png'));
  }

  // En yüksekten en düşüğe
  users.sort((a, b) => b.score.compareTo(a.score));
  
  return users;
});

void showLeaderboardSheet(BuildContext context, WidgetRef ref) {
  final isDarkMode = ref.read(themeProvider);
  final isEn = ref.read(languageProvider) == AppLanguage.en;

  final sheetColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
  final textColor = isDarkMode ? Colors.white : const Color(0xFF1E293B);
  final subtitleColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

  final firebaseUser = ref.read(currentUserProvider).value;
  final myUid = firebaseUser?.uid ?? 'me';

  final dbUsersAsync = ref.watch(globalLeaderboardProvider);

  final titleText = isEn ? 'Global Leaderboard' : 'Küresel Sıralama';
  final rankText = isEn ? 'Your Rank: #' : 'Sıran: #';
  final pointsText = isEn ? 'pts' : 'puan';

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
          initialChildSize: 0.8,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          builder: (_, controller) {
             return ClipRRect(
               borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
               child: BackdropFilter(
                 filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                 child: dbUsersAsync.when(
                   loading: () => Container(color: sheetColor.withValues(alpha: isDarkMode ? 0.85 : 0.90), child: const Center(child: CircularProgressIndicator())),
                   error: (err, stack) => Container(color: sheetColor.withValues(alpha: isDarkMode ? 0.85 : 0.90), child: Center(child: Text('Veritabanına bağlanılamadı. / Connection failed.', style: TextStyle(color: textColor)))),
                   data: (users) {
                     final userRank = users.indexWhere((u) => u.id == myUid) + 1;
                     
                     return Container(
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
                           // Drag handle
                           Container(
                             margin: const EdgeInsets.only(top: 12, bottom: 8),
                             width: 40,
                             height: 5,
                             decoration: BoxDecoration(
                               color: subtitleColor.withValues(alpha: 0.5),
                               borderRadius: BorderRadius.circular(10),
                             ),
                           ),
                           // Title & Current Rank Badge
                           Padding(
                             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                             child: Row(
                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                               children: [
                                 Text(
                                   titleText,
                                   style: GoogleFonts.inter(
                                     fontSize: 22,
                                     fontWeight: FontWeight.bold,
                                     color: textColor,
                                   ),
                                 ),
                                 if (userRank > 0)
                                   Container(
                                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                     decoration: BoxDecoration(
                                       color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                                       borderRadius: BorderRadius.circular(20),
                                       border: Border.all(color: const Color(0xFF4F46E5).withValues(alpha: 0.3)),
                                     ),
                                     child: Text(
                                       '$rankText$userRank',
                                       style: GoogleFonts.inter(
                                         fontSize: 13,
                                         fontWeight: FontWeight.bold,
                                         color: isDarkMode ? const Color(0xFF818CF8) : const Color(0xFF4F46E5),
                                       ),
                                     ),
                                   ),
                               ],
                             ),
                           ),
                           const SizedBox(height: 8),
                           
                           // The List
                           if (users.isEmpty)
                              Expanded(child: Center(child: Text(isEn ? 'No users found.' : 'Henüz oyuncu bulunamadı.', style: TextStyle(color: textColor))))
                           else
                             Expanded(
                               child: ListView.separated(
                                 controller: controller,
                                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                 itemCount: users.length,
                                 separatorBuilder: (context, index) => const SizedBox(height: 12),
                                 itemBuilder: (context, index) {
                                   final u = users[index];
                                   final isMe = u.id == myUid;
                                   final rank = index + 1;
                                   
                                   // Top 3 colors
                                   Color? rankColor;
                                   if (rank == 1) {
                                     rankColor = const Color(0xFFFBBF24); // Gold
                                   } else if (rank == 2) {
                                     rankColor = const Color(0xFF94A3B8); // Silver
                                   } else if (rank == 3) {
                                     rankColor = const Color(0xFFD97706); // Bronze
                                   }
      
                                   return Container(
                                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                     decoration: BoxDecoration(
                                       color: isMe 
                                         ? const Color(0xFF4F46E5).withValues(alpha: 0.15)
                                         : (isDarkMode ? const Color(0xFF0F172A).withValues(alpha: 0.5) : Colors.white),
                                       borderRadius: BorderRadius.circular(20),
                                       border: Border.all(
                                         color: isMe 
                                           ? const Color(0xFF4F46E5).withValues(alpha: 0.5)
                                           : Colors.transparent,
                                       ),
                                       boxShadow: [
                                         if (!isDarkMode && !isMe)
                                           BoxShadow(
                                             color: Colors.grey.withValues(alpha: 0.08),
                                             blurRadius: 10,
                                             offset: const Offset(0, 4),
                                           )
                                       ],
                                     ),
                                     child: Row(
                                       children: [
                                         // Ranking Number
                                         SizedBox(
                                           width: 32,
                                           child: Text(
                                             '#$rank',
                                             style: GoogleFonts.inter(
                                               fontSize: 18,
                                               fontWeight: FontWeight.bold,
                                               color: rankColor ?? subtitleColor,
                                             ),
                                           ),
                                         ),
                                         const SizedBox(width: 8),
                                         
                                         // Avatar
                                         Container(
                                           width: 44,
                                           height: 44,
                                           decoration: BoxDecoration(
                                             shape: BoxShape.circle,
                                             color: isMe ? const Color(0xFF4F46E5) : (rankColor ?? subtitleColor.withValues(alpha: 0.3)),
                                           ),
                                           child: Center(
                                             child: Icon(
                                                isMe ? Icons.person : Icons.emoji_events,
                                                color: Colors.white,
                                                size: 20,
                                             )
                                           ),
                                         ),
                                         const SizedBox(width: 14),
                                         
                                         // Name
                                         Expanded(
                                           child: Text(
                                             u.name.isNotEmpty ? u.name : 'Anonim',
                                             style: GoogleFonts.inter(
                                               fontSize: 15,
                                               fontWeight: isMe ? FontWeight.w800 : FontWeight.w600,
                                               color: textColor,
                                             ),
                                             maxLines: 1,
                                             overflow: TextOverflow.ellipsis,
                                           ),
                                         ),
                                         
                                         // Score
                                         Column(
                                           crossAxisAlignment: CrossAxisAlignment.end,
                                           mainAxisAlignment: MainAxisAlignment.center,
                                           children: [
                                             Text(
                                               '${u.score}',
                                               style: GoogleFonts.inter(
                                                 fontSize: 18,
                                                 fontWeight: FontWeight.w900,
                                                 color: isMe ? (isDarkMode ? const Color(0xFF818CF8) : const Color(0xFF4F46E5)) : textColor,
                                               ),
                                             ),
                                             Text(
                                               pointsText,
                                               style: GoogleFonts.inter(
                                                 fontSize: 10,
                                                 fontWeight: FontWeight.bold,
                                                 color: subtitleColor,
                                               ),
                                             ),
                                           ],
                                         ),
                                       ],
                                     ),
                                   );
                                 },
                               ),
                             ),
                         ],
                       ),
                     );
                   }
                 )
               ),
             );
          },
        ),
      );
    },
  );
}
