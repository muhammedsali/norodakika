import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../settings/providers/theme_provider.dart';

// ─── Yön enum ─────────────────────────────────────────────
enum SwipeDirection { up, down, left, right }

// ─── Şekil modeli ─────────────────────────────────────────
class TargetShape {
  final IconData icon;
  final SwipeDirection correctDirection;
  final String name;
  final Color color;

  const TargetShape({
    required this.icon,
    required this.correctDirection,
    required this.name,
    required this.color,
  });
}

// ─── Combo overlay modeli ─────────────────────────────────
class _ComboPopup {
  final String text;
  final Color color;
  _ComboPopup(this.text, this.color);
}

// ─── Ana Widget ───────────────────────────────────────────
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
    with TickerProviderStateMixin {
  static const int _gameDurationSeconds = 45;

  // ─── Şekil tanımları (her şeklin kendine özel rengi var) ─
  static const List<TargetShape> _shapes = [
    TargetShape(
      icon: Icons.circle,
      correctDirection: SwipeDirection.up,
      name: 'Daire',
      color: Color(0xFF0D59F2),
    ),
    TargetShape(
      icon: Icons.square_rounded,
      correctDirection: SwipeDirection.down,
      name: 'Kare',
      color: Color(0xFF059669),
    ),
    TargetShape(
      icon: Icons.change_history,
      correctDirection: SwipeDirection.left,
      name: 'Üçgen',
      color: Color(0xFF9333EA),
    ),
    TargetShape(
      icon: Icons.diamond,
      correctDirection: SwipeDirection.right,
      name: 'Elmas',
      color: Color(0xFFF59E0B),
    ),
  ];

  // ─── Oyun durumu ──────────────────────────────────────────
  late TargetShape _currentShape;
  int _timeLeft = _gameDurationSeconds;
  int _score = 0;
  int _combo = 0;
  int _attempts = 0;
  int _correctAttempts = 0;
  bool _isPlaying = false;

  // Son swipe yönü (yön göstergesi highlight için)
  SwipeDirection? _lastSwipeDir;
  bool _lastWasCorrect = false;

  // Combo popup listesi
  final List<_ComboPopup> _popups = [];

  Timer? _timer;

  // ─── Animasyon controller'ları ─────────────────────────
  // Şekil kart animasyonu (scale-in)
  late AnimationController _cardController;
  late Animation<double> _cardScale;

  // Kart uçuş animasyonu (swipe yönüne doğru kayar)
  late AnimationController _swipeController;
  late Animation<Offset> _swipeOffset;
  late Animation<double> _swipeFade;
  SwipeDirection _swipeDir = SwipeDirection.up;

  // Doğru/Yanlış flaş animasyonu
  late AnimationController _flashController;
  late Animation<double> _flashAnim;
  Color _flashColor = Colors.transparent;

  // Combo metin animasyonu
  late AnimationController _comboController;
  late Animation<double> _comboScale;
  late Animation<double> _comboFade;

  // Zaman çubuğu rengi
  late AnimationController _timerBarController;

  @override
  void initState() {
    super.initState();

    // Kart scale-in
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _cardScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack),
    );

    // Swipe uçuş
    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _swipeOffset = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(_swipeController);
    _swipeFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _swipeController, curve: Curves.easeIn),
    );

    // Flaş
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _flashAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flashController, curve: Curves.easeOut),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          _flashController.reverse();
        }
      });

    // Combo pop
    _comboController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _comboScale = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(
          parent: _comboController,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)),
    );
    _comboFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _comboController,
          curve: const Interval(0.4, 1.0, curve: Curves.easeIn)),
    );

    // Zaman çubuğu
    _timerBarController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _gameDurationSeconds),
    );

    _setNextShape(animate: false);
    _startGame();
  }

  @override
  void didUpdateWidget(ShapeSwipeGame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPaused != oldWidget.isPaused) {
      if (widget.isPaused) {
        _timer?.cancel();
        _timerBarController.stop();
      } else if (_isPlaying) {
        _startTimer();
        _timerBarController.forward();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cardController.dispose();
    _swipeController.dispose();
    _flashController.dispose();
    _comboController.dispose();
    _timerBarController.dispose();
    super.dispose();
  }

  // ─── Oyunu başlat ─────────────────────────────────────────
  void _startGame() {
    setState(() {
      _isPlaying = true;
      _timeLeft = _gameDurationSeconds;
      _score = 0;
      _combo = 0;
      _attempts = 0;
      _correctAttempts = 0;
    });
    _startTimer();
    _timerBarController.forward(from: 0.0);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) _endGame();
      });
    });
  }

  void _endGame() {
    _timer?.cancel();
    _timerBarController.stop();
    setState(() => _isPlaying = false);
    final successRate =
        _attempts > 0 ? _correctAttempts / _attempts : 0.0;
    widget.onComplete({
      'score': _score,
      'successRate': successRate,
      'duration': _gameDurationSeconds - _timeLeft,
    });
  }

  // ─── Yeni şekil seç ───────────────────────────────────────
  void _setNextShape({bool animate = true}) {
    TargetShape next;
    do {
      next = _shapes[Random().nextInt(_shapes.length)];
    } while (animate && next == _currentShape && _shapes.length > 1);

    setState(() {
      _currentShape = next;
      _lastSwipeDir = null;
    });
    if (animate) _cardController.forward(from: 0.0);
  }

  // ─── Swipe işle ───────────────────────────────────────────
  void _handleSwipe(SwipeDirection direction) {
    if (!_isPlaying || widget.isPaused) return;

    final correct = direction == _currentShape.correctDirection;

    // Haptic feedback
    if (correct) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.heavyImpact();
    }

    setState(() {
      _attempts++;
      _lastSwipeDir = direction;
      _lastWasCorrect = correct;

      if (correct) {
        _correctAttempts++;
        _combo++;
        // Combo bonusu
        final bonus = _combo >= 5 ? 20 : (_combo >= 3 ? 15 : 10);
        _score += bonus;
        _flashColor = const Color(0xFF059669);
        _triggerComboPopup();
      } else {
        _combo = 0;
        _score = max(0, _score - 5);
        _flashColor = const Color(0xFFEF4444);
      }
    });

    // Flaş
    _flashController.forward(from: 0.0);

    // Kartı uçur
    _launchCard(direction);
  }

  // ─── Combo popup tetikle ─────────────────────────────────
  void _triggerComboPopup() {
    _ComboPopup? popup;
    if (_combo >= 7) {
      popup = _ComboPopup('🔥 x$_combo SÜPER!', const Color(0xFFEF4444));
    } else if (_combo >= 5) {
      popup = _ComboPopup('⚡ x$_combo COMBO!', const Color(0xFFF59E0B));
    } else if (_combo >= 3) {
      popup = _ComboPopup('✨ x$_combo', const Color(0xFF059669));
    } else if (_combo == 2) {
      popup = _ComboPopup('x2', const Color(0xFF0D59F2));
    }

    if (popup != null) {
      setState(() => _popups.add(popup!));
      _comboController.forward(from: 0.0);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) setState(() => _popups.remove(popup));
      });
    }
  }

  // ─── Kartı yönüne uçur ───────────────────────────────────
  void _launchCard(SwipeDirection dir) {
    const double dist = 1.5;
    Offset endOffset;
    switch (dir) {
      case SwipeDirection.up:
        endOffset = const Offset(0, -dist);
        break;
      case SwipeDirection.down:
        endOffset = const Offset(0, dist);
        break;
      case SwipeDirection.left:
        endOffset = const Offset(-dist, 0);
        break;
      case SwipeDirection.right:
        endOffset = const Offset(dist, 0);
        break;
    }

    _swipeOffset = Tween<Offset>(
      begin: Offset.zero,
      end: endOffset,
    ).animate(
      CurvedAnimation(parent: _swipeController, curve: Curves.easeIn),
    );

    _swipeController.forward(from: 0.0).then((_) {
      if (mounted && _isPlaying) {
        _swipeController.reset();
        _setNextShape();
      }
    });
  }

  // ─── Pan/Swipe algıla ─────────────────────────────────────
  void _onPanEnd(DragEndDetails d) {
    final dx = d.velocity.pixelsPerSecond.dx;
    final dy = d.velocity.pixelsPerSecond.dy;
    if (dx.abs() < 150 && dy.abs() < 150) return;

    if (dx.abs() > dy.abs()) {
      _handleSwipe(dx > 0 ? SwipeDirection.right : SwipeDirection.left);
    } else {
      _handleSwipe(dy > 0 ? SwipeDirection.down : SwipeDirection.up);
    }
  }

  // ─── BUILD ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF0F4FF);
    final textColor =
        isDark ? Colors.white : const Color(0xFF0F172A);

    return Container(
      color: bg,
      child: SafeArea(
        child: Stack(
          children: [
            // ── Ana kolon ──────────────────────────────────
            Column(
              children: [
                // Zaman çubuğu
                _buildTimerBar(isDark),

                const SizedBox(height: 10),

                // Skor + Zaman + Combo
                _buildTopBar(textColor, isDark),

                const SizedBox(height: 16),

                // Yön referans kılavuzu
                _buildDirectionGuide(isDark),

                const SizedBox(height: 8),

                // Swipe alanı
                Expanded(
                  child: GestureDetector(
                    onPanEnd: _onPanEnd,
                    behavior: HitTestBehavior.opaque,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Flaş overlay
                        AnimatedBuilder(
                          animation: _flashAnim,
                          builder: (_, __) => Container(
                            color: _flashColor.withValues(
                                alpha: _flashAnim.value * 0.18),
                          ),
                        ),

                        // Yön ok göstergesi (ortada büyük, solukta)
                        _buildSwipeArrow(),

                        // Şekil kartı
                        SlideTransition(
                          position: _swipeOffset,
                          child: FadeTransition(
                            opacity: _swipeFade,
                            child: ScaleTransition(
                              scale: _cardScale,
                              child: _buildShapeCard(isDark),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Alt bilgi
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Text(
                    'Şekle göre yönü sürükle!',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textColor.withValues(alpha: 0.45),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),

            // ── Combo popup overlay ────────────────────────
            ..._popups.map((p) => _buildComboPopup(p)),
          ],
        ),
      ),
    );
  }

  // ─── Zaman çubuğu ─────────────────────────────────────────
  Widget _buildTimerBar(bool isDark) {
    final pct = _timeLeft / _gameDurationSeconds;
    final barColor = pct > 0.5
        ? const Color(0xFF059669)
        : pct > 0.25
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          height: 6,
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor:
                isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 6,
          ),
        ),
      ),
    );
  }

  // ─── Üst bar: skor + süre + combo ─────────────────────────
  Widget _buildTopBar(Color textColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statChip(
            Icons.star_rounded,
            _score.toString(),
            const Color(0xFF0D59F2),
            isDark,
          ),
          // Süre (kırmızıya döner)
          _statChip(
            Icons.timer_rounded,
            '$_timeLeft s',
            _timeLeft <= 10
                ? const Color(0xFFEF4444)
                : const Color(0xFF059669),
            isDark,
            big: _timeLeft <= 10,
          ),
          _statChip(
            Icons.local_fire_department_rounded,
            _combo > 0 ? 'x$_combo' : '--',
            _combo >= 3 ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8),
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _statChip(
      IconData icon, String value, Color color, bool isDark,
      {bool big = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: big ? 18 : 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Yön kılavuzu (4 şekil → yön) ────────────────────────
  Widget _buildDirectionGuide(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _shapes
              .map((s) => _dirChip(s, isDark))
              .toList(),
        ),
      ),
    );
  }

  Widget _dirChip(TargetShape s, bool isDark) {
    // Aktif kılavuz: mevcut şeklin kılavuzu parlasın
    final isActive = _currentShape == s;
    IconData arrowIcon;
    String label;
    switch (s.correctDirection) {
      case SwipeDirection.up:
        arrowIcon = Icons.arrow_upward_rounded;
        label = 'Yukarı';
        break;
      case SwipeDirection.down:
        arrowIcon = Icons.arrow_downward_rounded;
        label = 'Aşağı';
        break;
      case SwipeDirection.left:
        arrowIcon = Icons.arrow_back_rounded;
        label = 'Sola';
        break;
      case SwipeDirection.right:
        arrowIcon = Icons.arrow_forward_rounded;
        label = 'Sağa';
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? s.color.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive ? s.color.withValues(alpha: 0.5) : Colors.transparent,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(s.icon,
              size: 22,
              color: isActive ? s.color : s.color.withValues(alpha: 0.45)),
          const SizedBox(height: 3),
          Icon(arrowIcon,
              size: 14,
              color: isActive ? s.color : s.color.withValues(alpha: 0.35)),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: isActive ? s.color : s.color.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Orta büyük ok göstergesi ─────────────────────────────
  Widget _buildSwipeArrow() {
    if (_lastSwipeDir == null) {
      // Animasyonlu ipucu okları (dört yön)
      return Opacity(
        opacity: 0.08,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
                top: 50,
                child: Icon(Icons.keyboard_arrow_up_rounded,
                    size: 48, color: _currentShape.color)),
            Positioned(
                bottom: 50,
                child: Icon(Icons.keyboard_arrow_down_rounded,
                    size: 48, color: _currentShape.color)),
            Positioned(
                left: 30,
                child: Icon(Icons.keyboard_arrow_left_rounded,
                    size: 48, color: _currentShape.color)),
            Positioned(
                right: 30,
                child: Icon(Icons.keyboard_arrow_right_rounded,
                    size: 48, color: _currentShape.color)),
          ],
        ),
      );
    }

    // Swipe yönü göster (kısa süreli)
    IconData arrowIcon;
    switch (_lastSwipeDir!) {
      case SwipeDirection.up:
        arrowIcon = Icons.arrow_upward_rounded;
        break;
      case SwipeDirection.down:
        arrowIcon = Icons.arrow_downward_rounded;
        break;
      case SwipeDirection.left:
        arrowIcon = Icons.arrow_back_rounded;
        break;
      case SwipeDirection.right:
        arrowIcon = Icons.arrow_forward_rounded;
        break;
    }

    return AnimatedBuilder(
      animation: _flashAnim,
      builder: (_, __) => Opacity(
        opacity: (1 - _flashAnim.value) * 0.8,
        child: Icon(
          arrowIcon,
          size: 80,
          color: _lastWasCorrect
              ? const Color(0xFF059669)
              : const Color(0xFFEF4444),
        ),
      ),
    );
  }

  // ─── Şekil kartı ──────────────────────────────────────────
  Widget _buildShapeCard(bool isDark) {
    return Container(
      width: 170,
      height: 170,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border.all(
          color: _currentShape.color.withValues(alpha: 0.5),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: _currentShape.color.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        _currentShape.icon,
        size: 90,
        color: _currentShape.color,
      ),
    );
  }

  // ─── Combo popup ──────────────────────────────────────────
  Widget _buildComboPopup(_ComboPopup popup) {
    return Positioned(
      top: 120,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: AnimatedBuilder(
            animation: _comboController,
            builder: (_, __) => Opacity(
              opacity: _comboFade.value.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: _comboScale.value,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: popup.color.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: popup.color.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    popup.text,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
