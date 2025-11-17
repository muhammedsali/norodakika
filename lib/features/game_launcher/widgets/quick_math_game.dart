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

class _QuickMathGameState extends State<QuickMathGame> {
  int _score = 0;
  int _correctAnswers = 0;
  int _totalQuestions = 0;
  double _timeProgress = 1.0;
  int _num1 = 0;
  int _num2 = 0;
  int _correctAnswer = 0;
  List<int> _options = [];
  Timer? _gameTimer;
  Timer? _progressTimer;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _generateQuestion();
    _startTimers();
  }

  void _startTimers() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_timeProgress > 0) {
        setState(() {
          _timeProgress -= 0.001;
        });
      } else {
        _endGame();
      }
    });

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeProgress <= 0) {
        _endGame();
      }
    });
  }

  void _generateQuestion() {
    final random = Random();
    _num1 = 10 + random.nextInt(90);
    _num2 = 10 + random.nextInt(90);
    _correctAnswer = _num1 + _num2;
    
    // Yanlış cevaplar oluştur
    _options = [_correctAnswer];
    while (_options.length < 3) {
      final wrongAnswer = _correctAnswer + (random.nextInt(20) - 10);
      if (wrongAnswer > 0 && !_options.contains(wrongAnswer)) {
        _options.add(wrongAnswer);
      }
    }
    _options.shuffle();
  }

  void _selectAnswer(int answer) {
    _totalQuestions++;
    if (answer == _correctAnswer) {
      _correctAnswers++;
      _score += 10;
    } else {
      _score = (_score - 5).clamp(0, double.infinity).toInt();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topRight,
          radius: 1.5,
          colors: [
            const Color(0xFF8A2BE2),
            const Color(0xFF0A0A2A),
          ],
        ),
      ),
      child: Stack(
        children: [
          _buildGridPattern(),
          Container(color: const Color(0xFF0A0A2A)),
          SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header - Score
                Column(
                  children: [
                    Text(
                      'SCORE',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                        color: const Color(0xFF34D399).withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_score',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: const Color(0xFF34D399),
                        shadows: [
                          Shadow(
                            color: const Color(0xFF34D399).withOpacity(0.7),
                            blurRadius: 8,
                          ),
                          Shadow(
                            color: const Color(0xFF34D399).withOpacity(0.5),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Timer Progress Bar
                    Container(
                      width: double.infinity,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _timeProgress.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF00FFFF),
                                Color(0xFFFF00FF),
                                Color(0xFFFF1E1E),
                              ],
                              stops: [0.0, 0.75, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Main Question
                Expanded(
                  child: Center(
                    child: Text(
                      '$_num1 + $_num2 = ?',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                // Answer Buttons
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildAnswerButton(_options[0]),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildAnswerButton(_options[1]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildAnswerButton(_options[2]),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildAnswerButton(int answer) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF8A2BE2).withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00FFFF).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectAnswer(answer),
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              '$answer',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridPattern() {
    return CustomPaint(
      painter: GridPatternPainter(),
      size: Size.infinite,
    );
  }
}

class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FFFF).withOpacity(0.1)
      ..strokeWidth = 1;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
