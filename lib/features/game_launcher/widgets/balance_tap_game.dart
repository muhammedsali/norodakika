import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/balance_tap_game_controller.dart';

class BalanceTapGame extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;
  final bool isPaused;

  const BalanceTapGame({
    super.key,
    required this.onComplete,
    this.isPaused = false,
  });

  @override
  State<BalanceTapGame> createState() => _BalanceTapGameState();
}

class _BalanceTapGameState extends State<BalanceTapGame> {
  late final BalanceTapGameController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BalanceTapGameController();
    if (!widget.isPaused) {
      _controller.start(onComplete: widget.onComplete);
    }
  }

  @override
  void didUpdateWidget(covariant BalanceTapGame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPaused != widget.isPaused) {
      if (widget.isPaused) {
        _controller.pause();
      } else {
        _controller.start(onComplete: widget.onComplete);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _tapLeft() {
    if (widget.isPaused) return;
    _controller.tapLeft();
  }

  void _tapRight() {
    if (widget.isPaused) return;
    _controller.tapRight();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor =
        isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final textColor =
        isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    const centerX = 0.5;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Balance Tap',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                ValueListenableBuilder<int>(
                  valueListenable: _controller.timeRemainingNotifier,
                  builder: (context, time, _) =>
                      _Pill(text: '$time s', isDark: isDark),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Noktayı merkezde tut. Sol / Sağ dokun.',
                style: GoogleFonts.spaceGrotesk(fontSize: 14, color: textColor),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2937) : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF374151)
                      : const Color(0xFFE5E7EB),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 70,
                    child: LayoutBuilder(
                      builder: (context, c) {
                        final width = c.maxWidth;
                        return ValueListenableBuilder<double>(
                          valueListenable: _controller.offsetNotifier,
                          builder: (context, offsetValue, child) {
                            final dotX = (centerX +
                                    (offsetValue /
                                        (BalanceTapGameController.maxOffset *
                                            2)))
                                .clamp(0.0, 1.0);
                            final x = dotX * width;
                            return Stack(
                              children: [
                                Positioned(
                                  left: width / 2 - 2,
                                  top: 10,
                                  bottom: 10,
                                  child: Container(
                                      width: 4, color: const Color(0xFF4F46E5)),
                                ),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  top: 34,
                                  child: Container(
                                      height: 4,
                                      color: isDark
                                          ? const Color(0xFF374151)
                                          : const Color(0xFFE5E7EB)),
                                ),
                                Positioned(
                                  left: x - 12,
                                  top: 22,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: offsetValue.abs() <= 0.25
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFEF4444),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.15),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<int>(
                    valueListenable: _controller.scoreNotifier,
                    builder: (context, score, _) {
                      return Text(
                        'Skor: $score',
                        style: GoogleFonts.robotoMono(
                            fontSize: 12, color: textColor),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'Sol',
                      color: const Color(0xFF3B82F6),
                      onTap: _tapLeft,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      label: 'Sağ',
                      color: const Color(0xFF8B5CF6),
                      onTap: _tapRight,
                    ),
                  ),
                ],
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
    final titleColor =
        isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
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

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withValues(alpha: 0.85)],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
