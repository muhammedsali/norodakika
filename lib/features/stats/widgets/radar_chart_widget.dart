import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../settings/providers/language_provider.dart';
import '../../../core/i18n/app_strings.dart';

class RadarChartWidget extends StatelessWidget {
  final Map<String, double> stats;
  final bool isDarkMode;
  final AppLanguage language;

  const RadarChartWidget({
    super.key,
    required this.stats,
    required this.isDarkMode,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(language);
    final areasTr = ['Refleks', 'Dikkat', 'Hafıza', 'Sayısal', 'Mantık', 'Dil'];

    // Uygulamanın modern renk paletine uygun canlı tonlar
    final colors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFFF97316), // Orange
      const Color(0xFF0EA5E9), // Sky
      const Color(0xFFFACC15), // Yellow
      const Color(0xFF22C55E), // Green
      const Color(0xFFEC4899), // Pink
    ];

    final dataEntries = areasTr.map((area) {
      final value = stats[area] ?? 0.0;
      return value.clamp(0.0, 100.0);
    }).toList();

    final cardBg = isDarkMode ? const Color(0xFF1F2937) : Colors.white;
    final borderColor =
        isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB);
    final gridColor =
        isDarkMode ? const Color(0xFF374151) : const Color(0xFFF3F4F6);
    final tickColor = isDarkMode ? Colors.white30 : Colors.black26;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 280,
            child: RadarChart(
              RadarChartData(
                radarShape: RadarShape.polygon,
                tickCount: 4, // 5 yerine 4 adım, daha sade bir görünüm verir
                ticksTextStyle: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors
                      .transparent, // Tick numaralarını gizledik, daha temiz duruyor
                ),
                radarBorderData: BorderSide(
                  color: gridColor,
                  width: 2,
                ),
                gridBorderData: BorderSide(
                  color: gridColor,
                  width: 1.5,
                ),
                tickBorderData: BorderSide(
                  color: tickColor,
                  width: 1,
                ),
                getTitle: (index, angle) {
                  if (index >= areasTr.length) {
                    return const RadarChartTitle(text: '');
                  }
                  return RadarChartTitle(
                    text: s.categoryLabel(areasTr[index]),
                    angle: angle,
                  );
                },
                titleTextStyle: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode
                      ? const Color(0xFFF9FAFB)
                      : const Color(0xFF4B5563),
                  letterSpacing: 0.5,
                ),
                dataSets: [
                  RadarDataSet(
                    fillColor: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                    borderColor: const Color(0xFF4F46E5),
                    borderWidth: 2.5,
                    entryRadius: 4,
                    dataEntries: dataEntries
                        .map((value) => RadarEntry(value: value))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Kategoriler ve Yüzdeler (Modern Kapsül Görünümü)
          Wrap(
            spacing: 10,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: areasTr.asMap().entries.map((entry) {
              final index = entry.key;
              final areaTr = areasTr[index];
              final value = stats[areaTr] ?? 0.0;
              final itemColor = colors[index];

              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: itemColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: itemColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: itemColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: itemColor.withValues(alpha: 0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      s.categoryLabel(areaTr),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            isDarkMode ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${value.toInt()}%',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: itemColor,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
