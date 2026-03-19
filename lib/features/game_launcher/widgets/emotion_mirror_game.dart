import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../settings/providers/language_provider.dart';
import '../../../core/i18n/app_strings.dart';

class EmotionMirrorGame extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>) onComplete;
  final bool isPaused;

  const EmotionMirrorGame({
    super.key,
    required this.onComplete,
    this.isPaused = false,
  });

  @override
  ConsumerState<EmotionMirrorGame> createState() => _EmotionMirrorGameState();
}

class _EmotionMirrorGameState extends ConsumerState<EmotionMirrorGame>
    with SingleTickerProviderStateMixin {
  final Random _rng = Random();
  Timer? _timer;

  final ValueNotifier<int> _timeRemainingNotifier = ValueNotifier<int>(30);

  int _correct = 0;
  int _wrong = 0;
  int _score = 0;

  int _level = 1;
  int _targetScore = 1000;
  int _totalPlayTime = 0;

  late _Prompt _prompt;

  late AnimationController _levelUpController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final _items = const <_EmotionItem>[
    _EmotionItem('Happy', 'Mutlu', '😊'),
    _EmotionItem('Sad', 'Üzgün', '😢'),
    _EmotionItem('Angry', 'Kızgın', '😠'),
    _EmotionItem('Surprised', 'Şaşkın', '😮'),
    _EmotionItem('Calm', 'Sakin', '😌'),
    _EmotionItem('Scared', 'Korkmuş', '😨'),
    _EmotionItem('Excited', 'Heyecanlı', '🤩'),
    _EmotionItem('Confused', 'Kafası Karışık', '😕'),
    _EmotionItem('Sleepy', 'Uykulu', '😴'),
    _EmotionItem('Loved', 'Aşık', '😍'),
    _EmotionItem('Laughing', 'Komik', '😂'),
    _EmotionItem('Cool', 'Havalı', '😎'),
    _EmotionItem('Thinking', 'Düşünceli', '🤔'),
    _EmotionItem('Crying', 'Ağlayan', '😭'),
    _EmotionItem('Mind Blown', 'Şok Olmuş', '🤯'),
    _EmotionItem('Nauseated', 'Midesi Bulanmış', '🤢'),
    _EmotionItem('Zany', 'Çılgın', '🤪'),
    _EmotionItem('Freezing', 'Donmuş', '🥶'),
    _EmotionItem('Hot', 'Bunalmış', '🥵'),
    _EmotionItem('Pleading', 'Masum', '🥺'),
    _EmotionItem('Nerd', 'Bilmiş', '🤓'),
    _EmotionItem('Shushing', 'Sessiz', '🤫'),
    _EmotionItem('Winking', 'Göz Kırpan', '😉'),
    _EmotionItem('Angel', 'Melek Gibi', '😇'),
    _EmotionItem('Devil', 'Sinsi', '😈'),
    _EmotionItem('Party', 'Partileyen', '🥳'),
    _EmotionItem('Yawning', 'Esneyen', '🥱'),
    _EmotionItem('Drooling', 'İştahlı', '🤤'),
    _EmotionItem('Zipper-Mouth', 'Sır Tutan', '🤐'),
    _EmotionItem('Money-Mouth', 'Zengin', '🤑'),
  ];

  @override
  void initState() {
    super.initState();
    _prompt = _nextPrompt();

    _levelUpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(parent: _levelUpController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _levelUpController,
          curve: const Interval(0.6, 1.0, curve: Curves.easeOut)),
    );

    if (!widget.isPaused) _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _timeRemainingNotifier.value--;
      _totalPlayTime++;

      if (_timeRemainingNotifier.value <= 0) {
        _timeRemainingNotifier.value = 0;
        _finish();
      }
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
    _levelUpController.dispose();
    super.dispose();
  }

  _Prompt _nextPrompt() {
    final isEn = ref.read(languageProvider) == AppLanguage.en;
    final real = _items[_rng.nextInt(_items.length)];
    final shouldMatch = _rng.nextBool();
    final other = _items[_rng.nextInt(_items.length)];
    
    final label = shouldMatch ? (isEn ? real.en : real.tr) : (isEn ? other.en : other.tr);

    final isMatch = shouldMatch || (isEn ? (label == real.en) : (label == real.tr));
    return _Prompt(emoji: real.emoji, label: label, isMatch: isMatch);
  }

  void _answer(bool yes) {
    if (widget.isPaused || _timeRemainingNotifier.value <= 0) return;
    final isCorrect = (yes == _prompt.isMatch);

    setState(() {
      if (isCorrect) {
        _correct++;
        _score += 120 + (_level * 20);

        if (_score >= _targetScore) {
          _level++;
          _targetScore += _level * 800;
          _timeRemainingNotifier.value += 15;
          _levelUpController.forward(from: 0.0);
        }
      } else {
        _wrong++;
        _score = max(0, _score - 70);
        _timeRemainingNotifier.value = max(0, _timeRemainingNotifier.value - 3);
      }
      _prompt = _nextPrompt();
    });
  }

  void _finish() {
    _timer?.cancel();
    final total = max(1, _correct + _wrong);
    widget.onComplete({
      'score': _score.toDouble(),
      'level': _level,
      'successRate': _correct / total,
      'duration': _totalPlayTime,
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final s = AppStrings(lang);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor =
        isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final textColor =
        isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final levelColor =
        isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6);

    return SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Emotion Mirror',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          s.metaLevel + ' $_level • ' + (s.isEn ? 'Goal: ' : 'Hedef: ') + '$_targetScore',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: levelColor,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1F2937) : Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF374151)
                              : const Color(0xFFE5E7EB),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withValues(
                                alpha: _timeRemainingNotifier.value <= 5
                                    ? 0.5
                                    : 0.0),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: ValueListenableBuilder<int>(
                        valueListenable: _timeRemainingNotifier,
                        builder: (context, time, _) => Text(
                          '$time s',
                          style: GoogleFonts.robotoMono(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: time <= 5 ? Colors.redAccent : titleColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                    child: Text(
                      s.emotionQuestion,
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 14, color: textColor),
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
                        color: isDark
                            ? const Color(0xFF374151)
                            : const Color(0xFFE5E7EB),
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
                          textAlign: TextAlign
                              .center, // Hata veren kısım buraya taşındı
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: _AnswerButton(
                                label: s.yes,
                                color: const Color(0xFF10B981),
                                onTap: () => _answer(true),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _AnswerButton(
                                label: s.no,
                                color: const Color(0xFFEF4444),
                                onTap: () => _answer(false),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                isDark ? Colors.black26 : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            s.metaScore + ': $_score',
                            style: GoogleFonts.robotoMono(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: titleColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _levelUpController,
              builder: (context, child) {
                if (_levelUpController.isDismissed)
                  return const SizedBox.shrink();

                return Container(
                  color: const Color(0xFF10B981)
                      .withValues(alpha: _fadeAnimation.value * 0.2),
                  child: Center(
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Text(
                          (s.isEn ? 'LEVEL ' : 'SEVİYE ') + '$_level!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFFBBF24),
                            shadows: [
                              const Shadow(
                                color: Color(0xFFD97706),
                                blurRadius: 20,
                                offset: Offset(0, 0),
                              ),
                              const Shadow(
                                color: Colors.black45,
                                blurRadius: 10,
                                offset: Offset(2, 4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
          height: 60,
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
                fontSize: 18,
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
