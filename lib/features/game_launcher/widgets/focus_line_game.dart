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

class _FocusLineGameState extends State<FocusLineGame> with TickerProviderStateMixin {
  static const int gameDuration = 60; // saniye
  static const int maxLives = 3;
  static const int baseSpawnInterval = 1200;

  final Random _rng = Random();
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  Timer? _timer;
  Timer? _spawnTimer;

  int _timeRemaining = gameDuration;
  int _level = 1;
  int _score = 0;
  int _lives = maxLives;
  int _combo = 0;
  int _bestCombo = 0;
  int _correctHits = 0;
  int _wrongHits = 0;
  int _missedTargets = 0;

  Color _targetColor = Colors.blue;
  final List<_FocusDot> _dots = [];
  int _spawnInterval = baseSpawnInterval;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);

    _resetTargetColor();
    _startGame();
  }

  void _resetTargetColor() {
    const colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple];
    _targetColor = colors[_rng.nextInt(colors.length)];
  }

  void _startGame() {
    _timeRemaining = gameDuration;
    _score = 0;
    _level = 1;
    _lives = maxLives;
    _combo = 0;
    _bestCombo = 0;
    _correctHits = 0;
    _wrongHits = 0;
    _missedTargets = 0;
    _dots.clear();
    _spawnInterval = baseSpawnInterval;

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _timeRemaining--;
        // Her 10 saniyede bir level artışı
        if ((gameDuration - _timeRemaining) % 10 == 0 && _timeRemaining < gameDuration) {
          _level++;
          _spawnInterval = (baseSpawnInterval * (1 - (_level - 1) * 0.1)).clamp(600, baseSpawnInterval).toInt();
          _resetTargetColor();
        }
      });
      if (_timeRemaining <= 0) {
        _finishGame();
      }
    });

    _spawnTimer = Timer.periodic(
      Duration(milliseconds: _spawnInterval),
      (t) {
        if (!mounted || _timeRemaining <= 0) return;
        _spawnDot();
      },
    );
  }

  void _spawnDot() {
    if (_timeRemaining <= 0) return;

    final isTarget = _rng.nextDouble() < 0.4; // %40 hedef, %60 yanlış
    final color = isTarget ? _targetColor : _randomOtherColor(_targetColor);

    setState(() {
      _dots.add(
        _FocusDot(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          color: color,
          spawnTime: DateTime.now(),
        ),
      );

      // Çok birikmesin
      if (_dots.length > 15) {
        final removed = _dots.removeAt(0);
        if (removed.color == _targetColor) {
          _missedTargets++;
          _combo = 0;
        }
      }
    });
  }

  Color _randomOtherColor(Color exclude) {
    const all = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple];
    final filtered = all.where((c) => c != exclude).toList();
    return filtered[_rng.nextInt(filtered.length)];
  }

  void _onDotTap(_FocusDot dot) {
    HapticFeedback.lightImpact();

    setState(() {
      if (dot.color == _targetColor) {
        _correctHits++;
        _combo++;
        if (_combo > _bestCombo) _bestCombo = _combo;
        
        // Combo bonusu
        final comboBonus = _combo > 1 ? (_combo - 1) * 10 : 0;
        _score += (100 + comboBonus + (_level * 5)).toInt();
      } else {
        _wrongHits++;
        _lives--;
        _combo = 0;
        _score = (_score - 50).clamp(0, 999999);
        _shakeController.forward(from: 0.0);
        
        if (_lives <= 0) {
          _finishGame();
          return;
        }
      }
      _dots.remove(dot);
    });
  }

  void _finishGame() {
    _timer?.cancel();
    _spawnTimer?.cancel();

    final totalHits = _correctHits + _wrongHits;
    final successRate = totalHits == 0 ? 0.0 : _correctHits / totalHits;

    widget.onComplete({
      'score': _score.toDouble(),
      'successRate': successRate,
      'duration': gameDuration - _timeRemaining,
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _spawnTimer?.cancel();
    _pulseController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6);
    final panelColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final titleColor = isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final subtitleColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: panelColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
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
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: titleColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Sadece hedef renkteki noktalara dokun',
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
                            Row(
                              children: List.generate(maxLives, (index) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Icon(
                                    Icons.favorite,
                                    size: 20,
                                    color: index < _lives
                                        ? Colors.red
                                        : subtitleColor.withOpacity(0.3),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Level $_level',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _targetColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Timer bar
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _timeRemaining / gameDuration,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _targetColor,
                                _targetColor.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStat('$_timeRemaining s', Icons.timer_outlined, subtitleColor),
                        _buildStat('Skor: $_score', Icons.star, Colors.amber),
                        if (_combo > 0)
                          _buildStat('Seri: $_combo', Icons.local_fire_department, Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Target color indicator
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: _targetColor.withOpacity(0.1 + _pulseController.value * 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _targetColor.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _targetColor,
                            boxShadow: [
                              BoxShadow(
                                color: _targetColor.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Hedef renk: Bu renge dokun',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _targetColor,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Game area
              Expanded(
                child: AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(sin(_shakeController.value * 2 * pi) * _shakeAnimation.value, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF020617) : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            final height = constraints.maxHeight;
                            final centerY = height / 2;

                            return Stack(
                              children: [
                                // Ana çizgi
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  top: centerY - 2,
                                  height: 4,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          _targetColor.withOpacity(0.3),
                                          _targetColor.withOpacity(0.1),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Noktalar
                                for (final dot in _dots)
                                  Positioned(
                                    top: centerY - 15,
                                    left: (width - 30) * _dots.indexOf(dot) / (_dots.length.clamp(1, 15)) + 15,
                                    child: GestureDetector(
                                      onTapDown: (_) => _onDotTap(dot),
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: dot.color,
                                          boxShadow: [
                                            BoxShadow(
                                              color: dot.color.withOpacity(0.6),
                                              blurRadius: 12,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String text, IconData icon, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _FocusDot {
  final String id;
  final Color color;
  final DateTime spawnTime;

  _FocusDot({
    required this.id,
    required this.color,
    required this.spawnTime,
  });
}
