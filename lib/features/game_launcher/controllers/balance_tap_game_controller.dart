import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

class BalanceTapGameController {
  static const int totalSeconds = 45;
  static const double maxOffset = 1.2;
  static const double driftPerTick = 0.03;
  static const double tapStep = 0.18;
  static const double centerZoneThreshold = 0.25;

  Timer? _timer;
  Timer? _tick;
  final Random _rng = Random();

  final ValueNotifier<int> timeRemainingNotifier = ValueNotifier<int>(totalSeconds);
  final ValueNotifier<double> offsetNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);

  int _ticksInZone = 0;
  int _ticksTotal = 0;
  bool _isFinished = false;

  void start({required void Function(Map<String, dynamic>) onComplete}) {
    if (_isFinished) return;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      timeRemainingNotifier.value--;
      if (timeRemainingNotifier.value <= 0) {
        finish(onComplete: onComplete);
      }
    });

    _tick?.cancel();
    _tick = Timer.periodic(const Duration(milliseconds: 70), (_) {
      _ticksTotal++;
      final drift = (_rng.nextDouble() - 0.5) * 2 * driftPerTick;
      offsetNotifier.value = (offsetNotifier.value + drift).clamp(-maxOffset, maxOffset);
      final inZone = offsetNotifier.value.abs() <= centerZoneThreshold;
      if (inZone) {
        _ticksInZone++;
        scoreNotifier.value += 2;
      } else {
        scoreNotifier.value = max(0, scoreNotifier.value - 1);
      }
    });
  }

  void pause() {
    _timer?.cancel();
    _tick?.cancel();
  }

  void tapLeft() {
    if (_isFinished) return;
    offsetNotifier.value = (offsetNotifier.value - tapStep).clamp(-maxOffset, maxOffset);
  }

  void tapRight() {
    if (_isFinished) return;
    offsetNotifier.value = (offsetNotifier.value + tapStep).clamp(-maxOffset, maxOffset);
  }

  void finish({required void Function(Map<String, dynamic>) onComplete}) {
    if (_isFinished) return;
    _isFinished = true;
    pause();
    final successRate = _ticksTotal == 0 ? 0.0 : (_ticksInZone / _ticksTotal);
    onComplete({
      'score': scoreNotifier.value.toDouble(),
      'successRate': successRate,
      'duration': totalSeconds - timeRemainingNotifier.value,
    });
  }

  void dispose() {
    pause();
    timeRemainingNotifier.dispose();
    offsetNotifier.dispose();
    scoreNotifier.dispose();
  }
}
