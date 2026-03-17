import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class NatureSortGame extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;
  final bool isPaused;

  const NatureSortGame({
    super.key,
    required this.onComplete,
    this.isPaused = false,
  });

  @override
  State<NatureSortGame> createState() => _NatureSortGameState();
}

class _NatureSortGameState extends State<NatureSortGame> {
  static const int totalSeconds = 60;

  final Random _rng = Random();
  Timer? _timer;
  int _timeRemaining = totalSeconds;

  int _correct = 0;
  int _wrong = 0;
  int _score = 0;
  int _combo = 0; // Yeni: Kombo sistemi
  int _cardIndex = 0; // Kartların key'lerini yenilemek için

  late _NatureCard _card;

  // Yeni: Çok daha genişletilmiş bitki listesi
  final _plants = const <_NatureCard>[
    _NatureCard('Çam Ağacı', '🌲', _NatureType.plant),
    _NatureCard('Çiçek', '🌸', _NatureType.plant),
    _NatureCard('Yaprak', '🍃', _NatureType.plant),
    _NatureCard('Kaktüs', '🌵', _NatureType.plant),
    _NatureCard('Ayçiçeği', '🌻', _NatureType.plant),
    _NatureCard('Palmiye', '🌴', _NatureType.plant),
    _NatureCard('Lale', '🌷', _NatureType.plant),
    _NatureCard('Mantar', '🍄', _NatureType.plant),
    _NatureCard('Havuç', '🥕', _NatureType.plant),
    _NatureCard('Yonca', '🍀', _NatureType.plant),
    _NatureCard('Elma', '🍎', _NatureType.plant),
    _NatureCard('Buğday', '🌾', _NatureType.plant),
  ];

  // Yeni: Çok daha genişletilmiş hayvan listesi
  final _animals = const <_NatureCard>[
    _NatureCard('Kuş', '🐦', _NatureType.animal),
    _NatureCard('Balık', '🐟', _NatureType.animal),
    _NatureCard('Kedi', '🐱', _NatureType.animal),
    _NatureCard('Köpek', '🐶', _NatureType.animal),
    _NatureCard('Aslan', '🦁', _NatureType.animal),
    _NatureCard('Kaplan', '🐯', _NatureType.animal),
    _NatureCard('Kurbağa', '🐸', _NatureType.animal),
    _NatureCard('Arı', '🐝', _NatureType.animal),
    _NatureCard('Kelebek', '🦋', _NatureType.animal),
    _NatureCard('Penguen', '🐧', _NatureType.animal),
    _NatureCard('Yunus', '🐬', _NatureType.animal),
    _NatureCard('Ahtapot', '🐙', _NatureType.animal),
  ];

  @override
  void initState() {
    super.initState();
    _card = _nextCard();
    if (!widget.isPaused) _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _timeRemaining--);
      if (_timeRemaining <= 0) _finish();
    });
  }

  @override
  void didUpdateWidget(covariant NatureSortGame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPaused != widget.isPaused) {
      if (widget.isPaused) {
        _timer?.cancel();
      } else {
        _startTimer();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  _NatureCard _nextCard() {
    final fromPlants = _rng.nextBool();
    final list = fromPlants ? _plants : _animals;
    return list[_rng.nextInt(list.length)];
  }

  void _answer(_NatureType selectedType) {
    if (_timeRemaining <= 0 || widget.isPaused) return;

    final isCorrect = selectedType == _card.type;

    setState(() {
      if (isCorrect) {
        HapticFeedback.lightImpact(); // Doğru cevapta hafif titreşim
        _correct++;
        _combo++;
        _score += 100 + (_combo * 10); // Kombo yaptıkça daha çok puan
      } else {
        HapticFeedback.heavyImpact(); // Yanlış cevapta sert titreşim
        _wrong++;
        _combo = 0;
        _score = max(0, _score - 60);
      }

      _cardIndex++;
      _card = _nextCard();
    });
  }

  void _finish() {
    _timer?.cancel();
    final total = max(1, _correct + _wrong);
    widget.onComplete({
      'score': _score.toDouble(),
      'successRate': _correct / total,
      'duration': (totalSeconds - _timeRemaining),
      'goodHits': _correct,
      'badHits': _wrong,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor =
        isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final textColor =
        isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nature Sort',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                _Pill(text: '$_timeRemaining s', isDark: isDark),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Kartı sola (Bitki) veya sağa (Hayvan) kaydır!',
                style: GoogleFonts.spaceGrotesk(fontSize: 14, color: textColor),
              ),
            ),
            const SizedBox(height: 18),

            // Oyun Alanı
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Animasyonlu ve Kaydırılabilir Kart
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Dismissible(
                      // Her karta benzersiz bir key veriyoruz ki widget ağacı sıfırlansın
                      key: ValueKey<int>(_cardIndex),
                      direction: DismissDirection.horizontal,
                      onDismissed: (direction) {
                        if (direction == DismissDirection.endToStart) {
                          // Sola kaydırma (Bitki)
                          _answer(_NatureType.plant);
                        } else if (direction == DismissDirection.startToEnd) {
                          // Sağa kaydırma (Hayvan)
                          _answer(_NatureType.animal);
                        }
                      },
                      // Sola kaydırırken arka plan
                      secondaryBackground: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 32),
                        child: const Icon(Icons.park_rounded,
                            color: Color(0xFF10B981), size: 48),
                      ),
                      // Sağa kaydırırken arka plan
                      background: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 32),
                        child: const Icon(Icons.pets_rounded,
                            color: Color(0xFF3B82F6), size: 48),
                      ),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xFF1F2937) : Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF374151)
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_card.emoji,
                                style: const TextStyle(fontSize: 96)),
                            const SizedBox(height: 24),
                            Text(
                              _card.label,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: titleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Alt Butonlar ve İstatistikler
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _ChoiceButton(
                        label: 'Sola Kaydır\nBİTKİ',
                        icon: Icons.keyboard_double_arrow_left_rounded,
                        color: const Color(0xFF10B981),
                        onTap: () => _answer(_NatureType.plant),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ChoiceButton(
                        label: 'Sağa Kaydır\nHAYVAN',
                        icon: Icons.keyboard_double_arrow_right_rounded,
                        isRightArrow: true,
                        color: const Color(0xFF3B82F6),
                        onTap: () => _answer(_NatureType.animal),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Doğru: $_correct   Yanlış: $_wrong   Kombo: x$_combo',
                      style: GoogleFonts.robotoMono(
                          fontSize: 13,
                          color: textColor,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'SKOR: $_score',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    color: titleColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final IconData icon;
  final bool isRightArrow;

  const _ChoiceButton({
    required this.label,
    required this.color,
    required this.onTap,
    required this.icon,
    this.isRightArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withValues(alpha: 0.85)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isRightArrow) ...[
                Icon(icon,
                    color: Colors.white.withValues(alpha: 0.8), size: 28),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              if (isRightArrow) ...[
                const SizedBox(width: 8),
                Icon(icon,
                    color: Colors.white.withValues(alpha: 0.8), size: 28),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final bool isDark;

  const _Pill({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final titleColor =
        isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined,
              size: 16, color: titleColor.withValues(alpha: 0.7)),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.robotoMono(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
        ],
      ),
    );
  }
}

enum _NatureType { plant, animal }

class _NatureCard {
  final String label;
  final String emoji;
  final _NatureType type;

  const _NatureCard(this.label, this.emoji, this.type);
}
