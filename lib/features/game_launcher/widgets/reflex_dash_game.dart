import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
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
  static const int gameDuration = 40; // saniye
  static const double _initialLifetimeMs = 1400;
  static const double _minLifetimeMs = 850;
  static const double _initialSpawnMs = 900;
  static const double _minSpawnMs = 480;
  static const double _difficultyStepMs = 12;

  late Timer _timer;
  late Ticker _ticker;

  final Random _rng = Random();

  int _timeRemaining = gameDuration;
  bool _isFinished = false;
  bool _isRunning = false;

  int _score = 0;
  int _goodHits = 0;
  int _badHits = 0;
  int _missed = 0;
  int _hearts = 3;
  int _combo = 0;
  int _bestCombo = 0;

  double _spawnCooldownMs = _initialSpawnMs;
  double _spawnAccumulatorMs = 0;
  double _currentLifetimeMs = _initialLifetimeMs;

  Duration _lastTick = Duration.zero;
  final List<_DashTarget> _targets = [];

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
    _startGame();
  }

  @override
  void didUpdateWidget(covariant ReflexDashGame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPaused != widget.isPaused) {
      if (widget.isPaused) {
        _isRunning = false;
      } else if (!_isFinished) {
        _isRunning = true;
      }
    }
  }

  void _startGame() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isRunning || _isFinished) return;
      setState(() {
        _timeRemaining--;
      });
      if (_timeRemaining <= 0) {
        _finishGame();
      }
    });

    _resetState();
  }

  void _resetState() {
    _timeRemaining = gameDuration;
    _score = 0;
    _goodHits = 0;
    _badHits = 0;
    _missed = 0;
    _hearts = 3;
    _combo = 0;
    _bestCombo = 0;
    _spawnCooldownMs = _initialSpawnMs;
    _currentLifetimeMs = _initialLifetimeMs;
    _spawnAccumulatorMs = 0;
    _lastTick = Duration.zero;
    _targets.clear();
    _isFinished = false;
    _isRunning = true;
  }

  void _onTick(Duration elapsed) {
    if (!_isRunning || _isFinished) return;
    if (_lastTick == Duration.zero) {
      _lastTick = elapsed;
      return;
    }

    final dtMs = (elapsed - _lastTick).inMilliseconds.toDouble();
    _lastTick = elapsed;

    _updateTargets(dtMs);
    _spawnAccumulatorMs += dtMs;
    if (_spawnAccumulatorMs >= _spawnCooldownMs) {
      _spawnAccumulatorMs = 0;
      _spawnTarget();
      _increaseDifficulty();
    }
  }

  void _updateTargets(double dtMs) {
    if (!mounted) return;

    final expired = <_DashTarget>[];
    for (final target in _targets) {
      target.elapsedMs += dtMs;
      if (target.progress >= 1) {
        expired.add(target);
      }
    }

    if (expired.isNotEmpty) {
      setState(() {
        for (final target in expired) {
          _targets.remove(target);
          if (target.isGood) {
            _missed++;
            _hearts = max(0, _hearts - 1);
            _combo = 0;
            _checkDeath();
          }
        }
      });
    } else {
      setState(() {});
    }
  }

  void _spawnTarget() {
    if (!mounted) return;
    final lane = _rng.nextInt(3);
    final isGood = _rng.nextDouble() > 0.28; // çoğunluk iyi
    _targets.add(
      _DashTarget(
        id: DateTime.now().microsecondsSinceEpoch,
        lane: lane,
        isGood: isGood,
        lifetimeMs: _currentLifetimeMs,
      ),
    );
  }

  void _increaseDifficulty() {
    _spawnCooldownMs = max(_minSpawnMs, _spawnCooldownMs - _difficultyStepMs);
    _currentLifetimeMs = max(_minLifetimeMs, _currentLifetimeMs - _difficultyStepMs);
  }

  void _handleTapOnLane(int lane) {
    if (_isFinished || !_isRunning) return;

    HapticFeedback.lightImpact();

    // en önde olan hedefi bul
    _DashTarget? hit;
    for (final target in _targets.where((t) => t.lane == lane)) {
      if (hit == null || target.progress > hit!.progress) {
        hit = target;
      }
    }

    if (hit == null) {
      setState(() {
        _badHits++;
        _combo = 0;
        _score = max(0, _score - 60);
      });
      return;
    }

    setState(() {
      _targets.remove(hit);
      if (hit!.isGood) {
        _goodHits++;
        _combo++;
        _bestCombo = max(_bestCombo, _combo);
        _score += 120 + (_combo * 15);
      } else {
        _badHits++;
        _combo = 0;
        _hearts = max(0, _hearts - 1);
        _score = max(0, _score - 120);
        _checkDeath();
      }
    });
  }

  void _checkDeath() {
    if (_hearts <= 0) {
      _finishGame();
    }
  }

  void _finishGame() {
    if (_isFinished) return;
    _isFinished = true;
    _isRunning = false;
    _timer.cancel();

    final totalAttempts = _goodHits + _badHits + _missed;
    final accuracy = totalAttempts == 0 ? 0.0 : _goodHits / totalAttempts;

    widget.onComplete({
      'score': _score.toDouble(),
      'accuracy': accuracy,
      'duration': gameDuration,
      'goodHits': _goodHits,
      'badHits': _badHits,
      'missed': _missed,
      'bestCombo': _bestCombo,
    });
    setState(() {});
  }

  @override
  void dispose() {
    _timer.cancel();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0B1220) : const Color(0xFFF7F8FB);
    final panelColor = isDark ? const Color(0xFF111827) : Colors.white;
    final titleColor = isDark ? const Color(0xFFF9FAFB) : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(titleColor, subtitleColor, panelColor),
              const SizedBox(height: 12),
              _buildMeters(titleColor, subtitleColor, panelColor),
              const SizedBox(height: 12),
              Expanded(child: _buildArena(isDark, panelColor)),
              const SizedBox(height: 12),
              _buildControls(panelColor, subtitleColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color titleColor, Color subtitleColor, Color panelColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reflex Dash',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Düşen iyi hedeflere dokun, kırmızılardan kaç.',
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
                  fontWeight: FontWeight.w700,
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
    );
  }

  Widget _buildMeters(Color titleColor, Color subtitleColor, Color panelColor) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: panelColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withOpacity(0.02)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(
                    3,
                    (i) => Padding(
                      padding: EdgeInsets.only(right: i == 2 ? 0 : 6),
                      child: Icon(
                        Icons.favorite_rounded,
                        size: 18,
                        color: i < _hearts
                            ? const Color(0xFFEF4444)
                            : subtitleColor.withOpacity(0.35),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.local_fire_department_rounded,
                        color: Color(0xFFFFA000), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Kombo $_combo',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        color: titleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: panelColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withOpacity(0.02)),
          ),
          child: Row(
            children: [
              const Icon(Icons.bolt_rounded, color: Color(0xFF4F46E5)),
              const SizedBox(width: 8),
              Text(
                'x${_bestCombo == 0 ? 1 : min(9, _combo).toString()}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArena(bool isDark, Color panelColor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final laneWidth = constraints.maxWidth / 3;
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: panelColor,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              for (int lane = 0; lane < 3; lane++)
                Positioned(
                  left: lane * laneWidth,
                  width: laneWidth,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF111827), const Color(0xFF0B1324)]
                            : [const Color(0xFFF8FAFC), const Color(0xFFE8ECF4)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF1F2937)
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                  ),
                ),
              for (final target in _targets)
                Positioned(
                  left: target.lane * laneWidth + 14,
                  width: laneWidth - 28,
                  top: (constraints.maxHeight - 40) * target.progress,
                  child: _DashChip(target: target),
                ),
              if (_isFinished)
                _ResultOverlay(
                  score: _score,
                  accuracy: _goodHits + _badHits + _missed == 0
                      ? 0
                      : _goodHits / (_goodHits + _badHits + _missed),
                  bestCombo: _bestCombo,
                ),
              if (!_isFinished && !_isRunning)
                _PauseOverlay(onResume: () {
                  setState(() {
                    _isRunning = true;
                  });
                }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControls(Color panelColor, Color subtitleColor) {
    return Row(
      children: [
        for (int lane = 0; lane < 3; lane++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: GestureDetector(
                onTapDown: (_) => _handleTapOnLane(lane),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  height: 62,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: panelColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.bolt_rounded,
                      color: lane == 1
                          ? const Color(0xFF4F46E5)
                          : subtitleColor.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _DashTarget {
  final int id;
  final int lane; // 0,1,2
  final bool isGood;
  final double lifetimeMs;
  double elapsedMs;

  _DashTarget({
    required this.id,
    required this.lane,
    required this.isGood,
    required this.lifetimeMs,
    this.elapsedMs = 0,
  });

  double get progress => elapsedMs / lifetimeMs;
}

class _DashChip extends StatelessWidget {
  final _DashTarget target;

  const _DashChip({required this.target});

  @override
  Widget build(BuildContext context) {
    final colors = target.isGood
        ? const [Color(0xFF22C55E), Color(0xFF16A34A)]
        : const [Color(0xFFEF4444), Color(0xFFB91C1C)];

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 120),
      opacity: target.progress.clamp(0, 1).toDouble(),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.25),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultOverlay extends StatelessWidget {
  final int score;
  final double accuracy;
  final int bestCombo;

  const _ResultOverlay({
    required this.score,
    required this.accuracy,
    required this.bestCombo,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Oyun Bitti',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Skor: $score',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4F46E5),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'İsabet: ${(accuracy * 100).toStringAsFixed(1)}%',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'En iyi kombo: $bestCombo',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PauseOverlay extends StatelessWidget {
  final VoidCallback onResume;

  const _PauseOverlay({required this.onResume});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: ElevatedButton.icon(
            onPressed: onResume,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Devam Et'),
          ),
        ),
      ),
    );
  }
}
