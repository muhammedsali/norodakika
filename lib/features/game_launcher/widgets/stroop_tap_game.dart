import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Hızlı tepki + bilişsel çakışma (Stroop) mini oyunu.
/// Kelimenin ANLAMINA karşılık gelen rengi seç; yazı rengine aldanma.
class StroopTapGame extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;

  const StroopTapGame({super.key, required this.onComplete});

  @override
  State<StroopTapGame> createState() => _StroopTapGameState();
}

class _StroopTapGameState extends State<StroopTapGame> {
  static const int gameDuration = 60; // saniye
  static const int maxHearts = 3;

  final List<String> _colorWords = ['KIRMIZI', 'MAVİ', 'YEŞİL', 'SARI'];
  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
  ];

  final Random _rng = Random();

  Timer? _gameTimer;
  DateTime? _questionStartTime;
  DateTime? _gameStartTime;

  int _timeRemaining = gameDuration;
  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int _hearts = maxHearts;
  int _correct = 0;
  int _wrong = 0;
  int _answered = 0;
  double _totalReactionMs = 0;

  late String _currentWord;
  late Color _currentColor;
  late List<Color> _options;

  bool _isFinished = false;
  bool _isInputLocked = false;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _resetState();
    _spawnQuestion();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isFinished) return;
      if (!mounted) return;
      setState(() {
        _timeRemaining--;
      });
      if (_timeRemaining <= 0) {
        _finishGame();
      }
    });
  }

  void _resetState() {
    _gameStartTime = DateTime.now();
    _timeRemaining = gameDuration;
    _score = 0;
    _streak = 0;
    _bestStreak = 0;
    _hearts = maxHearts;
    _correct = 0;
    _wrong = 0;
    _answered = 0;
    _totalReactionMs = 0;
    _isFinished = false;
    _isInputLocked = false;
  }

  void _spawnQuestion() {
    final wordIndex = _rng.nextInt(_colorWords.length);
    var colorIndex = _rng.nextInt(_colors.length);

    // Stroop etkisi için çoğunlukla anlam ve renk farklı
    if (colorIndex == wordIndex && _rng.nextDouble() < 0.7) {
      colorIndex = (colorIndex + 1 + _rng.nextInt(_colors.length - 1)) %
          _colors.length;
    }

    _currentWord = _colorWords[wordIndex];
    _currentColor = _colors[colorIndex];
    _questionStartTime = DateTime.now();

    _options = List<Color>.from(_colors)..shuffle(_rng);
    setState(() {});
  }

  void _selectColor(Color selected) {
    if (_isFinished || _isInputLocked) return;
    _isInputLocked = true;

    HapticFeedback.lightImpact();

    final correctColor = _colors[_colorWords.indexOf(_currentWord)];
    final isCorrect = selected == correctColor;

    final reactionMs =
        DateTime.now().difference(_questionStartTime ?? DateTime.now()).inMilliseconds;

    setState(() {
      _answered++;
      if (isCorrect) {
        _correct++;
        _streak++;
        _bestStreak = max(_bestStreak, _streak);
        _score += 150 + (_streak * 15);
        _totalReactionMs += reactionMs.toDouble();
      } else {
        _wrong++;
        _streak = 0;
        _hearts = max(0, _hearts - 1);
        _score = max(0, _score - 120);
        if (_hearts == 0) {
          _finishGame();
        }
      }
    });

    Future.delayed(const Duration(milliseconds: 160), () {
      if (!_isFinished) {
        _isInputLocked = false;
        _spawnQuestion();
      }
    });
  }

  void _finishGame() {
    if (_isFinished) return;
    _isFinished = true;
    _gameTimer?.cancel();

    final duration =
        DateTime.now().difference(_gameStartTime ?? DateTime.now()).inSeconds;
    final accuracy = _answered == 0 ? 0.0 : _correct / _answered;
    final avgReaction =
        _correct == 0 ? 0.0 : _totalReactionMs / _correct.toDouble();

    widget.onComplete({
      'score': _score.toDouble(),
      'successRate': accuracy,
      'duration': duration,
      'correct': _correct,
      'wrong': _wrong,
      'bestStreak': _bestStreak,
      'avgReactionMs': avgReaction,
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

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1220) : const Color(0xFFF6F8FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(isDark),
              const SizedBox(height: 12),
              _buildTimerBar(isDark),
              const SizedBox(height: 12),
              _buildPromptCard(isDark),
              const SizedBox(height: 16),
              _buildOptionsGrid(isDark),
              const SizedBox(height: 12),
              _buildStatsBar(isDark),
              if (_isFinished) _ResultOverlay(onRestart: _startGame),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final panelColor = isDark ? const Color(0xFF111827) : Colors.white;

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
                'Stroop Tap',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Kelimenin ANLAMINI seç, rengine kanma.',
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
    final progress = _timeRemaining / gameDuration;
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

  Widget _buildPromptCard(bool isDark) {
    final panelColor = isDark ? const Color(0xFF111827) : Colors.white;
    final shadowColor = Colors.black.withOpacity(isDark ? 0.4 : 0.08);

    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: panelColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Yazıya göre rengi seç!',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Text(
                _currentWord,
                key: ValueKey(_currentWord + _currentColor.value.toString()),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 78,
                  fontWeight: FontWeight.w800,
                  color: _currentColor,
                  shadows: [
                    Shadow(
                      color: _currentColor.withOpacity(0.28),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Anlam: ${_currentWord[0].toUpperCase()}${_currentWord.substring(1).toLowerCase()}',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsGrid(bool isDark) {
    final panelColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final shadowColor = Colors.black.withOpacity(0.08);
    final buttonTexts = ['KIRMIZI', 'MAVİ', 'YEŞİL', 'SARI'];

    return Column(
      children: [
        Row(
          children: [
            for (int i = 0; i < 2; i++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i == 0 ? 8 : 0),
                  child: _ColorButton(
                    color: _options[i],
                    label: buttonTexts[_colors.indexOf(_options[i])],
                    isDark: isDark,
                    panelColor: panelColor,
                    shadowColor: shadowColor,
                    onTap: () => _selectColor(_options[i]),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (int i = 2; i < 4; i++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i == 2 ? 8 : 0),
                  child: _ColorButton(
                    color: _options[i],
                    label: buttonTexts[_colors.indexOf(_options[i])],
                    isDark: isDark,
                    panelColor: panelColor,
                    shadowColor: shadowColor,
                    onTap: () => _selectColor(_options[i]),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsBar(bool isDark) {
    final panelColor = isDark ? const Color(0xFF111827) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final accuracy = _answered == 0 ? 0.0 : _correct / _answered;
    final avgReaction =
        _correct == 0 ? 0 : (_totalReactionMs / max(1, _correct)).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: panelColor,
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
            icon: Icons.psychology,
            label: 'Doğruluk',
            value: '${(accuracy * 100).toStringAsFixed(0)}%',
            color: const Color(0xFF22C55E),
          ),
          _StatChip(
            icon: Icons.timer,
            label: 'Reaksiyon',
            value: _correct == 0 ? '-' : '${avgReaction}ms',
            color: subtitleColor,
          ),
          _StatChip(
            icon: Icons.leaderboard,
            label: 'En iyi seri',
            value: '$_bestStreak',
            color: titleColor,
          ),
        ],
      ),
    );
  }
}

class _ColorButton extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDark;
  final Color panelColor;
  final Color shadowColor;
  final VoidCallback onTap;

  const _ColorButton({
    required this.color,
    required this.label,
    required this.isDark,
    required this.panelColor,
    required this.shadowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 64,
        decoration: BoxDecoration(
          color: panelColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.7),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ),
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

class _ResultOverlay extends StatelessWidget {
  final VoidCallback onRestart;

  const _ResultOverlay({required this.onRestart});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
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
                ElevatedButton.icon(
                  onPressed: onRestart,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Tekrar Oyna'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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

