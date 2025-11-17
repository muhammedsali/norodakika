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
  int _timeRemaining = 60;
  int _num1 = 0;
  int _num2 = 0;
  int _correctAnswer = 0;
  List<int> _options = [];
  Timer? _gameTimer;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _generateQuestion();
    _startTimer();
  }

  void _startTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
      } else {
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
    while (_options.length < 4) {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      child: Column(
        children: [
          // Skor ve zaman
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Skor',
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      '$_score',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Kalan Süre',
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      '$_timeRemaining',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Soru
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_num1 + $_num2 = ?',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Cevap seçenekleri
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: _options.map((option) {
                      return ElevatedButton(
                        onPressed: () => _selectAnswer(option),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6E00FF),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(100, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          '$option',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

