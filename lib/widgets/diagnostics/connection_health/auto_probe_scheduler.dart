library;

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../providers/app_provider.dart';
import '../../../services/health/tunnel_health_models.dart';

/// ═══════════════════════════════════════════════════════════════
///  AutoProbeScheduler — زمان‌بندی auto-probe با backoff نمایی.
///
///  وقتی تونلی از stopped به running می‌ره، یک probe خودکار
///  با تاخیر کوتاه اجرا می‌شه تا SOCKS فرصت آماده شدن داشته باشه.
///  اگه شکست خورد، با backoff دوباره تلاش می‌کنه.
///
///  attempt 1: 2s
///  attempt 2: 3s
///  attempt 3: 5s
///  attempt 4: 8s
///  attempt 5+: 12s
///  حداکثر 6 تلاش
/// ═══════════════════════════════════════════════════════════════
class AutoProbeScheduler {
  final Map<TunnelKind, Timer> _timers = {};

  /// تونل‌هایی که auto-probe موفق داشتن (جلوگیری از تکرار).
  final Set<TunnelKind> _completed = {};

  /// وضعیت قبلی هر تونل برای تشخیص transition.
  final Map<TunnelKind, bool> _previousRunning = {};

  /// callback وقتی باید probe اجرا بشه.
  final Future<bool> Function(TunnelKind kind) runProbe;

  /// callback وقتی transition تشخیص داده شد (برای setState).
  final void Function() onStateChanged;

  AutoProbeScheduler({
    required this.runProbe,
    required this.onStateChanged,
  });

  void dispose() {
    for (final t in _timers.values) {
      t.cancel();
    }
    _timers.clear();
  }

  /// تشخیص transition و زمان‌بندی auto-probe.
  void detectTransitions(
    AppProvider provider,
    Map<TunnelKind, bool> runningStates,
  ) {
    for (final kind in TunnelKind.values) {
      final isRunning = runningStates[kind] ?? false;
      final wasRunning = _previousRunning[kind] ?? false;

      // transition: stopped → running
      if (isRunning && !wasRunning) {
        debugPrint(
          '[AutoProbeScheduler] ${kind.displayName} '
          'transitioned to running — scheduling auto-probe',
        );
        _completed.remove(kind);
        _schedule(kind, attempt: 1);
      }

      // transition: running → stopped
      if (!isRunning && wasRunning) {
        debugPrint(
          '[AutoProbeScheduler] ${kind.displayName} '
          'transitioned to stopped',
        );
        _timers.remove(kind)?.cancel();
        _completed.remove(kind);
      }

      _previousRunning[kind] = isRunning;
    }
  }

  void _schedule(TunnelKind kind, {required int attempt}) {
    _timers.remove(kind)?.cancel();

    if (_completed.contains(kind)) return;

    final delay = _delayForAttempt(attempt);
    debugPrint(
      '[AutoProbeScheduler] ${kind.displayName} '
      'auto-probe attempt #$attempt in ${delay.inSeconds}s',
    );

    _timers[kind] = Timer(delay, () async {
      _timers.remove(kind);
      if (_completed.contains(kind)) return;

      final ok = await runProbe(kind);

      if (ok) {
        _completed.add(kind);
        onStateChanged();
      } else if (attempt < 6) {
        _schedule(kind, attempt: attempt + 1);
      } else {
        debugPrint(
          '[AutoProbeScheduler] ${kind.displayName} '
          'auto-probe giving up after $attempt attempts',
        );
      }
    });
  }

  Duration _delayForAttempt(int attempt) {
    switch (attempt) {
      case 1:
        return const Duration(seconds: 2);
      case 2:
        return const Duration(seconds: 3);
      case 3:
        return const Duration(seconds: 5);
      case 4:
        return const Duration(seconds: 8);
      default:
        return const Duration(seconds: 12);
    }
  }

  /// کنسل کردن auto-probe برای یک تونل (مثلاً وقتی user خودش
  /// دکمه probe رو زد).
  void cancelFor(TunnelKind kind) {
    _timers.remove(kind)?.cancel();
    _completed.add(kind);
  }

  bool isCompleted(TunnelKind kind) => _completed.contains(kind);
}
