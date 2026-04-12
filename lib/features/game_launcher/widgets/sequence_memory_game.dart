import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/audio_service.dart';

// ─────────────────────────────────────────────
// Data class — tüm oyun durumu tek yerde
// ─────────────────────────────────────────────
class _GameState {
  final int hearts;
  final int score;
  final int round;
  final int completed;
  final int attempts;
  final int streak;
  final int bestStreak;

  const _GameState({
    this.hearts = _SequenceMemoryGameState.maxHearts,
    this.score = 0,
    this.round = 1,
    this.completed = 0,
    this.attempts = 0,
    this.streak = 0,
    this.bestStreak = 0,
  });

  _GameState copyWith({
    int? hearts,
    int? score,
    int? round,
    int? completed,
    int? attempts,
    int? streak,
    int? bestStreak,
  }) =>
      _GameState(
        hearts: hearts ?? this.hearts,
        score: score ?? this.score,
        round: round ?? this.round,
        completed: completed ?? this.completed,
        attempts: attempts ?? this.attempts,
        streak: streak ?? this.streak,
        bestStreak: bestStreak ?? this.bestStreak,
      );

  double get successRate =>
      attempts == 0 ? 0.0 : completed / attempts;

  int get wrongAttempts => attempts - completed;
}

// ─────────────────────────────────────────────
// Widget
// ─────────────────────────────────────────────
class SequenceMemoryGame extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;
  final bool isPaused;
  final AudioService audioService;

  SequenceMemoryGame({
    super.key,
    required this.onComplete,
    required this.isPaused,
    AudioService? audioService,
  }) : audioService = audioService ?? AudioService();

  @override
  State<SequenceMemoryGame> createState() =>
      _SequenceMemoryGameState();
}

