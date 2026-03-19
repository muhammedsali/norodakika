import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/audio_service.dart';

/// Görsel algı oyunu: 4 karttan farklı olanı hızlıca bul.
class OddOneOutGame extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;
  final bool isPaused;

  const OddOneOutGame({
    super.key,
    required this.onComplete,
    this.isPaused = false,
  });

  @override
  State<OddOneOutGame> createState() => _OddOneOutGameState();
}

class _OddOneOutGameState extends State<OddOneOutGame> {
  static const int totalSeconds = 60;
  static const int roundMs = 5200;
  static const int maxHearts = 3;

  final Random _rng = Random();

  Timer? _gameTimer;
  Timer? _roundTimer;

  final ValueNotifier<int> _timeRemainingNotifier = ValueNotifier<int>(totalSeconds);
  final ValueNotifier<double> _roundProgressNotifier = ValueNotifier<double>(1.0);
  int _hearts = maxHearts;
  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int _correct = 0;
  int _wrong = 0;
  int _rounds = 0;

  late List<_CardFace> _options;
  late int _oddIndex;
  bool _isFinished = false;
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  @override
  void didUpdateWidget(covariant OddOneOutGame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPaused != widget.isPaused && !_isFinished) {
      if (widget.isPaused) {
        _gameTimer?.cancel();
        _roundTimer?.cancel();
      } else {
        _startTimers();
      }
    }
  }

  void _startGame() {
    _resetState();
    _startTimers();
    _buildRound();
  }

  void _resetState() {
    _timeRemainingNotifier.value = totalSeconds;
    _hearts = maxHearts;
    _score = 0;
    _streak = 0;
    _bestStreak = 0;
    _correct = 0;
    _wrong = 0;
    _rounds = 0;
    _roundProgressNotifier.value = 1.0;
    _isFinished = false;
  }

  void _startTimers() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _isFinished) return;
      _timeRemainingNotifier.value--;
      if (_timeRemainingNotifier.value <= 0) _finish();
    });

    _roundTimer?.cancel();
    _roundTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted || _isFinished) return;
      _roundProgressNotifier.value -= 0.1 / (roundMs / 1000);
      if (_roundProgressNotifier.value <= 0) {
        _handleTimeout();
      }
    });
  }

  void _handleTimeout() {
    _audioService.playWrong(); // ❌ Süre doldu
    HapticFeedback.mediumImpact();
    _streak = 0;
    _hearts = max(0, _hearts - 1);
    _score = max(0, _score - 80);
    _buildRound();
    if (_hearts == 0) {
      _finish();
    }
  }

  void _buildRound() {
    if (_isFinished) return;
    _rounds++;
    _roundProgressNotifier.value = 1.0;

    final icons = [
      Icons.rocket_launch_rounded,
      Icons.diamond_rounded,
      Icons.anchor_rounded,
      Icons.favorite_rounded,
      Icons.ac_unit_rounded,
      Icons.local_fire_department_rounded,
    ];
    final colors = [
      Colors.redAccent,
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.tealAccent,
    ];

    final baseIcon = icons[_rng.nextInt(icons.length)];
    final baseColor = colors[_rng.nextInt(colors.length)];

    _options = List.generate(
      4,
      (_) => _CardFace(icon: baseIcon, color: baseColor),
    );

    _oddIndex = _rng.nextInt(4);
    IconData oddIcon = baseIcon;
    Color oddColor = baseColor;
    
    while (oddIcon == baseIcon && oddColor == baseColor) {
      if (_rng.nextBool()) {
        oddIcon = icons[_rng.nextInt(icons.length)];
      } else {
        oddColor = colors[_rng.nextInt(colors.length)];
      }
    }
    _options[_oddIndex] = _CardFace(icon: oddIcon, color: oddColor);
    setState(() {});
  }

  void _onSelect(int index) {
    if (_isFinished || widget.isPaused) return;
    HapticFeedback.selectionClick();
    _audioService.playTap(); // 👆 Dokunma sesi

    final isCorrect = index == _oddIndex;
    setState(() {
      if (isCorrect) {
        _audioService.playCorrect(); // ✅ Doğru cevap sesi
        HapticFeedback.lightImpact();
        _correct++;
        _streak++;
        _bestStreak = max(_bestStreak, _streak);
        _score += 140 + (_streak * 12);
      } else {
        _audioService.playWrong(); // ❌ Yanlış cevap sesi
        HapticFeedback.mediumImpact();
        _wrong++;
        _streak = 0;
        _hearts = max(0, _hearts - 1);
        _score = max(0, _score - 100);
        if (_hearts == 0) {
          _finish();
          return;
        }
      }
      _buildRound();
    });
  }

  void _finish() {
    if (_isFinished) return;
    _isFinished = true;
    _gameTimer?.cancel();
    _roundTimer?.cancel();

    final successRate = _rounds == 0 ? 0.0 : _correct / _rounds;
    final duration = totalSeconds - max(0, _timeRemainingNotifier.value);

    _audioService.playGameOver(); // 🎮 Oyun bitiş sesi

    widget.onComplete({
      'score': _score.toDouble(),
      'successRate': successRate,
      'duration': duration,
      'totalAttempts': _rounds,
      'correctAttempts': _correct,
      'wrongAttempts': _wrong,
    });

    setState(() {});
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _roundTimer?.cancel();
    _timeRemainingNotifier.dispose();
    _roundProgressNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0B1220) : const Color(0xFFF6F8FB);
    final panel = isDark ? const Color(0xFF111827) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(isDark, panel),
              const SizedBox(height: 12),
              _buildTimerBar(isDark),
              const SizedBox(height: 12),
              _buildRoundBar(isDark),
              const SizedBox(height: 12),
              Expanded(child: _buildCards(isDark, panel)),
              const SizedBox(height: 12),
              _buildStats(panel, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, Color panel) {
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Odd One Out',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Farklı kartı hızlıca bul ve seç.',
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
                valueListenable: _timeRemainingNotifier,
                builder: (context, time, child) {
                  return Text(
                    '$time s',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  );
                },
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

  Widget _buildTimerBar(bool isDark) {
    return ValueListenableBuilder<int>(
      valueListenable: _timeRemainingNotifier,
      builder: (context, timeRemaining, child) {
        final progress = timeRemaining / totalSeconds;
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 12,
            backgroundColor: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation<Color>(
              Color.lerp(const Color(0xFF22C55E), const Color(0xFFEF4444), 1 - progress)!,
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoundBar(bool isDark) {
    return ValueListenableBuilder<double>(
      valueListenable: _roundProgressNotifier,
      builder: (context, roundProgress, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: roundProgress.clamp(0, 1),
            minHeight: 10,
            backgroundColor: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation<Color>(
              Color.lerp(const Color(0xFF60A5FA), const Color(0xFFF59E0B), 1 - roundProgress)!,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCards(bool isDark, Color panel) {
    return Row(
      children: [
        for (int i = 0; i < _options.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == _options.length - 1 ? 0 : 10),
              child: GestureDetector(
                onTap: () => _onSelect(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
                  decoration: BoxDecoration(
                    color: panel,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _options[i].color.withValues(alpha: 0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _options[i].icon,
                        size: 44,
                        color: _options[i].color,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kart ${i + 1}',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStats(Color panel, bool isDark) {
    final subtitleColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final accuracy = _rounds == 0 ? 0.0 : _correct / _rounds;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.02)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StatChip(
            icon: Icons.favorite,
            label: 'Can',
            value: '$_hearts/$maxHearts',
            color: const Color(0xFFEF4444),
          ),
          _StatChip(
            icon: Icons.local_fire_department,
            label: 'Seri',
            value: '$_streak',
            color: const Color(0xFFFFA000),
          ),
          _StatChip(
            icon: Icons.psychology_alt,
            label: 'Doğruluk',
            value: '${(accuracy * 100).toStringAsFixed(0)}%',
            color: const Color(0xFF22C55E),
          ),
          _StatChip(
            icon: Icons.leaderboard,
            label: 'En iyi seri',
            value: '$_bestStreak',
            color: subtitleColor,
          ),
        ],
      ),
    );
  }
}

class _CardFace {
  final IconData icon;
  final Color color;

  _CardFace({required this.icon, required this.color});
}

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
              style: GoogleFonts.spaceGrotesk(fontSize: 11, color: color.withValues(alpha: 0.8)),
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


