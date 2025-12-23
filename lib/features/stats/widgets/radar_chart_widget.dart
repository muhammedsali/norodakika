import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class RadarChartWidget extends StatelessWidget {
  final Map<String, double> stats;
  final bool isDarkMode;

  const RadarChartWidget({
    super.key,
    required this.stats,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final areas = ['Refleks', 'Dikkat', 'Hafıza', 'Sayısal', 'Mantık', 'Dil'];
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFFF97316),
      const Color(0xFF0EA5E9),
      const Color(0xFFFACC15),
      const Color(0xFF22C55E),
      const Color(0xFFEC4899),
    ];

    final dataEntries = areas.map((area) {
      final value = stats[area] ?? 0.0;
      return value.clamp(0.0, 100.0);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                tickCount: 5,
                ticksTextStyle: GoogleFonts.poppins(
                  fontSize: 10,
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                ),
                radarBorderData: BorderSide(
                  color: isDarkMode
                      ? const Color(0xFF374151)
                      : Colors.grey[300]!,
                  width: 1,
                ),
                gridBorderData: BorderSide(
                  color: isDarkMode
                      ? const Color(0xFF374151)
                      : Colors.grey[300]!,
                  width: 1,
                ),
                tickBorderData: BorderSide(
                  color: isDarkMode
                      ? const Color(0xFF374151)
                      : Colors.grey[300]!,
                  width: 1,
                ),
                getTitle: (index, angle) {
                  if (index >= areas.length) return const RadarChartTitle(text: '');
                  return RadarChartTitle(
                    text: areas[index],
                    angle: angle,
                  );
                },
                titleTextStyle: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                dataSets: [
                  RadarDataSet(
                    fillColor: const Color(0xFF4F46E5).withOpacity(0.2),
                    borderColor: const Color(0xFF4F46E5),
                    borderWidth: 2,
                    entryRadius: 3,
                    dataEntries: dataEntries
                        .map((value) => RadarEntry(value: value))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: areas.asMap().entries.map((entry) {
              final index = entry.key;
              final area = entry.value;
              final value = stats[area] ?? 0.0;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colors[index].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors[index],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$area: ${value.toInt()}%',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black87,
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
