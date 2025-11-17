import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math';

class StroopTapGame extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;

  const StroopTapGame({super.key, required this.onComplete});

  @override
  State<StroopTapGame> createState() => _StroopTapGameState();
}

class _StroopTapGameState extends State<StroopTapGame> {
  int _score = 0;
  int _correctAnswers = 0;
  int _totalQuestions = 0;
  int _timeRemaining = 60;
  String _currentWord = '';
  Color _currentWordColor = Colors.blue;
  List<Color> _colorOptions = [];
  DateTime? _startTime;
  Timer? _gameTimer;
  int _reactionTime = 0;
  DateTime? _questionStartTime;

  final List<String> _colorWords = ['Red', 'Blue', 'Green', 'Yellow'];
  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
  ];

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
    final wordIndex = random.nextInt(_colorWords.length);
    final colorIndex = random.nextInt(_colors.length);
    
    _currentWord = _colorWords[wordIndex];
    _currentWordColor = _colors[colorIndex];
    _questionStartTime = DateTime.now();
    
    // Renk seçenekleri
    _colorOptions = List.from(_colors);
    _colorOptions.shuffle();
  }

  void _selectColor(Color selectedColor) {
    _totalQuestions++;
    final correctColor = _colors[_colorWords.indexOf(_currentWord)];
    final isCorrect = selectedColor == correctColor;
    
    if (isCorrect) {
      _correctAnswers++;
      _score += 10;
      _reactionTime = DateTime.now().difference(_questionStartTime!).inMilliseconds;
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFD1C4E9),
            const Color(0xFFB3E5FC),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.science, color: Color(0xFFF0F0F0), size: 28),
                  Expanded(
                    child: Text(
                      'Stroop Tap',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFF0F0F0),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Text(
                    'Score: $_score',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF0F0F0),
                    ),
                  ),
                ],
              ),
            ),
            
            // Main Content
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Word Display
                  Expanded(
                    child: Center(
                      child: Text(
                        _currentWord,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 96,
                          fontWeight: FontWeight.bold,
                          color: _currentWordColor,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Color Buttons
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildColorButton(_colorOptions[0]),
                        const SizedBox(width: 16),
                        _buildColorButton(_colorOptions[1]),
                        const SizedBox(width: 16),
                        _buildColorButton(_colorOptions[2]),
                        const SizedBox(width: 16),
                        _buildColorButton(_colorOptions[3]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _reactionTime > 0
                    ? 'Reaction Time: $_reactionTime ms'
                    : 'Select the color of the word',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  color: const Color(0xFFF0F0F0).withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () => _selectColor(color),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

