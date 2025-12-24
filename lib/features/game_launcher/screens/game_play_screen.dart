import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../../../core/models/game_model.dart';
import '../../../core/models/attempt_model.dart';
import '../../../core/memory/memory_bank.dart';
// import '../../../services/local_storage_service.dart'; // Artık kullanılmıyor
import '../../../core/api/api_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/reflex_tap_game.dart';
import '../widgets/reflex_dash_game.dart';
import '../widgets/quick_math_game.dart';
import '../widgets/memory_board_game.dart';
import '../widgets/stroop_tap_game.dart';
import '../widgets/focus_line_game.dart';
import '../widgets/n_back_mini_game.dart';
import '../widgets/logic_puzzle_game.dart';
import '../widgets/recall_phase_game.dart';
import '../widgets/word_sprint_game.dart';
import '../widgets/sequence_memory_game.dart';
import '../widgets/odd_one_out_game.dart';

class GamePlayScreen extends ConsumerStatefulWidget {
  final GameModel game;
  final bool? isDarkOverride;

  const GamePlayScreen({
    super.key,
    required this.game,
    this.isDarkOverride,
  });

  @override
  ConsumerState<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends ConsumerState<GamePlayScreen>
    with SingleTickerProviderStateMixin {
  bool _isGameStarted = false;
  bool _isGameComplete = false;
  Map<String, dynamic>? _gameResult;
  int _runId = 0; // oyun tekrarları için
  bool _isPaused = false;
  bool _showLogo = true;
  late AnimationController _logoController;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _showLogoScreen();
  }

