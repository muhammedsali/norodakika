import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/memory/memory_bank.dart';
import '../../auth/providers/auth_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColorPrimary = isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final textColorSecondary = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563);

    // Kullanıcı yoksa bile ilerleme sekmesi boş kalmasın diye sahte veri gösteriyoruz.
    if (user == null) {
      final mockHistory = _fakeHistory();
      return _buildStatsBody(
        history: mockHistory,
        isDark: isDark,
        textColorPrimary: textColorPrimary,
        textColorSecondary: textColorSecondary,
      );
    }

    final userDataAsync = ref.watch(userDataProvider);

    return userDataAsync.when(
      data: (userData) {
        final rawHistory = (userData == null || userData.history == null)
            ? <dynamic>[]
            : List.from(userData.history as List);
        final history = rawHistory.isNotEmpty ? rawHistory : _fakeHistory();

        return _buildStatsBody(
          history: history,
          isDark: isDark,
          textColorPrimary: textColorPrimary,
          textColorSecondary: textColorSecondary,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          'Hata: $error',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: textColorSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsBody({
    required List history,
    required bool isDark,
    required Color textColorPrimary,
    required Color textColorSecondary,
  }) {
    final radarStats = MemoryBank.calculateRadarStats(history);
    final categories = MemoryBank.categories;

    // Bugün özeti için hesaplamalar
    final now = DateTime.now();
    final todayAttempts = history.where((h) {
      if (h is Map && h['timestamp'] != null) {
        try {
          final ts = DateTime.parse(h['timestamp'].toString());
          return ts.year == now.year && ts.month == now.month && ts.day == now.day;
        } catch (_) {
          return false;
        }
      }
      return false;
    }).toList();

    final gamesToday = todayAttempts.length;
    final totalSecondsToday = todayAttempts.fold<int>(0, (prev, h) {
      if (h is Map && h['duration'] != null) {
        final d = int.tryParse(h['duration'].toString()) ?? 0;
        return prev + d;
      }
      return prev;
    });
    final totalMinutesToday = (totalSecondsToday / 60).floor();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Bugün Özeti Kartı
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2937) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bugün özeti',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColorPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      gamesToday > 0
                          ? '$gamesToday oyun, yaklaşık $totalMinutesToday dk'
                          : 'Bugün henüz oyun oynamadın',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: textColorSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.today, size: 18, color: Color(0xFF4F46E5)),
                      const SizedBox(width: 6),
                      Text(
                        '${now.day}.${now.month}.${now.year}',
                        style: GoogleFonts.robotoMono(
                          fontSize: 12,
                          color: const Color(0xFF4F46E5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Radar Chart
          Container(
            height: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF020617) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: RadarChart(
              RadarChartData(
                dataSets: [
                  RadarDataSet(
                    fillColor: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                    borderColor: const Color(0xFF4F46E5),
                    borderWidth: 2,
                    dataEntries: categories.map((category) {
                      final value = radarStats[category] ?? 0.0;
                      // Normalize to 0-1 aralığı
                      return RadarEntry(value: (value / 100).clamp(0.0, 1.0));
                    }).toList(),
                  ),
                ],
                tickCount: 5,
                ticksTextStyle: GoogleFonts.poppins(
                  fontSize: 10,
                  color: textColorSecondary,
                ),
                tickBorderData: const BorderSide(color: Colors.grey, width: 1),
                borderData: FlBorderData(show: true),
                radarBackgroundColor: isDark ? const Color(0xFF020617) : Colors.grey[100],
                gridBorderData: const BorderSide(color: Colors.grey, width: 1),
                titlePositionPercentageOffset: 0.2,
                getTitle: (index, angle) {
                  return RadarChartTitle(
                    text: categories[index],
                    angle: angle,
                    positionPercentageOffset: 0.15,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // İstatistik Kartları
          ...categories.map((category) {
            final value = radarStats[category] ?? 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F2937) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColorPrimary,
                      ),
                    ),
                    Text(
                      '${value.toStringAsFixed(1)} / 100',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6E00FF),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

List<Map<String, dynamic>> _fakeHistory() {
  final now = DateTime.now();
  return [
    {
      "area": "Hafıza",
      "score": 78,
      "duration": 45,
      "timestamp": now.toIso8601String(),
    },
    {
      "area": "Dikkat",
      "score": 82,
      "duration": 50,
      "timestamp": now.subtract(const Duration(hours: 1)).toIso8601String(),
    },
    {
      "area": "Refleks",
      "score": 74,
      "duration": 35,
      "timestamp": now.subtract(const Duration(days: 1)).toIso8601String(),
    },
    {
      "area": "Mantık",
      "score": 69,
      "duration": 40,
      "timestamp": now.subtract(const Duration(days: 2)).toIso8601String(),
    },
    {
      "area": "Sayısal Zeka",
      "score": 76,
      "duration": 48,
      "timestamp": now.subtract(const Duration(days: 2, hours: 2)).toIso8601String(),
    },
    {
      "area": "Görsel Algı",
      "score": 71,
      "duration": 38,
      "timestamp": now.subtract(const Duration(days: 3)).toIso8601String(),
    },
    {
      "area": "Dil",
      "score": 80,
      "duration": 42,
      "timestamp": now.subtract(const Duration(days: 3, hours: 3)).toIso8601String(),
    },
  ];
}