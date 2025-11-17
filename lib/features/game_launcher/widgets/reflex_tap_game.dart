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
  Color _targetColor = Colors.green;
  int _timeRemaining = 30;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _startTime = DateTime.now();
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
    });

    Future.delayed(Duration(milliseconds: 500 + Random().nextInt(1500)), () {
      if (mounted && _timeRemaining > 0) {
        setState(() {
          _showTarget = true;
          _targetColor = Random().nextBool() ? Colors.green : Colors.red;
        });
      }
    });
  }

  void _onTap() {
    if (!_showTarget) {
      _totalTaps++;
      return;
    }

    _totalTaps++;
    if (_targetColor == Colors.green) {
      _correctTaps++;
      _score += 10;
    } else {
      _score = (_score - 5).clamp(0, double.infinity).toInt();
    }

    setState(() {
      _showTarget = false;
    });

    _showRandomTarget();
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
          
          // Oyun alanı
          Expanded(
            child: GestureDetector(
              onTap: _onTap,
              child: Container(
                width: double.infinity,
                color: Colors.grey[800],
                child: Center(
                  child: _showTarget
                      ? Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: _targetColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _targetColor.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Icon(
                            _targetColor == Colors.green ? Icons.check : Icons.close,
                            color: Colors.white,
                            size: 60,
                          ),
                        )
                      : Text(
                          'Bekle...',
                          style: GoogleFonts.poppins(
                            color: Colors.white54,
                            fontSize: 24,
                          ),
                        ),
                ),
              ),
            ),
          ),
          
          // Talimat
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Yeşil daireye bas, kırmızıya basma!',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

