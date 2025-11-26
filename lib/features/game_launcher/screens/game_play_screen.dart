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
import '../widgets/quick_math_game.dart';
import '../widgets/memory_board_game.dart';
import '../widgets/stroop_tap_game.dart';
import '../widgets/n_back_mini_game.dart';
import '../widgets/logic_puzzle_game.dart';
import '../widgets/recall_phase_game.dart';

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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          'Oyun Tamamlandı!',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6E00FF),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Skor: ${score.toStringAsFixed(1)}',
              style: GoogleFonts.poppins(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Başarı Oranı: ${(successRate * 100).toStringAsFixed(1)}%',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Dialog'u kapat
              Navigator.pop(context); // Oyun ekranından çık
            },
            child: Text(
              'Tamam',
              style: GoogleFonts.poppins(
                color: const Color(0xFF6E00FF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameWidget() {
    if (!_isGameStarted) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (widget.game.id) {
      case 'REF01':
        return ReflexTapGame(onComplete: _onGameComplete);
      case 'NUM01':
        return QuickMathGame(onComplete: _onGameComplete);
      case 'MEM02':
        return MemoryBoardGame(onComplete: _onGameComplete);
      case 'ATT01':
        return StroopTapGame(onComplete: _onGameComplete);
      case 'MEM01':
        return NBackMiniGame(onComplete: _onGameComplete);
      case 'LOG01':
        return LogicPuzzleGame(onComplete: _onGameComplete);
      case 'MEM03':
        return RecallPhaseGame(onComplete: _onGameComplete);
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
      child: Scaffold(
        backgroundColor: bgColor,
        body: _buildGameWidget(),
      ),
    );
  }
}
