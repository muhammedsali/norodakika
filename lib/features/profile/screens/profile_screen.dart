import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/i18n/app_strings.dart';
import '../../settings/providers/language_provider.dart';
import '../../auth/screens/auth_gate_screen.dart';
import '../../../core/widgets/neuron_background.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final bool isDarkMode;

  const ProfileScreen({
    super.key,
    required this.isDarkMode,
  });

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;
    final lang = ref.watch(languageProvider);
    final s = AppStrings(lang);
    final bool isDark = widget.isDarkMode;
    final bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6);
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final titleColor = isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final subtitleColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    final displayEmail = user?.email ?? 'kullanici@ornek.com';
    final customName = ref.watch(customNameProvider).value;
    final displayName = customName ?? user?.displayName ?? displayEmail.split('@').first;
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF0F2F5),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : const Color(0xFF4F46E5)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          s.profileTitle,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: NeuronBackground(isDarkMode: isDark),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profil Avatar
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark 
                          ? Colors.white.withValues(alpha: 0.08) 
                          : Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark 
                            ? Colors.white.withValues(alpha: 0.12) 
                            : Colors.black.withValues(alpha: 0.05),
                        width: 1.5,
                      ),
                    ),
                child: Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF4F46E5), Color(0xFF10B981)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  displayName,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: titleColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => _showNameEditDialog(context, displayName),
                                child: Icon(Icons.edit_rounded, size: 16, color: subtitleColor),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            displayEmail,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13,
                              color: subtitleColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              s.levelBeginner,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF4F46E5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark 
                          ? Colors.white.withValues(alpha: 0.08) 
                          : Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark 
                            ? Colors.white.withValues(alpha: 0.12) 
                            : Colors.black.withValues(alpha: 0.05),
                        width: 1.5,
                      ),
                    ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.generalInfo,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          s.totalSessions,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            color: subtitleColor,
                          ),
                        ),
                        Text(
                          '-',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            color: titleColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          s.dailyGoal,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            color: subtitleColor,
                          ),
                        ),
                        Text(
                          '5 oyun',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            color: titleColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

                  const SizedBox(height: 32),
                  
                  // Çıkış Yap Butonu
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        await ref.read(authNotifierProvider.notifier).logout();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const AuthGateScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        s.logout,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showNameEditDialog(BuildContext context, String currentName) async {
    final s = AppStrings(ref.read(languageProvider));
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    final controller = TextEditingController(text: currentName == s.userFallback || currentName.contains('@') ? '' : currentName);
    final isDark = widget.isDarkMode;
    const primaryColor = Color(0xFF4F46E5);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'İsim Değiştir',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Yeni adınızı girin',
              hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: primaryColor, width: 2),
              ),
            ),
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  // Her durumda SharedPreferences'a kaydedelim
                  await ref.read(authNotifierProvider.notifier).updateCustomName(newName);
                  
                  // Firebase Auth güncellendi, ancak yine de tedbir amaçlı try-catch
                  try {
                    await user.updateDisplayName(newName);
                    await user.reload();
                  } catch (e) {
                    debugPrint('Firebase profile sync error (ignored): $e');
                  }
                }
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Kaydet', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
    setState(() {});
  }
}

