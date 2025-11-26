import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math';

class ReflexTapGame extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;

  const ReflexTapGame({super.key, required this.onComplete});

  @override
  State<ReflexTapGame> createState() => _ReflexTapGameState();
}

class _ReflexTapGameState extends State<ReflexTapGame> {
  int _score = 0;
  int _totalTaps = 0;
  int _correctTaps = 0;
  DateTime? _startTime;
  Timer? _gameTimer;
  bool _showTarget = false;
  Color _targetColor = const Color(0xFF2BADEE);
  int _timeRemaining = 30;
  int _reactionTime = 0;
  DateTime? _tapStartTime;
  String _feedbackText = '';

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _startGame();
  }

  void _startGame() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
        _showRandomTarget();
      } else {
        _endGame();
      }
    });
    _showRandomTarget();
  }

  void _showRandomTarget() {
    setState(() {
      _showTarget = false;
      _feedbackText = '';
    });

    Future.delayed(Duration(milliseconds: 500 + Random().nextInt(1500)), () {
      if (mounted && _timeRemaining > 0) {
        setState(() {
          _showTarget = true;
          _targetColor = const Color(0xFF2BADEE);
          _tapStartTime = DateTime.now();
        });
      }
    });
  }

  void _onTap() {
    if (!_showTarget) {
      _totalTaps++;
      return;
    }

    final reactionTime = DateTime.now().difference(_tapStartTime!).inMilliseconds;
    _totalTaps++;
    _correctTaps++;
    _score += 10;
    _reactionTime = reactionTime;

    setState(() {
      _showTarget = false;
      _feedbackText = reactionTime < 200
          ? 'Harika!'
          : reactionTime < 400
              ? 'İyi!'
              : 'Fena değil';
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _showRandomTarget();
      }
    });
  }

  void _endGame() {
    _gameTimer?.cancel();
    final duration = DateTime.now().difference(_startTime!).inSeconds;
    final successRate = _totalTaps > 0 ? _correctTaps / _totalTaps : 0.0;

    widget.onComplete({
      'score': _score.toDouble(),
      'successRate': successRate,
      'duration': duration,
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6);
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textPrimary =
        isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final textSecondary =
        isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    return Container
    (
      color: backgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoChip(
                    label: 'Süre',
                    value: '$_timeRemaining sn',
                    isDark: isDark,
                  ),
                  _buildInfoChip(
                    label: 'Skor',
                    value: '$_score',
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF374151)
                            : const Color(0xFFE5E7EB),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 32,
                          offset: Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_reactionTime > 0)
                          Text(
                            '$_reactionTime ms',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                        if (_feedbackText.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 24),
                            child: Text(
                              _feedbackText,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ),
                        GestureDetector(
                          onTap: _onTap,
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              gradient: _showTarget
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFF4F46E5),
                                        Color(0xFF10B981),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: _showTarget
                                  ? null
                                  : (isDark
                                      ? const Color(0xFF111827)
                                      : const Color(0xFFE5E7EB)),
                              shape: BoxShape.circle,
                              boxShadow: _showTarget
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF4F46E5)
                                            .withOpacity(0.5),
                                        blurRadius: 24,
                                        spreadRadius: 6,
                                      ),
                                      BoxShadow(
                                        color: const Color(0xFF10B981)
                                            .withOpacity(0.4),
                                        blurRadius: 40,
                                        spreadRadius: 10,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: AnimatedOpacity(
                                opacity: _showTarget ? 1 : 0.4,
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  _showTarget ? 'ŞİMDİ DOKUN' : 'BEKLE',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? const Color(0xFFF9FAFB)
                                        : const Color(0xFF111827),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Düğmenin rengi değiştiğinde mümkün olan en hızlı şekilde dokun.',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            color: textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? const Color(0xFF9CA3AF)
                  : const Color(0xFF6B7280),
            ),
          ),
          Text(
            value,
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
    );
  }
}