  void _showLogoScreen() {
    _logoController.forward();
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _logoController.reverse();
        Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _showLogo = false;
            });
            _startGame();
          }
        });
      }
    });
  }

  Future<void> _startGame() async {
    setState(() {
      _isGameStarted = true;
    });
  }

  Future<void> _onGameComplete(Map<String, dynamic> result) async {
    final userAsync = ref.read(currentUserProvider);
    final user = userAsync.value;
    
    if (user == null) return;

    final difficulty = await ref.read(firestoreServiceProvider).getGameDifficulty(
      userId: user.uid,
      gameId: widget.game.id,
    );

    setState(() {
      _isGameComplete = true;
      _gameResult = result;
    });

    // Attempt kaydet
    await _saveAttempt(result, difficulty, user.uid);
  }

  Future<void> _saveAttempt(
    Map<String, dynamic> result,
    double difficulty,
    String userId,
  ) async {
    try {
      final score = (result['score'] as num?)?.toDouble() ?? 0.0;
      final successRate = (result['successRate'] as num?)?.toDouble() ?? 0.0;
      final duration = (result['duration'] as int?) ?? 0;

      final attempt = AttemptModel(
        gameId: widget.game.id,
        userId: userId,
        score: score,
        successRate: successRate,
        difficulty: difficulty,
        duration: duration,
        timestamp: DateTime.now(),
        area: widget.game.area,
      );

      // Firestore'a kaydet
      await ref.read(firestoreServiceProvider).saveAttempt(attempt);

      // API'ye gönder (opsiyonel)
      try {
        await ApiService.submitAttempt(attempt);
      } catch (e) {
        // API hatası kritik değil
        print('API gönderim hatası: $e');
      }

      // Zorluk seviyesini güncelle
      final newDifficulty = MemoryBank.updateDifficulty(
        difficulty,
        successRate,
      );
      
      await ref.read(firestoreServiceProvider).updateGameDifficulty(
        userId: userId,
        gameId: widget.game.id,
        newDifficulty: newDifficulty,
      );
    } catch (e) {
      print('Attempt kaydetme hatası: $e');
    }
  }

  void _showResultDialog() {
    if (_gameResult == null) return;

    final score = (_gameResult!['score'] as num?)?.toDouble() ?? 0.0;
    final successRate = (_gameResult!['successRate'] as num?)?.toDouble() ?? 0.0;
    final duration = (_gameResult!['duration'] as num?)?.toInt() ?? 0;

    final baseTheme = Theme.of(context);
    final effectiveIsDark =
        widget.isDarkOverride ?? baseTheme.brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(effectiveIsDark ? 0.75 : 0.5),
      builder: (ctx) {
        final bgColor = effectiveIsDark
            ? const Color(0xFF1F2937)
            : Colors.white;
        final titleColor = effectiveIsDark
            ? const Color(0xFFF9FAFB)
            : const Color(0xFF111827);
        final textColor = effectiveIsDark
            ? const Color(0xFF9CA3AF)
            : const Color(0xFF6B7280);
        final borderColor = effectiveIsDark
            ? const Color(0xFF374151)
            : const Color(0xFFE5E7EB);

        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 420,
                  minHeight: 220,
                ),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: effectiveIsDark
                          ? Colors.black.withOpacity(0.6)
                          : Colors.black.withOpacity(0.15),
                      blurRadius: 40,
                      spreadRadius: 0,
                      offset: const Offset(0, 20),
                    ),
                  ],
                  border: Border.all(
                    color: borderColor,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Oyun tamamlandı',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Skor',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 13,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                score.toStringAsFixed(1),
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: titleColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Başarı oranı',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 13,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${(successRate * 100).toStringAsFixed(1)}%',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: titleColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Süre: ${duration.toString()} sn',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(ctx); // Dialog'u kapat
                              setState(() {
                                _isGameComplete = false;
                                _gameResult = null;
                                _isGameStarted = false;
                                _showLogo = true;
                                _runId++;
                              });
                              _showLogoScreen();
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: effectiveIsDark
                                    ? const Color(0xFF4B5563)
                                    : const Color(0xFF4F46E5),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              'Tekrar oyna',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: titleColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(ctx); // Dialog'u kapat
                                Navigator.pop(ctx); // Oyun ekranından çık
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4F46E5),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              child: Text(
                                'Ana ekrana dön',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Future<bool> _showExitConfirmDialog() async {
    // Oyun sonucu zaten gösteriliyorsa veya hiç başlamadıysa direkt çık
    if (!_isGameStarted || _isGameComplete) {
      return true;
    }

    final baseTheme = Theme.of(context);
    final effectiveIsDark =
        widget.isDarkOverride ?? baseTheme.brightness == Brightness.dark;
    final bgColor = effectiveIsDark
        ? const Color(0xFF1F2937)
        : Colors.white;
    final titleColor = effectiveIsDark
        ? const Color(0xFFF9FAFB)
        : const Color(0xFF111827);
    final textColor = effectiveIsDark
        ? const Color(0xFF9CA3AF)
        : const Color(0xFF6B7280);
    final borderColor = effectiveIsDark
        ? const Color(0xFF374151)
        : const Color(0xFFE5E7EB);

    setState(() {
      _isPaused = true;
    });

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(effectiveIsDark ? 0.75 : 0.5),
      builder: (ctx) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 420,
                  minHeight: 200,
                ),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: effectiveIsDark
                          ? Colors.black.withOpacity(0.6)
                          : Colors.black.withOpacity(0.15),
                      blurRadius: 40,
                      spreadRadius: 0,
                      offset: const Offset(0, 20),
                    ),
                  ],
                  border: Border.all(
                    color: borderColor,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Oyundan çıkmak istiyor musun?',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'İlerleyişin kaydedildi (varsa) fakat bu oyunu şimdi sonlandıracaksın.',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(ctx).pop(false); // oyuna devam et
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: effectiveIsDark
                                    ? const Color(0xFF4B5563)
                                    : const Color(0xFF4F46E5),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              'Devam et',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: titleColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(ctx).pop(true); // çıkışı onayla
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4F46E5),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              child: Text(
                                'Ana ekrana dön',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    // true => çıkışa izin ver, false/null => kal
    final shouldExit = result ?? false;

    if (!shouldExit) {
      // Oyuna devam
      setState(() {
        _isPaused = false;
      });
    }

    return shouldExit;
  }

  Widget _buildGameWidget() {
    if (!_isGameStarted) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (widget.game.id) {
      case 'REF01':
        return ReflexTapGame(
          key: ValueKey('reflex_$_runId'),
          onComplete: _onGameComplete,
          isPaused: _isPaused,
        );
      case 'REF02':
        return ReflexDashGame(
          key: ValueKey('reflexdash_$_runId'),
          onComplete: _onGameComplete,
          isPaused: _isPaused,
        );
      case 'NUM01':
        return QuickMathGame(
          key: ValueKey('quickmath_$_runId'),
          onComplete: _onGameComplete,
        );
      case 'MEM02':
        return MemoryBoardGame(
          key: ValueKey('memoryboard_$_runId'),
          onComplete: _onGameComplete,
        );
      case 'ATT01':
        return StroopTapGame(
          key: ValueKey('stroop_$_runId'),
          onComplete: _onGameComplete,
        );
      case 'ATT02':
        return FocusLineGame(
          key: ValueKey('focusline_$_runId'),
          onComplete: _onGameComplete,
        );
      case 'MEM01':
        return NBackMiniGame(
          key: ValueKey('nback_$_runId'),
          onComplete: _onGameComplete,
        );
      case 'LOG01':
        return LogicPuzzleGame(
          key: ValueKey('logic_$_runId'),
          onComplete: _onGameComplete,
        );
      case 'MEM03':
        return RecallPhaseGame(
          key: ValueKey('recall_$_runId'),
          onComplete: _onGameComplete,
        );
      case 'LANG02':
        return WordSprintGame(
          key: ValueKey('wordsprint_$_runId'),
          onComplete: _onGameComplete,
        );
      case 'MEM04':
        return SequenceMemoryGame(
          key: ValueKey('sequenceecho_$_runId'),
          onComplete: _onGameComplete,
        );
      case 'VIS02':
        return OddOneOutGame(
          key: ValueKey('oddone_$_runId'),
          onComplete: _onGameComplete,
        );
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${widget.game.name}',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Bu oyun yakında eklenecek!',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        );
    }
  }

  Map<String, dynamic> _getGameLogoData() {
    switch (widget.game.id) {
      case 'REF01':
        return {
          'icon': Icons.touch_app,
          'gradient': [Color(0xFFEF4444), Color(0xFFDC2626)],
          'emoji': '⚡',
        };
      case 'REF02':
        return {
          'icon': Icons.directions_run,
          'gradient': [Color(0xFF10B981), Color(0xFF059669)],
          'emoji': '🏃',
        };
      case 'ATT01':
        return {
          'icon': Icons.palette,
          'gradient': [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
          'emoji': '🎨',
        };
      case 'ATT02':
        return {
          'icon': Icons.remove,
          'gradient': [Color(0xFF06B6D4), Color(0xFF0891B2)],
          'emoji': '➖',
        };
      case 'MEM01':
        return {
          'icon': Icons.psychology,
          'gradient': [Color(0xFFEC4899), Color(0xFFDB2777)],
          'emoji': '🧠',
        };
      case 'LOG01':
        return {
          'icon': Icons.extension,
          'gradient': [Color(0xFFF59E0B), Color(0xFFD97706)],
          'emoji': '🧩',
        };
      case 'NUM01':
        return {
          'icon': Icons.calculate,
          'gradient': [Color(0xFF3B82F6), Color(0xFF2563EB)],
          'emoji': '🔢',
        };
      case 'MEM02':
        return {
          'icon': Icons.grid_view,
          'gradient': [Color(0xFF14B8A6), Color(0xFF0D9488)],
          'emoji': '🎴',
        };
      case 'MEM03':
        return {
          'icon': Icons.text_fields,
          'gradient': [Color(0xFF6366F1), Color(0xFF4F46E5)],
          'emoji': '📝',
        };
      case 'MEM04':
        return {
          'icon': Icons.repeat,
          'gradient': [Color(0xFFA855F7), Color(0xFF9333EA)],
          'emoji': '🔁',
        };
      case 'VIS02':
        return {
          'icon': Icons.find_in_page,
          'gradient': [Color(0xFFF97316), Color(0xFFEA580C)],
          'emoji': '🔍',
        };
      case 'LANG02':
        return {
          'icon': Icons.speed,
          'gradient': [Color(0xFF06B6D4), Color(0xFF0891B2)],
          'emoji': '💨',
        };
      default:
        return {
          'icon': Icons.sports_esports,
          'gradient': [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          'emoji': '🎮',
        };
    }
  }

  Widget _buildLogoScreen() {
    final baseTheme = Theme.of(context);
    final effectiveIsDark =
        widget.isDarkOverride ?? baseTheme.brightness == Brightness.dark;
    final bgColor =
        effectiveIsDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6);
    final titleColor =
        effectiveIsDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);

    final logoData = _getGameLogoData();
    final gradientColors = logoData['gradient'] as List<Color>;
    final emoji = logoData['emoji'] as String;

    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: effectiveIsDark
                  ? [
                      bgColor,
                      gradientColors[0].withOpacity(0.1),
                    ]
                  : [
                      bgColor,
                      gradientColors[0].withOpacity(0.05),
                    ],
            ),
          ),
          child: Center(
            child: Opacity(
              opacity: _logoFadeAnimation.value,
              child: Transform.scale(
                scale: _logoScaleAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Oyun logosu - Emoji ve gradient container
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow efekti
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: gradientColors[0].withOpacity(0.3),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        // Ana logo container
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: gradientColors,
                            ),
                            borderRadius: BorderRadius.circular(36),
                            boxShadow: [
                              BoxShadow(
                                color: gradientColors[0].withOpacity(0.5),
                                blurRadius: 25,
                                spreadRadius: 5,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 72),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // Oyun adı
                    Text(
                      widget.game.name,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                        letterSpacing: -1,
                        shadows: [
                          Shadow(
                            color: gradientColors[0].withOpacity(0.3),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Oyun açıklaması
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Text(
                        widget.game.description,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          color: effectiveIsDark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF6B7280),
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Yükleniyor göstergesi
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          gradientColors[0],
                        ),
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

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isGameComplete && _gameResult != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showResultDialog();
      });
    }

    final baseTheme = Theme.of(context);
    final effectiveIsDark =
        widget.isDarkOverride ?? baseTheme.brightness == Brightness.dark;
    final bgColor =
        effectiveIsDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6);

    final themedData = baseTheme.copyWith(
      brightness: effectiveIsDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bgColor,
    );

    return Theme(
      data: themedData,
      child: WillPopScope(
        onWillPop: _showExitConfirmDialog,
        child: Scaffold(
          backgroundColor: bgColor,
          body: _showLogo ? _buildLogoScreen() : _buildGameWidget(),
        ),
      ),
    );
  }
}
