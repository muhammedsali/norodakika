import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class LogicPuzzleGame extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;

  const LogicPuzzleGame({super.key, required this.onComplete});

  @override
  State<LogicPuzzleGame> createState() => _LogicPuzzleGameState();
}

class _LogicPuzzleGameState extends State<LogicPuzzleGame> with TickerProviderStateMixin {
  static const int totalQuestions = 15;
  static const int maxLives = 3;

  int _score = 0;
  int _correctAnswers = 0;
  int _totalQuestions = 0;
  int _level = 1;
  int _lives = maxLives;
  int _combo = 0;
  int _bestCombo = 0;
  List<String> _sequence = [];
  String? _missingShape;
  List<String> _answerOptions = [];
  DateTime? _startTime;

  final List<String> _shapes = ['◯', '■', '△', '●', '▲', '□'];
  final Random _rng = Random();

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _generatePuzzle();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _generatePuzzle() {
    final sequenceLength = 3 + (_level ~/ 3); // Level artışıyla daha uzun diziler
    _sequence = List.generate(sequenceLength, (index) => _shapes[_rng.nextInt(_shapes.length)]);
    
    // Daha gelişmiş pattern detection
    final pattern = _detectPattern();
    _missingShape = pattern;
    
    // Cevap seçenekleri
    _answerOptions = [pattern!];
    while (_answerOptions.length < 4) {
      final option = _shapes[_rng.nextInt(_shapes.length)];
      if (!_answerOptions.contains(option)) {
        _answerOptions.add(option);
      }
    }
    _answerOptions.shuffle();
  }

  String? _detectPattern() {
    if (_sequence.length < 2) return _shapes[_rng.nextInt(_shapes.length)];

    // Pattern 1: Alternatif (A, B, A, B, ? -> A)
    if (_sequence.length >= 2) {
      bool isAlternating = true;
      for (int i = 2; i < _sequence.length; i++) {
        if (_sequence[i] != _sequence[i - 2]) {
          isAlternating = false;
          break;
        }
      }
      if (isAlternating) {
        return _sequence[_sequence.length - 2];
      }
    }

    // Pattern 2: Tekrar (A, B, C, A, ? -> B)
    if (_sequence.length >= 4) {
      final first = _sequence[0];
      for (int i = 3; i < _sequence.length; i++) {
        if (_sequence[i] == first) {
          return _sequence[1];
        }
      }
    }

    // Pattern 3: Döngü (A, B, C, ? -> A)
    if (_sequence.length >= 3) {
      return _sequence[0];
    }

    // Pattern 4: Son iki şeklin tekrarı
    if (_sequence.length >= 2) {
      return _sequence[_sequence.length - 2];
    }

    return _shapes[_rng.nextInt(_shapes.length)];
  }

  void _selectAnswer(String answer) {
    _totalQuestions++;
    
    if (answer == _missingShape) {
      _correctAnswers++;
      _combo++;
      if (_combo > _bestCombo) _bestCombo = _combo;
      
      // Combo bonusu ve level bonusu
      final baseScore = 20 + (_level * 5);
      final comboBonus = _combo > 1 ? (_combo - 1) * 10 : 0;
      
      setState(() {
        _score += baseScore + comboBonus;
        // Her 3 doğru cevapta level artışı
        if (_correctAnswers % 3 == 0) {
          _level++;
        }
      });
    } else {
      _lives--;
      _combo = 0;
      _score = (_score - 10).clamp(0, 999999);
      _shakeController.forward(from: 0.0);
      
      if (_lives <= 0) {
        _endGame();
        return;
      }
    }
    
    // 15 soru sonra oyunu bitir
    if (_totalQuestions >= totalQuestions) {
      _endGame();
    } else {
      setState(() {
        _generatePuzzle();
      });
    }
  }

  void _endGame() {
    final duration = DateTime.now().difference(_startTime!).inSeconds;
    final successRate = _totalQuestions > 0 ? _correctAnswers / _totalQuestions : 0.0;

    widget.onComplete({
      'score': _score.toDouble(),
      'successRate': successRate,
      'duration': duration,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6);
    final panelColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final titleColor = isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final subtitleColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final accentColor = isDark ? const Color(0xFF6C5CE7) : const Color(0xFF6366F1);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: panelColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Logic Puzzle',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: titleColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Paterni bul',
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
                            Row(
                              children: List.generate(maxLives, (index) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Icon(
                                    Icons.favorite,
                                    size: 20,
                                    color: index < _lives
                                        ? Colors.red
                                        : subtitleColor.withOpacity(0.3),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Level $_level',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: accentColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStat('Skor: $_score', Icons.star, Colors.amber, subtitleColor),
                        if (_combo > 0)
                          _buildStat('Seri: $_combo', Icons.local_fire_department, Colors.orange, subtitleColor),
                        _buildStat('$_totalQuestions/$totalQuestions', Icons.help_outline, accentColor, subtitleColor),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Puzzle Sequence
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(sin(_shakeController.value * 2 * pi) * _shakeAnimation.value, 0),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: panelColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(isDark ? 0.2 : 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ..._sequence.map((shape) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              shape,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: titleColor,
                              ),
                            ),
                          )),
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: accentColor.withOpacity(0.5 + _pulseController.value * 0.3),
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    '?',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: accentColor,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const Spacer(flex: 2),
              // Answer Choices
              Row(
                children: [
                  Expanded(
                    child: _buildAnswerButton(_answerOptions[0], isDark, panelColor, titleColor, accentColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildAnswerButton(_answerOptions[1], isDark, panelColor, titleColor, accentColor),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildAnswerButton(_answerOptions[2], isDark, panelColor, titleColor, accentColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildAnswerButton(_answerOptions[3], isDark, panelColor, titleColor, accentColor),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerButton(String shape, bool isDark, Color panelColor, Color titleColor, Color accentColor) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectAnswer(shape),
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              shape,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String text, IconData icon, Color color, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
