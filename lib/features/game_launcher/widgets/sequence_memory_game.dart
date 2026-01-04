import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/audio_service.dart';

/// Simon benzeri sıra tekrarlama oyunu.
/// Gösterilen hücre sırasını aynı sırayla dokun.
class SequenceMemoryGame extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;

  const SequenceMemoryGame({super.key, required this.onComplete});

  @override
  State<SequenceMemoryGame> createState() => _SequenceMemoryGameState();
}

class _SequenceMemoryGameState extends State<SequenceMemoryGame> {
  static const int totalSeconds = 60;
  static const int baseLength = 3;
  static const int maxHearts = 3;

  final Random _rng = Random();

  late List<int> _sequence;
  final List<int> _input = [];

  int _timeRemaining = totalSeconds;
  int _hearts = maxHearts;
  int _score = 0;
  int _round = 1;
  int _completed = 0;
  int _attempts = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int _activeIndex = -1;

  bool _isPlaying = false;
  bool _isFinished = false;

  Timer? _gameTimer;
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _resetState();
    _startTimer();
    _startRound();
  }

  void _resetState() {
    _timeRemaining = totalSeconds;
    _hearts = maxHearts;
    _score = 0;
    _round = 1;
    _completed = 0;
    _attempts = 0;
    _streak = 0;
    _bestStreak = 0;
    _isFinished = false;
    _isPlaying = false;
    _activeIndex = -1;
    _input.clear();
    _sequence = [];
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _isFinished) return;
      setState(() {
        _timeRemaining--;
      });
      if (_timeRemaining <= 0) {
        _finish();
      }
    });
  }

  void _startRound() {
    if (_isFinished) return;
    _attempts++;
    _input.clear();
    final length = baseLength + _round - 1;
    _sequence = List.generate(length, (_) => _rng.nextInt(9));
    _playSequence();
  }

  Future<void> _playSequence() async {
    _isPlaying = true;
    setState(() {});
    for (int i = 0; i < _sequence.length; i++) {
      if (_isFinished) return;
      await Future.delayed(const Duration(milliseconds: 220));
      if (!mounted || _isFinished) return;
      setState(() {
        _activeIndex = _sequence[i];
      });
      await Future.delayed(const Duration(milliseconds: 520));
      if (!mounted || _isFinished) return;
      setState(() {
        _activeIndex = -1;
      });
    }
    if (!mounted || _isFinished) return;
    setState(() {
      _isPlaying = false;
    });
  }

  void _handleTap(int index) {
    if (_isFinished || _isPlaying || _timeRemaining <= 0) return;
    HapticFeedback.selectionClick();
    _audioService.playTap(); // 👆 Dokunma sesi

    final expected = _sequence[_input.length];
    final isCorrect = expected == index;

    setState(() {
      if (isCorrect) {
        _audioService.playCorrect(); // ✅ Doğru cevap sesi
        HapticFeedback.lightImpact();
        _input.add(index);
        _score += 35;
        if (_input.length == _sequence.length) {
          _completed++;
          _streak++;
          _bestStreak = max(_bestStreak, _streak);
          _score += 180 + (_round * 12);
          _audioService.playLevelUp(); // 🎉 Seviye tamamlandı
          _round++;
          _startRound();
        }
      } else {
        _audioService.playWrong(); // ❌ Yanlış cevap sesi
        HapticFeedback.mediumImpact();
        _streak = 0;
        _hearts = max(0, _hearts - 1);
        _score = max(0, _score - 120);
        if (_hearts == 0) {
          _finish();
        } else {
          _startRound();
        }
      }
    });
  }

  void _finish() {
    if (_isFinished) return;
    _isFinished = true;
    _gameTimer?.cancel();

    final successRate = _attempts == 0 ? 0.0 : _completed / _attempts;
    final duration = totalSeconds - max(0, _timeRemaining);
    final wrongAttempts = _attempts - _completed;

    _audioService.playGameOver(); // 🎮 Oyun bitiş sesi

    widget.onComplete({
      'score': _score.toDouble(),
      'successRate': successRate,
      'duration': duration,
      'totalAttempts': _attempts,
      'correctAttempts': _completed,
      'wrongAttempts': wrongAttempts,
    });

    setState(() {});
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
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
              Expanded(child: _buildGrid(isDark, panel)),
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

  Widget _buildTimerBar(bool isDark) {
    final progress = _timeRemaining / totalSeconds;
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
  }

  Widget _buildGrid(bool isDark, Color panel) {
    final highlight = isDark ? const Color(0xFF4F46E5) : const Color(0xFF2563EB);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = min(constraints.maxWidth, constraints.maxHeight);
          final cellSize = (size - 32) / 3;
          return Center(
            child: SizedBox(
              width: cellSize * 3 + 24,
              height: cellSize * 3 + 24,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  final isActive = index == _activeIndex;
                  return GestureDetector(
                    onTap: () => _handleTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: isActive
                            ? highlight
                            : isDark
                                ? const Color(0xFF0F172A)
                                : const Color(0xFFF4F5F7),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: highlight.withOpacity(0.45),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStats(Color panel, bool isDark) {
    final subtitleColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.02)),
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
            icon: Icons.check_circle,
            label: 'Tamamlanan',
            value: '$_completed',
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
              style: GoogleFonts.spaceGrotesk(fontSize: 11, color: color.withOpacity(0.8)),
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


