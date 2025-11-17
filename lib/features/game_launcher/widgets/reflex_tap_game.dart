import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math';

class ReflexTapGame extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;

  const ReflexTapGame({super.key, required this.onComplete});

  @override
  State<ReflexTapGame> createState() => _ReflexTapGameState();
}

class _ReflexTapGameState extends State<ReflexTapGame> {
  int _score = 0;
  int _totalTaps = 0;
  int _correctTaps = 0;
  DateTime? _startTime;
  Timer? _gameTimer;
  bool _showTarget = false;
  Color _targetColor = const Color(0xFF2BADEE);
  int _timeRemaining = 30;
  int _reactionTime = 0;
  DateTime? _tapStartTime;
  String _feedbackText = '';

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _startGame();
  }

  void _startGame() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
        _showRandomTarget();
      } else {
        _endGame();
      }
    });
    _showRandomTarget();
  }

  void _showRandomTarget() {
    setState(() {
      _showTarget = false;
      _feedbackText = '';
    });

    Future.delayed(Duration(milliseconds: 500 + Random().nextInt(1500)), () {
      if (mounted && _timeRemaining > 0) {
        setState(() {
          _showTarget = true;
          _targetColor = const Color(0xFF2BADEE);
          _tapStartTime = DateTime.now();
        });
      }
    });
  }

  void _onTap() {
    if (!_showTarget) {
      _totalTaps++;
      return;
    }

    final reactionTime = DateTime.now().difference(_tapStartTime!).inMilliseconds;
    _totalTaps++;
    _correctTaps++;
    _score += 10;
    _reactionTime = reactionTime;

    setState(() {
      _showTarget = false;
      _feedbackText = reactionTime < 200 ? 'Great!' : reactionTime < 400 ? 'Good!' : 'OK';
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _showRandomTarget();
      }
    });
  }

  void _endGame() {
    _gameTimer?.cancel();
    final duration = DateTime.now().difference(_startTime!).inSeconds;
    final successRate = _totalTaps > 0 ? _correctTaps / _totalTaps : 0.0;

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
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            const Color(0xFFC6B4CE).withOpacity(0.15),
            const Color(0xFF0A1931),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFFF0F0F0)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Reflex Tap',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
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
            ),
            
            // Main Content
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Reaction Time Display
                    if (_reactionTime > 0)
                      Text(
                        '$_reactionTime ms',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFF0F0F0),
                        ),
                      ),
                    
                    // Feedback Text
                    if (_feedbackText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 64),
                        child: Text(
                          _feedbackText,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            color: const Color(0xFFA0D2DB),
                          ),
                        ),
                      ),
                    
                    // Central Button
                    GestureDetector(
                      onTap: _onTap,
                      child: Container(
                        width: 256,
                        height: 256,
                        decoration: BoxDecoration(
                          color: _showTarget ? _targetColor : Colors.transparent,
                          shape: BoxShape.circle,
                          boxShadow: _showTarget
                              ? [
                                  BoxShadow(
                                    color: _targetColor.withOpacity(0.6),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                  BoxShadow(
                                    color: _targetColor.withOpacity(0.4),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFFC6B4CE).withOpacity(0.3),
                                    blurRadius: 60,
                                    spreadRadius: 15,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                    
                    // Instruction Text
                    Padding(
                      padding: const EdgeInsets.only(top: 64),
                      child: Text(
                        'Tap when the button changes color',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          color: const Color(0xFFF0F0F0).withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
