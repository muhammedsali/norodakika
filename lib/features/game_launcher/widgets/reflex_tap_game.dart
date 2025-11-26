import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const ReflexGameApp());
}

class ReflexGameApp extends StatelessWidget {
  const ReflexGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reflex Pro',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        primarySwatch: Colors.indigo,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF111827),
      ),
      themeMode: ThemeMode.system,
      home: ReflexGameScreen(isPaused: false),
    );
  }
}

class ReflexGameScreen extends StatefulWidget {
  final bool isPaused;

  const ReflexGameScreen({super.key, required this.isPaused});

  @override
  State<ReflexGameScreen> createState() => _ReflexGameScreenState();
}

class _ReflexGameScreenState extends State<ReflexGameScreen> with TickerProviderStateMixin {
  // Game Constants
  static const int gameDuration = 30;
  static const int minDelayMs = 500;
  static const int maxDelayMs = 2000;

  // State Variables
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

  // Target Logic
  bool _isTargetVisible = false;
  DateTime? _tapStartTime;
  Timer? _gameLoopTimer;
  Timer? _targetTimer;

  // Feedback UI
  String _feedbackText = "";
  Color _feedbackColor = Colors.transparent;
  int? _lastReactionTime;

  // Animation Controllers
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _pulseController;

  void _resumeTimers() {
    // Süre kaldığı yerden devam etsin
    _gameLoopTimer?.cancel();
    _targetTimer?.cancel();

    _gameLoopTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) return;
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

