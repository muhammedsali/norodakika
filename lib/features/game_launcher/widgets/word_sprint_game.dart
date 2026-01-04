import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/audio_service.dart';

/// Kelime akışı: gerçek kelimelere dokun, uydurmalara dokunma.
/// 60 sn, 3 can, seri/bonus, kaçan kelime cezası, hızlanan spawn.
class WordSprintGame extends StatefulWidget {
  final void Function(Map<String, dynamic>) onComplete;

  const WordSprintGame({
    super.key,
    required this.onComplete,
  });

  @override
  State<WordSprintGame> createState() => _WordSprintGameState();
}

class _WordSprintGameState extends State<WordSprintGame> {
  static const int gameDuration = 60; // saniye
  static const int maxHearts = 3;
  static const double initialSpawnMs = 1100;
  static const double minSpawnMs = 520;
  static const double spawnStep = 16;

  final Random _rng = Random();

  Timer? _timer;
  Timer? _spawnTimer;

  int _timeRemaining = gameDuration;
  int _hearts = maxHearts;
  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int _correctHits = 0;
  int _wrongHits = 0;
  int _missed = 0;

  double _spawnMs = initialSpawnMs;

  final List<_WordItem> _items = [];
  final AudioService _audioService = AudioService();

  static const _realWords = [
    'memory', 'focus', 'speed', 'brain', 'logic', 'number',
    'zihin', 'hafiza', 'dikkat', 'refleks', 'kelime', 'sayi',
    'derin', 'ritim', 'denge', 'tempo', 'enerji', 'uzay',
  ];

