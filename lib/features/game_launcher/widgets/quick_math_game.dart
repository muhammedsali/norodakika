import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math';

class QuickMathGame extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;
  final bool isPaused;

  const QuickMathGame({
    super.key,
    required this.onComplete,
    required this.isPaused,
  });

  @override
  State<QuickMathGame> createState() => _QuickMathGameState();
}

class _QuickMathGameState extends State<QuickMathGame>
    with TickerProviderStateMixin {
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
  int _elapsedSeconds = 0;
  bool _isFinished = false;

  // Feedback renkleri
  Color? _lastFeedbackColor;
  bool _showFeedback = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _pulseController;
  late AnimationController _feedbackController;

  @override
  void initState() {
    super.initState();

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

    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _generateQuestion(startTimers: !widget.isPaused);
  }

  @override
  void didUpdateWidget(covariant QuickMathGame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPaused != widget.isPaused && !_isFinished) {
      if (widget.isPaused) {
        _pauseTimers();
      } else {
        _resumeTimers();
      }
    }
  }

  void _pauseTimers() {
    _gameTimer?.cancel();
    _progressTimer?.cancel();
  }

  void _resumeTimers() {
    _startProgressTimer();
    _startGameTimer();
  }

  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _isFinished) return;
      _elapsedSeconds++;
      if (_elapsedSeconds >= gameDuration) {
        _endGame();
      }
    });
  }

  void _startProgressTimer() {
    final timePerQuestion =
        (baseTimePerQuestion - (_level - 1) * 0.3).clamp(1.5, 8.0);

    _progressTimer?.cancel();
    _progressTimer =
        Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted || _isFinished) return;
      if (_timeProgress > 0) {
        setState(() {
          _timeProgress -= 0.05 / timePerQuestion;
        });
      } else {
        _handleTimeOut();
      }
    });
  }

  void _generateQuestion({bool startTimers = true}) {
    final random = Random();

    if (_level <= 3) {
      _num1 = 10 + random.nextInt(90);
      _num2 = 10 + random.nextInt(90);
      _operator = '+';
      _correctAnswer = _num1 + _num2;
    } else if (_level <= 6) {
      _num1 = 50 + random.nextInt(150);
      _num2 = 50 + random.nextInt(150);
      _operator = random.nextBool() ? '+' : '-';
      _correctAnswer =
          _operator == '+' ? _num1 + _num2 : (_num1 - _num2).abs();
    } else {
      _num1 = 10 + random.nextInt(20);
      _num2 = 10 + random.nextInt(20);
      _operator = '×';
      _correctAnswer = _num1 * _num2;
    }

    _options = [_correctAnswer];
    int attempts = 0;
    while (_options.length < 3 && attempts < 100) {
      attempts++;
      int wrong;
      if (_operator == '×') {
        wrong = _correctAnswer + (random.nextInt(60) - 30);
      } else {
        wrong = _correctAnswer + (random.nextInt(40) - 20);
      }
      if (wrong > 0 && !_options.contains(wrong)) {
        _options.add(wrong);
      }
    }
    _options.shuffle();

    setState(() {
      _timeProgress = 1.0;
    });

    // Sadece pause değilse zamanlayıcıları başlat
    if (startTimers && !widget.isPaused && !_isFinished) {
      _resumeTimers();
    }
  }

  void _handleTimeOut() {
    if (_isFinished) return;
    _progressTimer?.cancel();
    _lives = (_lives - 1).clamp(0, maxLives);
    _combo = 0;
    _totalQuestions++;

    if (_lives <= 0) {
      _endGame();
      return;
    }

    HapticFeedback.heavyImpact();
    _shakeController.forward(from: 0.0);
    _generateQuestion();
  }

  void _selectAnswer(int answer) {
    if (widget.isPaused || _isFinished) return;
    _progressTimer?.cancel();
    _totalQuestions++;

    if (answer == _correctAnswer) {
      HapticFeedback.lightImpact();
      _correctAnswers++;
      _combo++;
      if (_combo > _bestCombo) _bestCombo = _combo;

      final baseScore = 10 + (_level * 2);
      final comboBonus = _combo > 1 ? (_combo - 1) * 5 : 0;
      final timeBonus = (_timeProgress * 20).toInt();

      setState(() {
        _score += baseScore + comboBonus + timeBonus;
        _showFeedback = true;
        _lastFeedbackColor = const Color(0xFF22C55E);
      });

      if (_correctAnswers % 5 == 0) {
        setState(() => _level++);
      }
    } else {
      HapticFeedback.heavyImpact();
      _lives = (_lives - 1).clamp(0, maxLives);
      _combo = 0;
      _score = (_score - 10).clamp(0, 999999);
      _shakeController.forward(from: 0.0);

      setState(() {
        _showFeedback = true;
        _lastFeedbackColor = const Color(0xFFEF4444);
      });

      if (_lives <= 0) {
        _endGame();
        return;
      }
    }

    // Feedback kısa süre göster
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _showFeedback = false);
    });

    _generateQuestion();
  }

  void _endGame() {
    if (_isFinished) return;
    _isFinished = true;
    _gameTimer?.cancel();
    _progressTimer?.cancel();

    final successRate =
        _totalQuestions > 0 ? _correctAnswers / _totalQuestions : 0.0;

    widget.onComplete({
      'score': _score.toDouble(),
      'successRate': successRate,
      'duration': _elapsedSeconds,
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _progressTimer?.cancel();
    _shakeController.dispose();
    _pulseController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor =
        isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6);
    final panelColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final titleColor =
        isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final subtitleColor =
        isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              _buildHeader(isDark, panelColor, titleColor, subtitleColor),
              const SizedBox(height: 16),
              // Timer Progress Bar
              _buildProgressBar(isDark),
              const SizedBox(height: 24),
              // Soru
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          sin(_shakeController.value * 2 * pi) *
                              _shakeAnimation.value,
                          0,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: _showFeedback
                                ? (_lastFeedbackColor ??
                                        const Color(0xFF22C55E))
                                    .withValues(alpha: 0.1)
                                : panelColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: _showFeedback
                                  ? (_lastFeedbackColor ??
                                      const Color(0xFF22C55E))
                                  : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: isDark ? 0.3 : 0.06),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Text(
                            '$_num1 $_operator $_num2 = ?',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 52,
                              fontWeight: FontWeight.bold,
                              color: titleColor,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Cevap butonları
              _buildAnswerButtons(isDark, panelColor, titleColor),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, Color panelColor, Color titleColor,
      Color subtitleColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Sol: başlık + süre
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Math',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Süre: ${gameDuration - _elapsedSeconds}s',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
          // Orta: can kalpleri
          Row(
            children: List.generate(maxLives, (i) {
              return Padding(
                padding: const EdgeInsets.only(left: 4),
                child: AnimatedScale(
                  scale: i < _lives ? 1.0 : 0.8,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.favorite_rounded,
                    size: 22,
                    color: i < _lives
                        ? const Color(0xFFEF4444)
                        : subtitleColor.withValues(alpha: 0.3),
                  ),
                ),
              );
            }),
          ),
          // Sağ: skor + level
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$_score',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF6366F1),
                ),
              ),
              Row(
                children: [
                  Text(
                    'Lvl $_level',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: const Color(0xFF3B82F6),
                        fontWeight: FontWeight.w600),
                  ),
                  if (_combo > 1) ...[
                    const SizedBox(width: 8),
                    Text(
                      '🔥x$_combo',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return LinearProgressIndicator(
            value: _timeProgress.clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: isDark
                ? const Color(0xFF374151)
                : const Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation<Color>(
              Color.lerp(
                const Color(0xFFEF4444),
                const Color(0xFF22C55E),
                _timeProgress,
              )!,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnswerButtons(
      bool isDark, Color panelColor, Color titleColor) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildAnswerButton(
                    _options[0], isDark, panelColor, titleColor)),
            const SizedBox(width: 12),
            Expanded(
                child: _buildAnswerButton(
                    _options[1], isDark, panelColor, titleColor)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _buildAnswerButton(
              _options[2], isDark, panelColor, titleColor),
        ),
      ],
    );
  }

  Widget _buildAnswerButton(
      int answer, bool isDark, Color panelColor, Color titleColor) {
    return Material(
      color: panelColor,
      borderRadius: BorderRadius.circular(18),
      elevation: isDark ? 0 : 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        onTap: () => _selectAnswer(answer),
        borderRadius: BorderRadius.circular(18),
        splashColor: const Color(0xFF6366F1).withValues(alpha: 0.15),
        highlightColor: const Color(0xFF6366F1).withValues(alpha: 0.08),
        child: Container(
          height: 76,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF374151)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Center(
            child: Text(
              '$answer',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
