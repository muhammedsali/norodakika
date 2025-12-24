import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math';

class QuickMathGame extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;

  const QuickMathGame({super.key, required this.onComplete});

  @override
  State<QuickMathGame> createState() => _QuickMathGameState();
}

class _QuickMathGameState extends State<QuickMathGame> with TickerProviderStateMixin {
  static const int gameDuration = 60;
  static const int maxLives = 3;
  static const double baseTimePerQuestion = 5.0;

  int _score = 0;
  int _level = 1;
  int _lives = maxLives;
  int _correctAnswers = 0;
  int _totalQuestions = 0;
  int _combo = 0;
  int _bestCombo = 0;
  double _timeProgress = 1.0;
  int _num1 = 0;
  int _num2 = 0;
  String _operator = '+';
  int _correctAnswer = 0;
  List<int> _options = [];
  Timer? _gameTimer;
  Timer? _progressTimer;
  DateTime? _startTime;

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

    _generateQuestion();
    _startTimers();
  }

  void _startTimers() {
    final timePerQuestion = baseTimePerQuestion - (_level - 1) * 0.3;
    
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;
      if (_timeProgress > 0) {
        setState(() {
          _timeProgress -= 0.05 / timePerQuestion;
        });
      } else {
        _handleTimeOut();
      }
    });

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final elapsed = DateTime.now().difference(_startTime!).inSeconds;
      if (elapsed >= gameDuration) {
        _endGame();
      }
    });
  }

  void _generateQuestion() {
    final random = Random();
    final levelMultiplier = _level;
    
    // Level'a göre zorluk artışı
    if (_level <= 3) {
      // Kolay: 10-99 arası toplama
      _num1 = 10 + random.nextInt(90);
      _num2 = 10 + random.nextInt(90);
      _operator = '+';
      _correctAnswer = _num1 + _num2;
    } else if (_level <= 6) {
      // Orta: 50-200 arası toplama/çıkarma
      _num1 = 50 + random.nextInt(150);
      _num2 = 50 + random.nextInt(150);
      _operator = random.nextBool() ? '+' : '-';
      _correctAnswer = _operator == '+' ? _num1 + _num2 : _num1 - _num2;
    } else {
      // Zor: 100-500 arası çarpma
      _num1 = 10 + random.nextInt(20);
      _num2 = 10 + random.nextInt(20);
      _operator = '×';
      _correctAnswer = _num1 * _num2;
    }
    
    // Yanlış cevaplar oluştur
    _options = [_correctAnswer];
    while (_options.length < 3) {
      int wrongAnswer;
      if (_operator == '+') {
        wrongAnswer = _correctAnswer + (random.nextInt(40) - 20);
      } else if (_operator == '-') {
        wrongAnswer = _correctAnswer + (random.nextInt(40) - 20);
      } else {
        wrongAnswer = _correctAnswer + (random.nextInt(60) - 30);
      }
      if (wrongAnswer > 0 && !_options.contains(wrongAnswer)) {
        _options.add(wrongAnswer);
      }
    }
    _options.shuffle();
    
    setState(() {
      _timeProgress = 1.0;
    });
    _startTimers();
  }

  void _handleTimeOut() {
    _lives--;
    _combo = 0;
    _totalQuestions++;
    
    if (_lives <= 0) {
      _endGame();
      return;
    }
    
    _shakeController.forward(from: 0.0);
    _generateQuestion();
  }

  void _selectAnswer(int answer) {
    _progressTimer?.cancel();
    _totalQuestions++;
    
    if (answer == _correctAnswer) {
      _correctAnswers++;
      _combo++;
      if (_combo > _bestCombo) _bestCombo = _combo;
      
      // Combo bonusu ve level bonusu
      final baseScore = 10 + (_level * 2);
      final comboBonus = _combo > 1 ? (_combo - 1) * 5 : 0;
      final timeBonus = (_timeProgress * 20).toInt();
      
      setState(() {
        _score += baseScore + comboBonus + timeBonus;
      });
      
      // Her 5 doğru cevapta level artışı
      if (_correctAnswers % 5 == 0) {
        setState(() {
          _level++;
        });
      }
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
    
    setState(() {
      _generateQuestion();
    });
  }

  void _endGame() {
    _gameTimer?.cancel();
    _progressTimer?.cancel();
    final duration = DateTime.now().difference(_startTime!).inSeconds;
    final successRate = _totalQuestions > 0 ? _correctAnswers / _totalQuestions : 0.0;

    widget.onComplete({
      'score': _score.toDouble(),
      'successRate': successRate,
      'duration': duration,
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _progressTimer?.cancel();
    _shakeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6);
    final panelColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final titleColor = isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final subtitleColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

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
                              'Quick Math',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: titleColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Hızlı hesapla!',
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
                                color: Colors.blue,
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
                        _buildStat('Doğru: $_correctAnswers', Icons.check_circle, Colors.green, subtitleColor),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Timer Progress Bar
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _timeProgress.clamp(0.0, 1.0),
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue,
                              Colors.blue.withOpacity(0.7 + _pulseController.value * 0.3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const Spacer(),
              // Main Question
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(sin(_shakeController.value * 2 * pi) * _shakeAnimation.value, 0),
                    child: Text(
                      '$_num1 $_operator $_num2 = ?',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                        letterSpacing: 2,
                      ),
                    ),
                  );
                },
              ),
              const Spacer(),
              // Answer Buttons
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildAnswerButton(_options[0], isDark, panelColor, titleColor),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildAnswerButton(_options[1], isDark, panelColor, titleColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildAnswerButton(_options[2], isDark, panelColor, titleColor),
                      ),
                    ],
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

  Widget _buildAnswerButton(int answer, bool isDark, Color panelColor, Color titleColor) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
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
          onTap: () => _selectAnswer(answer),
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              '$answer',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 32,
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
