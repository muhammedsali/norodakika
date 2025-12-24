import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ReflexTapGame extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;
  final bool isPaused;

  const ReflexTapGame({
    super.key,
    required this.onComplete,
    required this.isPaused,
  });

  @override
  State<ReflexTapGame> createState() => _ReflexTapGameState();
}

class _ReflexTapGameState extends State<ReflexTapGame> with TickerProviderStateMixin {
  static const int gameDuration = 30;
  static const int minDelayMs = 500;
  static const int maxDelayMs = 2500;

  GameState _gameState = GameState.idle;
  int _score = 0;
  int _timeRemaining = gameDuration;
  int _combo = 0;
  double _multiplier = 1.0;
  int _totalTaps = 0;
  int _correctTaps = 0;
  int _bestReactionTime = 9999;
  List<int> _reactionTimes = [];
  int _maxCombo = 0;
  bool _isPaused = false;

  bool _isTargetVisible = false;
  DateTime? _tapStartTime;
  Timer? _gameLoopTimer;
  Timer? _targetTimer;

  String _feedbackText = "";
  Color _feedbackColor = Colors.transparent;
  int? _lastReactionTime;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  void _resumeTimers() {
    _gameLoopTimer?.cancel();
    _targetTimer?.cancel();

    _gameLoopTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused || !mounted) return;
      if (_timeRemaining > 0) {
        setState(() => _timeRemaining--);
      } else {
        _endGame();
      }
    });

    _scheduleNextTarget();
  }

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_glowController);

    _isPaused = widget.isPaused;

    if (!_isPaused) {
      _startGame();
    }
  }

  @override
  void didUpdateWidget(covariant ReflexTapGame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPaused != widget.isPaused) {
      _isPaused = widget.isPaused;
      if (_isPaused) {
        _gameLoopTimer?.cancel();
        _targetTimer?.cancel();
      } else {
        if (_gameState == GameState.playing) {
          _resumeTimers();
        }
      }
    }
  }

  @override
  void dispose() {
    _gameLoopTimer?.cancel();
    _targetTimer?.cancel();
    _shakeController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _gameState = GameState.playing;
      _score = 0;
      _timeRemaining = gameDuration;
      _combo = 0;
      _multiplier = 1.0;
      _feedbackText = "";
      _lastReactionTime = null;
      _isTargetVisible = false;
      _maxCombo = 0;
      _reactionTimes = [];
      _bestReactionTime = 9999;
    });

    _gameLoopTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused || !mounted) return;
      if (_timeRemaining > 0) {
        setState(() => _timeRemaining--);
      } else {
        _endGame();
      }
    });

    _scheduleNextTarget();
  }

  void _endGame() {
    _gameLoopTimer?.cancel();
    _targetTimer?.cancel();
    setState(() {
      _gameState = GameState.finished;
      _isTargetVisible = false;
    });

    if (widget.onComplete != null) {
      final durationSeconds = gameDuration;
      final successRate = _totalTaps == 0 ? 0.0 : _correctTaps / _totalTaps;

      widget.onComplete({
        'score': _score.toDouble(),
        'successRate': successRate,
        'duration': durationSeconds,
      });
    }
  }

  void _scheduleNextTarget() {
    if (_timeRemaining <= 0 || _isPaused || !mounted) return;

    final randomDelay = minDelayMs + Random().nextInt(maxDelayMs - minDelayMs);

    _targetTimer = Timer(Duration(milliseconds: randomDelay), () {
      if (mounted && _gameState == GameState.playing) {
        setState(() {
          _isTargetVisible = true;
          _tapStartTime = DateTime.now();
        });
      }
    });
  }

  void _handleTap() {
    if (_gameState != GameState.playing || _isPaused) return;

    setState(() {
      _totalTaps++;
    });

    if (!_isTargetVisible) {
      HapticFeedback.heavyImpact();
      _shakeController.forward(from: 0.0);

      setState(() {
        _score = max(0, _score - 500);
        _combo = 0;
        _multiplier = 1.0;
        _feedbackText = "ÇOK ERKEN!";
        _feedbackColor = Colors.redAccent;
      });

      _targetTimer?.cancel();
      _scheduleNextTarget();
      return;
    }

    final reactionTime = DateTime.now().difference(_tapStartTime!).inMilliseconds;

    HapticFeedback.lightImpact();

    _reactionTimes.add(reactionTime);
    if (reactionTime < _bestReactionTime) {
      _bestReactionTime = reactionTime;
    }

    _updateScoreAndCombo(reactionTime);

    setState(() {
      _isTargetVisible = false;
      _lastReactionTime = reactionTime;
    });

    _scheduleNextTarget();
  }

  void _updateScoreAndCombo(int ms) {
    int baseScore = max(0, 1000 - ms);

    setState(() {
      if (ms < 400) {
        _multiplier = 1.5;
        _correctTaps++;
        _combo++;
        if (_combo > _maxCombo) {
          _maxCombo = _combo;
        }
      } else {
        _multiplier = 1.0;
        _combo = 0;
      }

      _score += (baseScore * _multiplier).toInt();

      if (ms < 200) {
        _feedbackText = "EFSANE!";
        _feedbackColor = Colors.purpleAccent;
      } else if (ms < 300) {
        _feedbackText = "MÜKEMMEL!";
        _feedbackColor = Colors.greenAccent;
      } else if (ms < 400) {
        _feedbackText = "İYİ!";
        _feedbackColor = Colors.blueAccent;
      } else {
        _feedbackText = "YAVAŞ...";
        _feedbackColor = Colors.orangeAccent;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6);
    final panelColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final titleColor = isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final textSecondary = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    final int? averageReaction = _reactionTimes.isEmpty
        ? null
        : (_reactionTimes.reduce((a, b) => a + b) / _reactionTimes.length).round();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildHUD(isDark, panelColor, titleColor, textSecondary),
              const Spacer(),
              Stack(
                alignment: Alignment.center,
                children: [
                  if (_gameState == GameState.finished) _buildEndScreen(isDark, panelColor, titleColor, textSecondary),
                  if (_gameState == GameState.playing) _buildGameButton(isDark, textSecondary),
                ],
              ),
              const Spacer(),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: _gameState == GameState.playing && _lastReactionTime != null
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "$_lastReactionTime ms",
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: titleColor,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _feedbackText,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _feedbackColor,
                              letterSpacing: 1.5,
                            ),
                          ),
                          if (averageReaction != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Ortalama: ',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 13,
                                      color: textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '${averageReaction} ms',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: titleColor,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  if (_combo > 0) ...[
                                    Text(
                                      'Seri: ',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 13,
                                        color: textSecondary,
                                      ),
                                    ),
                                    Text(
                                      'x$_combo',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHUD(bool isDark, Color panelColor, Color titleColor, Color textSecondary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem("SÜRE", "$_timeRemaining", Icons.timer, titleColor, textSecondary),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _combo > 1 ? 1.0 : 0.0,
            child: Column(
              children: [
                Text("COMBO", style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
                Text("x$_multiplier", style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.orangeAccent, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          _buildStatItem("SKOR", "$_score", Icons.emoji_events, titleColor, textSecondary),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color titleColor, Color textSecondary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: textSecondary),
            const SizedBox(width: 4),
            Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.bold, color: textSecondary)),
          ],
        ),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
      ],
    );
  }

  Widget _buildGameButton(bool isDark, Color textSecondary) {
    return AnimatedBuilder(
      animation: Listenable.merge([_shakeAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(sin(_shakeController.value * pi * 8) * _shakeAnimation.value, 0),
          child: GestureDetector(
            onTapDown: (_) => _handleTap(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _isTargetVisible
                    ? LinearGradient(
                        colors: [
                          const Color(0xFF10B981),
                          const Color(0xFF059669),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF374151), const Color(0xFF1F2937)]
                            : [const Color(0xFFF3F4F6), const Color(0xFFE5E7EB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                boxShadow: _isTargetVisible
                    ? [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(_glowAnimation.value),
                          blurRadius: 50,
                          spreadRadius: 10,
                        )
                      ]
                    : [],
              ),
              child: Center(
                child: _isTargetVisible
                    ? Text(
                        "BAS!",
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bolt, color: textSecondary, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            "BEKLE",
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEndScreen(bool isDark, Color panelColor, Color titleColor, Color textSecondary) {
    int avgSpeed = _reactionTimes.isEmpty ? 0 : (_reactionTimes.reduce((a, b) => a + b) / _reactionTimes.length).round();
    
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
            blurRadius: 40,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("OYUN BİTTİ", style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.bold, color: titleColor)),
          const SizedBox(height: 16),
          Text("$_score", style: GoogleFonts.spaceGrotesk(fontSize: 64, fontWeight: FontWeight.w900, color: Colors.indigo, height: 1)),
          Text("PUAN", style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.bold, color: textSecondary, letterSpacing: 2)),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statBox("En İyi", "${_bestReactionTime == 9999 ? 0 : _bestReactionTime}ms", isDark, titleColor, textSecondary),
              _statBox("Ortalama", "${avgSpeed}ms", isDark, titleColor, textSecondary),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statBox("Kombo", "x$_maxCombo", isDark, titleColor, textSecondary),
              _statBox("İsabet", "${_totalTaps == 0 ? 0 : ((_correctTaps / _totalTaps) * 100).round()}%", isDark, titleColor, textSecondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value, bool isDark, Color titleColor, Color textSecondary) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 12, color: textSecondary)),
        Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.bold, color: titleColor)),
      ],
    );
  }
}

enum GameState { idle, playing, finished }
