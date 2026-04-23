import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Model ───────────────────────────────────────────────────────────────────

class _FocusDot {
  final String id;
  final Color color;
  final bool isTarget;
  final DateTime spawnTime;
  double xFraction; // 0.0 – 1.0 within game area

  _FocusDot({
    required this.id,
    required this.color,
    required this.isTarget,
    required this.spawnTime,
    required this.xFraction,
  });
}

class _ComboPopup {
  final String label;
  final Color color;
  final Offset position;
  final DateTime createdAt;

  _ComboPopup({
    required this.label,
    required this.color,
    required this.position,
    required this.createdAt,
  });
}

// ─── Widget ──────────────────────────────────────────────────────────────────

class FocusLineGame extends StatefulWidget {
  final void Function(Map<String, dynamic>) onComplete;
  final bool isPaused;

  const FocusLineGame({
    super.key,
    required this.onComplete,
    required this.isPaused,
  });

  @override
  State<FocusLineGame> createState() => _FocusLineGameState();
}

class _FocusLineGameState extends State<FocusLineGame>
    with TickerProviderStateMixin {
  // ── Constants ──────────────────────────────────────────────────────────────
  static const int _initialSeconds = 45;
  static const int _levelBonusSeconds = 12;
  static const int _maxLives = 3;
  static const int _baseSpawnMs = 1100;
  static const int _minSpawnMs = 380;
  static const int _dotLifetimeMs = 3500; // hedef bu süreden sonra kaybolur
  static const double _targetSpawnChance = 0.38; // %38 hedef
  static const int _dotSize = 36;

  static const List<Color> _palette = [
    Color(0xFF3B82F6), // blue
    Color(0xFFEF4444), // red
    Color(0xFF22C55E), // green
    Color(0xFFF97316), // orange
    Color(0xFFA855F7), // purple
    Color(0xFFEC4899), // pink
  ];

  // ── State ──────────────────────────────────────────────────────────────────
  final Random _rng = Random();

  late AnimationController _pulseCtrl;
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;
  late AnimationController _levelBannerCtrl;
  late Animation<double> _levelBannerAnim;

  Timer? _countdownTimer;
  Timer? _spawnTimer;
  Timer? _dotExpiryTimer; // her 200ms'de expired dotları temizle

  late ValueNotifier<int> _timeNotifier;

  int _totalSeconds = _initialSeconds;
  int _level = 1;
  int _targetsToClear = 5;
  int _clearedInLevel = 0;
  int _score = 0;
  int _lives = _maxLives;
  int _combo = 0;
  int _bestCombo = 0;
  int _correctHits = 0;
  int _wrongHits = 0;
  int _missedTargets = 0;
  int _spawnMs = _baseSpawnMs;

  Color _targetColor = _palette[0];
  final List<_FocusDot> _dots = [];
  final List<_ComboPopup> _popups = [];

  bool _showLevelBanner = false;

  // ── Init / Dispose ─────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _timeNotifier = ValueNotifier<int>(_initialSeconds);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 12)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeCtrl);

    _levelBannerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _levelBannerAnim = CurvedAnimation(
      parent: _levelBannerCtrl,
      curve: Curves.elasticOut,
    );

    _pickTargetColor();
    if (!widget.isPaused) _startTimers();
  }

  @override
  void didUpdateWidget(covariant FocusLineGame old) {
    super.didUpdateWidget(old);
    if (old.isPaused != widget.isPaused) {
      if (widget.isPaused) {
        _pauseTimers();
      } else if (_timeNotifier.value > 0) {
        _startTimers();
      }
    }
  }

  @override
  void dispose() {
    _pauseTimers();
    _dotExpiryTimer?.cancel();
    _pulseCtrl.dispose();
    _shakeCtrl.dispose();
    _levelBannerCtrl.dispose();
    _timeNotifier.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _pickTargetColor() {
    final prev = _targetColor;
    Color next;
    do {
      next = _palette[_rng.nextInt(_palette.length)];
    } while (next == prev && _palette.length > 1);
    _targetColor = next;
  }

  void _pauseTimers() {
    _countdownTimer?.cancel();
    _spawnTimer?.cancel();
    _dotExpiryTimer?.cancel();
  }

  void _startTimers() {
    _pauseTimers();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _timeNotifier.value--;
      if (_timeNotifier.value <= 0) _finishGame();
    });

    _restartSpawnTimer();

    _dotExpiryTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!mounted || widget.isPaused) return;
      _expireOldDots();
    });
  }

  void _restartSpawnTimer() {
    _spawnTimer?.cancel();
    _spawnTimer = Timer.periodic(Duration(milliseconds: _spawnMs), (_) {
      if (!mounted || _timeNotifier.value <= 0 || widget.isPaused) return;
      _spawnDot();
    });
  }

  // ── Spawn Logic ────────────────────────────────────────────────────────────

  void _spawnDot() {
    final isTarget = _rng.nextDouble() < _targetSpawnChance;

    // Hedef renk dışında her seferinde farklı bir renk seç
    Color color;
    if (isTarget) {
      color = _targetColor;
    } else {
      final others = _palette.where((c) => c != _targetColor).toList();
      color = others[_rng.nextInt(others.length)];
    }

    // Boş bir X aralığı bul (çakışma önleme)
    double x = _safeXFraction();

    setState(() {
      _dots.add(_FocusDot(
        id: '${DateTime.now().microsecondsSinceEpoch}',
        color: color,
        isTarget: isTarget,
        spawnTime: DateTime.now(),
        xFraction: x,
      ));

      // Ekranda max 14 dot
      if (_dots.length > 14) {
        final overflow = _dots.removeAt(0);
        if (overflow.isTarget) _handleMissedTarget();
      }
    });
  }

  double _safeXFraction() {
    // 10 deneme ile çakışmayan yer bul, yoksa rastgele
    for (int i = 0; i < 10; i++) {
      final candidate = _rng.nextDouble() * 0.85 + 0.05; // 5%–90%
      final tooClose = _dots.any((d) => (d.xFraction - candidate).abs() < 0.08);
      if (!tooClose) return candidate;
    }
    return _rng.nextDouble() * 0.85 + 0.05;
  }

  void _expireOldDots() {
    final now = DateTime.now();
    final expired = _dots
        .where((d) =>
            d.isTarget &&
            now.difference(d.spawnTime).inMilliseconds > _dotLifetimeMs)
        .toList();

    if (expired.isEmpty) return;

    setState(() {
      for (final dot in expired) {
        _dots.remove(dot);
        _handleMissedTarget();
      }
    });
  }

  void _handleMissedTarget() {
    _missedTargets++;
    _combo = 0;
    _lives = max(0, _lives - 1);
    HapticFeedback.heavyImpact();
    _shakeCtrl.forward(from: 0.0);
    if (_lives <= 0) _finishGame();
  }

  // ── Tap Handler ────────────────────────────────────────────────────────────

  void _onDotTap(_FocusDot dot, Offset globalPos) {
    if (_timeNotifier.value <= 0 || widget.isPaused) return;

    setState(() {
      _dots.remove(dot);

      if (dot.isTarget) {
        HapticFeedback.lightImpact();
        _correctHits++;
        _combo++;
        _clearedInLevel++;
        if (_combo > _bestCombo) _bestCombo = _combo;

        final comboBonus = _combo > 1 ? (_combo - 1) * 15 : 0;
        _score += 100 + comboBonus + (_level * 5);

        // Combo popup
        _addComboPopup(globalPos);

        if (_clearedInLevel >= _targetsToClear) _levelUp();
      } else {
        HapticFeedback.mediumImpact();
        _wrongHits++;
        _combo = 0;
        _score = max(0, _score - 50);
        _shakeCtrl.forward(from: 0.0);
        _lives--;
        if (_lives <= 0) _finishGame();
      }
    });
  }

  void _addComboPopup(Offset pos) {
    String label;
    Color color;

    if (_combo >= 10) {
      label = '🔥 x$_combo LEGEND!';
      color = const Color(0xFFEC4899);
    } else if (_combo >= 5) {
      label = '⚡ x$_combo ULTRA';
      color = const Color(0xFFA855F7);
    } else if (_combo >= 3) {
      label = '✨ x$_combo HOT';
      color = const Color(0xFFF97316);
    } else if (_combo >= 2) {
      label = 'x$_combo';
      color = const Color(0xFF22C55E);
    } else {
      return; // x1 için popup yok
    }

    final popup = _ComboPopup(
      label: label,
      color: color,
      position: pos,
      createdAt: DateTime.now(),
    );
    _popups.add(popup);

    // 800ms sonra sil
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _popups.remove(popup));
    });
  }

  // ── Level Up ───────────────────────────────────────────────────────────────

  void _levelUp() {
    _level++;
    _targetsToClear = 5 + (_level - 1) * 3;
    _clearedInLevel = 0;
    _timeNotifier.value += _levelBonusSeconds;
    _totalSeconds += _levelBonusSeconds;
    _spawnMs = max(_minSpawnMs, (_spawnMs * 0.85).toInt());
    _pickTargetColor();
    _lives = min(_maxLives, _lives + 1);
    _dots.clear();

    // Banner
    _showLevelBanner = true;
    _levelBannerCtrl.forward(from: 0.0).then((_) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          _levelBannerCtrl.reverse().then((_) {
            if (mounted) setState(() => _showLevelBanner = false);
          });
        }
      });
    });

    _restartSpawnTimer();
  }

  // ── Finish ─────────────────────────────────────────────────────────────────

  void _finishGame() {
    _pauseTimers();
    final total = _correctHits + _wrongHits;
    widget.onComplete({
      'score': _score.toDouble(),
      'successRate': total == 0 ? 0.0 : _correctHits / total,
      'duration': _level * 15,
      'missedTargets': _missedTargets,
      'level': _level,
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0A0F1E) : const Color(0xFFF0F2F8);
    final panel = isDark ? const Color(0xFF131929) : Colors.white;
    final textPrimary = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _buildHeader(panel, textPrimary, textMuted, isDark),
                  const SizedBox(height: 12),
                  _buildTargetIndicator(),
                  const SizedBox(height: 12),
                  Expanded(child: _buildGameArea(isDark)),
                ],
              ),
            ),
            // Combo popups — global overlay
            ..._popups.map((p) => _buildComboPopup(p)),
            // Level banner
            if (_showLevelBanner) _buildLevelBanner(isDark),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(Color panel, Color textPrimary, Color textMuted, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title + level
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Focus Line',
                    style: GoogleFonts.orbitron(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _targetColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _targetColor.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          'SEVİYE $_level',
                          style: GoogleFonts.orbitron(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _targetColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$_clearedInLevel / $_targetsToClear',
                        style: GoogleFonts.orbitron(
                          fontSize: 11,
                          color: textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Lives + score
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: List.generate(_maxLives, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: AnimatedScale(
                          scale: i < _lives ? 1.0 : 0.6,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.favorite_rounded,
                            size: 22,
                            color: i < _lives
                                ? const Color(0xFFEF4444)
                                : textMuted.withValues(alpha: 0.3),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_score pts',
                    style: GoogleFonts.orbitron(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFBBF24),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress + timer
          ValueListenableBuilder<int>(
            valueListenable: _timeNotifier,
            builder: (_, t, __) {
              final frac = (_totalSeconds == 0)
                  ? 0.0
                  : (t / _totalSeconds).clamp(0.0, 1.0);
              final isLow = t <= 10;
              return Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: frac,
                      minHeight: 6,
                      backgroundColor: textMuted.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isLow ? const Color(0xFFEF4444) : _targetColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _stat(
                        isLow ? '⏱ $t s!' : '⏱ $t s',
                        isLow ? const Color(0xFFEF4444) : textMuted,
                      ),
                      if (_combo >= 2)
                        _stat('🔥 COMBO x$_combo', _comboColor(_combo)),
                      _stat('En iyi: x$_bestCombo', const Color(0xFFFBBF24)),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Color _comboColor(int c) {
    if (c >= 10) return const Color(0xFFEC4899);
    if (c >= 5) return const Color(0xFFA855F7);
    if (c >= 3) return const Color(0xFFF97316);
    return const Color(0xFF22C55E);
  }

  Widget _stat(String text, Color color) {
    return Text(
      text,
      style: GoogleFonts.orbitron(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  // ── Target Indicator ───────────────────────────────────────────────────────

  Widget _buildTargetIndicator() {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, __) {
        final glow = _pulseCtrl.value;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: _targetColor.withValues(alpha: 0.08 + glow * 0.08),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: _targetColor.withValues(alpha: 0.4 + glow * 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _targetColor.withValues(alpha: 0.15 + glow * 0.15),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _targetColor,
                  boxShadow: [
                    BoxShadow(
                      color: _targetColor.withValues(alpha: 0.6 + glow * 0.3),
                      blurRadius: 10,
                      spreadRadius: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'BU RENGİ DOKUN!',
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _targetColor,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Game Area ──────────────────────────────────────────────────────────────

  Widget _buildGameArea(bool isDark) {
    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (_, child) {
        return Transform.translate(
          offset: Offset(
            sin(_shakeCtrl.value * 3 * pi) * _shakeAnim.value,
            0,
          ),
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF060D1F) : const Color(0xFFFAFBFF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? const Color(0xFF1E2D4A)
                : const Color(0xFFDDE3F0),
            width: 1.5,
          ),
        ),
        child: LayoutBuilder(builder: (context, box) {
          final W = box.maxWidth;
          final H = box.maxHeight;
          final cy = H / 2;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Izgara çizgileri (arka plan)
              ...List.generate(5, (i) {
                final y = H * (i + 1) / 6;
                return Positioned(
                  left: 0,
                  right: 0,
                  top: y,
                  child: Container(
                    height: 1,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.03)
                        : Colors.black.withValues(alpha: 0.03),
                  ),
                );
              }),

              // Ana çizgi
              Positioned(
                left: 16,
                right: 16,
                top: cy - 2,
                height: 4,
                child: AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, __) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          _targetColor.withValues(alpha: 0.1),
                          _targetColor.withValues(alpha: 0.4 + _pulseCtrl.value * 0.2),
                          _targetColor.withValues(alpha: 0.1),
                        ]),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: _targetColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Dotlar
              for (final dot in List<_FocusDot>.from(_dots))
                _buildDot(dot, W, cy),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDot(_FocusDot dot, double areaWidth, double cy) {
    final left = (areaWidth - _dotSize) * dot.xFraction;

    // Hedef dot'lar için kalan süreye göre opacity
    double opacity = 1.0;
    if (dot.isTarget) {
      final age = DateTime.now().difference(dot.spawnTime).inMilliseconds;
      final life = _dotLifetimeMs.toDouble();
      opacity = (1.0 - (age / life)).clamp(0.3, 1.0);
    }

    return Positioned(
      left: left,
      top: cy - _dotSize / 2,
      child: GestureDetector(
        onTapDown: (d) => _onDotTap(dot, d.globalPosition),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 100),
          opacity: opacity,
          child: Container(
            width: _dotSize.toDouble(),
            height: _dotSize.toDouble(),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dot.color,
              boxShadow: [
                BoxShadow(
                  color: dot.color.withValues(alpha: dot.isTarget ? 0.8 : 0.4),
                  blurRadius: dot.isTarget ? 18 : 8,
                  spreadRadius: dot.isTarget ? 3 : 1,
                ),
              ],
            ),
            child: dot.isTarget
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white30,
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  // ── Combo Popup ────────────────────────────────────────────────────────────

  Widget _buildComboPopup(_ComboPopup p) {
    return Positioned(
      left: p.position.dx - 60,
      top: p.position.dy - 60,
      child: IgnorePointer(
        child: _ComboPopupWidget(popup: p),
      ),
    );
  }

  // ── Level Banner ───────────────────────────────────────────────────────────

  Widget _buildLevelBanner(bool isDark) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: ScaleTransition(
            scale: _levelBannerAnim,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              decoration: BoxDecoration(
                color: _targetColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _targetColor.withValues(alpha: 0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SEVİYE $_level',
                    style: GoogleFonts.orbitron(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+$_levelBonusSeconds saniye · Hız arttı!',
                    style: GoogleFonts.orbitron(
                      fontSize: 12,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Combo Popup Widget ───────────────────────────────────────────────────────

class _ComboPopupWidget extends StatefulWidget {
  final _ComboPopup popup;
  const _ComboPopupWidget({required this.popup});

  @override
  State<_ComboPopupWidget> createState() => _ComboPopupWidgetState();
}

class _ComboPopupWidgetState extends State<_ComboPopupWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnim = Tween<double>(begin: 0.5, end: 1.2)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.5)));

    _fadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.5, 1.0)),
    );

    _slideAnim = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1.5)).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 1.0)),
    );

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return SlideTransition(
          position: _slideAnim,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.popup.color,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: widget.popup.color.withValues(alpha: 0.6),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  widget.popup.label,
                  style: GoogleFonts.orbitron(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}