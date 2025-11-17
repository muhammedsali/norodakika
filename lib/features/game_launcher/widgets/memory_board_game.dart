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
  int _moves = 0;
  Timer? _timer;
  int _elapsedSeconds = 0;
  final List<IconData> _icons = [
    Icons.lightbulb,
    Icons.biotech,
    Icons.atm,
    Icons.psychology,
    Icons.memory,
    Icons.psychology,
    Icons.science,
    Icons.auto_awesome,
  ];

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _initializeGame() {
    // 8 çift kart (16 kart toplam)
    _cards = List.generate(8, (index) => index)..addAll(List.generate(8, (index) => index));
    _cards.shuffle();
    _flipped = List.filled(16, false);
    _matched = List.filled(16, false);
    _firstCard = null;
    _score = 0;
    _matches = 0;
    _moves = 0;
  }

  void _flipCard(int index) {
    if (_flipped[index] || _matched[index]) return;

    setState(() {
      _flipped[index] = true;

      if (_firstCard == null) {
        _firstCard = index;
      } else {
        _moves++;
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
    _timer?.cancel();
    final duration = _elapsedSeconds;
    final successRate = _matches / 8.0;

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
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.1, 0.2),
          radius: 0.4,
          colors: [
            const Color(0xFFCAF0F8).withOpacity(0.05),
            Colors.transparent,
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
                  Icon(Icons.psychology, color: const Color(0xFFE0E0E0), size: 32),
                  Expanded(
                    child: Text(
                      'Memory Game',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFE0E0E0),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Icon(Icons.settings, color: Color(0xFFE0E0E0), size: 32),
                ],
              ),
            ),
            
            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFE0E0E0).withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hamle Sayısı',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              color: const Color(0xFFE0E0E0).withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_moves',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFE0E0E0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFE0E0E0).withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Süre',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              color: const Color(0xFFE0E0E0).withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTime(_elapsedSeconds),
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFE0E0E0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Cards Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: 16,
                  itemBuilder: (context, index) {
                    return _buildCard(index);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(int index) {
    final isFlipped = _flipped[index];
    final isMatched = _matched[index];
    final cardValue = _cards[index];
    final icon = _icons[cardValue];

    return GestureDetector(
      onTap: () => _flipCard(index),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF101922),
          borderRadius: BorderRadius.circular(8),
          border: isMatched
              ? Border.all(color: const Color(0xFF00B4D8), width: 2)
              : isFlipped
                  ? Border.all(color: const Color(0xFF00B4D8), width: 2)
                  : Border.all(color: const Color(0xFF9D4EDD).withOpacity(0.3)),
        ),
        child: isMatched || isFlipped
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isMatched
                      ? const Color(0xFF00B4D8).withOpacity(0.2)
                      : Colors.transparent,
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.5,
                    colors: [
                      const Color(0xFF9D4EDD).withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: _buildCardBackPattern(),
              ),
      ),
    );
  }

  Widget _buildCardBackPattern() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.5,
          colors: [
            const Color(0xFF9D4EDD).withOpacity(0.2),
            Colors.transparent,
          ],
        ),
      ),
      child: CustomPaint(
        painter: CardBackPatternPainter(),
        size: Size.infinite,
      ),
    );
  }
}

class CardBackPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF9D4EDD).withOpacity(0.05)
      ..style = PaintingStyle.fill;

    const step = 10.0;
    for (double x = 0; x < size.width; x += step * 2) {
      for (double y = 0; y < size.height; y += step * 2) {
        canvas.drawRect(
          Rect.fromLTWH(x, y, step, step),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
