import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math';

class NBackMiniGame extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;

  const NBackMiniGame({super.key, required this.onComplete});

  @override
  State<NBackMiniGame> createState() => _NBackMiniGameState();
}

class _NBackMiniGameState extends State<NBackMiniGame> {
  int _score = 0;
  int _correctMatches = 0;
  int _totalQuestions = 0;
  int _timeRemaining = 60;
  List<String> _sequence = [];
  int _currentIndex = 0;
  DateTime? _startTime;
  Timer? _gameTimer;
  Timer? _sequenceTimer;

  final List<String> _letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _initializeSequence();
    _startTimers();
  }

  void _startTimers() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        _endGame();
      }
    });

    _sequenceTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_timeRemaining > 0) {
        _nextInSequence();
      } else {
        timer.cancel();
      }
    });
  }

  void _initializeSequence() {
    final random = Random();
    _sequence = List.generate(20, (index) => _letters[random.nextInt(_letters.length)]);
    _currentIndex = 0;
  }

  void _nextInSequence() {
    if (_currentIndex < _sequence.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _initializeSequence();
    }
  }

  void _checkMatch(bool isLocationMatch, bool isSoundMatch) {
    _totalQuestions++;
    
    // Basit kontrol - gerçekte n-back mantığı daha karmaşık
    final random = Random();
    final shouldMatch = random.nextBool();
    
    if (shouldMatch && (isLocationMatch || isSoundMatch)) {
      _correctMatches++;
      _score += 10;
    } else if (!shouldMatch && !isLocationMatch && !isSoundMatch) {
      _correctMatches++;
      _score += 10;
    } else {
      _score = (_score - 5).clamp(0, double.infinity).toInt();
    }
  }

  void _endGame() {
    _gameTimer?.cancel();
    _sequenceTimer?.cancel();
    final duration = DateTime.now().difference(_startTime!).inSeconds;
    final successRate = _totalQuestions > 0 ? _correctMatches / _totalQuestions : 0.0;

    widget.onComplete({
      'score': _score.toDouble(),
      'successRate': successRate,
      'duration': duration,
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _sequenceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLetter = _currentIndex < _sequence.length ? _sequence[_currentIndex] : 'A';
    final activePosition = _currentIndex % 9;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2C2A4A),
      ),
      child: Stack(
        children: [
          _buildBackgroundPattern(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.psychology, color: const Color(0xFFE6E6FA), size: 32),
                  Expanded(
                    child: Text(
                      'N-Back Mini',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Text(
                    'Süre: ${_formatTime(_timeRemaining)}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFE6E6FA),
                    ),
                  ),
                ],
              ),
              
              const Spacer(flex: 1),
              
              // Game Grid
              Expanded(
                flex: 3,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: 9,
                      itemBuilder: (context, index) {
                        final isActive = index == activePosition;
                        return Container(
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF00BFFF)
                                : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF00BFFF).withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                          child: isActive
                              ? Center(
                                  child: Text(
                                    currentLetter,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 64,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : null,
                        );
                      },
                    ),
                  ),
                ),
              ),
              
              const Spacer(flex: 2),
              
              // Action Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: () => _checkMatch(true, false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BFFF).withOpacity(0.2),
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: const Color(0xFF00BFFF),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Konum Eşleşmesi',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: () => _checkMatch(false, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BFFF).withOpacity(0.2),
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: const Color(0xFF00BFFF),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.volume_up, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Ses Eşleşmesi',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
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

  Widget _buildBackgroundPattern() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00BFFF).withOpacity(0.1),
            const Color(0xFFCFADF1).withOpacity(0.1),
          ],
        ),
      ),
    );
  }
}

