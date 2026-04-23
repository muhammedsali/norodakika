import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/focus_checkin_game_controller.dart';

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
  late final FocusCheckInGameController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FocusCheckInGameController();
    if (!widget.isPaused) {
      _controller.start(
        onStateChanged: _refresh,
        onComplete: widget.onComplete,
      );
    }
  }

  @override
  void didUpdateWidget(covariant FocusCheckInGame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPaused != widget.isPaused) {
      if (widget.isPaused) {
        _controller.pause();
      } else {
        _controller.start(
          onStateChanged: _refresh,
          onComplete: widget.onComplete,
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _tap() {
    _controller.tap(
      onStateChanged: _refresh,
      onComplete: widget.onComplete,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final textColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    final bg = _controller.stimulusAt == null
        ? (isDark ? const Color(0xFF1F2937) : Colors.white)
        : (_controller.isTarget ? const Color(0xFF10B981) : const Color(0xFFEF4444));

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
                  valueListenable: _controller.timeRemainingNotifier,
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
                          _controller.stimulusAt == null
                              ? 'Hazır…'
                              : (_controller.isTarget ? 'DOKUN!' : 'DOKUNMA'),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: _controller.stimulusAt == null
                                ? titleColor
                                : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Deneme: ${_controller.trial}/${FocusCheckInGameController.trials}',
                          style: GoogleFonts.robotoMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _controller.stimulusAt == null ? textColor : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Skor: ${_controller.score}   En iyi: ${_controller.bestMs == 9999 ? '-' : '${_controller.bestMs}ms'}',
                          style: GoogleFonts.robotoMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _controller.stimulusAt == null ? textColor : Colors.white,
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
