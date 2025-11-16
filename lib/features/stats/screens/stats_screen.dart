import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/memory/memory_bank.dart';
import '../../../core/models/user_model.dart';
import '../../../services/firebase_service.dart';
import '../../auth/providers/auth_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Kullanıcı bulunamadı')),
      );
    }

    final userDataAsync = ref.watch(userDataProvider(user.uid));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6E00FF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Zihin Gelişim Grafiği',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: SafeArea(
        child: userDataAsync.when(
          data: (userData) {
            if (userData == null) {
              return const Center(child: Text('Veri yüklenemedi'));
            }

            final radarStats = MemoryBank.calculateRadarStats(userData.history);
            final categories = MemoryBank.categories;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Radar Chart
                  Container(
                    height: 300,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: RadarChart(
                      RadarChartData(
                        dataSets: [
                          RadarDataSet(
                            fillColor: const Color(0xFF6E00FF).withOpacity(0.3),
                            borderColor: const Color(0xFF6E00FF),
                            borderWidth: 2,
                            dataEntries: categories.map((category) {
                              final value = radarStats[category] ?? 0.0;
                              // Normalize to 0-1 range (assuming max score is 100)
                              return RadarEntry(value: (value / 100).clamp(0.0, 1.0));
                            }).toList(),
                          ),
                        ],
                        tickCount: 5,
                        ticksTextStyle: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                        tickBorderData: const BorderSide(color: Colors.grey, width: 1),
                        borderData: FlBorderData(show: true),
                        radarBackgroundColor: Colors.grey[100],
                        gridBorderData: const BorderSide(color: Colors.grey, width: 1),
                        titlePositionPercentageOffset: 0.2,
                        getTitle: (index, angle) {
                          return RadarChartTitle(
                            text: categories[index],
                            angle: angle,
                            positionPercentageOffset: 0.15,
                            textStyle: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
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
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              value.toStringAsFixed(1),
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
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Hata: $error', style: GoogleFonts.poppins()),
          ),
        ),
      ),
    );
  }
}

