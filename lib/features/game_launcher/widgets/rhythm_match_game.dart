import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RhythmMatchGame extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;

  const RhythmMatchGame({super.key, required this.onComplete});

  @override
  State<RhythmMatchGame> createState() => _RhythmMatchGameState();
}

class _RhythmMatchGameState extends State<RhythmMatchGame> {
  static const int totalSeconds = 60;
  static const int rounds = 10;
  static const int stepsPerRound = 4;

  final Random _rng = Random();

  Timer? _timer;
  int _timeRemaining = totalSeconds;

  int _roundIndex = 0;
  bool _showingSequence = true;
  int _inputStep = 0;

  int _correctRounds = 0;
  int _wrongRounds = 0;
  int _score = 0;

  late List<int> _sequence;
  int? _highlight;

  @override
  void initState() {
    super.initState();
    _resetRound();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _timeRemaining--;
      });
      if (_timeRemaining <= 0) {
        _finish();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resetRound() {
    _sequence = List.generate(stepsPerRound, (_) => _rng.nextInt(4));
    _showingSequence = true;
    _inputStep = 0;
    _highlight = null;
    _playSequence();
  }

  Future<void> _playSequence() async {
    for (int i = 0; i < _sequence.length; i++) {
      if (!mounted) return;
      setState(() {
        _highlight = _sequence[i];
      });
      await Future.delayed(const Duration(milliseconds: 450));
      if (!mounted) return;
      setState(() {
        _highlight = null;
      });
      await Future.delayed(const Duration(milliseconds: 200));
    }
    if (!mounted) return;
    setState(() {
      _showingSequence = false;
    });
  }

  void _onTapPad(int index) {
    if (_showingSequence) return;

    final expected = _sequence[_inputStep];
    if (index == expected) {
      _inputStep++;
      if (_inputStep >= _sequence.length) {
        _correctRounds++;
        _score += 150;
        _nextRound();
      }
    } else {
      _wrongRounds++;
      _score = max(0, _score - 80);
      _nextRound();
    }
  }

  void _nextRound() {
    _roundIndex++;
    if (_roundIndex >= rounds) {
      _finish();
      return;
    }
    _resetRound();
  }

  void _finish() {
    _timer?.cancel();

    final total = max(1, _correctRounds + _wrongRounds);
    final successRate = _correctRounds / total;

    widget.onComplete({
      'score': _score.toDouble(),
      'successRate': successRate,
      'duration': (totalSeconds - _timeRemaining),
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final textColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    final colors = [
      const Color(0xFFEF4444),
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
    ];

    return SafeArea(
      
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rhythm Match',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1F2937) : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Text(
                    '$_timeRemaining s',
                    style: GoogleFonts.robotoMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _showingSequence
                    ? 'Watch the sequence…'
                    : 'Repeat it by tapping the pads.',
                style: GoogleFonts.spaceGrotesk(fontSize: 14, color: textColor),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2937) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Round ${_roundIndex + 1}/$rounds',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                  Text(
                    'Score: $_score',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.1,
                children: List.generate(4, (i) {
                  final base = colors[i];
                  final isHighlighted = _highlight == i;
                  return GestureDetector(
                    onTap: () => _onTapPad(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            base.withOpacity(isHighlighted ? 1 : 0.85),
                            base.withOpacity(isHighlighted ? 0.85 : 0.55),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: base.withOpacity(isHighlighted ? 0.5 : 0.25),
                            blurRadius: isHighlighted ? 24 : 16,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
