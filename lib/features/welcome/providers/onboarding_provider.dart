import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/local_storage_service.dart';
import '../models/onboarding_page_model.dart';

// ─── Onboarding State ──────────────────────────────────────
class OnboardingState {
  /// Kaçıncı sayfada olduğumuzu tutar
  final int currentPage;

  /// Tüm sayfa verileri
  final List<OnboardingPageModel> pages;

  const OnboardingState({
    required this.currentPage,
    required this.pages,
  });

  /// Toplam sayfa sayısı
  int get pageCount => pages.length;

  /// Son sayfa mı?
  bool get isLastPage => currentPage == pages.length - 1;

  /// Mevcut sayfa verisi
  OnboardingPageModel get currentPageData => pages[currentPage];

  OnboardingState copyWith({int? currentPage}) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      pages: pages,
    );
  }
}

// ─── Onboarding Notifier ───────────────────────────────────
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(_buildInitialState());

  // Başlangıç durumunu statik olarak oluştur
  static OnboardingState _buildInitialState() {
    return OnboardingState(
      currentPage: 0,
      pages: _buildPages(),
    );
  }

  // ─── Tüm onboarding sayfa verilerini burada tanımla ───────
  static List<OnboardingPageModel> _buildPages() {
    return const [
      OnboardingPageModel(
        icon: Icons.psychology_rounded,
        tag: '01 — GİRİŞ',
        title: 'Beynini Her\nGün ',
        highlight: 'Eğit',
        subtitle:
            'Günde sadece 3 dakika ayır ve bilişsel gücünü üst seviyeye taşı. '
            'Küçük adımlar büyük fark yaratır.',
        gradientColors: [Color(0xFF0D59F2), Color(0xFF7C3AED)],
        accentColor: Color(0xFF0D59F2),
        chips: [
          OnboardingChip(icon: Icons.timer_rounded, label: '3 dakika/gün'),
          OnboardingChip(icon: Icons.bolt_rounded, label: 'Hızlı gelişim'),
        ],
      ),
      OnboardingPageModel(
        icon: Icons.speed_rounded,
        tag: '02 — OYUNLAR',
        title: 'Hız. Odak.\n',
        highlight: 'Hafıza.',
        subtitle:
            '7 farklı bilişsel alanda 17+ mini oyun seni bekliyor. '
            'Sınırlarını zorla ve her gün daha iyi ol.',
        gradientColors: [Color(0xFF059669), Color(0xFF0891B2)],
        accentColor: Color(0xFF059669),
        chips: [
          OnboardingChip(icon: Icons.games_rounded, label: '17+ oyun'),
          OnboardingChip(icon: Icons.category_rounded, label: '7 kategori'),
        ],
      ),
      OnboardingPageModel(
        icon: Icons.trending_up_rounded,
        tag: '03 — İLERLEME',
        title: 'Gelişimini\n',
        highlight: 'Takip Et',
        subtitle:
            'Radar grafiği ve istatistiklerle bilişsel skorlarını görsel olarak izle. '
            'Hangi alanda güçlüsün, keşfet.',
        gradientColors: [Color(0xFF9333EA), Color(0xFFEC4899)],
        accentColor: Color(0xFF9333EA),
        chips: [
          OnboardingChip(
              icon: Icons.bar_chart_rounded, label: 'Detaylı istatistik'),
          OnboardingChip(icon: Icons.radar, label: 'Radar grafik'),
        ],
      ),
      OnboardingPageModel(
        icon: Icons.rocket_launch_rounded,
        tag: '04 — BAŞLA',
        title: 'Hazır mısın?\n',
        highlight: 'Haydi!',
        subtitle:
            'NöroDakika ile beyin antrenmanına hemen başlayabilirsin. '
            'Giriş yap veya üye ol, ücretsiz.',
        gradientColors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
        accentColor: Color(0xFFF59E0B),
        chips: [
          OnboardingChip(icon: Icons.lock_open_rounded, label: 'Ücretsiz'),
          OnboardingChip(
              icon: Icons.cloud_sync_rounded, label: 'Bulut kayıt'),
        ],
      ),
    ];
  }

  // ─── Genel olarak mevcut sayfayı değiştir ─────────────────
  void changePage(int index) {
    if (index < 0 || index >= state.pageCount) return;
    state = state.copyWith(currentPage: index);
  }

  // ─── Onboarding tamamlandı olarak işaretle ────────────────
  Future<void> markAsSeen() async {
    await LocalStorageService.setOnboardingSeen();
  }
}

// ─── Provider tanımı ──────────────────────────────────────
final onboardingProvider =
    StateNotifierProvider.autoDispose<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(),
);