class _SequenceMemoryGameState
    extends State<SequenceMemoryGame> {
  // ── Sabitler ──────────────────────────────
  static const int totalSeconds = 60;
  static const int baseLength = 3;
  static const int maxHearts = 3;

  static const int _tapPoints = 35;
  static const int _roundCompleteBase = 180;
  static const int _roundCompleteMultiplier = 12;
  static const int _wrongPenalty = 120;

  static const Duration _preDelay =
      Duration(milliseconds: 220);
  static const Duration _showDelay =
      Duration(milliseconds: 520);

  // ── State ──────────────────────────────────
  final _rng = Random();
  _GameState _gs = const _GameState();

  late List<int> _sequence;
  final List<int> _input = [];

  final _timeNotifier =
      ValueNotifier<int>(totalSeconds);
  final _activeNotifier = ValueNotifier<int>(-1);

  bool _isPlaying = false;
  bool _isFinished = false;
  bool _sequenceCancelled = false;

  Timer? _gameTimer;

  // ── Lifecycle ──────────────────────────────
  @override
  void initState() {
    super.initState();
    _sequence = [];
    if (!widget.isPaused) {
      _startTimer();
      _startRound();
    }
  }

  @override
  void didUpdateWidget(covariant SequenceMemoryGame old) {
    super.didUpdateWidget(old);
    if (old.isPaused == widget.isPaused) return;

    if (widget.isPaused) {
      _gameTimer?.cancel();
    } else if (!_isFinished) {
      _startTimer();
      if (_sequence.isEmpty) _startRound();
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _timeNotifier.dispose();
    _activeNotifier.dispose();
    super.dispose();
  }

  // ── Timer ──────────────────────────────────
  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer =
        Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _isFinished) return;
      _timeNotifier.value--;
      if (_timeNotifier.value <= 0) _finish();
    });
  }

  // ── Round logic ────────────────────────────
  void _startRound() {
    if (_isFinished) return;
    _gs = _gs.copyWith(attempts: _gs.attempts + 1);
    _input.clear();
    final length = baseLength + _gs.round - 1;
    _sequence =
        List.generate(length, (_) => _rng.nextInt(9));
    _playSequence();
  }

  Future<void> _playSequence() async {
    _sequenceCancelled = false;
    setState(() => _isPlaying = true);

    for (final cell in _sequence) {
      if (_sequenceCancelled) return;
      await Future.delayed(_preDelay);
      if (_sequenceCancelled) return;
      _activeNotifier.value = cell;
      await Future.delayed(_showDelay);
      if (_sequenceCancelled) return;
      _activeNotifier.value = -1;
    }

    if (!_sequenceCancelled && mounted) {
      setState(() => _isPlaying = false);
    }
  }

  // ── Input ──────────────────────────────────
  bool get _inputBlocked =>
      _isFinished ||
      _isPlaying ||
      _timeNotifier.value <= 0 ||
      widget.isPaused;

  void _handleTap(int index) {
    if (_inputBlocked) return;
    HapticFeedback.selectionClick();
    widget.audioService.playTap();

    final expected = _sequence[_input.length];
    if (index == expected) {
      _onCorrectTap(index);
    } else {
      _onWrongTap();
    }
  }

  void _onCorrectTap(int index) {
    widget.audioService.playCorrect();
    HapticFeedback.lightImpact();
    _input.add(index);

    final newScore = _gs.score + _tapPoints;

    if (_input.length < _sequence.length) {
      setState(() => _gs = _gs.copyWith(score: newScore));
      return;
    }

    // Tur tamamlandı
    final newStreak = _gs.streak + 1;
    widget.audioService.playLevelUp();
    setState(() {
      _gs = _gs.copyWith(
        score: newScore +
            _roundCompleteBase +
            (_gs.round * _roundCompleteMultiplier),
        round: _gs.round + 1,
        completed: _gs.completed + 1,
        streak: newStreak,
        bestStreak: max(_gs.bestStreak, newStreak),
      );
    });
    _startRound();
  }

  void _onWrongTap() {
    widget.audioService.playWrong();
    HapticFeedback.mediumImpact();
    final newHearts = max(0, _gs.hearts - 1);
    setState(() {
      _gs = _gs.copyWith(
        hearts: newHearts,
        score: max(0, _gs.score - _wrongPenalty),
        streak: 0,
      );
    });
    if (newHearts == 0) {
      _finish();
    } else {
      _startRound();
    }
  }

  // ── Finish ─────────────────────────────────
  void _finish() {
    if (_isFinished) return;
    _isFinished = true;
    _sequenceCancelled = true;
    _gameTimer?.cancel();
    widget.audioService.playGameOver();

    final duration =
        totalSeconds - max(0, _timeNotifier.value);

    widget.onComplete({
      'score': _gs.score.toDouble(),
      'successRate': _gs.successRate,
      'duration': duration,
      'totalAttempts': _gs.attempts,
      'correctAttempts': _gs.completed,
      'wrongAttempts': _gs.wrongAttempts,
    });
    setState(() {});
  }

  // ── Build ──────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark
        ? const Color(0xFF0B1220)
        : const Color(0xFFF6F8FB);
    final panel =
        isDark ? const Color(0xFF111827) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _Header(
                isDark: isDark,
                panel: panel,
                timeNotifier: _timeNotifier,
                score: _gs.score,
              ),
              const SizedBox(height: 12),
              _TimerBar(
                isDark: isDark,
                timeNotifier: _timeNotifier,
                totalSeconds: totalSeconds,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _Grid(
                  isDark: isDark,
                  panel: panel,
                  activeNotifier: _activeNotifier,
                  onTap: _handleTap,
                ),
              ),
              const SizedBox(height: 12),
              _StatsBar(
                panel: panel,
                isDark: isDark,
                hearts: _gs.hearts,
                streak: _gs.streak,
                completed: _gs.completed,
                bestStreak: _gs.bestStreak,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Alt widget'lar — her biri tek sorumlu
// ─────────────────────────────────────────────

class _Header extends StatelessWidget {
  final bool isDark;
  final Color panel;
  final ValueNotifier<int> timeNotifier;
  final int score;

  const _Header({
    required this.isDark,
    required this.panel,
    required this.timeNotifier,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor =
        isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark
        ? const Color(0xFF9CA3AF)
        : const Color(0xFF6B7280);

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: panel,
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
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Sequence Echo',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Gösterilen sırayı aynı şekilde tekrar et.',
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
              ValueListenableBuilder<int>(
                valueListenable: timeNotifier,
                builder: (_, t, __) => Text(
                  '$t s',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Skor: $score',
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
}

// ─────────────────────────────────────────────
class _TimerBar extends StatelessWidget {
  final bool isDark;
  final ValueNotifier<int> timeNotifier;
  final int totalSeconds;

  const _TimerBar({
    required this.isDark,
    required this.timeNotifier,
    required this.totalSeconds,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: timeNotifier,
      builder: (_, t, __) {
        final progress = t / totalSeconds;
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 12,
            backgroundColor: isDark
                ? const Color(0xFF1F2937)
                : const Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation<Color>(
              Color.lerp(
                const Color(0xFF22C55E),
                const Color(0xFFEF4444),
                1 - progress,
              )!,
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
class _Grid extends StatelessWidget {
  final bool isDark;
  final Color panel;
  final ValueNotifier<int> activeNotifier;
  final void Function(int) onTap;

  const _Grid({
    required this.isDark,
    required this.panel,
    required this.activeNotifier,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final highlight = isDark
        ? const Color(0xFF4F46E5)
        : const Color(0xFF2563EB);
    final cellBg = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF4F5F7);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (_, constraints) {
          final size = min(
              constraints.maxWidth,
              constraints.maxHeight);
          final cellSize = (size - 32) / 3;

          return Center(
            child: SizedBox(
              width: cellSize * 3 + 24,
              height: cellSize * 3 + 24,
              child: GridView.builder(
                physics:
                    const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 9,
                itemBuilder: (_, index) {
                  return ValueListenableBuilder<int>(
                    valueListenable: activeNotifier,
                    builder: (_, active, __) {
                      final isActive = index == active;
                      return GestureDetector(
                        onTap: () => onTap(index),
                        child: AnimatedContainer(
                          duration: const Duration(
                              milliseconds: 160),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(14),
                            color: isActive
                                ? highlight
                                : cellBg,
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: highlight
                                          .withValues(
                                              alpha: 0.45),
                                      blurRadius: 18,
                                      offset:
                                          const Offset(0, 8),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
class _StatsBar extends StatelessWidget {
  final Color panel;
  final bool isDark;
  final int hearts;
  final int streak;
  final int completed;
  final int bestStreak;

  const _StatsBar({
    required this.panel,
    required this.isDark,
    required this.hearts,
    required this.streak,
    required this.completed,
    required this.bestStreak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Colors.black.withValues(alpha: 0.02)),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          _StatChip(
            icon: Icons.favorite,
            label: 'Can',
            value:
                '$hearts/${_SequenceMemoryGameState.maxHearts}',
            color: const Color(0xFFEF4444),
          ),
          _StatChip(
            icon: Icons.local_fire_department,
            label: 'Seri',
            value: '$streak',
            color: const Color(0xFFFFA000),
          ),
          _StatChip(
            icon: Icons.check_circle,
            label: 'Tamamlanan',
            value: '$completed',
            color: const Color(0xFF22C55E),
          ),
          _StatChip(
            icon: Icons.leaderboard,
            label: 'En iyi seri',
            value: '$bestStreak',
            color: isDark
                ? const Color(0xFF9CA3AF)
                : const Color(0xFF6B7280),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                color: color.withValues(alpha: 0.8),
              ),
            ),
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}