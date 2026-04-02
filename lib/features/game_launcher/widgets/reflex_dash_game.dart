import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/audio_service.dart';

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
  late Ticker _ticker;

  final Random _rng = Random();

  bool _isFinished = false;
  bool _isRunning = false;

  int _score = 0;
  int _goodHits = 0;
  int _badHits = 0;
  int _missed = 0;
  int _hearts = 3;
  int _combo = 0;
  int _bestCombo = 0;

  // Bölüm Modu Değişkenleri
  int _level = 1;
  int _targetsToClear = 5;
  int _targetsClearedInLevel = 0;

  double _spawnCooldownMs = 1200;
  double _spawnAccumulatorMs = 0;
  double _currentLifetimeMs = 1800;

  Duration _lastTick = Duration.zero;
  final List<_DashTarget> _targets = [];

  // FPS Optimizasyonu: Sadece arenayı güncelleyen Notifier
  final ValueNotifier<int> _renderNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
    _resetState();
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

  void _resetState() {
    setState(() {
      _score = 0;
      _goodHits = 0;
      _badHits = 0;
      _missed = 0;
      _hearts = 3;
      _combo = 0;
      _bestCombo = 0;
      _level = 1;
      _targetsToClear = 5;
      _targetsClearedInLevel = 0;
      _spawnCooldownMs = 1200;
      _currentLifetimeMs = 1800;
      _spawnAccumulatorMs = 0;
      _lastTick = Duration.zero;
      _targets.clear();
      _isFinished = false;
      _isRunning = true;
    });
  }

  void _onTick(Duration elapsed) {
    if (!_isRunning || _isFinished) {
      _lastTick = elapsed;
      return;
    }
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
    }
  }

  void _updateTargets(double dtMs) {
    bool needsUpdate = false;
    final expired = <_DashTarget>[];
    
    for (final target in _targets) {
      target.elapsedMs += dtMs;
      needsUpdate = true; // Position changed
      if (target.progress >= 1) {
        expired.add(target);
      }
    }

    if (expired.isNotEmpty) {
      for (final target in expired) {
        _targets.remove(target);
        if (target.isGood) {
          _missed++;
          AudioService().playWrong();
          setState(() {
            _hearts = max(0, _hearts - 1);
            _combo = 0;
          });
          _checkDeath();
        }
      }
    }
    
    if (needsUpdate && mounted) {
      // FPS Fix: Sadece arena güncellenir, setState kullanılmaz!
      _renderNotifier.value++;
    }
  }

  void _spawnTarget() {
    if (!mounted) return;
    final lane = _rng.nextInt(3);
    final isGood = _rng.nextDouble() > 0.3; // %70 iyi, %30 kötü
    _targets.add(
      _DashTarget(
        id: DateTime.now().microsecondsSinceEpoch,
        lane: lane,
        isGood: isGood,
        lifetimeMs: _currentLifetimeMs,
      ),
    );
  }

  void _levelUp() {
    setState(() {
      _level++;
      _targetsToClear += 3; // Sonraki bölümde hedefler artar
      _targetsClearedInLevel = 0;
      
      // Hız artışı
      _spawnCooldownMs = max(400, _spawnCooldownMs * 0.85);
      _currentLifetimeMs = max(800, _currentLifetimeMs * 0.90);
      
      _hearts = min(3, _hearts + 1); // Ödül can
      _targets.clear();
      AudioService().playLevelUp();
    });
  }

  void _handleTapOnLane(int lane) {
    if (_isFinished || !_isRunning) return;

    // Hedefi bul
    _DashTarget? hit;
    for (final target in _targets.where((t) => t.lane == lane)) {
      if (hit == null || target.progress > hit.progress) {
        hit = target;
      }
    }

    if (hit == null) {
      AudioService().playWrong();
      setState(() {
        _badHits++;
        _combo = 0;
        _score = max(0, _score - 20);
      });
      return;
    }

    _targets.remove(hit);
    
    if (hit.isGood) {
      AudioService().playTap();
      _goodHits++;
      _targetsClearedInLevel++;
      
      setState(() {
        _combo++;
        _bestCombo = max(_bestCombo, _combo);
        _score += 50 + (_combo * 10);
      });

      if (_targetsClearedInLevel >= _targetsToClear) {
        _levelUp();
      }
    } else {
      AudioService().playWrong();
      setState(() {
        _badHits++;
        _combo = 0;
        _hearts = max(0, _hearts - 1);
        _score = max(0, _score - 50);
      });
      _checkDeath();
    }
    
    _renderNotifier.value++; // Arenayı zorla güncelle
  }

  void _checkDeath() {
    if (_hearts <= 0) {
      AudioService().playGameOver();
      _finishGame();
    }
  }

  void _finishGame() {
    if (_isFinished) return;
    _isFinished = true;
    _isRunning = false;

    final totalAttempts = _goodHits + _badHits + _missed;
    final accuracy = totalAttempts == 0 ? 0.0 : _goodHits / totalAttempts;

    widget.onComplete({
      'score': _score.toDouble(),
      'successRate': accuracy,
      'duration': _level * 15, // Tahmini harcanan süre
      'goodHits': _goodHits,
      'badHits': _badHits,
      'missed': _missed,
      'bestCombo': _bestCombo,
      'level': _level
    });
    setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    _renderNotifier.dispose();
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
            color: Colors.black.withValues(alpha: 0.06),
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
                'Bölüm: $_level - Hedef: $_targetsClearedInLevel / $_targetsToClear',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4F46E5),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Skor: $_score',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
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
              border: Border.all(color: Colors.black.withValues(alpha: 0.02)),
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
                            : subtitleColor.withValues(alpha: 0.35),
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
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ValueListenableBuilder<int>(
            valueListenable: _renderNotifier,
            builder: (context, _, __) {
              return Stack(
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
                  // Hedefler
                  for (final target in _targets)
                    Positioned(
                      left: target.lane * laneWidth + 14,
                      width: laneWidth - 28,
                      top: (constraints.maxHeight - 40) * target.progress,
                      child: _DashChip(target: target),
                    ),
                  if (!_isFinished && !_isRunning)
                    _PauseOverlay(onResume: () {
                      setState(() {
                        _isRunning = true;
                      });
                    }),
                ],
              );
            }
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
                child: Container(
                  height: 62,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: panelColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.bolt_rounded,
                      color: Color(0xFF4F46E5),
                      size: 28,
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
  final int lane; 
  final bool isGood;
  final double lifetimeMs;
  double elapsedMs = 0.0;

  _DashTarget({
    required this.id,
    required this.lane,
    required this.isGood,
    required this.lifetimeMs,
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

    return Container(
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
            color: colors.first.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
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
          color: Colors.black.withValues(alpha: 0.35),
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
