import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../settings/providers/theme_provider.dart';

/// Şekillerin yönlerini belirten enum
enum SwipeDirection { up, down, left, right }

/// Şekil modellerini tutan sınıf (SOLID - Tek Sorumluluk Prensibi)
class TargetShape {
  final IconData icon;
  final SwipeDirection correctDirection;
  final String name;

  const TargetShape({
    required this.icon,
    required this.correctDirection,
    required this.name,
  });
}

class ShapeSwipeGame extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic> result) onComplete;
  final bool isPaused;

  const ShapeSwipeGame({
    super.key,
    required this.onComplete,
    this.isPaused = false,
  });

  @override
  ConsumerState<ShapeSwipeGame> createState() => _ShapeSwipeGameState();
}

class _ShapeSwipeGameState extends ConsumerState<ShapeSwipeGame>
    with SingleTickerProviderStateMixin {
  
  static const int _gameDurationSeconds = 60;
  
  // Şekil listesi tanımlamaları
  final List<TargetShape> _shapes = const [
    TargetShape(icon: Icons.circle, correctDirection: SwipeDirection.up, name: "Daire (Yukarı)"),
    TargetShape(icon: Icons.square, correctDirection: SwipeDirection.down, name: "Kare (Aşağı)"),
    TargetShape(icon: Icons.change_history, correctDirection: SwipeDirection.left, name: "Üçgen (Sola)"),
    TargetShape(icon: Icons.diamond, correctDirection: SwipeDirection.right, name: "Elmas (Sağa)"),
  ];

  late TargetShape _currentShape;
  int _timeLeft = _gameDurationSeconds;
  int _score = 0;
  int _attempts = 0;
  int _correctAttempts = 0;
  bool _isPlaying = false;
  
  Timer? _timer;
  
  // Animasyon kontrolleri
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  Color _feedbackColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    
    _setNextShape();
    _startGame();
  }

  @override
  void didUpdateWidget(ShapeSwipeGame oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Duraklatma yönetimi (SOLID)
    if (widget.isPaused != oldWidget.isPaused) {
      if (widget.isPaused) {
        _timer?.cancel();
      } else if (_isPlaying) {
        _startTimer();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _timeLeft = _gameDurationSeconds;
      _score = 0;
      _attempts = 0;
      _correctAttempts = 0;
    });
    _startTimer();
    _animController.forward(from: 0.0);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          _endGame();
        }
      });
    });
  }

  void _endGame() {
    _timer?.cancel();
    setState(() {
      _isPlaying = false;
    });
    
    double successRate = _attempts > 0 ? _correctAttempts / _attempts : 0.0;
    
    // Oyun sonucu gönderme
    widget.onComplete({
      'score': _score,
      'successRate': successRate,
      'duration': _gameDurationSeconds - _timeLeft,
    });
  }

  void _setNextShape() {
    final random = Random();
    setState(() {
      _currentShape = _shapes[random.nextInt(_shapes.length)];
      _feedbackColor = Colors.transparent;
    });
    _animController.forward(from: 0.0);
  }

  void _handleSwipe(SwipeDirection direction) {
    if (!_isPlaying || widget.isPaused) return;

    setState(() {
      _attempts++;
      if (direction == _currentShape.correctDirection) {
        // Doğru yön
        _correctAttempts++;
        _score += 10;
        _feedbackColor = Colors.green.withValues(alpha: 0.5);
      } else {
        // Yanlış yön
        _score = max(0, _score - 5);
        _feedbackColor = Colors.red.withValues(alpha: 0.5);
      }
    });

    // Kısa bir bekleme ve yeni şekil
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted && _isPlaying) {
        _setNextShape();
      }
    });
  }

  // Sürükleme (pan) bitişini yön olarak çözümleyen yardımcı metod
  void _onPanEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;
    final dx = velocity.dx;
    final dy = velocity.dy;
    
    // Hız eşiği, yanlışlıkla küçük dokunuşları yoksaymak için
    if (dx.abs() < 100 && dy.abs() < 100) return;

    if (dx.abs() > dy.abs()) {
      if (dx > 0) {
        _handleSwipe(SwipeDirection.right);
      } else {
        _handleSwipe(SwipeDirection.left);
      }
    } else {
      if (dy > 0) {
        _handleSwipe(SwipeDirection.down);
      } else {
        _handleSwipe(SwipeDirection.up);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final bgColor = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF0F2F5);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);

    return Container(
      color: bgColor,
      child: SafeArea(
        child: Column(
          children: [
            // Üst Bar: Skor ve Zaman
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatCard("Skor", _score.toString(), isDarkMode, textColor),
                  _buildStatCard("Zaman", "$_timeLeft s", isDarkMode, textColor),
                ],
              ),
            ),
            
            // Kullanıcı Yönergeleri
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                   _buildDirectionGuide(Icons.circle, Icons.arrow_upward, isDarkMode, textColor),
                   _buildDirectionGuide(Icons.square, Icons.arrow_downward, isDarkMode, textColor),
                   _buildDirectionGuide(Icons.change_history, Icons.arrow_back, isDarkMode, textColor),
                   _buildDirectionGuide(Icons.diamond, Icons.arrow_forward, isDarkMode, textColor),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Ana Oyun Alanı (Swipe Dedektörü)
            Expanded(
              flex: 4,
              child: GestureDetector(
                onPanEnd: _onPanEnd,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  color: Colors.transparent, // Sürüklemeyi yakalamak için önemli
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: _feedbackColor != Colors.transparent 
                          ? _feedbackColor 
                          : isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Icon(
                          _currentShape.icon,
                          size: 100,
                          color: isDarkMode ? const Color(0xFF0EA5E9) : const Color(0xFF0284C7),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Alt Bilgi
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                "Şekle uygun yöne ekranda kaydırın",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: textColor.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // İstatistik Kartı Oluşturucu
  Widget _buildStatCard(String label, String value, bool isDark, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
            width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: textColor.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 20,
                  color: textColor,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
  
  // Yön Bildirim Yönergesi
  Widget _buildDirectionGuide(IconData shapeShape, IconData directionShape, bool isDark, Color textColor) {
    return Column(
      children: [
        Icon(shapeShape, size: 24, color: isDark ? const Color(0xFF0EA5E9) : const Color(0xFF0284C7)),
        const SizedBox(height: 4),
        Icon(directionShape, size: 20, color: textColor.withValues(alpha: 0.8)),
      ],
    );
  }
}
