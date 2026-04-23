import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ══════════════════════════════════════════════════════════════════════════════
// ENUM (SABİT) DEĞERLER
// ══════════════════════════════════════════════════════════════════════════════

enum DotType { normal, ghost, bomb, shield, timeBoost, doubleScore }
enum LaneRow { top, mid, bottom }

// ══════════════════════════════════════════════════════════════════════════════
// MODELLER
// ══════════════════════════════════════════════════════════════════════════════

class _FocusDot {
  final String id;
  final Color color;
  final bool isTarget;
  final DotType type;
  final DateTime spawnTime;
  final LaneRow lane;
  double xFraction;
  bool popped = false;

  _FocusDot({
    required this.id,
    required this.color,
    required this.isTarget,
    required this.type,
    required this.spawnTime,
    required this.xFraction,
    required this.lane,
  });
}

class _Particle {
  Offset position;
  Offset velocity;
  Color color;
  double radius;
  double life;

  _Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.radius,
  });
}

class _ComboPopup {
  final String label;
  final Color color;
  final Offset position;
  _ComboPopup({required this.label, required this.color, required this.position});
}

class _FloatingText {
  final String text;
  final Color color;
  final Offset position;
  _FloatingText({required this.text, required this.color, required this.position});
}

// ══════════════════════════════════════════════════════════════════════════════
// PARÇACIK ÇİZİCİ (PAINTER)
// ══════════════════════════════════════════════════════════════════════════════

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.life.clamp(0.0, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(p.position, p.radius * p.life, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}

// ══════════════════════════════════════════════════════════════════════════════
// ANA OYUN WIDGET'I
// ══════════════════════════════════════════════════════════════════════════════

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

  // ── Sabitler ────────────────────────────────────────────────────────────────
  static const int _initialSeconds    = 45;
  static const int _levelBonusSec     = 10;
  static const int _maxLives          = 3;
  static const int _baseSpawnMs       = 1000;
  static const int _minSpawnMs        = 350;
  static const int _normalLifeMs      = 3200;
  static const int _powerupLifeMs     = 4500;
  static const int _dotSize           = 38;

  static const double _targetChance      = 0.35;
  static const double _ghostChance       = 0.07;
  static const double _bombChance        = 0.06;
  static const double _shieldChance      = 0.04;
  static const double _timeBoostChance   = 0.03;
  static const double _doubleChance      = 0.03;

  static const List<Color> _palette = [
    Color(0xFF38BDF8),
    Color(0xFFFF4D6D),
    Color(0xFF4ADE80),
    Color(0xFFFBBF24),
    Color(0xFFC084FC),
    Color(0xFFFB923C),
  ];

  // ── Animasyon Kontrolcüleri ─────────────────────────────────────────────────
  late AnimationController _pulseCtrl;
  late AnimationController _shakeCtrl;
  late Animation<double>   _shakeAnim;
  late AnimationController _levelCtrl;
  late Animation<double>   _levelAnim;
  late AnimationController _particleCtrl;
  late AnimationController _dangerCtrl;
  late AnimationController _doubleCtrl;

  // ── Zamanlayıcılar ──────────────────────────────────────────────────────────
  Timer? _countdownTimer;
  Timer? _spawnTimer;
  Timer? _expiryTimer;
  Timer? _doubleScoreTimer;

  // ── Bildiriciler ve Durum Yönetimi ──────────────────────────────────────────
  final Random _rng = Random();
  late ValueNotifier<int> _timeNotifier;

  int  _totalSeconds       = _initialSeconds;
  int  _level              = 1;
  int  _targetsToClear     = 5;
  int  _clearedInLevel     = 0;
  int  _score              = 0;
  int  _lives              = _maxLives;
  int  _combo              = 0;
  int  _bestCombo          = 0;
  int  _correctHits        = 0;
  int  _wrongHits          = 0;
  int  _missedTargets      = 0;
  int  _spawnMs            = _baseSpawnMs;
  bool _doubleScoreActive  = false;
  int  _doubleSecondsLeft  = 0;
  bool _streakShield       = false;
  bool _showLevelBanner    = false;

  Color _targetColor = _palette[0];

  final List<_FocusDot>    _dots         = [];
  final List<_Particle>    _particles    = [];
  final List<_ComboPopup>  _comboPopups  = [];
  final List<_FloatingText> _floatTexts  = [];

  // ── Başlatma (Init) ─────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _timeNotifier = ValueNotifier<int>(_initialSeconds);

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 850))
      ..repeat(reverse: true);

    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _shakeAnim = Tween<double>(begin: 0, end: 14)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeCtrl);

    _levelCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));
    _levelAnim = CurvedAnimation(parent: _levelCtrl, curve: Curves.elasticOut);

    _particleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 16))
      ..addListener(_tickParticles);

    _dangerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);

    _doubleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..repeat(reverse: true);

    _pickTargetColor();
    if (!widget.isPaused) _startTimers();
  }

  @override
  void didUpdateWidget(covariant FocusLineGame old) {
    super.didUpdateWidget(old);
    if (old.isPaused != widget.isPaused) {
      widget.isPaused ? _pauseTimers() : _startTimers();
    }
  }

  @override
  void dispose() {
    _pauseTimers();
    _doubleScoreTimer?.cancel();
    _pulseCtrl.dispose();
    _shakeCtrl.dispose();
    _levelCtrl.dispose();
    _particleCtrl.dispose();
    _dangerCtrl.dispose();
    _doubleCtrl.dispose();
    _timeNotifier.dispose();
    super.dispose();
  }

  // ── Yardımcı Fonksiyonlar ───────────────────────────────────────────────────

  void _pickTargetColor() {
    final prev = _targetColor;
    Color next;
    do { next = _palette[_rng.nextInt(_palette.length)]; }
    while (next == prev);
    _targetColor = next;
  }

  void _pauseTimers() {
    _countdownTimer?.cancel();
    _spawnTimer?.cancel();
    _expiryTimer?.cancel();
    _particleCtrl.stop();
  }

  void _startTimers() {
    _pauseTimers();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _timeNotifier.value--;
      if (_timeNotifier.value <= 0) _finishGame();
    });

    _restartSpawn();

    _expiryTimer = Timer.periodic(const Duration(milliseconds: 150), (_) {
      if (!mounted || widget.isPaused) return;
      _expireDots();
    });

    _particleCtrl.repeat();
  }

  void _restartSpawn() {
    _spawnTimer?.cancel();
    _spawnTimer = Timer.periodic(Duration(milliseconds: _spawnMs), (_) {
      if (!mounted || _timeNotifier.value <= 0 || widget.isPaused) return;
      _spawnDot();
    });
  }

  // ── Parçacıklar ─────────────────────────────────────────────────────────────

  void _tickParticles() {
    if (_particles.isEmpty) return;
    setState(() {
      for (final p in _particles) {
        p.position += p.velocity;
        p.velocity = Offset(p.velocity.dx * 0.93, p.velocity.dy * 0.93 + 0.28);
        p.life -= 0.034;
      }
      _particles.removeWhere((p) => p.life <= 0);
    });
  }

  void _burst(Offset globalPos, Color color, {int count = 14}) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(globalPos);
    for (int i = 0; i < count; i++) {
      final angle = _rng.nextDouble() * 2 * pi;
      final speed = 3.0 + _rng.nextDouble() * 6;
      _particles.add(_Particle(
        position: local,
        velocity: Offset(cos(angle) * speed, sin(angle) * speed - 2),
        color: color,
        radius: 3.0 + _rng.nextDouble() * 4,
      ));
    }
  }

  // ── Üretim (Spawn) ──────────────────────────────────────────────────────────

  void _spawnDot() {
    final roll = _rng.nextDouble();
    double cursor = 0;

    DotType type;
    Color color;
    bool isTarget;

    cursor += _ghostChance;
    if (roll < cursor) {
      type = DotType.ghost; color = _targetColor; isTarget = false;
    } else {
      cursor += _bombChance;
      if (roll < cursor) {
        type = DotType.bomb; color = const Color(0xFFFF1744); isTarget = false;
      } else {
        cursor += _shieldChance;
        if (roll < cursor) {
          type = DotType.shield; color = const Color(0xFF00E5FF); isTarget = false;
        } else {
          cursor += _timeBoostChance;
          if (roll < cursor) {
            type = DotType.timeBoost; color = const Color(0xFF69FF47); isTarget = false;
          } else {
            cursor += _doubleChance;
            if (roll < cursor) {
              type = DotType.doubleScore; color = const Color(0xFFFFD700); isTarget = false;
            } else {
              cursor += _targetChance;
              if (roll < cursor) {
                type = DotType.normal; color = _targetColor; isTarget = true;
              } else {
                type = DotType.normal;
                final others = _palette.where((c) => c != _targetColor).toList();
                color = others[_rng.nextInt(others.length)];
                isTarget = false;
              }
            }
          }
        }
      }
    }

    final lane = LaneRow.values[_rng.nextInt(LaneRow.values.length)];
    final x = _safeX(lane);

    setState(() {
      _dots.add(_FocusDot(
        id: '${DateTime.now().microsecondsSinceEpoch}_${_rng.nextInt(9999)}',
        color: color,
        isTarget: isTarget,
        type: type,
        spawnTime: DateTime.now(),
        xFraction: x,
        lane: lane,
      ));

      if (_dots.length > 18) {
        final overflow = _dots.removeAt(0);
        if (overflow.isTarget) _handleMissed(silent: true);
      }
    });
  }

  double _safeX(LaneRow lane) {
    final same = _dots.where((d) => d.lane == lane).toList();
    for (int i = 0; i < 12; i++) {
      final c = _rng.nextDouble() * 0.84 + 0.04;
      if (!same.any((d) => (d.xFraction - c).abs() < 0.09)) return c;
    }
    return _rng.nextDouble() * 0.84 + 0.04;
  }

  void _expireDots() {
    final now = DateTime.now();
    final expired = _dots.where((d) {
      if (d.popped) return false;
      final life = (d.isTarget) ? _normalLifeMs : (d.type != DotType.normal ? _powerupLifeMs : _normalLifeMs * 2);
      return now.difference(d.spawnTime).inMilliseconds > life;
    }).toList();
    if (expired.isEmpty) return;
    setState(() {
      for (final d in expired) {
        _dots.remove(d);
        if (d.isTarget) _handleMissed(silent: false);
      }
    });
  }

  void _handleMissed({required bool silent}) {
    _missedTargets++;
    _combo = 0;
    if (_streakShield) {
      _streakShield = false;
      _addFloatCenter('🛡 KALKAN KURTARDI!', const Color(0xFF00E5FF));
      return;
    }
    _lives = max(0, _lives - 1);
    if (!silent) {
      HapticFeedback.heavyImpact();
      _shakeCtrl.forward(from: 0.0);
    }
    if (_lives <= 0) _finishGame();
  }

  // ── Dokunma İşlemleri ───────────────────────────────────────────────────────

  void _onTap(_FocusDot dot, Offset globalPos) {
    if (_timeNotifier.value <= 0 || widget.isPaused || dot.popped) return;
    dot.popped = true;

    setState(() {
      _dots.remove(dot);
      _burst(globalPos, dot.color, count: dot.type == DotType.bomb ? 22 : 13);

      switch (dot.type) {
        case DotType.shield:
          _lives = min(_maxLives, _lives + 1);
          HapticFeedback.lightImpact();
          _addFloat('+1 ❤️', const Color(0xFFFF4D6D), globalPos);
          return;

        case DotType.timeBoost:
          _timeNotifier.value += 5;
          _totalSeconds += 5;
          HapticFeedback.lightImpact();
          _addFloat('+5s ⏱', const Color(0xFF4ADE80), globalPos);
          return;

        case DotType.doubleScore:
          _activateDouble();
          HapticFeedback.lightImpact();
          _addFloat('2X SKOR! ⚡', const Color(0xFFFFD700), globalPos);
          return;

        case DotType.bomb:
          HapticFeedback.heavyImpact();
          _combo = 0;
          _lives--;
          _addFloat('BOMB! 💣 -1❤️', const Color(0xFFFF1744), globalPos);
          _shakeCtrl.forward(from: 0.0);
          if (_lives <= 0) _finishGame();
          return;

        case DotType.ghost:
          HapticFeedback.mediumImpact();
          _wrongHits++;
          _combo = 0;
          _score = max(0, _score - 80);
          _addFloat('-80 👻 TUZAK!', Colors.white.withValues(alpha: 0.7), globalPos);
          _shakeCtrl.forward(from: 0.0);
          _lives--;
          if (_lives <= 0) _finishGame();
          return;

        case DotType.normal:
          if (dot.isTarget) {
            HapticFeedback.lightImpact();
            _correctHits++;
            _combo++;
            _clearedInLevel++;
            if (_combo > _bestCombo) _bestCombo = _combo;

            if (_combo > 0 && _combo % 5 == 0) {
              _streakShield = true;
              _addFloat('🛡 KORUMA KAZANILDI!', const Color(0xFF00E5FF), globalPos);
            }

            int pts = 100 + (_combo > 1 ? (_combo - 1) * 15 : 0) + _level * 5;
            if (_doubleScoreActive) pts *= 2;
            _score += pts;

            _addComboPopup(globalPos);
            _addFloat('+$pts', const Color(0xFFFBBF24), globalPos);

            if (_clearedInLevel >= _targetsToClear) _levelUp();
          } else {
            HapticFeedback.mediumImpact();
            _wrongHits++;
            _combo = 0;
            _score = max(0, _score - 50);
            _addFloat('-50 ✗', const Color(0xFFFF4D6D), globalPos);
            _shakeCtrl.forward(from: 0.0);
            _lives--;
            if (_lives <= 0) _finishGame();
          }
      }
    });
  }

  void _activateDouble() {
    _doubleScoreActive = true;
    _doubleSecondsLeft = 8;
    _doubleScoreTimer?.cancel();
    _doubleScoreTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _doubleSecondsLeft--;
        if (_doubleSecondsLeft <= 0) {
          _doubleScoreActive = false;
          _doubleScoreTimer?.cancel();
        }
      });
    });
  }

  void _addComboPopup(Offset pos) {
    if (_combo < 2) return;
    String label;
    Color color;
    if (_combo >= 15)     { label = '🌌 x$_combo GODLIKE'; color = const Color(0xFFFF4D6D); }
    else if (_combo >= 10){ label = '🔥 x$_combo LEGEND';  color = const Color(0xFFC084FC); }
    else if (_combo >= 7) { label = '⚡ x$_combo ULTRA';   color = const Color(0xFFFBBF24); }
    else if (_combo >= 4) { label = '✨ x$_combo HOT';     color = const Color(0xFFFB923C); }
    else                  { label = 'x$_combo';             color = const Color(0xFF4ADE80); }

    final p = _ComboPopup(label: label, color: color, position: pos);
    _comboPopups.add(p);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _comboPopups.remove(p));
    });
  }

  void _addFloat(String text, Color color, Offset pos) {
    final ft = _FloatingText(text: text, color: color, position: pos);
    _floatTexts.add(ft);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _floatTexts.remove(ft));
    });
  }

  void _addFloatCenter(String text, Color color) {
    final sz = MediaQuery.of(context).size;
    _addFloat(text, color, Offset(sz.width / 2, sz.height / 2));
  }

  void _levelUp() {
    _level++;
    _targetsToClear = 5 + (_level - 1) * 3;
    _clearedInLevel = 0;
    _timeNotifier.value += _levelBonusSec;
    _totalSeconds += _levelBonusSec;
    _spawnMs = max(_minSpawnMs, (_spawnMs * 0.82).toInt());
    _pickTargetColor();
    _lives = min(_maxLives, _lives + 1);
    _dots.clear();

    _showLevelBanner = true;
    _levelCtrl.forward(from: 0.0).then((_) {
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        _levelCtrl.reverse().then((_) {
          if (mounted) setState(() => _showLevelBanner = false);
        });
      });
    });

    _restartSpawn();
  }

  void _finishGame() {
    _pauseTimers();
    final total = _correctHits + _wrongHits;
    widget.onComplete({
      'score': _score.toDouble(),
      'successRate': total == 0 ? 0.0 : _correctHits / total,
      'duration': _level * 15,
      'missedTargets': _missedTargets,
      'level': _level,
      'bestCombo': _bestCombo,
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ARAYÜZ (BUILD)
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? const Color(0xFF080C18) : const Color(0xFFF0F2FA);
    final panel  = isDark ? const Color(0xFF101624) : Colors.white;
    final tPri   = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final tMut   = isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8);
    final isLow  = _timeNotifier.value <= 10;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            // Parçacık katmanı
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _ParticlePainter(_particles)),
              ),
            ),

            // İçerik
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildHeader(panel, tPri, tMut, isDark, isLow),
                  const SizedBox(height: 8),
                  _buildPowerupLegend(isDark),
                  const SizedBox(height: 8),
                  _buildTargetBar(),
                  const SizedBox(height: 8),
                  Expanded(child: _buildGameArea(isDark)),
                ],
              ),
            ),

            // Kombo açılır pencereleri
            ..._comboPopups.map((p) => Positioned(
                  left: p.position.dx - 70,
                  top:  p.position.dy - 70,
                  child: IgnorePointer(child: _ComboPopupWidget(popup: p)),
                )),

            // Yüzen metinler
            ..._floatTexts.map((ft) => Positioned(
                  left: ft.position.dx - 40,
                  top:  ft.position.dy - 30,
                  child: IgnorePointer(child: _FloatingTextWidget(ft: ft)),
                )),

            // Seviye banner'ı
            if (_showLevelBanner) _buildLevelBanner(),

            // Tehlike sınırı
            if (isLow)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _dangerCtrl,
                    builder: (_, __) => Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFFF4D6D)
                              .withValues(alpha: 0.2 + _dangerCtrl.value * 0.4),
                          width: 3,
                        ),
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

  // ── Üst Kısım (Header) ──────────────────────────────────────────────────────

  Widget _buildHeader(Color panel, Color tPri, Color tMut, bool isDark, bool isLow) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _targetColor.withValues(alpha: 0.1),
            blurRadius: 18, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FOCUS LINE',
                      style: GoogleFonts.orbitron(
                        fontSize: 18, fontWeight: FontWeight.w900,
                        color: tPri, letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        _levelBadge(),
                        const SizedBox(width: 8),
                        Text(
                          '$_clearedInLevel / $_targetsToClear hedef',
                          style: GoogleFonts.orbitron(
                            fontSize: 10, color: tMut, fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _livesRow(tMut),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (_doubleScoreActive)
                        AnimatedBuilder(
                          animation: _doubleCtrl,
                          builder: (_, __) => Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700)
                                  .withValues(alpha: 0.12 + _doubleCtrl.value * 0.18),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFFFD700), width: 1),
                            ),
                            child: Text(
                              '2X  ${_doubleSecondsLeft}s',
                              style: GoogleFonts.orbitron(
                                fontSize: 9, fontWeight: FontWeight.w800,
                                color: const Color(0xFFFFD700),
                              ),
                            ),
                          ),
                        ),
                      Text(
                        '$_score pts',
                        style: GoogleFonts.orbitron(
                          fontSize: 13, fontWeight: FontWeight.w800,
                          color: const Color(0xFFFBBF24),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder<int>(
            valueListenable: _timeNotifier,
            builder: (_, t, __) {
              final frac = (_totalSeconds == 0) ? 0.0 : (t / _totalSeconds).clamp(0.0, 1.0);
              return Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: frac,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isLow
                                  ? [const Color(0xFFFF4D6D), const Color(0xFFFF8C00)]
                                  : [_targetColor, _targetColor.withValues(alpha: 0.55)],
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: (isLow ? const Color(0xFFFF4D6D) : _targetColor)
                                    .withValues(alpha: 0.55),
                                blurRadius: 7,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _stat(isLow ? '⚠️ $t s!' : '⏱ $t s',
                          isLow ? const Color(0xFFFF4D6D) : tMut),
                      if (_combo >= 2)
                        _stat('🔥 ${_combo}x', _comboColor(_combo)),
                      _stat('🏆 EN İYİ: $_bestCombo', const Color(0xFFFBBF24)),
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

  Widget _levelBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          _targetColor.withValues(alpha: 0.3),
          _targetColor.withValues(alpha: 0.1),
        ]),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _targetColor.withValues(alpha: 0.6), width: 1),
      ),
      child: Text(
        'SEVİYE $_level',
        style: GoogleFonts.orbitron(
          fontSize: 9, fontWeight: FontWeight.w900,
          color: _targetColor, letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _livesRow(Color muted) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_streakShield)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, __) => Icon(
                Icons.shield_rounded,
                size: 18,
                color: const Color(0xFF00E5FF)
                    .withValues(alpha: 0.6 + _pulseCtrl.value * 0.4),
              ),
            ),
          ),
        ...List.generate(_maxLives, (i) => Padding(
          padding: const EdgeInsets.only(left: 3),
          child: AnimatedScale(
            scale: i < _lives ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.favorite_rounded, size: 20,
              color: i < _lives
                  ? const Color(0xFFFF4D6D)
                  : muted.withValues(alpha: 0.22),
            ),
          ),
        )),
      ],
    );
  }

  Widget _stat(String text, Color color) {
    return Text(
      text,
      style: GoogleFonts.orbitron(
        fontSize: 10, fontWeight: FontWeight.w700, color: color,
      ),
    );
  }

  Color _comboColor(int c) {
    if (c >= 15) return const Color(0xFFFF4D6D);
    if (c >= 10) return const Color(0xFFC084FC);
    if (c >= 7)  return const Color(0xFFFBBF24);
    if (c >= 4)  return const Color(0xFFFB923C);
    return const Color(0xFF4ADE80);
  }

  // ── Güçlendirici Açıklamaları ───────────────────────────────────────────────

  Widget _buildPowerupLegend(bool isDark) {
    final items = [
      ('👻', 'Hayalet\n(tuzak!)',    const Color(0xFF94A3B8)),
      ('💣', 'Bomba\n(-1❤️)',       const Color(0xFFFF4D6D)),
      ('🛡', 'Kalkan\n(+1❤️)',      const Color(0xFF00E5FF)),
      ('⏱', '+5sn\nBoost',          const Color(0xFF4ADE80)),
      ('⚡', '2X Skor\n8sn',        const Color(0xFFFFD700)),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((item) => Container(
          margin: const EdgeInsets.only(right: 6),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: item.$3.withValues(alpha: isDark ? 0.07 : 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: item.$3.withValues(alpha: 0.28), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item.$1, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 4),
              Text(
                item.$2,
                style: GoogleFonts.orbitron(
                  fontSize: 7, color: item.$3, fontWeight: FontWeight.w600, height: 1.3,
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  // ── Hedef Çubuğu ────────────────────────────────────────────────────────────

  Widget _buildTargetBar() {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: _targetColor.withValues(alpha: 0.07 + _pulseCtrl.value * 0.06),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: _targetColor.withValues(alpha: 0.35 + _pulseCtrl.value * 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _targetColor.withValues(alpha: 0.1 + _pulseCtrl.value * 0.12),
              blurRadius: 18, spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18, height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _targetColor,
                boxShadow: [BoxShadow(color: _targetColor.withValues(alpha: 0.7), blurRadius: 10, spreadRadius: 3)],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'BU RENGİ DOKUN!',
              style: GoogleFonts.orbitron(
                fontSize: 11, fontWeight: FontWeight.w800,
                color: _targetColor, letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Oyun Alanı ──────────────────────────────────────────────────────────────

  Widget _buildGameArea(bool isDark) {
    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (_, child) => Transform.translate(
        offset: Offset(sin(_shakeCtrl.value * 3 * pi) * _shakeAnim.value, 0),
        child: child,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF050A15) : const Color(0xFFF8FAFF),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark ? const Color(0xFF1A2540) : const Color(0xFFDDE3F0),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(color: _targetColor.withValues(alpha: 0.05), blurRadius: 20, spreadRadius: 2),
          ],
        ),
        child: LayoutBuilder(builder: (ctx, box) {
          final W = box.maxWidth;
          final H = box.maxHeight;
          final laneY = {
            LaneRow.top:    H * 0.22,
            LaneRow.mid:    H * 0.50,
            LaneRow.bottom: H * 0.78,
          };

          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // Şerit parlama çizgileri
              for (final e in laneY.entries)
                Positioned(
                  left: 18, right: 18,
                  top: e.value - 1.5, height: 3,
                  child: AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, __) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          _targetColor.withValues(alpha: 0.04),
                          _targetColor.withValues(alpha: 0.22 + _pulseCtrl.value * 0.14),
                          _targetColor.withValues(alpha: 0.04),
                        ]),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),

              // Şerit etiketleri
              for (final e in laneY.entries)
                Positioned(
                  left: 5, top: e.value - 7,
                  child: Text(
                    e.key == LaneRow.top ? 'A' : e.key == LaneRow.mid ? 'B' : 'C',
                    style: GoogleFonts.orbitron(
                      fontSize: 8,
                      color: _targetColor.withValues(alpha: 0.25),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

              // Noktalar
              for (final dot in List<_FocusDot>.from(_dots))
                _buildDotWidget(dot, W, laneY[dot.lane]!),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDotWidget(_FocusDot dot, double W, double cy) {
    final left = (W - _dotSize) * dot.xFraction;
    final age  = DateTime.now().difference(dot.spawnTime).inMilliseconds;
    final life = dot.isTarget ? _normalLifeMs : (dot.type != DotType.normal ? _powerupLifeMs : _normalLifeMs * 2);
    final lifeProgress = (1.0 - age / life).clamp(0.0, 1.0);
    final opacity      = dot.type == DotType.ghost ? 0.32 : lifeProgress.clamp(0.22, 1.0);

    final String? emoji = switch (dot.type) {
      DotType.bomb        => '💣',
      DotType.shield      => '🛡',
      DotType.timeBoost   => '⏱',
      DotType.doubleScore => '⚡',
      DotType.ghost       => '👻',
      DotType.normal      => null,
    };

    final bool isSpecial = emoji != null;
    final bgColor = isSpecial
        ? dot.color.withValues(alpha: 0.18)
        : dot.color;

    return Positioned(
      left: left,
      top:  cy - _dotSize / 2,
      child: GestureDetector(
        onTapDown: (d) => _onTap(dot, d.globalPosition),
        child: Opacity(
          opacity: opacity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Zamanlayıcı halkası
              if (dot.isTarget || isSpecial)
                SizedBox(
                  width:  _dotSize + 10.0,
                  height: _dotSize + 10.0,
                  child: CircularProgressIndicator(
                    value: lifeProgress,
                    strokeWidth: 2.5,
                    backgroundColor: dot.color.withValues(alpha: 0.14),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      dot.color.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              // Nokta gövdesi
              Container(
                width:  _dotSize.toDouble(),
                height: _dotSize.toDouble(),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: bgColor,
                  border: isSpecial
                      ? Border.all(color: dot.color, width: 2)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: dot.color.withValues(alpha: dot.isTarget ? 0.75 : 0.35),
                      blurRadius: dot.isTarget ? 20 : 10,
                      spreadRadius: dot.isTarget ? 3 : 1,
                    ),
                  ],
                ),
                child: emoji != null
                    ? Center(child: Text(emoji, style: const TextStyle(fontSize: _dotSize * 0.5)))
                    : dot.isTarget
                        ? Center(
                            child: Container(
                              width: 10, height: 10,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.38),
                              ),
                            ),
                          )
                        : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Seviye Banner'ı ─────────────────────────────────────────────────────────

  Widget _buildLevelBanner() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: ScaleTransition(
            scale: _levelAnim,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_targetColor, _targetColor.withValues(alpha: 0.65)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: _targetColor.withValues(alpha: 0.6),
                    blurRadius: 44, spreadRadius: 8,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '🎉  SEVİYE $_level',
                    style: GoogleFonts.orbitron(
                      fontSize: 26, fontWeight: FontWeight.w900,
                      color: Colors.white, letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '+$_levelBonusSec sn  ·  Hız arttı  ·  +❤️',
                    style: GoogleFonts.orbitron(
                      fontSize: 11, color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w500,
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

// ══════════════════════════════════════════════════════════════════════════════
// KOMBO AÇILIR PENCERE WIDGET'I
// ══════════════════════════════════════════════════════════════════════════════

class _ComboPopupWidget extends StatefulWidget {
  final _ComboPopup popup;
  const _ComboPopupWidget({required this.popup});
  @override
  State<_ComboPopupWidget> createState() => _ComboPopupWidgetState();
}

class _ComboPopupWidgetState extends State<_ComboPopupWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale, _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _scale = Tween<double>(begin: 0.4, end: 1.15)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.5)));
    _fade = Tween<double>(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.55, 1.0)));
    _slide = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1.8))
        .animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 1.0)));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: widget.popup.color,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: widget.popup.color.withValues(alpha: 0.7), blurRadius: 14, spreadRadius: 3)],
              ),
              child: Text(
                widget.popup.label,
                style: GoogleFonts.orbitron(
                  fontSize: 13, fontWeight: FontWeight.w900,
                  color: Colors.white, letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// YÜZEN METİN WIDGET'I
// ══════════════════════════════════════════════════════════════════════════════

class _FloatingTextWidget extends StatefulWidget {
  final _FloatingText ft;
  const _FloatingTextWidget({required this.ft});
  @override
  State<_FloatingTextWidget> createState() => _FloatingTextWidgetState();
}

class _FloatingTextWidgetState extends State<_FloatingTextWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fade = Tween<double>(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.4, 1.0)));
    _slide = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1.4))
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Text(
            widget.ft.text,
            style: GoogleFonts.orbitron(
              fontSize: 12, fontWeight: FontWeight.w800,
              color: widget.ft.color,
              shadows: [Shadow(color: widget.ft.color.withValues(alpha: 0.8), blurRadius: 8)],
            ),
          ),
        ),
      ),
    );
  }
}