  static const _fakeWords = [
    'memroy', 'foduc', 'spaed', 'brein', 'lagic', 'numbar',
    'zhin', 'hafzia', 'dikakt', 'refkles', 'kelmie', 'sayii',
    'derni', 'ritmi', 'dnege', 'tepm0', 'enerjj', 'uzaay',
  ];

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _resetState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || _isFinished) return;
      setState(() {
        _timeRemaining--;
      });
      if (_timeRemaining <= 0) {
        _finishGame();
      }
    });
    _startSpawnTimer();
  }

  bool _isFinished = false;

  void _resetState() {
    _timeRemaining = gameDuration;
    _hearts = maxHearts;
    _score = 0;
    _streak = 0;
    _bestStreak = 0;
    _correctHits = 0;
    _wrongHits = 0;
    _missed = 0;
    _spawnMs = initialSpawnMs;
    _items.clear();
    _isFinished = false;
  }

  void _startSpawnTimer() {
    _spawnTimer?.cancel();
    _spawnTimer = Timer.periodic(Duration(milliseconds: _spawnMs.toInt()), (_) {
      if (!mounted || _isFinished) return;
      _spawnWord();
      _spawnMs = max(minSpawnMs, _spawnMs - spawnStep);
      _startSpawnTimer();
    });
  }

  void _spawnWord() {
    final isReal = _rng.nextBool();
    final text = isReal
        ? _realWords[_rng.nextInt(_realWords.length)]
        : _fakeWords[_rng.nextInt(_fakeWords.length)];

    _items.add(
      _WordItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        text: text,
        isReal: isReal,
      ),
    );

    // çok birikmesin
    if (_items.length > 10) {
      final lost = _items.removeAt(0);
      if (lost.isReal) {
        _registerMiss();
      }
    }

    setState(() {});
  }

  void _onWordTap(_WordItem item) {
    if (_isFinished) return;
    HapticFeedback.selectionClick();
    _audioService.playTap(); // 👆 Dokunma sesi

    setState(() {
      if (item.isReal) {
        _audioService.playCorrect(); // ✅ Doğru kelime sesi
        HapticFeedback.lightImpact();
        _correctHits++;
        _streak++;
        _bestStreak = max(_bestStreak, _streak);
        _score += 140 + (_streak * 12);
      } else {
        _audioService.playWrong(); // ❌ Yanlış kelime sesi
        HapticFeedback.mediumImpact();
        _wrongHits++;
        _streak = 0;
        _hearts = max(0, _hearts - 1);
        _score = max(0, _score - 120);
        if (_hearts == 0) {
          _finishGame();
        }
      }
      _items.remove(item);
    });
  }

  void _registerMiss() {
    _audioService.playWrong(); // ❌ Kaçan kelime
    HapticFeedback.mediumImpact();
    _missed++;
    _streak = 0;
    _hearts = max(0, _hearts - 1);
    _score = max(0, _score - 80);
    if (_hearts == 0) {
      _finishGame();
    }
  }

  void _finishGame() {
    if (_isFinished) return;
    _isFinished = true;
    _timer?.cancel();
    _spawnTimer?.cancel();

    final totalHits = _correctHits + _wrongHits + _missed;
    final successRate = totalHits == 0 ? 0.0 : _correctHits / totalHits;

    _audioService.playGameOver(); // 🎮 Oyun bitiş sesi

    widget.onComplete({
      'score': _score.toDouble(),
      'successRate': successRate,
      'duration': gameDuration,
      'totalAttempts': totalHits,
      'correctAttempts': _correctHits,
      'wrongAttempts': _wrongHits + _missed,
    });

    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    _spawnTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0B1220) : const Color(0xFFF6F8FB);
    final panel = isDark ? const Color(0xFF111827) : Colors.white;
    final titleColor = isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final subtitleColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(titleColor, subtitleColor, panel),
              const SizedBox(height: 12),
              _buildTimerBar(isDark),
              const SizedBox(height: 12),
              Expanded(child: _buildStream(panel, isDark, titleColor, subtitleColor)),
              const SizedBox(height: 12),
              _buildStats(panel, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color titleColor, Color subtitleColor, Color panel) {
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
                'Word Sprint',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Gerçek kelimeyi kap, uydurma gelirse kaç.',
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

  Widget _buildStream(Color panel, bool isDark, Color titleColor, Color subtitleColor) {
    return Container(
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;

          return Stack(
            children: [
              Positioned(
                left: 12,
                right: 12,
                top: 8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ChipTag(label: 'Can', value: '$_hearts/$maxHearts', color: const Color(0xFFEF4444)),
                    _ChipTag(label: 'Seri', value: '$_streak', color: const Color(0xFFFFA000)),
                    _ChipTag(label: 'En iyi seri', value: '$_bestStreak', color: titleColor),
                  ],
                ),
              ),
              for (int i = 0; i < _items.length; i++)
                Positioned(
                  top: 44.0 + (height - 80) / 8 * i,
                  left: 12,
                  right: 12,
                  child: GestureDetector(
                    onTapDown: (_) => _onWordTap(_items[i]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _items[i].text,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: titleColor,
                            ),
                          ),
                          Icon(
                            Icons.touch_app,
                            size: 18,
                            color: subtitleColor,
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
    );
  }

  Widget _buildStats(Color panel, bool isDark) {
    final subtitleColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final accuracy =
        (_correctHits + _wrongHits + _missed) == 0 ? 0.0 : _correctHits / (_correctHits + _wrongHits + _missed);

    return Container(
      width: double.infinity,
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
            icon: Icons.check_circle,
            label: 'Doğru',
            value: '$_correctHits',
            color: const Color(0xFF22C55E),
          ),
          _StatChip(
            icon: Icons.close,
            label: 'Hatalı',
            value: '$_wrongHits',
            color: const Color(0xFFEF4444),
          ),
          _StatChip(
            icon: Icons.visibility_off,
            label: 'Kaçan',
            value: '$_missed',
            color: subtitleColor,
          ),
          _StatChip(
            icon: Icons.psychology,
            label: 'Doğruluk',
            value: '${(accuracy * 100).toStringAsFixed(0)}%',
            color: const Color(0xFF3B82F6),
          ),
        ],
      ),
    );
  }
}

class _ChipTag extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ChipTag({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(Icons.bolt_rounded, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
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


class _WordItem {
  final String id;
  final String text;
  final bool isReal;

  _WordItem({
    required this.id,
    required this.text,
    required this.isReal,
  });
}
