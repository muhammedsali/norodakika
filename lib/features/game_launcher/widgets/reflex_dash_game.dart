import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ReflexDashGame extends StatefulWidget {
  final void Function(Map<String, dynamic>) onComplete;
  final bool isPaused;

  const ReflexDashGame({
    super.key,
    required this.onComplete,
    required this.isPaused,
  });

  @override
  State<ReflexDashGame> createState() => _ReflexDashGameState();
}

class _ReflexDashGameState extends State<ReflexDashGame>
    with SingleTickerProviderStateMixin {
  static const int gameDuration = 30; // saniye

  late Timer _timer;
  int _timeRemaining = gameDuration;

  final Random _rng = Random();

  // Her hedef için ortalama yaşam süresi ve hız
  static const int targetLifetimeMs = 1500;

  int _score = 0;
  int _correctHits = 0;
  int _wrongHits = 0;
  int _spawnedTargets = 0;

  List<_DashTarget> _targets = [];

  late AnimationController _controller;

  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: targetLifetimeMs),
    )..addListener(_updateTargets);

    _startGame();
  }

  @override
  void didUpdateWidget(covariant ReflexDashGame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPaused != widget.isPaused) {
      if (widget.isPaused) {
        _timer.cancel();
        _controller.stop();
      } else if (!_isFinished) {
        _resumeGame();
      }
    }
  }

  void _startGame() {
    _timeRemaining = gameDuration;
    _score = 0;
    _correctHits = 0;
    _wrongHits = 0;
    _spawnedTargets = 0;
    _targets = [];
    _isFinished = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (widget.isPaused) return;
      setState(() {
        _timeRemaining--;
      });
      if (_timeRemaining <= 0) {
        _finishGame();
      }
    });

    _spawnInitialTargets();
    _controller.repeat();
  }

  void _resumeGame() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (widget.isPaused) return;
      setState(() {
        _timeRemaining--;
      });
      if (_timeRemaining <= 0) {
        _finishGame();
      }
    });
    _controller.repeat();
  }

  void _spawnInitialTargets() {
    _targets = List.generate(3, (_) => _createRandomTarget());
    _spawnedTargets = _targets.length;
  }

  _DashTarget _createRandomTarget() {
    final lane = _rng.nextInt(3); // 0,1,2
    final isGood = _rng.nextBool();
    return _DashTarget(
      lane: lane,
      isGood: isGood,
      progress: 0,
    );
  }

  void _updateTargets() {
    if (!mounted || widget.isPaused || _isFinished) return;

    setState(() {
      final dt = _controller.value; // 0..1
      for (var t in _targets) {
        t.progress = dt;
      }

      if (_controller.status == AnimationStatus.completed ||
          _controller.status == AnimationStatus.dismissed) {
        // Döngü sonunda hedefleri yenile
        _targets = List.generate(3, (_) => _createRandomTarget());
        _spawnedTargets += _targets.length;
        _controller.forward(from: 0);
      }
    });
  }

  void _handleTapOnLane(int lane) {
    if (_isFinished || widget.isPaused) return;

    HapticFeedback.lightImpact();

    setState(() {
      final hitTargetIndex = _targets.indexWhere((t) => t.lane == lane);
      if (hitTargetIndex == -1) {
        // boş yere bastı
        _wrongHits++;
        _score = (_score - 50).clamp(0, 999999);
        return;
      }

      final target = _targets[hitTargetIndex];
      if (target.isGood) {
        _correctHits++;
        _score += 100;
      } else {
        _wrongHits++;
        _score = (_score - 100).clamp(0, 999999);
      }

      // vurulan hedefi kaldır ve yeni bir tane üret
      _targets[hitTargetIndex] = _createRandomTarget();
      _spawnedTargets++;
    });
  }

  void _finishGame() {
    _timer.cancel();
    _controller.stop();

    setState(() {
      _isFinished = true;
    });

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
    _controller.dispose();
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
                        'Reflex Dash',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Doğru şeritteki hedeflere hızlıca dokun.',
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
              const SizedBox(height: 16),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final laneWidth = constraints.maxWidth / 3;

                    return Stack(
                      children: [
                        // şerit arka planları
                        for (int lane = 0; lane < 3; lane++)
                          Positioned(
                            left: lane * laneWidth,
                            right: constraints.maxWidth - (lane + 1) * laneWidth,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF374151)
                                      : const Color(0xFFE5E7EB),
                                ),
                              ),
                            ),
                          ),

                        // hedefler
                        for (final target in _targets)
                          Positioned(
                            left: target.lane * laneWidth + 8,
                            width: laneWidth - 16,
                            top: constraints.maxHeight * target.progress,
                            child: Container(
                              height: 36,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                gradient: LinearGradient(
                                  colors: target.isGood
                                      ? const [Color(0xFF10B981), Color(0xFF059669)]
                                      : const [Color(0xFFEF4444), Color(0xFFB91C1C)],
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (int lane = 0; lane < 3; lane++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTapDown: (_) => _handleTapOnLane(lane),
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: isDark
                                  ? const Color(0xFF1F2937)
                                  : Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.bolt,
                                color: lane == 1
                                    ? const Color(0xFF4F46E5)
                                    : subtitleColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashTarget {
  int lane; // 0,1,2
  bool isGood;
  double progress; // 0..1 (ekranda yukarıdan aşağıya)

  _DashTarget({
    required this.lane,
    required this.isGood,
    required this.progress,
  });
}
