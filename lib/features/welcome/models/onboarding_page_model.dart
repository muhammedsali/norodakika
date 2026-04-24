import 'package:flutter/material.dart';

// ─── Özellik chip verisi ───────────────────────────────────
class OnboardingChip {
  final IconData icon;
  final String label;

  const OnboardingChip({
    required this.icon,
    required this.label,
  });
}

// ─── Tek onboarding sayfası için veri modeli ──────────────
class OnboardingPageModel {
  final IconData icon;
  final String tag;

  /// Başlığın gradient olmayan kısmı
  final String title;

  /// Başlığın gradient (renkli) kısmı
  final String highlight;

  final String subtitle;
  final List<Color> gradientColors;
  final Color accentColor;
  final List<OnboardingChip> chips;

  const OnboardingPageModel({
    required this.icon,
    required this.tag,
    required this.title,
    required this.highlight,
    required this.subtitle,
    required this.gradientColors,
    required this.accentColor,
    required this.chips,
  });
}
