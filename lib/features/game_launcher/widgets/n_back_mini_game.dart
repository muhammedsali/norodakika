import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Mekanik: 2-back (varsayılan). Hem konum hem harf için N-back kontrolü.
/// Her 2 saniyede yeni uyaran (pozisyon + harf) gelir, oyuncu N adım önceki
/// uyaranla eşleşiyorsa ilgili butona basar. Yanlışlar can düşürür.
class NBackMiniGame extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;

  const NBackMiniGame({super.key, required this.onComplete});

  @override
  State<NBackMiniGame> createState() => _NBackMiniGameState();
}

class _NBackMiniGameState extends State<NBackMiniGame> {
  static const int nLevel = 2;
  static const int gameDuration = 60; // saniye
  static const int beatMs = 2000; // yeni uyaran aralığı
  static const int maxHearts = 3;

  final List<String> _letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
  final Random _rng = Random();

  Timer? _gameTimer;
  Timer? _beatTimer;
  DateTime? _startTime;

  int _timeRemaining = gameDuration;
  int _score = 0;
  int _hearts = maxHearts;
  int _streak = 0;
  int _bestStreak = 0;
  int _correct = 0;
  int _wrong = 0;
  int _totalAttempts = 0;
  int _misses = 0;

  bool _isFinished = false;
  bool _lockedForBeat = false;

  final List<_Stimulus> _history = [];
  late _Stimulus _current;

  bool _answeredPosition = false;
  bool _answeredLetter = false;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _resetState();
    _pushStimulus();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isFinished) return;
      setState(() {
        _timeRemaining--;
      });
      if (_timeRemaining <= 0) {
        _finishGame();
      }
    });

    _beatTimer = Timer.periodic(Duration(milliseconds: beatMs), (_) {
      if (_isFinished) return;
      _evaluateMisses();
      _pushStimulus();
    });
  }

  void _resetState() {
    _startTime = DateTime.now();
    _timeRemaining = gameDuration;
    _score = 0;
    _hearts = maxHearts;
    _streak = 0;
    _bestStreak = 0;
    _correct = 0;
    _wrong = 0;
    _totalAttempts = 0;
    _misses = 0;
    _history.clear();
    _isFinished = false;
    _lockedForBeat = false;
    _answeredPosition = false;
    _answeredLetter = false;
  }

  void _pushStimulus() {
    final stimulus = _Stimulus(
      position: _rng.nextInt(9),
      letter: _letters[_rng.nextInt(_letters.length)],
      ts: DateTime.now(),
    );

    if (_history.length > 12) {
      _history.removeAt(0);
    }
    _history.add(stimulus);
    _current = stimulus;
    _lockedForBeat = false;
    _answeredLetter = false;
    _answeredPosition = false;
    setState(() {});
  }

  void _evaluateMisses() {
    // Oyuncu bu beat'te cevap vermediyse ve eşleşme varsa "kaçırma" say.
    final target = _getTarget(nLevel);
    if (target == null) return;

    final hasLetterMatch = _current.letter == target.letter;
    final hasPosMatch = _current.position == target.position;

    if (hasLetterMatch && !_answeredLetter) {
      _registerMiss();
    }
    if (hasPosMatch && !_answeredPosition) {
      _registerMiss();
    }
  }

  void _registerMiss() {
    _misses++;
    _streak = 0;
    _hearts = max(0, _hearts - 1);
    if (_hearts == 0) {
      _finishGame();
    }
  }

  _Stimulus? _getTarget(int n) {
    if (_history.length <= n) return null;
    return _history[_history.length - 1 - n];
  }

  void _handleAnswer({required bool forPosition}) {
    if (_isFinished || _lockedForBeat) return;
    if (forPosition && _answeredPosition) return;
    if (!forPosition && _answeredLetter) return;

    HapticFeedback.lightImpact();

    final target = _getTarget(nLevel);
    if (target == null) return; // henüz doldurmadıysa

    final isMatch = forPosition
        ? _current.position == target.position
        : _current.letter == target.letter;

    setState(() {
      _totalAttempts++;
      if (isMatch) {
        _correct++;
        _streak++;
        _bestStreak = max(_bestStreak, _streak);
        _score += 160 + (_streak * 12);
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

    if (forPosition) {
      _answeredPosition = true;
    } else {
      _answeredLetter = true;
    }

    // Eğer her iki tip için de cevap verildiyse beat kilitle.
    if (_answeredLetter && _answeredPosition) {
      _lockedForBeat = true;
    }
  }

  void _finishGame() {
    if (_isFinished) return;
    _isFinished = true;
    _gameTimer?.cancel();
    _beatTimer?.cancel();

    final duration = DateTime.now().difference(_startTime ?? DateTime.now()).inSeconds;
    final successRate = _totalAttempts == 0 ? 0.0 : _correct / _totalAttempts;

    widget.onComplete({
      'score': _score.toDouble(),
      'successRate': successRate,
      'duration': duration,
      'correct': _correct,
      'wrong': _wrong,
      'misses': _misses,
      'bestStreak': _bestStreak,
    });

    setState(() {});
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _beatTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0B1220) : const Color(0xFFF5F7FB);
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
              Expanded(child: _buildArena(isDark, panel)),
              const SizedBox(height: 12),
              _buildActions(panel, isDark),
              const SizedBox(height: 8),
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
                'N-Back',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'N=$nLevel, konum + harf eşleştirme',
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

  Widget _buildArena(bool isDark, Color panel) {
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
      child: Column(
        children: [
          Text(
            'Şu anki uyaran',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
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
                        final isActive = index == _current.position;
                        return AnimatedContainer(
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
                          child: isActive
                              ? Center(
                                  child: Text(
                                    _current.letter,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 56,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : null,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'N=$nLevel geri bak: ${_history.length <= nLevel ? "Hazırlanıyor..." : _history[_history.length - 1 - nLevel].letter}',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(Color panel, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: 'Konum N-back',
                icon: Icons.location_on_rounded,
                color: const Color(0xFF22C55E),
                panel: panel,
                isDark: isDark,
                onTap: () => _handleAnswer(forPosition: true),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionButton(
                label: 'Harf N-back',
                icon: Icons.text_fields_rounded,
                color: const Color(0xFF3B82F6),
                panel: panel,
                isDark: isDark,
                onTap: () => _handleAnswer(forPosition: false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStats(Color panel, bool isDark) {
    final subtitleColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final accuracy = _totalAttempts == 0 ? 0.0 : _correct / _totalAttempts;

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
            icon: Icons.done_all,
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
          _StatChip(
            icon: Icons.visibility_off,
            label: 'Kaçan',
            value: '$_misses',
            color: subtitleColor,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color panel;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.panel,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 62,
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.6), width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
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


class _Stimulus {
  final int position; // 0-8
  final String letter;
  final DateTime ts;

  _Stimulus({
    required this.position,
    required this.letter,
    required this.ts,
  });
}