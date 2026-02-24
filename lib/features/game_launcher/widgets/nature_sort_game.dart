import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NatureSortGame extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;

  const NatureSortGame({super.key, required this.onComplete});

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

  late _NatureCard _card;

  final _plants = const <_NatureCard>[
    _NatureCard('Çam', '🌲', _NatureType.plant),
    _NatureCard('Çiçek', '🌸', _NatureType.plant),
    _NatureCard('Yaprak', '🍃', _NatureType.plant),
    _NatureCard('Kaktüs', '🌵', _NatureType.plant),
  ];

  final _animals = const <_NatureCard>[
    _NatureCard('Kuş', '🐦', _NatureType.animal),
    _NatureCard('Balık', '🐟', _NatureType.animal),
    _NatureCard('Kedi', '🐱', _NatureType.animal),
    _NatureCard('Köpek', '🐶', _NatureType.animal),
  ];

  @override
  void initState() {
    super.initState();
    _card = _nextCard();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _timeRemaining--);
      if (_timeRemaining <= 0) _finish();
    });
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

  void _answer(_NatureType type) {
    final ok = type == _card.type;
    setState(() {
      if (ok) {
        _correct++;
        _score += 110;
      } else {
        _wrong++;
        _score = max(0, _score - 60);
      }
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final textColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

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
                'Kartı doğru kategoriye sür: Bitki mi Hayvan mı?',
                style: GoogleFonts.spaceGrotesk(fontSize: 14, color: textColor),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F2937) : Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_card.emoji, style: const TextStyle(fontSize: 84)),
                    const SizedBox(height: 12),
                    Text(
                      _card.label,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _ChoiceButton(
                            label: 'Bitki',
                            color: const Color(0xFF10B981),
                            onTap: () => _answer(_NatureType.plant),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ChoiceButton(
                            label: 'Hayvan',
                            color: const Color(0xFF3B82F6),
                            onTap: () => _answer(_NatureType.animal),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Doğru: $_correct   Yanlış: $_wrong   Skor: $_score',
                      style: GoogleFonts.robotoMono(fontSize: 12, color: textColor),
                    ),
                  ],
                ),
              ),
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

  const _ChoiceButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withOpacity(0.85)],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
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
    final titleColor = isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.robotoMono(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: titleColor,
        ),
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
