import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

class FocusCheckInGameController {
  static const int totalSeconds = 45;
  static const int trials = 18;

  final Random _rng = Random();
  Timer? _timer;
  int _trialToken = 0;
  bool _isFinished = false;
  bool _isDisposed = false;
  bool _isPaused = false;

  final ValueNotifier<int> timeRemainingNotifier = ValueNotifier<int>(totalSeconds);

  int trial = 0;
  bool isTarget = false;
  bool locked = false;
  int correct = 0;
  int wrong = 0;
  int score = 0;
  DateTime? stimulusAt;
  int bestMs = 9999;

  void start({
    required VoidCallback onStateChanged,
    required void Function(Map<String, dynamic>) onComplete,
  }) {
    if (_isDisposed || _isFinished) return;
    _isPaused = false;
    _startTimer(onComplete: onComplete);
    if (trial == 0 && stimulusAt == null) {
      _nextTrial(onStateChanged: onStateChanged, onComplete: onComplete);
    }
  }

  void pause() {
    _isPaused = true;
    _timer?.cancel();
  }

  void tap({
    required VoidCallback onStateChanged,
    required void Function(Map<String, dynamic>) onComplete,
  }) {
    if (_isPaused || locked || stimulusAt == null || _isFinished || _isDisposed) return;
    final rt = DateTime.now().difference(stimulusAt!).inMilliseconds;

    if (isTarget) {
      correct++;
      score += 130;
      if (rt < bestMs) bestMs = rt;
    } else {
      wrong++;
      score = max(0, score - 70);
    }
    locked = true;
    onStateChanged();

    Future.delayed(const Duration(milliseconds: 250), () {
      _nextTrial(onStateChanged: onStateChanged, onComplete: onComplete);
    });
  }

  void finish({required void Function(Map<String, dynamic>) onComplete}) {
    if (_isFinished || _isDisposed) return;
    _isFinished = true;
    _timer?.cancel();
    final total = max(1, correct + wrong);
    onComplete({
      'score': score.toDouble(),
      'successRate': correct / total,
      'duration': totalSeconds - timeRemainingNotifier.value,
    });
  }

  void dispose() {
    _isDisposed = true;
    _trialToken++;
    _timer?.cancel();
    timeRemainingNotifier.dispose();
  }

  void _startTimer({required void Function(Map<String, dynamic>) onComplete}) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isDisposed || _isPaused || _isFinished) return;
      timeRemainingNotifier.value--;
      if (timeRemainingNotifier.value <= 0) finish(onComplete: onComplete);
    });
  }

  Future<void> _nextTrial({
    required VoidCallback onStateChanged,
    required void Function(Map<String, dynamic>) onComplete,
  }) async {
    if (_isDisposed || _isFinished || _isPaused) return;
    if (trial >= trials) {
      finish(onComplete: onComplete);
      return;
    }

    final token = ++_trialToken;
    locked = true;
    isTarget = false;
    stimulusAt = null;
    onStateChanged();

    await Future.delayed(Duration(milliseconds: 500 + _rng.nextInt(700)));
    if (!_canContinue(token)) return;

    locked = false;
    isTarget = _rng.nextDouble() < 0.45;
    stimulusAt = DateTime.now();
    trial++;
    onStateChanged();

    await Future.delayed(const Duration(milliseconds: 900));
    if (!_canContinue(token) || stimulusAt == null) return;

    if (isTarget) {
      wrong++;
      score = max(0, score - 60);
      locked = true;
      onStateChanged();
      await Future.delayed(const Duration(milliseconds: 250));
      if (_canContinue(token)) {
        _nextTrial(onStateChanged: onStateChanged, onComplete: onComplete);
      }
      return;
    }

    locked = true;
    onStateChanged();
    await Future.delayed(const Duration(milliseconds: 250));
    if (_canContinue(token)) {
      _nextTrial(onStateChanged: onStateChanged, onComplete: onComplete);
    }
  }

  bool _canContinue(int token) {
    return !_isDisposed && !_isPaused && !_isFinished && token == _trialToken;
  }
}
