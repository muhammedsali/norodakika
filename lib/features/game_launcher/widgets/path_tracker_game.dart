import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PathTrackerGame extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;
  final bool isPaused;

  const PathTrackerGame({
    super.key,
    required this.onComplete,
    required this.isPaused,
  });

  @override
  State<PathTrackerGame> createState() => _PathTrackerGameState();
}

class _PathTrackerGameState extends State<PathTrackerGame> {
  static const int totalSeconds = 60;
  static const int maxHearts = 3;

  final Random _rng = Random();

  Timer? _gameTimer;
  final ValueNotifier<int> _timeNotifier = ValueNotifier<int>(totalSeconds);
  
  int _score = 0;
  int _hearts = maxHearts;
  int _level = 1;
  int _correct = 0;
  int _wrong = 0;
  int _streak = 0;
  int _bestStreak = 0;

  int _targetsClearedInLevel = 0;
  int _targetsToClear = 5;

  bool _isFinished = false;

  // Grid Info
  final int _gridSize = 3; // 3x3
  int _startRow = 1;
  int _startCol = 1;

  int _currentRow = 1;
  int _currentCol = 1;

  final List<String> _moves = []; // 'U', 'D', 'L', 'R'
  int _moveSequenceCount = 3; // Başlangıçta 3 hamle

  // Game Phase
  // 0: Start delay, 1: Original Position Showing, 2: Moves Showing, 3: Waiting for input
  int _phase = 0;
  int _currentMoveIndex = 0;
  String _currentMoveDisplay = '';
  
  Timer? _phaseTimer;
  double _moveDelayMs = 1200;

  @override
  void initState() {
    super.initState();
    _startTimers();
    _initRound();
  }