    // Shake Animation Setup (For Penalty)
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);

    // Pulse Animation (For Idle State breathing effect)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _isPaused = widget.isPaused;

    // Ekran açılır açılmaz oyunu başlat (pause değilse)
    if (!_isPaused) {
      _startGame();
    }
  }

  @override
  void didUpdateWidget(covariant ReflexGameScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPaused != widget.isPaused) {
      _isPaused = widget.isPaused;
      if (_isPaused) {
        // Zamanlayıcıları durdur
        _gameLoopTimer?.cancel();
        _targetTimer?.cancel();
      } else {
        // Devam et: süre kaldığı yerden aksın
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
    super.dispose();
  }

  // --- GAME LOGIC ---

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
    });

    // Countdown Timer
    _gameLoopTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) return;
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
  }

  void _scheduleNextTarget() {
    if (_timeRemaining <= 0 || _isPaused) return;

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
      _combo++;
      _totalTaps++;
    });

    // --- CASE 1: EARLY TAP (PENALTY) ---
    if (!_isTargetVisible) {
      HapticFeedback.heavyImpact(); // Titreşim
      _shakeController.forward(from: 0.0); // Ekranı salla

      setState(() {
        _score = max(0, _score - 500);
        _combo = 0;
        _multiplier = 1.0;
        _feedbackText = "ÇOK ERKEN!";
        _feedbackColor = Colors.redAccent;
      });

      // Spam engellemek için mevcut timer'ı iptal edip yeniden planla
      _targetTimer?.cancel();
      _scheduleNextTarget();
      return;
    }

    // --- CASE 2: SUCCESSFUL TAP ---
    final reactionTime = DateTime.now().difference(_tapStartTime!).inMilliseconds;

    HapticFeedback.lightImpact();

    // Update Stats
    _reactionTimes.add(reactionTime);
    if (reactionTime < (_lastReactionTime ?? 9999)) {
      _lastReactionTime = reactionTime;
    }

    // Logic Calculation
    _updateScoreAndCombo(reactionTime);

    // UI Updates
    setState(() {
      _isTargetVisible = false;
    });

    _scheduleNextTarget();
  }

  void _updateScoreAndCombo(int ms) {
    // Score Formula: Max(0, 1000 - ms) * multiplier
    int baseScore = max(0, 1000 - ms);

    setState(() {
      // Combo Logic
      if (ms < 400) {
        _multiplier = 1.5;
        _correctTaps++;
        if (_combo > _maxCombo) {
          _maxCombo = _combo;
        }
      } else {
        _multiplier = 1.0;
      }

      _score += (baseScore * _multiplier).toInt();

      // Feedback Text
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

  // --- UI WIDGETS ---

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textSecondary =
        isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    final int? averageReaction = _reactionTimes.isEmpty
        ? null
        : (_reactionTimes.reduce((a, b) => a + b) / _reactionTimes.length)
            .round();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // HUD (Heads Up Display)
              _buildHUD(isDark),

              const Spacer(),

              // MAIN GAME AREA
              Stack(
                alignment: Alignment.center,
                children: [
                  if (_gameState == GameState.finished) _buildEndScreen(isDark),
                  if (_gameState == GameState.playing) _buildGameButton(isDark),
                ],
              ),

              const Spacer(),

              // FEEDBACK TEXT AREA
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
                              color: isDark ? Colors.white : Colors.black87,
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
                                      color: isDark
                                          ? const Color(0xFFF9FAFB)
                                          : const Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
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
                                      color: isDark
                                          ? const Color(0xFFF9FAFB)
                                          : const Color(0xFF111827),
                                    ),
                                  ),
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

  Widget _buildHUD(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem("SÜRE", "$_timeRemaining", Icons.timer, isDark),

          // Animated Combo
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _combo > 1 ? 1.0 : 0.0,
            child: Column(
              children: [
                Text("COMBO", style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.indigo)),
                Text("x$_multiplier", style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.indigoAccent, fontStyle: FontStyle.italic)),
              ],
            ),
          ),

          _buildStatItem("SKOR", "$_score", Icons.emoji_events, isDark),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          ],
        ),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildGameButton(bool isDark) {
    // Shake animation wrapper
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(sin(_shakeController.value * pi * 8) * 8, 0), // Basit shake matematiği
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) => _handleTap(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: _isTargetVisible
                ? const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)], // Emerald Green
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF374151), const Color(0xFF1F2937)] // Dark Gray
                        : [const Color(0xFFF3F4F6), const Color(0xFFE5E7EB)], // Light Gray
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            boxShadow: _isTargetVisible
                ? [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(0.6),
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
                      const Icon(Icons.bolt, color: Colors.grey, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        "BEKLE",
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartScreen(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937).withOpacity(0.9) : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.indigo.withOpacity(0.1)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 30)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("REFLEX PRO", style: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.indigo)),
          const SizedBox(height: 16),
          _infoRow(Icons.bolt, "Hızlı bas = Çok Puan", isDark),
          const SizedBox(height: 8),
          _infoRow(Icons.warning_amber_rounded, "Erken bas = -500 Ceza", isDark, isWarning: true),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _startGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text("BAŞLA", style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildEndScreen(bool isDark) {
    int avgSpeed = _reactionTimes.isEmpty ? 0 : (_reactionTimes.reduce((a, b) => a + b) / _reactionTimes.length).round();
    
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937).withOpacity(0.95) : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 40)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("OYUN BİTTİ", style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 16),
          Text("$_score", style: GoogleFonts.spaceGrotesk(fontSize: 64, fontWeight: FontWeight.w900, color: Colors.indigo, height: 1)),
          Text("PUAN", style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 2)),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statBox("En İyi", "${_bestReactionTime == 9999 ? 0 : _bestReactionTime}ms", isDark),
              _statBox("Ortalama", "${avgSpeed}ms", isDark),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statBox("Kombo", "x$_maxCombo", isDark),
              _statBox("İsabet", "${_totalTaps == 0 ? 0 : ((_correctTaps / _totalTaps) * 100).round()}%", isDark),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _startGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text("TEKRAR OYNA", style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, bool isDark, {bool isWarning = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: isWarning ? Colors.red : Colors.green),
        const SizedBox(width: 8),
        Text(text, style: GoogleFonts.spaceGrotesk(color: isDark ? Colors.white70 : Colors.black87)),
      ],
    );
  }

  Widget _statBox(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 12, color: Colors.grey)),
        Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
      ],
    );
  }
}

enum GameState { idle, playing, finished }

// Basit wrapper: mevcut ReflexGameScreen'i GamePlayScreen içinde kullanabilmek için
class ReflexTapGame extends StatelessWidget {
  final Function(Map<String, dynamic>) onComplete;
  final bool isPaused;

  const ReflexTapGame({
    super.key,
    required this.onComplete,
    required this.isPaused,
  });

  @override
  Widget build(BuildContext context) {
    // Şimdilik sadece ReflexGameScreen'i gösteriyoruz.
    // İleride istenirse onComplete entegrasyonu bu ekrana eklenebilir.
    return ReflexGameScreen(isPaused: isPaused);
  }
}