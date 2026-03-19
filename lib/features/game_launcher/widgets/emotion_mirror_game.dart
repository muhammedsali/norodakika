import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmotionMirrorGame extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;
  final bool isPaused;

  const EmotionMirrorGame({
    super.key,
    required this.onComplete,
    this.isPaused = false,
  });

  @override
  State<EmotionMirrorGame> createState() => _EmotionMirrorGameState();
}

class _EmotionMirrorGameState extends State<EmotionMirrorGame> {
  static const int totalSeconds = 60;

  final Random _rng = Random();
  Timer? _timer;
  final ValueNotifier<int> _timeRemainingNotifier = ValueNotifier<int>(totalSeconds);

  int _correct = 0;
  int _wrong = 0;
  int _score = 0;

  late _Prompt _prompt;

  final _items = const <_EmotionItem>[
    _EmotionItem('Happy', 'Mutlu', '😊'),
    _EmotionItem('Sad', 'Üzgün', '😢'),
    _EmotionItem('Angry', 'Kızgın', '😠'),
    _EmotionItem('Surprised', 'Şaşkın', '😮'),
    _EmotionItem('Calm', 'Sakin', '😌'),
  ];

  @override
  void initState() {
    super.initState();
    _prompt = _nextPrompt();
    if (!widget.isPaused) _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _timeRemainingNotifier.value--;
      if (_timeRemainingNotifier.value <= 0) _finish();
    });
  }

  @override
  void didUpdateWidget(covariant EmotionMirrorGame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPaused != widget.isPaused) {
      if (widget.isPaused) {
        _timer?.cancel();
      } else {
        _startTimer();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timeRemainingNotifier.dispose();
    super.dispose();
  }

  _Prompt _nextPrompt() {
    final real = _items[_rng.nextInt(_items.length)];
    final shouldMatch = _rng.nextBool();
    final label = shouldMatch
        ? real.tr
        : _items[_rng.nextInt(_items.length)].tr;

    final isMatch = label == real.tr;
    return _Prompt(emoji: real.emoji, label: label, isMatch: isMatch);
  }

  void _answer(bool yes) {
    if (widget.isPaused) return;
    final isCorrect = (yes == _prompt.isMatch);

    setState(() {
      if (isCorrect) {
        _correct++;
        _score += 120;
      } else {
        _wrong++;
        _score = max(0, _score - 70);
      }
      _prompt = _nextPrompt();
    });
  }

  void _finish() {
    _timer?.cancel();
    final total = max(1, _correct + _wrong);
    widget.onComplete({
      'score': _score.toDouble(),
      'successRate': _correct / total,
      'duration': (totalSeconds - _timeRemainingNotifier.value),
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final textColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Emotion Mirror',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1F2937) : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: ValueListenableBuilder<int>(
                    valueListenable: _timeRemainingNotifier,
                    builder: (context, time, _) => Text(
                      '$time s',
                      style: GoogleFonts.robotoMono(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Emoji ile kelime aynı duyguyu anlatıyor mu?',
                style: GoogleFonts.spaceGrotesk(fontSize: 14, color: textColor),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F2937) : Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _prompt.emoji,
                      style: const TextStyle(fontSize: 88),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _prompt.label,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _AnswerButton(
                            label: 'Evet',
                            color: const Color(0xFF10B981),
                            onTap: () => _answer(true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _AnswerButton(
                            label: 'Hayır',
                            color: const Color(0xFFEF4444),
                            onTap: () => _answer(false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Doğru: $_correct   Yanlış: $_wrong   Skor: $_score',
                      style: GoogleFonts.robotoMono(fontSize: 12, color: textColor),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withValues(alpha: 0.85)],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmotionItem {
  final String en;
  final String tr;
  final String emoji;

  const _EmotionItem(this.en, this.tr, this.emoji);
}

class _Prompt {
  final String emoji;
  final String label;
  final bool isMatch;

  _Prompt({required this.emoji, required this.label, required this.isMatch});
}