  @override
  void didUpdateWidget(covariant PathTrackerGame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPaused != widget.isPaused) {
      if (widget.isPaused) {
        _gameTimer?.cancel();
        _phaseTimer?.cancel();
      } else if (!_isFinished) {
        _startTimers();
        if (_phase == 2) {
          _runMovesSequence(); // Kaldığı yerden devam
        }
      }
    }
  }

  void _startTimers() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || _isFinished) return;
      _timeNotifier.value--;
      if (_timeNotifier.value <= 0) {
        _finishGame();
      }
    });
  }

  void _initRound() {
    if (_isFinished) return;
    _phase = 0;
    
    // Rastgele başlangıç pozisyonu
    _startRow = _rng.nextInt(_gridSize);
    _startCol = _rng.nextInt(_gridSize);
    _currentRow = _startRow;
    _currentCol = _startCol;

    // Rota oluştur
    _moves.clear();
    for (int i = 0; i < _moveSequenceCount; i++) {
      _moves.add(_generateValidMove());
    }

    if (mounted) setState(() {});
    
    // Kısa bir bekleme ve start gösterme
    _phaseTimer?.cancel();
    _phaseTimer = Timer(const Duration(milliseconds: 1000), () {
      if (!mounted || _isFinished) return;
      setState(() {
        _phase = 1; // Pozisyon gösteriliyor
      });
      
      _phaseTimer = Timer(const Duration(milliseconds: 1500), () {
        if (!mounted || _isFinished) return;
        setState(() {
          _phase = 2; // Oklar gösterilecek
          _currentMoveIndex = 0;
        });
        _runMovesSequence();
      });
    });
  }

  String _generateValidMove() {
    List<String> possible = [];
    if (_currentRow > 0) possible.add('U');
    if (_currentRow < _gridSize - 1) possible.add('D');
    if (_currentCol > 0) possible.add('L');
    if (_currentCol < _gridSize - 1) possible.add('R');

    String move = possible[_rng.nextInt(possible.length)];
    if (move == 'U') _currentRow--;
    if (move == 'D') _currentRow++;
    if (move == 'L') _currentCol--;
    if (move == 'R') _currentCol++;

    return move;
  }

  void _runMovesSequence() {
    if (_currentMoveIndex >= _moves.length) {
      setState(() {
        _phase = 3; // Oyuncu seçimi yapacak
        _currentMoveDisplay = '';
      });
      return;
    }

    setState(() {
      _currentMoveDisplay = _moves[_currentMoveIndex];
    });

    _phaseTimer = Timer(Duration(milliseconds: (_moveDelayMs * 0.7).toInt()), () {
      if (!mounted || _isFinished) return;
      
      setState(() {
        _currentMoveDisplay = ''; // Boşluk
      });
      
      _phaseTimer = Timer(Duration(milliseconds: (_moveDelayMs * 0.3).toInt()), () {
        if (!mounted || _isFinished) return;
        _currentMoveIndex++;
        _runMovesSequence();
      });
    });
  }

  void _onCellTap(int r, int c) {
    if (_phase != 3 || widget.isPaused || _isFinished) return;

    if (r == _currentRow && c == _currentCol) {
      // Doğru
      HapticFeedback.lightImpact();
      _correct++;
      _streak++;
      _bestStreak = max(_bestStreak, _streak);
      _targetsClearedInLevel++;
      _score += 100 + (_streak * 15);
      
      if (_targetsClearedInLevel >= _targetsToClear) {
        _levelUp();
      } else {
        _initRound();
      }
    } else {
      // Yanlış
      HapticFeedback.heavyImpact();
      _wrong++;
      _streak = 0;
      _score = max(0, _score - 50);
      _hearts = max(0, _hearts - 1);
      
      if (_hearts <= 0) {
        _finishGame();
      } else {
        _initRound();
      }
    }
  }

  void _levelUp() {
    setState(() {
      _level++;
      _targetsClearedInLevel = 0;
      _targetsToClear += 2;
      _moveSequenceCount++;
      _moveDelayMs = max(400, _moveDelayMs * 0.9); // Hızlan
      _timeNotifier.value += 15; // Bonus zaman
      _hearts = min(maxHearts, _hearts + 1);
    });
    _initRound();
  }

  void _finishGame() {
    if (_isFinished) return;
    _isFinished = true;
    _gameTimer?.cancel();
    _phaseTimer?.cancel();
    
    final total = _correct + _wrong;
    final successRate = total == 0 ? 0.0 : _correct / total;

    widget.onComplete({
      'score': _score.toDouble(),
      'successRate': successRate,
      'duration': totalSeconds - max(0, _timeNotifier.value),
      'correctAttempts': _correct,
      'wrongAttempts': _wrong,
      'level': _level,
      'bestCombo': _bestStreak,
    });
    setState(() {});
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _phaseTimer?.cancel();
    _timeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0B1220) : const Color(0xFFF7F8FB);
    final panel = isDark ? const Color(0xFF111827) : Colors.white;
    final titleColor = isDark ? const Color(0xFFF9FAFB) : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(titleColor, panel),
              const SizedBox(height: 12),
              _buildStats(panel, titleColor, subtitleColor),
              const SizedBox(height: 24),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildGameArea(isDark),
                    const SizedBox(height: 40),
                    _buildFeedbackText(titleColor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color titleColor, Color panel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                'Path Tracker',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Seviye $_level  -  $_targetsClearedInLevel / $_targetsToClear',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6366F1),
                ),
              ),
            ],
          ),
          ValueListenableBuilder<int>(
            valueListenable: _timeNotifier,
            builder: (context, time, _) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: time <= 10 ? const Color(0xFFFEE2E2) : titleColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: time <= 10 ? const Color(0xFFEF4444) : Colors.transparent,
                ),
              ),
              child: Text(
                '$time s',
                style: GoogleFonts.robotoMono(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: time <= 10 ? const Color(0xFFEF4444) : titleColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(Color panel, Color titleColor, Color subtitleColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StatChip(icon: Icons.favorite_rounded, label: 'Can', value: '$_hearts/3', color: const Color(0xFFEF4444)),
          _StatChip(icon: Icons.local_fire_department, label: 'Seri', value: '$_streak', color: const Color(0xFFF59E0B)),
          _StatChip(icon: Icons.star_rounded, label: 'Skor', value: '$_score', color: const Color(0xFF6366F1)),
        ],
      ),
    );
  }

  Widget _buildGameArea(bool isDark) {
    return Center(
      child: Column(
        children: [
          // Yönlendirme ekranı
          SizedBox(
            height: 100,
            child: Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 100),
                opacity: _currentMoveDisplay.isNotEmpty ? 1.0 : 0.0,
                child: Icon(
                  _getArrowIcon(_currentMoveDisplay),
                  size: 80,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Izgara
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_gridSize, (r) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_gridSize, (c) {
                    final isStartPos = (_phase == 1 && r == _startRow && c == _startCol);
                    return GestureDetector(
                      onTapDown: (_) => _onCellTap(r, c),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.all(4),
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: isStartPos 
                              ? const Color(0xFF3B82F6) 
                              : (isDark ? const Color(0xFF374151) : Colors.white),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            if (isStartPos)
                              BoxShadow(
                                color: const Color(0xFF3B82F6).withValues(alpha: 0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: isStartPos
                            ? const Icon(Icons.circle, color: Colors.white, size: 24)
                            : null,
                      ),
                    );
                  }),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackText(Color titleColor) {
    String text = '';
    Color c = titleColor;

    if (_phase == 0) {
      text = 'Hazırlan...';
    } else if (_phase == 1) {
      text = 'Başlangıç Noktasını Aklında Tut!';
      c = const Color(0xFF3B82F6);
    } else if (_phase == 2) {
      text = 'Yönleri Zihninde Takip Et!';
      c = const Color(0xFFF59E0B);
    } else if (_phase == 3) {
      text = 'Hedef Nerede? Dokun!';
      c = const Color(0xFF10B981);
    }

    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: c,
      ),
    );
  }

  IconData _getArrowIcon(String move) {
    switch (move) {
      case 'U': return Icons.arrow_upward_rounded;
      case 'D': return Icons.arrow_downward_rounded;
      case 'L': return Icons.arrow_back_rounded;
      case 'R': return Icons.arrow_forward_rounded;
      default: return Icons.help_outline;
    }
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(fontSize: 11, color: color.withValues(alpha: 0.8)),
            ),
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
