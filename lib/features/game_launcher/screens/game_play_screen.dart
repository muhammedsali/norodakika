import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/game_model.dart';
import '../../../core/models/attempt_model.dart';
import '../../../core/memory/memory_bank.dart';
import '../../../services/unity_bridge_service.dart';
import '../../../services/firebase_service.dart';
import '../../../core/api/api_service.dart';
import '../../auth/providers/auth_provider.dart';

class GamePlayScreen extends ConsumerStatefulWidget {
  final GameModel game;

  const GamePlayScreen({
    super.key,
    required this.game,
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
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    // Zorluk seviyesini getir
    final difficulty = await FirebaseService.getGameDifficulty(
      userId: user.uid,
      gameId: widget.game.id,
    );

    setState(() {
      _isGameStarted = true;
    });

    // Unity oyununu başlat
    await UnityBridgeService.launchGame(
      gameId: widget.game.id,
      difficulty: difficulty,
      onGameComplete: (result) async {
        setState(() {
          _isGameComplete = true;
          _gameResult = result;
        });

        // Attempt kaydet
        await _saveAttempt(result, difficulty, user.uid);
      },
    );
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

      // Firebase'e kaydet
      await FirebaseService.saveAttempt(attempt);

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
      await FirebaseService.updateGameDifficulty(
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

  @override
  Widget build(BuildContext context) {
    if (_isGameComplete && _gameResult != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showResultDialog();
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Oyun başlığı
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      widget.game.name,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Denge için
                ],
              ),
            ),
            
            // Unity oyun alanı (placeholder - gerçek Unity widget buraya gelecek)
            Expanded(
              child: Container(
                color: Colors.grey[900],
                child: Center(
                  child: _isGameStarted
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              color: Color(0xFF6E00FF),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Unity oyunu yükleniyor...',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Gerçek Unity entegrasyonu için\nflutter_unity_widget kullanılacak',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                      : const CircularProgressIndicator(
                          color: Color(0xFF6E00FF),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    UnityBridgeService.dispose();
    super.dispose();
  }
}

