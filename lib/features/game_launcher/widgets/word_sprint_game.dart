import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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
  static const int spawnIntervalMs = 900;

  final Random _rng = Random();

  late Timer _timer;
  late Timer _spawnTimer;

  int _timeRemaining = gameDuration;

  final List<_WordItem> _items = [];

  int _score = 0;
  int _correctHits = 0;
  int _wrongHits = 0;

  static const _realWords = [
    'memory', 'focus', 'speed', 'brain', 'logic', 'number',
    'zihin', 'hafiza', 'dikkat', 'refleks', 'kelime', 'sayi',
  ];

  static const _fakeWords = [
    'memroy', 'foduc', 'spaed', 'brein', 'lagic', 'numbar',
    'zhin', 'hafzia', 'dikakt', 'refkles', 'kelmie', 'sayii',
  ];

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _timeRemaining = gameDuration;
    _score = 0;
    _correctHits = 0;
    _wrongHits = 0;
    _items.clear();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        _timeRemaining--;
      });
      if (_timeRemaining <= 0) {
        _finishGame();
      }
    });

    _spawnTimer = Timer.periodic(
      const Duration(milliseconds: spawnIntervalMs),
      (t) => _spawnWord(),
    );
  }

  void _spawnWord() {
    if (_timeRemaining <= 0) return;

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

    if (_items.length > 8) {
      _items.removeAt(0);
    }

    setState(() {});
  }

  void _onWordTap(_WordItem item) {
    HapticFeedback.lightImpact();

    setState(() {
      if (item.isReal) {
        _correctHits++;
        _score += 120;
      } else {
        _wrongHits++;
        _score = (_score - 100).clamp(0, 999999);
      }
      _items.remove(item);
    });
  }

  void _finishGame() {
    _timer.cancel();
    _spawnTimer.cancel();

    final totalHits = _correctHits + _wrongHits;
    final successRate = totalHits == 0 ? 0.0 : _correctHits / totalHits;

    widget.onComplete({
      'score': _score.toDouble(),
      'successRate': successRate,
      'duration': gameDuration,
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _spawnTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6);
    final titleColor = isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final subtitleColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Word Sprint',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gerçek kelimelere dokun, uydurmalara dokunma.',
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
                          fontWeight: FontWeight.bold,
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
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF020617) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final height = constraints.maxHeight;

                      return Stack(
                        children: [
                          for (int i = 0; i < _items.length; i++)
                            Positioned(
                              top: (height / 8) * (i + 0.5) - 16,
                              left: 16,
                              right: 16,
                              child: GestureDetector(
                                onTapDown: (_) => _onWordTap(_items[i]),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF111827)
                                        : const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(0xFF374151)
                                          : const Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _items[i].text,
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
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
                ),
              ),
            ],
          ),
        ),
      ),
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
