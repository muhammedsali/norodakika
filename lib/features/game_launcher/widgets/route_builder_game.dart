import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RouteBuilderGame extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;

  const RouteBuilderGame({super.key, required this.onComplete});

  @override
  State<RouteBuilderGame> createState() => _RouteBuilderGameState();
}

class _RouteBuilderGameState extends State<RouteBuilderGame> {
  static const int totalSeconds = 60;
  static const int grid = 5;
  static const int rounds = 10;

  final Random _rng = Random();
  Timer? _timer;
  int _timeRemaining = totalSeconds;

  int _round = 0;
  int _score = 0;
  int _correct = 0;
  int _wrong = 0;

  late _Puzzle _puzzle;

  @override
  void initState() {
    super.initState();
    _puzzle = _newPuzzle();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _timeRemaining--);
      if (_timeRemaining <= 0) _finish();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  _Puzzle _newPuzzle() {
    final start = const Point<int>(0, 0);
    final end = const Point<int>(grid - 1, grid - 1);

    while (true) {
      final blocked = <Point<int>>{};
      final blocksCount = 5 + _rng.nextInt(4);
      while (blocked.length < blocksCount) {
        final p = Point<int>(_rng.nextInt(grid), _rng.nextInt(grid));
        if (p == start || p == end) continue;
        blocked.add(p);
      }

      final dist = _bfsDistance(blocked, start, end);
      if (dist == null) continue;

      final options = _buildOptions(dist);
      return _Puzzle(blocked: blocked, start: start, end: end, answer: dist, options: options);
    }
  }

  List<int> _buildOptions(int dist) {
    final set = <int>{dist};
    while (set.length < 4) {
      final v = (dist + (_rng.nextInt(7) - 3)).clamp(2, 20);
      set.add(v);
    }
    final list = set.toList()..shuffle(_rng);
    return list;
  }

  int? _bfsDistance(Set<Point<int>> blocked, Point<int> s, Point<int> t) {
    final q = Queue<Point<int>>();
    final dist = <Point<int>, int>{};

    q.add(s);
    dist[s] = 0;

    while (q.isNotEmpty) {
      final p = q.removeFirst();
      if (p == t) return dist[p];

      final d = dist[p]!;
      for (final n in _neighbors(p)) {
        if (n.x < 0 || n.y < 0 || n.x >= grid || n.y >= grid) continue;
        if (blocked.contains(n)) continue;
        if (dist.containsKey(n)) continue;
        dist[n] = d + 1;
        q.add(n);
      }
    }

    return null;
  }

  Iterable<Point<int>> _neighbors(Point<int> p) sync* {
    yield Point<int>(p.x + 1, p.y);
    yield Point<int>(p.x - 1, p.y);
    yield Point<int>(p.x, p.y + 1);
    yield Point<int>(p.x, p.y - 1);
  }

  void _answer(int value) {
    final ok = value == _puzzle.answer;
    setState(() {
      if (ok) {
        _correct++;
        _score += 160;
      } else {
        _wrong++;
        _score = max(0, _score - 80);
      }

      _round++;
      if (_round >= rounds) {
        _finish();
      } else {
        _puzzle = _newPuzzle();
      }
    });
  }

  void _finish() {
    _timer?.cancel();
    final total = max(1, _correct + _wrong);
    widget.onComplete({
      'score': _score.toDouble(),
      'successRate': _correct / total,
      'duration': (totalSeconds - _timeRemaining),
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final textColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Route Builder',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                _Pill(text: '$_timeRemaining s', isDark: isDark),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Engelleri aşarak en kısa adım sayısını seç.',
                style: GoogleFonts.spaceGrotesk(fontSize: 14, color: textColor),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2937) : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Round ${_round + 1}/$rounds   Skor: $_score',
                    style: GoogleFonts.robotoMono(fontSize: 12, color: textColor),
                  ),
                  const SizedBox(height: 12),
                  AspectRatio(
                    aspectRatio: 1,
                    child: _GridView(puzzle: _puzzle, isDark: isDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.2,
                children: _puzzle.options
                    .map((v) => _OptionButton(
                          label: '$v',
                          color: const Color(0xFF4F46E5),
                          onTap: () => _answer(v),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridView extends StatelessWidget {
  final _Puzzle puzzle;
  final bool isDark;

  const _GridView({required this.puzzle, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final border = isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);
    final cellBg = isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB);

    return LayoutBuilder(
      builder: (context, c) {
        final size = min(c.maxWidth, c.maxHeight);
        final cell = size / _RouteBuilderGameState.grid;
        return Stack(
          children: [
            for (int y = 0; y < _RouteBuilderGameState.grid; y++)
              for (int x = 0; x < _RouteBuilderGameState.grid; x++)
                Positioned(
                  left: x * cell,
                  top: y * cell,
                  child: Container(
                    width: cell,
                    height: cell,
                    decoration: BoxDecoration(
                      color: cellBg,
                      border: Border.all(color: border),
                    ),
                    child: Center(
                      child: _cellContent(x, y),
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }

  Widget _cellContent(int x, int y) {
    final p = Point<int>(x, y);
    if (p == puzzle.start) {
      return const Text('S', style: TextStyle(fontWeight: FontWeight.bold));
    }
    if (p == puzzle.end) {
      return const Text('E', style: TextStyle(fontWeight: FontWeight.bold));
    }
    if (puzzle.blocked.contains(p)) {
      return const Text('■');
    }
    return const SizedBox.shrink();
  }
}

class _OptionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _OptionButton({
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
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withValues(alpha: 0.85)],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
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

class _Puzzle {
  final Set<Point<int>> blocked;
  final Point<int> start;
  final Point<int> end;
  final int answer;
  final List<int> options;

  _Puzzle({
    required this.blocked,
    required this.start,
    required this.end,
    required this.answer,
    required this.options,
  });
}
