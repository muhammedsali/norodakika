import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class LogicPuzzleGame extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;

  const LogicPuzzleGame({super.key, required this.onComplete});

  @override
  State<LogicPuzzleGame> createState() => _LogicPuzzleGameState();
}

class _LogicPuzzleGameState extends State<LogicPuzzleGame> {
  int _score = 0;
  int _correctAnswers = 0;
  int _totalQuestions = 0;
  int _level = 1;
  List<String> _sequence = [];
  String? _missingShape;
  List<String> _answerOptions = [];
  DateTime? _startTime;

  final List<String> _shapes = ['◯', '■', '△', '●', '▲', '□'];

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _generatePuzzle();
  }

  void _generatePuzzle() {
    final random = Random();
    _sequence = List.generate(3, (index) => _shapes[random.nextInt(3)]);
    
    // Eksik şekli belirle (basit mantık: önceki şekillerin devamı)
    final pattern = _detectPattern();
    _missingShape = pattern;
    
    // Cevap seçenekleri
    _answerOptions = [pattern!];
    while (_answerOptions.length < 3) {
      final option = _shapes[random.nextInt(_shapes.length)];
      if (!_answerOptions.contains(option)) {
        _answerOptions.add(option);
      }
    }
    _answerOptions.shuffle();
  }

  String? _detectPattern() {
    // Basit pattern detection - gerçekte daha karmaşık olabilir
    if (_sequence.length >= 2) {
      // Örnek: A, B, A, ? -> B olmalı
      if (_sequence[0] == _sequence[2]) {
        return _sequence[1];
      }
      // Örnek: A, B, C, ? -> A olmalı (döngü)
      if (_sequence.length == 3) {
        return _sequence[0];
      }
    }
    return _shapes[Random().nextInt(_shapes.length)];
  }

  void _selectAnswer(String answer) {
    _totalQuestions++;
    if (answer == _missingShape) {
      _correctAnswers++;
      _score += 20;
      _level++;
    } else {
      _score = (_score - 10).clamp(0, double.infinity).toInt();
    }
    
    // 10 soru sonra oyunu bitir
    if (_totalQuestions >= 10) {
      final duration = DateTime.now().difference(_startTime!).inSeconds;
      final successRate = _totalQuestions > 0 ? _correctAnswers / _totalQuestions : 0.0;

      widget.onComplete({
        'score': _score.toDouble(),
        'successRate': successRate,
        'duration': duration,
      });
    } else {
      setState(() {
        _generatePuzzle();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2C2A4A),
            const Color(0xFF1F2A40),
          ],
        ),
      ),
      child: Stack(
        children: [
          _buildBackgroundPattern(),
          Container(color: const Color(0xFF1F2A40)),
          SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.settings, color: Color(0xFFF0F0F0)),
                      onPressed: () {},
                    ),
                    Expanded(
                      child: Text(
                        'Level $_level-5',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFF0F0F0),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.pause, color: Color(0xFFF0F0F0)),
                      onPressed: () {},
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // Puzzle Sequence
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ..._sequence.map((shape) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        shape,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFF0F0F0),
                        ),
                      ),
                    )),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '?',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 32,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const Spacer(flex: 2),
                
                // Answer Choices
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAnswerButton(_answerOptions[0]),
                    const SizedBox(width: 16),
                    _buildAnswerButton(_answerOptions[1]),
                    const SizedBox(width: 16),
                    _buildAnswerButton(_answerOptions[2]),
                  ],
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildAnswerButton(String shape) {
    return Expanded(
      child: Container(
        height: 96,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _selectAnswer(shape),
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: Text(
                shape,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFF0F0F0),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.1, 0.2),
          radius: 0.25,
          colors: [
            const Color(0xFF88AAFF).withOpacity(0.1),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

