import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/game_model.dart';
import '../../../core/models/attempt_model.dart';
import '../../../core/memory/memory_bank.dart';
import '../../../services/local_storage_service.dart';
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

class _GamePlayScreenState extends ConsumerState<GamePlayScreen> {
  bool _isGameStarted = false;
  bool _isGameComplete = false;
  Map<String, dynamic>? _gameResult;
  int _runId = 0; // oyun tekrarları için
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  Future<void> _startGame() async {
    setState(() {
      _isGameStarted = true;
    });
  }

  Future<void> _onGameComplete(Map<String, dynamic> result) async {
    final userEmail = ref.read(currentUserProvider);
    if (userEmail == null) return;

    final difficulty = await LocalStorageService.getGameDifficulty(
      userId: userEmail,
      gameId: widget.game.id,
    );

    setState(() {
      _isGameComplete = true;
      _gameResult = result;
    });

    // Attempt kaydet
    await _saveAttempt(result, difficulty, userEmail);
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

      // Local storage'a kaydet
      await LocalStorageService.saveAttempt(attempt);

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
      await LocalStorageService.updateGameDifficulty(
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isDark = theme.brightness == Brightness.dark;
        final bgColor =
            isDark ? const Color(0xFF111827) : Colors.white;
        final titleColor =
            isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
        final textColor =
            isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563);

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
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 32,
                      offset: Offset(0, 16),
                    ),
                  ],
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF374151)
                        : const Color(0xFFE5E7EB),
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
                                _runId++;
                              });
                              _startGame();
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isDark
                                    ? const Color(0xFF4B5563)
                                    : const Color(0xFF4F46E5),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
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

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF111827) : Colors.white;
    final titleColor = isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final textColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563);

    setState(() {
      _isPaused = true;
    });

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
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
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 32,
                      offset: Offset(0, 16),
                    ),
                  ],
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF374151)
                        : const Color(0xFFE5E7EB),
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
                                color: isDark
                                    ? const Color(0xFF4B5563)
                                    : const Color(0xFF4F46E5),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
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
          body: _buildGameWidget(),
        ),
      ),
    );
  }
}
