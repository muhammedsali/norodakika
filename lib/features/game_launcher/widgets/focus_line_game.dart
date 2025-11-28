import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class FocusLineGame extends StatefulWidget {
  final void Function(Map<String, dynamic>) onComplete;

  const FocusLineGame({
    super.key,
    required this.onComplete,
  });

  @override
  State<FocusLineGame> createState() => _FocusLineGameState();
}

class _FocusLineGameState extends State<FocusLineGame> {
  static const int gameDuration = 45; // saniye
  static const int spawnIntervalMs = 800;

  final Random _rng = Random();

  late Timer _timer;
  late Timer _spawnTimer;

  int _timeRemaining = gameDuration;

  Color _targetColor = Colors.blue;

  // ekranda aynı anda birkaç nokta olsun
  final List<_FocusDot> _dots = [];

  int _score = 0;
  int _correctHits = 0;
  int _wrongHits = 0;

  @override
  void initState() {
    super.initState();
    _resetTargetColor();
    _startGame();
  }

  void _resetTargetColor() {
    const colors = [Colors.blue, Colors.red, Colors.green, Colors.orange];
    _targetColor = colors[_rng.nextInt(colors.length)];
  }

  void _startGame() {
    _timeRemaining = gameDuration;
    _score = 0;
    _correctHits = 0;
    _wrongHits = 0;
    _dots.clear();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        _timeRemaining--;
      });
      if (_timeRemaining <= 0) {
        _finishGame();
      }
    });

    _spawnTimer = Timer.periodic(
      const Duration(milliseconds: spawnIntervalMs),
      (t) => _spawnDot(),
    );
  }

  void _spawnDot() {
    if (_timeRemaining <= 0) return;

    final isTarget = _rng.nextBool();
    final color = isTarget ? _targetColor : _randomOtherColor(_targetColor);

    _dots.add(
      _FocusDot(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        color: color,
      ),
    );

    // çok birikmesin
    if (_dots.length > 12) {
      _dots.removeAt(0);
    }

    setState(() {});
  }

  Color _randomOtherColor(Color exclude) {
    final all = [Colors.blue, Colors.red, Colors.green, Colors.orange];
    final filtered = all.where((c) => c != exclude).toList();
    return filtered[_rng.nextInt(filtered.length)];
  }

  void _onDotTap(_FocusDot dot) {
    HapticFeedback.lightImpact();

    setState(() {
      if (dot.color == _targetColor) {
        _correctHits++;
        _score += 100;
      } else {
        _wrongHits++;
        _score = (_score - 75).clamp(0, 999999);
      }
      _dots.remove(dot);
    });
  }

  void _finishGame() {
    _timer.cancel();
    _spawnTimer.cancel();

    final totalHits = _correctHits + _wrongHits;
    final successRate = totalHits == 0 ? 0.0 : _correctHits / totalHits;

    widget.onComplete({
      'score': _score.toDouble(),
      'successRate': successRate,
      'duration': gameDuration,
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _spawnTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6);
    final titleColor = isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final subtitleColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Focus Line',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sadece hedef renkteki noktalara dokun.',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$_timeRemaining s',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Skor: $_score',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F2937) : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Hedef renk: ',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        color: subtitleColor,
                      ),
                    ),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _targetColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '(Doğru renklere bas, diğerlerini görmezden gel)',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF020617) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;

                      return Stack(
                        children: [
                          // ana çizgi
                          Positioned(
                            left: 0,
                            right: 0,
                            top: constraints.maxHeight / 2 - 1,
                            height: 2,
                            child: Container(
                              color: subtitleColor.withOpacity(0.4),
                            ),
                          ),
                          // noktalar
                          for (final dot in _dots)
                            Positioned(
                              top: constraints.maxHeight / 2 - 10,
                              left: (width - 20) * _dots.indexOf(dot) /
                                  (_dots.length.clamp(1, 12)) +
                                  10,
                              child: GestureDetector(
                                onTapDown: (_) => _onDotTap(dot),
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: dot.color,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FocusDot {
  final String id;
  final Color color;

  _FocusDot({
    required this.id,
    required this.color,
  });
}
