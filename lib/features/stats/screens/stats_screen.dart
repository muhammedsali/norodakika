import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/memory/memory_bank.dart';
import '../../../services/local_storage_service.dart';
import '../../../core/i18n/app_strings.dart';
import '../../auth/providers/auth_provider.dart';
import '../../settings/providers/language_provider.dart';

enum TimeFilter { day, week, month }

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  TimeFilter _selectedFilter = TimeFilter.day;
  Future<List<Map<String, dynamic>>>? _historyFuture;

  @override
  void initState() {
    super.initState();
    // Önce sahte verileri ekle, sonra history'yi yükle
    _historyFuture = _initializeData();
  }

  Future<List<Map<String, dynamic>>> _initializeData() async {
    // Şuanlık her zaman sahte veriler ekle (test amaçlı)
    await LocalStorageService.addMockData();
    // Veriler eklendikten sonra history'yi döndür
    return await LocalStorageService.getGameHistory();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;
    final lang = ref.watch(languageProvider);
    final s = AppStrings(lang);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColorPrimary =
        isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final textColorSecondary =
        isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563);

    // Kullanıcı yoksa local storage'dan veri oku
    if (user == null) {
      // _historyFuture null ise başlat
      _historyFuture ??= _initializeData();

      return FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final history = snapshot.data ?? [];
          // Eğer history boşsa sahte verileri göster
          final displayHistory = history.isNotEmpty ? history : _fakeHistory();

          return _buildStatsBodyWrapper(
            history: displayHistory,
            isDark: isDark,
            textColorPrimary: textColorPrimary,
            textColorSecondary: textColorSecondary,
            s: s,
          );
        },
      );
    }

    final userDataAsync = ref.watch(userDataProvider);

    return userDataAsync.when(
      data: (userData) {
        final rawHistory = (userData == null)
            ? <dynamic>[]
            : List.from(userData.history as List);
        final history = rawHistory.isNotEmpty ? rawHistory : _fakeHistory();

        return _buildStatsBodyWrapper(
          history: history,
          isDark: isDark,
          textColorPrimary: textColorPrimary,
          textColorSecondary: textColorSecondary,
          s: s,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          s.errorPrefix(error),
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: textColorSecondary,
          ),
        ),
      ),
    );
  }

  // İçeriği saran ve saydamlığı/padding'i ayarlayan ana wrapper
  Widget _buildStatsBodyWrapper({
    required List history,
    required bool isDark,
    required Color textColorPrimary,
    required Color textColorSecondary,
    required AppStrings s,
  }) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Arka plan şeffaf
      body: SafeArea(
        bottom: false, // Menü arkasına inebilmesi için kapattık
        child: _buildStatsBodyContent(
          history: history,
          isDark: isDark,
          textColorPrimary: textColorPrimary,
          textColorSecondary: textColorSecondary,
          s: s,
        ),
      ),
    );
  }

  Widget _buildStatsBodyContent({
    required List history,
    required bool isDark,
    required Color textColorPrimary,
    required Color textColorSecondary,
    required AppStrings s,
  }) {
    // Filtreye göre history'yi filtrele
    final filteredHistory = _filterHistoryByTime(history, _selectedFilter);
    final radarStats = MemoryBank.calculateRadarStats(filteredHistory);
    final categories = MemoryBank.categories;

    // Seçilen filtreye göre özet hesaplamaları
    final filteredAttempts = filteredHistory;

    final gamesCount = filteredAttempts.length;
    final totalSeconds = filteredAttempts.fold<int>(0, (prev, h) {
      if (h is Map && h['duration'] != null) {
        final d = int.tryParse(h['duration'].toString()) ?? 0;
        return prev + d;
      }
      return prev;
    });
    final totalMinutes = (totalSeconds / 60).floor();

    // Filtre başlığı
    String filterTitle;
    String filterSubtitle;
    switch (_selectedFilter) {
      case TimeFilter.day:
        filterTitle = s.summaryToday;
        filterSubtitle = gamesCount > 0
            ? s.gamesAndMinutes(gamesCount, totalMinutes)
            : s.noGamesToday;
        break;
      case TimeFilter.week:
        filterTitle = s.summaryWeek;
        filterSubtitle = gamesCount > 0
            ? s.gamesAndMinutes(gamesCount, totalMinutes)
            : s.noGamesWeek;
        break;
      case TimeFilter.month:
        filterTitle = s.summaryMonth;
        filterSubtitle = gamesCount > 0
            ? s.gamesAndMinutes(gamesCount, totalMinutes)
            : s.noGamesMonth;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        // Arka planı transparent yapmıyoruz çünkü kendi gradient'i var,
        // ama bunu Scaffold seviyesinde ele aldığımız için burada kalabilir.
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0B1220),
                  const Color(0xFF111827),
                  const Color(0xFF1F2937),
                ]
              : [
                  const Color(0xFFF9FAFB),
                  const Color(0xFFF3F4F6),
                  Colors.white,
                ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            20, 20, 20, 120), // Alt padding eklendi (Menü boşluğu)
        child: Column(
          children: [
            // Başlık
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.insights,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        s.statsTitle,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textColorPrimary,
                        ),
                      ),
                      Text(
                        s.statsSubtitle,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          color: textColorSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Filtre Butonları
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(6),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1F2937).withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF374151)
                      : const Color(0xFFE5E7EB),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: _buildFilterButton(
                      s.filterDay,
                      Icons.today,
                      TimeFilter.day,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFilterButton(
                      s.filterWeek,
                      Icons.date_range,
                      TimeFilter.week,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFilterButton(
                      s.filterMonth,
                      Icons.calendar_month,
                      TimeFilter.month,
                      isDark,
                    ),
                  ),
                ],
              ),
            ),

            // Özet Kartı - Modern Gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4F46E5),
                    Color(0xFF7C3AED),
                    Color(0xFF9333EA),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              filterTitle,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              filterSubtitle,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _selectedFilter == TimeFilter.day
                              ? Icons.today
                              : _selectedFilter == TimeFilter.week
                                  ? Icons.date_range
                                  : Icons.calendar_month,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getFilterDateRange(_selectedFilter),
                          style: GoogleFonts.robotoMono(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Radar Chart - Modern Card
            Container(
              height: 340,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1F2937).withValues(alpha: 0.8)
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF374151)
                      : const Color(0xFFE5E7EB),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: filteredHistory.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bar_chart,
                            size: 48,
                            color: textColorSecondary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            s.noDataForPeriod,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: textColorSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RadarChart(
                      RadarChartData(
                        dataSets: [
                          RadarDataSet(
                            fillColor:
                                const Color(0xFF4F46E5).withValues(alpha: 0.25),
                            borderColor: const Color(0xFF4F46E5),
                            borderWidth: 3,
                            dataEntries: categories.map((category) {
                              final value = radarStats[category] ?? 0.0;
                              // Normalize to 0-1 aralığı
                              return RadarEntry(
                                  value: (value / 100).clamp(0.0, 1.0));
                            }).toList(),
                          ),
                        ],
                        tickCount: 5,
                        ticksTextStyle: GoogleFonts.poppins(
                          fontSize: 10,
                          color: textColorSecondary,
                        ),
                        tickBorderData: BorderSide(
                          color: isDark
                              ? const Color(0xFF374151)
                              : const Color(0xFFE5E7EB),
                          width: 1.5,
                        ),
                        borderData: FlBorderData(show: true),
                        radarBackgroundColor: isDark
                            ? const Color(0xFF111827)
                            : const Color(0xFFF9FAFB),
                        gridBorderData: BorderSide(
                          color: isDark
                              ? const Color(0xFF374151)
                              : const Color(0xFFE5E7EB),
                          width: 1.5,
                        ),
                        titlePositionPercentageOffset: 0.2,
                        getTitle: (index, angle) {
                          return RadarChartTitle(
                            text: s.categoryLabel(categories[index]),
                            angle: angle,
                            positionPercentageOffset: 0.15,
                          );
                        },
                      ),
                    ),
            ),
            const SizedBox(height: 24),

            // İstatistik Kartları - Modern Progress Cards
            ...categories.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              final value = radarStats[category] ?? 0.0;
              final progress = (value / 100).clamp(0.0, 1.0);

              // Her kategori için farklı renk
              final categoryColors = [
                [const Color(0xFFEF4444), const Color(0xFFDC2626)], // Kırmızı
                [const Color(0xFF3B82F6), const Color(0xFF2563EB)], // Mavi
                [const Color(0xFF10B981), const Color(0xFF059669)], // Yeşil
                [const Color(0xFFF59E0B), const Color(0xFFD97706)], // Turuncu
                [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)], // Mor
                [const Color(0xFFEC4899), const Color(0xFFDB2777)], // Pembe
                [const Color(0xFF06B6D4), const Color(0xFF0891B2)], // Cyan
              ];

              final colors = categoryColors[index % categoryColors.length];
              final icon = _getCategoryIcon(category);

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1F2937).withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF374151)
                          : const Color(0xFFE5E7EB),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: colors,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colors[0].withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    icon,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        s.categoryLabel(category),
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: textColorPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${value.toStringAsFixed(1)} / 100',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: colors[0],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: isDark
                              ? const Color(0xFF374151)
                              : const Color(0xFFE5E7EB),
                          valueColor: AlwaysStoppedAnimation<Color>(colors[0]),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(
    String label,
    IconData icon,
    TimeFilter filter,
    bool isDark,
  ) {
    final isSelected = filter == _selectedFilter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : isDark
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Hafıza':
      case 'Memory':
        return Icons.psychology;
      case 'Dikkat':
      case 'Attention':
        return Icons.center_focus_strong;
      case 'Refleks':
      case 'Reflex':
        return Icons.flash_on;
      case 'Mantık':
      case 'Logic':
        return Icons.extension;
      case 'Sayısal Zeka':
      case 'Numerical':
        return Icons.calculate;
      case 'Görsel Algı':
      case 'Visual':
        return Icons.visibility;
      case 'Dil':
      case 'Language':
        return Icons.translate;
      default:
        return Icons.star;
    }
  }

  List _filterHistoryByTime(List history, TimeFilter filter) {
    final now = DateTime.now();
    DateTime startDate;

    switch (filter) {
      case TimeFilter.day:
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case TimeFilter.week:
        // Bu haftanın başlangıcı (Pazartesi)
        final weekday = now.weekday;
        startDate = now.subtract(Duration(days: weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case TimeFilter.month:
        startDate = DateTime(now.year, now.month, 1);
        break;
    }

    return history.where((h) {
      if (h is Map && h['timestamp'] != null) {
        try {
          final ts = DateTime.parse(h['timestamp'].toString());
          return ts.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
              ts.isBefore(now.add(const Duration(days: 1)));
        } catch (_) {
          return false;
        }
      }
      return false;
    }).toList();
  }

  String _getFilterDateRange(TimeFilter filter) {
    final now = DateTime.now();
    switch (filter) {
      case TimeFilter.day:
        return '${now.day}.${now.month}.${now.year}';
      case TimeFilter.week:
        final weekday = now.weekday;
        final weekStart = now.subtract(Duration(days: weekday - 1));
        return '${weekStart.day}.${weekStart.month} - ${now.day}.${now.month}';
      case TimeFilter.month:
        return '${now.month}/${now.year}';
    }
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
      "timestamp":
          now.subtract(const Duration(days: 2, hours: 2)).toIso8601String(),
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
      "timestamp":
          now.subtract(const Duration(days: 3, hours: 3)).toIso8601String(),
    },
  ];
}
