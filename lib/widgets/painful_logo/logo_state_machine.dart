library;

import 'dart:async';
import 'package:flutter/foundation.dart';

import 'logo_mode.dart';
import 'logo_audio_manager.dart';

class LogoStateMachine {
  final LogoAudioManager audio;
  final void Function(LogoMode mode) onModeChanged;
  final void Function(Timer? timer) onTimerCreated;

  final Duration hurtDuration;
  final Duration sadDuration;
  final Duration happyDuration;
  final Duration hiDuration;

  LogoMode _current = LogoMode.normal;
  Timer? _timer;
  LogoMode? _queuedMode;
  bool _disposed = false;

  LogoStateMachine({
    required this.audio,
    required this.onModeChanged,
    required this.onTimerCreated,
    required this.hurtDuration,
    required this.sadDuration,
    required this.happyDuration,
    required this.hiDuration,
  });

  LogoMode get current => _current;

  /// شروع اولیه با hi — بعد از hiDuration به normal برمی‌گردد.
  void startInitial() {
    debugPrint(
        'LogoStateMachine: startInitial (hi for ${hiDuration.inSeconds}s)');
    _applyMode(LogoMode.hi, hiDuration);
  }

  void transitionTo(LogoMode newMode) {
    if (_disposed) return;

    if (_current == LogoMode.sad && newMode == LogoMode.happy) {
      _queuedMode = LogoMode.happy;
      return;
    }

    if (newMode == LogoMode.sad) {
      _queuedMode = null;
    }

    debugPrint('LogoStateMachine: transition → $newMode '
        '(${_durationFor(newMode).inSeconds}s)');
    _applyMode(newMode, _durationFor(newMode));
  }

  Duration _durationFor(LogoMode mode) {
    switch (mode) {
      case LogoMode.hurt:
        return hurtDuration;
      case LogoMode.sad:
        return sadDuration;
      case LogoMode.happy:
        return happyDuration;
      case LogoMode.hi:
        return hiDuration;
      case LogoMode.normal:
        return hiDuration;
    }
  }

  void _applyMode(LogoMode mode, Duration duration) {
    _playSound(mode);
    _current = mode;
    onModeChanged(mode);

    _timer?.cancel();
    _timer = Timer(duration, _handleTimerExpiry);
    onTimerCreated(_timer);
  }

  void _playSound(LogoMode mode) {
    switch (mode) {
      case LogoMode.hurt:
        audio.playHurt();
        break;
      case LogoMode.sad:
        audio.playSad();
        break;
      case LogoMode.happy:
        audio.playHappy();
        break;
      case LogoMode.hi:
      case LogoMode.normal:
        break;
    }
  }

  void _handleTimerExpiry() {
    if (_disposed) return;

    final queued = _queuedMode;
    if (queued != null) {
      _queuedMode = null;
      _applyMode(queued, _durationFor(queued));
      return;
    }

    debugPrint('LogoStateMachine: timer expired → normal');
    _applyMode(LogoMode.normal, hiDuration);
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
  }
}
