import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math';

class RecallPhaseGame extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;

  const RecallPhaseGame({super.key, required this.onComplete});

  @override
  State<RecallPhaseGame> createState() => _RecallPhaseGameState();
}

class _RecallPhaseGameState extends State<RecallPhaseGame> {
  int _score = 0;
  int _correctSelections = 0;
  int _totalWords = 0;
  List<String> _shownWords = [];
  List<String> _allWords = [];
  Set<String> _selectedWords = {};
  bool _isMemorizationPhase = true;
  DateTime? _startTime;
  Timer? _memorizationTimer;

  final List<String> _wordPool = [
    'Ephemeral', 'Labyrinth', 'Mellifluous', 'Serendipity',
    'Wanderlust', 'Juxtaposition', 'Quintessential', 'Ineffable',
    'Sonder', 'Petrichor', 'Computer', 'Galaxy', 'Ocean',
    'Forest', 'Mountain', 'River', 'Desert', 'Island', 'Volcano',
    'System', 'Paradigm', 'Zephyr',
  ];

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _startMemorizationPhase();
  }

  void _startMemorizationPhase() {
    final random = Random();
    _shownWords = List.from(_wordPool);
    _shownWords.shuffle();
    _shownWords = _shownWords.take(8).toList();
    
    _memorizationTimer = Timer(const Duration(seconds: 10), () {
      setState(() {
        _isMemorizationPhase = false;
        _allWords = List.from(_wordPool);
        _allWords.shuffle();
      });
    });
  }

  void _toggleWord(String word) {
    if (_selectedWords.contains(word)) {
      setState(() {
        _selectedWords.remove(word);
      });
    } else {
      setState(() {
        _selectedWords.add(word);
      });
    }
  }

  void _finishTest() {
    _totalWords = _shownWords.length;
    _correctSelections = _selectedWords.where((word) => _shownWords.contains(word)).length;
    final incorrectSelections = _selectedWords.where((word) => !_shownWords.contains(word)).length;
    final missedWords = _shownWords.where((word) => !_selectedWords.contains(word)).length;
    
    _score = (_correctSelections * 10) - (incorrectSelections * 5) - (missedWords * 3);
    _score = _score.clamp(0, double.infinity).toInt();
    
    final duration = DateTime.now().difference(_startTime!).inSeconds;
    final successRate = _totalWords > 0 ? _correctSelections / _totalWords : 0.0;

    widget.onComplete({
      'score': _score.toDouble(),
      'successRate': successRate,
      'duration': duration,
    });
  }

  @override
  void dispose() {
    _memorizationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isMemorizationPhase) {
      return _buildMemorizationPhase();
    }
    
    return _buildRecallPhase();
  }

  Widget _buildMemorizationPhase() {
    return Container(
      color: const Color(0xFF101922),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Memorize these words',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: _shownWords.map((word) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF007BFF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      word,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecallPhase() {
    return Container(
      color: const Color(0xFF101922),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Tap the words you saw previously.',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF212529),
                ),
              ),
            ),
            
            // Word Chips
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _allWords.map((word) {
                    final isSelected = _selectedWords.contains(word);
                    final wasShown = _shownWords.contains(word);
                    
                    return InkWell(
                      onTap: () => _toggleWord(word),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF007BFF)
                              : Colors.grey[200]?.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              word,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? Colors.white : const Color(0xFF212529),
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            
            // Finish Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _finishTest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF212529),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Finish Test',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

