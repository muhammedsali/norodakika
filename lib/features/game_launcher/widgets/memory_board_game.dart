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
  // Oyun Durumu Değişkenleri
  late List<ItemModel> _gameCards;
  int _score = 0;
  int _moves = 0;
  int _matches = 0;
  Timer? _timer;
  int _elapsedSeconds = 0;
  
  // Mantıksal Kontroller
  int? _firstCardIndex;
  bool _isProcessing = false; // Tıklamaları engellemek için kilit

  final List<IconData> _icons = [
    Icons.extension, // yapboz parçası
    Icons.star_rounded,
    Icons.casino, // zar
    Icons.visibility, // göz
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
    // Kartları oluştur ve karıştır
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
    // 1. Kilit kontrolü: İşlem sürüyorsa veya kart zaten açıksa tıklamayı yoksay
    if (_isProcessing || _gameCards[index].isFlipped || _gameCards[index].isMatched) {
      return;
    }

    setState(() {
      _gameCards[index].isFlipped = true;
    });

    // İlk kart açılıyor
    if (_firstCardIndex == null) {
      _firstCardIndex = index;
    } 
    // İkinci kart açılıyor
    else {
      _moves++;
      _isProcessing = true; // Diğer tıklamaları kilitle

      // Eşleşme Kontrolü
      if (_gameCards[_firstCardIndex!].value == _gameCards[index].value) {
        // EŞLEŞME VAR
        setState(() {
          _gameCards[_firstCardIndex!].isMatched = true;
          _gameCards[index].isMatched = true;
          _matches++;
          _score += 20;
          _firstCardIndex = null;
          _isProcessing = false; // Kilidi aç
        });

        // Oyun Bitti mi?
        if (_matches == 8) {
          _endGame();
        }
      } else {
        // EŞLEŞME YOK (Hata cezası)
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              _gameCards[_firstCardIndex!].isFlipped = false;
              _gameCards[index].isFlipped = false;
              _firstCardIndex = null;
              _score = (_score - 2).clamp(0, 9999);
              _isProcessing = false; // Kilidi aç
            });
          }
        });
      }
    }
  }

  void _endGame() {
    _timer?.cancel();
    widget.onComplete({
      'score': _score.toDouble(),
      'successRate': _matches / 8.0, // Basitleştirilmiş oran
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6);
    final Color cardBack = isDark ? const Color(0xFF1F2937) : Colors.white;
    final Color accentColor = const Color(0xFF6366F1);
    final Color matchedColor = const Color(0xFF10B981);
    final Color gridBorder = isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Column(
            children: [
              // --- HEADER (Skor ve Süre) ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: cardBack,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: gridBorder),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem('HAMLE', '$_moves', accentColor),
                    _buildStatItem('SKOR', '$_score', isDark ? Colors.white : const Color(0xFF111827)),
                    _buildStatItem('SÜRE', _formatTime(_elapsedSeconds), accentColor),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // --- GRID BOARD ---
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF020617) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: gridBorder),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 24,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      // Kartları biraz daha kare yaparak alanı daha iyi doldur
                      childAspectRatio: 0.95,

                    ),
                    itemCount: 16,
                    itemBuilder: (context, index) {
                      final item = _gameCards[index];
                      return GestureDetector(
                        onTap: () => _handleCardTap(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                          decoration: BoxDecoration(
                            color: item.isMatched
                                ? matchedColor.withOpacity(isDark ? 0.18 : 0.12)
                                : item.isFlipped
                                    ? cardBack.withOpacity(isDark ? 0.9 : 1.0)
                                    : cardBack,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: item.isMatched
                                  ? matchedColor
                                  : item.isFlipped
                                      ? accentColor
                                      : gridBorder.withOpacity(0.7),
                              width: item.isFlipped || item.isMatched ? 2 : 1,
                            ),
                            boxShadow: item.isFlipped
                                ? [
                                    BoxShadow(
                                      color: accentColor.withOpacity(0.18),
                                      blurRadius: 14,
                                      offset: const Offset(0, 6),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: item.isFlipped || item.isMatched
                                ? Icon(
                                    item.icon,
                                    color: item.isMatched ? matchedColor : accentColor,
                                    size: 30,
                                  )
                                : Icon(
                                    Icons.grid_3x3,
                                    color: isDark ? Colors.white10 : const Color(0xFFE5E7EB),
                                    size: 22,
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          // HATA DÜZELTİLDİ: jetbrainsMono yerine robotoMono kullanıldı
          style: GoogleFonts.robotoMono(
            fontSize: 12,
            color: Colors.white54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

// Basit Veri Modeli
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