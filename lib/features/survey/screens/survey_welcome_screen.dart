import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../settings/providers/theme_provider.dart';
import '../../../core/widgets/neuron_background.dart';

class SurveyWelcomeScreen extends ConsumerWidget {
  final VoidCallback onStart;

  const SurveyWelcomeScreen({super.key, required this.onStart});

  BoxDecoration _getNeuDecoration({required bool isDarkMode}) {
    final bgColor = isDarkMode 
        ? const Color(0xFF1E293B).withValues(alpha: 0.7) 
        : Colors.white.withValues(alpha: 0.85);
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.05);

    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(32),
      border: Border.all(color: borderColor, width: 1.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.05),
          offset: const Offset(0, 8),
          blurRadius: 24,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final bgColor = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF0F2F5);
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    const primaryColor = Color(0xFF0D59F2);

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: NeuronBackground(isDarkMode: isDarkMode),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: _getNeuDecoration(isDarkMode: isDarkMode),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'HOŞ GELDİNİZ',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Kaydınız başarıyla oluşturuldu!\n\nNörodakika deneyimine başlamadan ve oyunları oynamadan önce bilişsel profilinizi oluşturabilmemiz için çok kısa bir ön test anketini tamamlamanız gerekmektedir.',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: subtitleColor,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: onStart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 8,
                            shadowColor: primaryColor.withValues(alpha: 0.4),
                          ),
                          child: Text(
                            'ANKETİ BAŞLAT',
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1.5),
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
    );
  }
}
