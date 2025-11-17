import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class MemoryBoardGame extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;

  const MemoryBoardGame({super.key, required this.onComplete});

  @override
  State<MemoryBoardGame> createState() => _MemoryBoardGameState();
}

class _MemoryBoardGameState extends State<MemoryBoardGame> {
  List<int> _cards = [];
  List<bool> _flipped = [];
  List<bool> _matched = [];
  int? _firstCard;
  int _score = 0;
  int _matches = 0;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _initializeGame();
  }

  void _initializeGame() {
    // 8 çift kart (16 kart toplam)
    _cards = List.generate(8, (index) => index + 1)..addAll(List.generate(8, (index) => index + 1));
    _cards.shuffle();
    _flipped = List.filled(16, false);
    _matched = List.filled(16, false);
    _firstCard = null;
    _score = 0;
    _matches = 0;
  }

  void _flipCard(int index) {
    if (_flipped[index] || _matched[index]) return;

    setState(() {
      _flipped[index] = true;

      if (_firstCard == null) {
        _firstCard = index;
      } else {
        if (_cards[_firstCard!] == _cards[index]) {
          // Eşleşme bulundu
          _matched[_firstCard!] = true;
          _matched[index] = true;
          _matches++;
          _score += 20;
          _firstCard = null;

          if (_matches == 8) {
            _endGame();
          }
        } else {
          // Eşleşme yok
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) {
              setState(() {
                _flipped[_firstCard!] = false;
                _flipped[index] = false;
                _firstCard = null;
                _score = (_score - 2).clamp(0, double.infinity).toInt();
              });
            }
          });
        }
      }
    });
  }

  void _endGame() {
    final duration = DateTime.now().difference(_startTime!).inSeconds;
    final successRate = _matches / 8.0;

    widget.onComplete({
      'score': _score.toDouble(),
      'successRate': successRate,
      'duration': duration,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      child: Column(
        children: [
          // Skor
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                const SizedBox(width: 40),
                Column(
                  children: [
                    Text(
                      'Eşleşme',
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      '$_matches/8',
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
          
          // Kartlar
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 16,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _flipCard(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _matched[index]
                            ? Colors.green
                            : _flipped[index]
                                ? const Color(0xFF6E00FF)
                                : Colors.grey[700],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: _matched[index] || _flipped[index]
                            ? Text(
                                '${_cards[index]}',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : const Icon(
                                Icons.help_outline,
                                color: Colors.white54,
                                size: 40,
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

