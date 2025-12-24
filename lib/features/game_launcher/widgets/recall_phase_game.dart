import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// İki fazlı bellek oyunu:
/// 1) Ezber: kelimeleri 12 sn gör, süre çubuğu doluyor.
/// 2) Hatırlama: karışık listeden seç; yanlış/kaçırma ceza, doğru ödül.
/// Can, seri ve süre takibi ile gerçek oyun hissi.
class RecallPhaseGame extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;

  const RecallPhaseGame({super.key, required this.onComplete});

  @override
  State<RecallPhaseGame> createState() => _RecallPhaseGameState();
}

class _RecallPhaseGameState extends State<RecallPhaseGame> {
  static const int memorizeSeconds = 12;
  static const int recallSeconds = 40;
  static const int maxHearts = 3;
  static const int poolSize = 24;
  static const int shownCount = 10;

  final Random _rng = Random();

  late List<String> _wordPool;
  late List<String> _shownWords;
  late List<String> _choices;

  final Set<String> _selected = {};

  Timer? _phaseTimer;
  int _timeRemaining = memorizeSeconds;
  bool _isMemorize = true;
  bool _isFinished = false;

  int _score = 0;
  int _hearts = maxHearts;
  int _streak = 0;
  int _bestStreak = 0;
  int _correct = 0;
  int _wrong = 0;
  int _missed = 0;

  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _buildPool();
    _startGame();
  }

  void _buildPool() {
    // Çeşitli tema karışımı
    const bank = [
      'Okyanus', 'Galaksi', 'Dağ', 'Orman', 'Vadi', 'Çöl', 'Ada', 'Volkan',
      'Ritim', 'Kadans', 'Melodi', 'Armoni', 'Tempo', 'Senfoni',
      'Kahve', 'Çay', 'Tarçın', 'Nane', 'Limon', 'Bal',
      'Kuantum', 'Foton', 'Plazma', 'Nötron', 'Atom', 'Molekül',
      'Rüzgar', 'Yağmur', 'Şimşek', 'Gökkuşağı', 'Pus', 'Dalgıç',
      'Merhamet', 'Cesaret', 'Sabır', 'Neşe', 'Umut', 'Şefkat',
    ];
    _wordPool = List<String>.from(bank)..shuffle(_rng);
    _wordPool = _wordPool.take(poolSize).toList();
  }

  void _startGame() {
    _resetState();
    _startMemorizePhase();
  }

  void _resetState() {
    _startTime = DateTime.now();
    _selected.clear();
    _hearts = maxHearts;
    _streak = 0;
    _bestStreak = 0;
    _correct = 0;
    _wrong = 0;
    _missed = 0;
    _score = 0;
    _isFinished = false;
  }

  void _startMemorizePhase() {
    _isMemorize = true;
    _timeRemaining = memorizeSeconds;
    _shownWords = List<String>.from(_wordPool)..shuffle(_rng);
    _shownWords = _shownWords.take(shownCount).toList();
    _choices = List<String>.from(_wordPool)..shuffle(_rng);

    _phaseTimer?.cancel();
    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _isFinished) return;
      setState(() {
        _timeRemaining--;
      });
      if (_timeRemaining <= 0) {
        _startRecallPhase();
      }
    });
  }

  void _startRecallPhase() {
    _isMemorize = false;
    _timeRemaining = recallSeconds;
    _phaseTimer?.cancel();
    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _isFinished) return;
      setState(() {
        _timeRemaining--;
      });
      if (_timeRemaining <= 0) {
        _finish();
      }
    });
    setState(() {});
  }

  void _toggleWord(String word) {
    if (_isMemorize || _isFinished) return;

    HapticFeedback.selectionClick();

    setState(() {
      if (_selected.contains(word)) {
        _selected.remove(word);
      } else {
        _selected.add(word);
      }
    });
  }

  void _submitSelection() {
    if (_isMemorize || _isFinished) return;

    int localCorrect = 0;
    int localWrong = 0;
    int localMiss = 0;

    for (final w in _selected) {
      if (_shownWords.contains(w)) {
        localCorrect++;
      } else {
        localWrong++;
      }
    }
    for (final w in _shownWords) {
      if (!_selected.contains(w)) {
        localMiss++;
      }
    }

    _correct += localCorrect;
    _wrong += localWrong;
    _missed += localMiss;

    if (localCorrect > 0 && localWrong == 0) {
      _streak++;
      _bestStreak = max(_bestStreak, _streak);
    } else {
      _streak = 0;
    }

    _score += (localCorrect * 120) - (localWrong * 90) - (localMiss * 50);
    _score = max(0, _score);

    _hearts = max(0, _hearts - localWrong - localMiss);
    if (_hearts == 0) {
      _finish();
      return;
    }

    _finish();
  }

  void _finish() {
    if (_isFinished) return;
    _isFinished = true;
    _phaseTimer?.cancel();

    final duration = DateTime.now().difference(_startTime ?? DateTime.now()).inSeconds;
    final totalTarget = _shownWords.length;
    final successRate = totalTarget == 0 ? 0.0 : _correct / totalTarget;

    widget.onComplete({
      'score': _score.toDouble(),
      'successRate': successRate,
      'duration': duration,
      'correct': _correct,
      'wrong': _wrong,
      'missed': _missed,
      'bestStreak': _bestStreak,
    });

    setState(() {});
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0B1220) : const Color(0xFFF5F7FB);
    final panel = isDark ? const Color(0xFF111827) : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(isDark, panel),
              const SizedBox(height: 12),
              _buildTimerBar(isDark),
              const SizedBox(height: 12),
              Expanded(
                child: _isMemorize
                    ? _buildMemorizePanel(isDark, panel)
                    : _buildRecallPanel(isDark, panel),
              ),
              const SizedBox(height: 12),
              if (!_isMemorize && !_isFinished)
                _buildSubmitButton(panel),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, Color panel) {
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recall Phase',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isMemorize
                    ? 'Kelimeleri hafızana al'
                    : 'Gördüğün kelimeleri seç',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_timeRemaining}s',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Skor: $_score',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimerBar(bool isDark) {
    final total = _isMemorize ? memorizeSeconds : recallSeconds;
    final progress = _timeRemaining / total;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: LinearProgressIndicator(
        value: progress.clamp(0, 1),
        minHeight: 12,
        backgroundColor: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
        valueColor: AlwaysStoppedAnimation<Color>(
          Color.lerp(const Color(0xFF22C55E), const Color(0xFFEF4444), 1 - progress)!,
        ),
      ),
    );
  }

  Widget _buildMemorizePanel(bool isDark, Color panel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Bu kelimeleri aklında tut',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: _shownWords
                    .map(
                      (w) => Chip(
                        label: Text(
                          w,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        backgroundColor: const Color(0xFF2563EB),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecallPanel(bool isDark, Color panel) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gördüklerini seç, emin değilsen pas geç.',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _choices
                    .map(
                      (word) => _WordCard(
                        word: word,
                        selected: _selected.contains(word),
                        onTap: () => _toggleWord(word),
                        isDark: isDark,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(Color panel) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _submitSelection,
        icon: const Icon(Icons.check_circle_outline),
        label: const Text('Gönder'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4F46E5),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

class _WordCard extends StatelessWidget {
  final String word;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  const _WordCard({
    required this.word,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF4F5F7);
    final selectedColor = const Color(0xFF22C55E);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? selectedColor : baseColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          word,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ),
    );
  }
}
