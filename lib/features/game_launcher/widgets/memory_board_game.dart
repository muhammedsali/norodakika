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
  late List<ItemModel> _gameCards;
  int _score = 0;
  int _moves = 0;
  int _matches = 0;
  Timer? _timer;
  int _elapsedSeconds = 0;
  
  int? _firstCardIndex;
  bool _isProcessing = false; 

  final List<IconData> _icons = [
    Icons.extension, 
    Icons.star_rounded,
    Icons.casino, 
    Icons.visibility, 
    Icons.favorite_rounded,
    Icons.flash_on,
    Icons.lightbulb_outline,
    Icons.auto_awesome,
  ];

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initializeGame() {
    List<ItemModel> cards = [];
    for (int i = 0; i < 8; i++) {
      cards.add(ItemModel(icon: _icons[i], value: i));
      cards.add(ItemModel(icon: _icons[i], value: i));
    }
    cards.shuffle();

    setState(() {
      _gameCards = cards;
      _score = 0;
      _moves = 0;
      _matches = 0;
      _elapsedSeconds = 0;
      _firstCardIndex = null;
      _isProcessing = false;
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  void _handleCardTap(int index) {
    if (_isProcessing || _gameCards[index].isFlipped || _gameCards[index].isMatched) {
      return;
    }

    setState(() {
      _gameCards[index].isFlipped = true;
    });

    if (_firstCardIndex == null) {
      _firstCardIndex = index;
    } else {
      _moves++;
      _isProcessing = true; 

      if (_gameCards[_firstCardIndex!].value == _gameCards[index].value) {
        setState(() {
          _gameCards[_firstCardIndex!].isMatched = true;
          _gameCards[index].isMatched = true;
          _matches++;
          // Hız bonusu: daha az hamlede eşleştirme = daha çok puan
          final speedBonus = (30 - _moves).clamp(0, 20);
          _score += 20 + speedBonus;
          _firstCardIndex = null;
          _isProcessing = false; 
        });

        if (_matches == 8) {
          _endGame();
        }
      } else {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              _gameCards[_firstCardIndex!].isFlipped = false;
              _gameCards[index].isFlipped = false;
              _firstCardIndex = null;
              _score = (_score - 2).clamp(0, 9999);
              _isProcessing = false; 
            });
          }
        });
      }
    }
  }

  void _endGame() {
    _timer?.cancel();
    final successRate = _matches / 8.0;
    widget.onComplete({
      'score': _score.toDouble(),
      'successRate': successRate, 
      'duration': _elapsedSeconds,
      'moves': _moves,
    });
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6);
    final panelColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final titleColor = isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final subtitleColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final accentColor = isDark ? const Color(0xFF6C5CE7) : const Color(0xFF6366F1);
    final successColor = isDark ? const Color(0xFF10B981) : const Color(0xFF059669);
    
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: panelColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hafıza Testi",
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Kartları eşleştir",
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: accentColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.timer_outlined, size: 18, color: accentColor),
                          const SizedBox(width: 6),
                          Text(
                            _formatTime(_elapsedSeconds),
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Game Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: AspectRatio(
                  aspectRatio: 0.9, 
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: 16,
                        itemBuilder: (context, index) {
                          return _buildCard(_gameCards[index], index, isDark, panelColor, titleColor, successColor, accentColor);
                        },
                      );
                    }
                  ),
                ),
              ),
            ),

            // Footer Stats
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: panelColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(isDark ? 0.2 : 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildFooterStat('HAMLE', '$_moves', Icons.touch_app_rounded, Colors.orange, titleColor, subtitleColor),
                  Container(width: 1, height: 40, color: isDark ? const Color(0xFF374151) : Colors.grey.shade200),
                  _buildFooterStat('SKOR', '$_score', Icons.emoji_events_rounded, accentColor, titleColor, subtitleColor),
                  Container(width: 1, height: 40, color: isDark ? const Color(0xFF374151) : Colors.grey.shade200),
                  _buildFooterStat('DURUM', '${(_matches/8*100).toInt()}%', Icons.pie_chart_rounded, successColor, titleColor, subtitleColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(ItemModel item, int index, bool isDark, Color panelColor, Color titleColor, Color successColor, Color accentColor) {
    return GestureDetector(
      onTap: () => _handleCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        decoration: BoxDecoration(
          color: item.isMatched
              ? successColor
              : item.isFlipped
                  ? panelColor
                  : accentColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: item.isFlipped 
                ? Colors.black.withOpacity(isDark ? 0.2 : 0.05) 
                : accentColor.withOpacity(0.4),
              blurRadius: item.isFlipped ? 5 : 10,
              offset: item.isFlipped ? const Offset(0, 2) : const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: item.isFlipped || item.isMatched
              ? Icon(
                  item.icon,
                  color: item.isMatched ? Colors.white : titleColor,
                  size: 32,
                )
              : Text(
                  "?",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildFooterStat(String label, String value, IconData icon, Color color, Color titleColor, Color subtitleColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color.withOpacity(0.8)),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: subtitleColor,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

class ItemModel {
  final IconData icon;
  final int value;
  bool isFlipped;
  bool isMatched;

  ItemModel({
    required this.icon,
    required this.value,
    this.isFlipped = false,
    this.isMatched = false,
  });
}
