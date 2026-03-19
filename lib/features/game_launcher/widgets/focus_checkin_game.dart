import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FocusCheckInGame extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;
  final bool isPaused;

  const FocusCheckInGame({
    super.key,
    required this.onComplete,
    this.isPaused = false,
  });

  @override
  State<FocusCheckInGame> createState() => _FocusCheckInGameState();
}

class _FocusCheckInGameState extends State<FocusCheckInGame> {
  static const int totalSeconds = 45;
  static const int trials = 18;

  final Random _rng = Random();
  Timer? _timer;
  final ValueNotifier<int> _timeRemainingNotifier = ValueNotifier<int>(totalSeconds);

  int _trial = 0;
  bool _isTarget = false;
  bool _locked = false;

  int _correct = 0;
  int _wrong = 0;
  int _score = 0;

  DateTime? _stimulusAt;
  int _bestMs = 9999;

  @override
  void initState() {
    super.initState();
    if (!widget.isPaused) _startTimer();
    _nextTrial();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _timeRemainingNotifier.value--;
      if (_timeRemainingNotifier.value <= 0) _finish();
    });
  }

  @override
  void didUpdateWidget(covariant FocusCheckInGame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPaused != widget.isPaused) {
      if (widget.isPaused) {
        _timer?.cancel();
      } else {
        _startTimer();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timeRemainingNotifier.dispose();
    super.dispose();
  }

  Future<void> _nextTrial() async {
    if (!mounted) return;
    if (_trial >= trials) {
      _finish();
      return;
    }

    setState(() {
      _locked = true;
      _isTarget = false;
      _stimulusAt = null;
    });

    await Future.delayed(Duration(milliseconds: 500 + _rng.nextInt(700)));
    if (!mounted) return;

    setState(() {
      _locked = false;
      _isTarget = _rng.nextDouble() < 0.45;
      _stimulusAt = DateTime.now();
      _trial++;
    });

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    if (_stimulusAt != null && _isTarget) {
      setState(() {
        _wrong++;
        _score = max(0, _score - 60);
        _locked = true;
      });
      await Future.delayed(const Duration(milliseconds: 250));
      _nextTrial();
    } else if (_stimulusAt != null && !_isTarget) {
      setState(() {
        _locked = true;
      });
      await Future.delayed(const Duration(milliseconds: 250));
      _nextTrial();
    }
  }

  void _tap() {
    if (_locked || _stimulusAt == null || widget.isPaused) return;

    final rt = DateTime.now().difference(_stimulusAt!).inMilliseconds;

    setState(() {
      if (_isTarget) {
        _correct++;
        _score += 130;
        if (rt < _bestMs) _bestMs = rt;
      } else {
        _wrong++;
        _score = max(0, _score - 70);
      }
      _locked = true;
    });

    Future.delayed(const Duration(milliseconds: 250), _nextTrial);
  }

  void _finish() {
    _timer?.cancel();
    final total = max(1, _correct + _wrong);
    widget.onComplete({
      'score': _score.toDouble(),
      'successRate': _correct / total,
      'duration': (totalSeconds - _timeRemainingNotifier.value),
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final textColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    final bg = _stimulusAt == null
        ? (isDark ? const Color(0xFF1F2937) : Colors.white)
        : (_isTarget ? const Color(0xFF10B981) : const Color(0xFFEF4444));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Focus Check-In',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                ValueListenableBuilder<int>(
                  valueListenable: _timeRemainingNotifier,
                  builder: (context, time, _) => _Pill(text: '$time s', isDark: isDark),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Yeşil gelince dokun. Kırmızı gelince dokunma.',
                style: GoogleFonts.spaceGrotesk(fontSize: 14, color: textColor),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: GestureDetector(
                onTap: _tap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _stimulusAt == null
                              ? 'Hazır…'
                              : (_isTarget ? 'DOKUN!' : 'DOKUNMA'),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: _stimulusAt == null
                                ? titleColor
                                : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Deneme: $_trial/$trials',
                          style: GoogleFonts.robotoMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _stimulusAt == null ? textColor : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Skor: $_score   En iyi: ${_bestMs == 9999 ? '-' : '${_bestMs}ms'}',
                          style: GoogleFonts.robotoMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _stimulusAt == null ? textColor : Colors.white,
                          ),
                        ),
                      ],
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
}

class _Pill extends StatelessWidget {
  final String text;
  final bool isDark;

  const _Pill({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final titleColor = isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.robotoMono(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: titleColor,
        ),
      ),
    );
  }
}
