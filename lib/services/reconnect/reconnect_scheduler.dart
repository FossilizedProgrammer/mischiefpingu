library;

import 'dart:async';

import 'reconnect_backoff.dart';

typedef ReconnectLogFn = void Function(String message, {String source});

/// ═══════════════════════════════════════════════════════════════
///  مدیریت timerها برای auto-reconnect (per tunnel).
/// ═══════════════════════════════════════════════════════════════
class ReconnectScheduler {
  final Map<String, Timer> _timers = {};
  final Set<String> _activeKeys = {};

  /// schedule یک reconnect.
  void schedule({
    required String key,
    required Duration baseDelay,
    required bool Function() shouldReconnect,
    required void Function() onReconnect,
    required ReconnectLogFn log,
    required String logSource,
    required ReconnectBackoff backoff,
    Future<bool> Function(String tunnel)? acquireLease,
    void Function(String tunnel)? releaseLease,
  }) {
    if (_activeKeys.contains(key)) return;

    _timers[key]?.cancel();

    backoff.pruneIfStale(key);
    final retryCount = backoff.retryCountFor(key);
    final delay = backoff.computeDelay(baseDelay, retryCount);

    if (retryCount > 0) {
      log(
        '→ $key auto-reconnect scheduled in ${delay.inSeconds}s '
        '(retry #${retryCount + 1})',
        source: logSource,
      );
    }

    final timer = Timer(delay, () async {
      _activeKeys.remove(key);

      if (!shouldReconnect()) return;

      if (acquireLease != null) {
        final granted = await acquireLease(key);
        if (!granted) {
          log(
            '→ $key auto-reconnect blocked by RecoveryCoordinator '
            '— will retry on next state change',
            source: logSource,
          );
          return;
        }
      }

      try {
        backoff.recordAttempt(key, retryCount);
        log('↻ Auto-reconnecting $key...', source: logSource);
        onReconnect();
      } finally {
        releaseLease?.call(key);
      }
    });

    _timers[key] = timer;
    _activeKeys.add(key);
  }

  void cancel(String key) {
    _timers[key]?.cancel();
    _timers.remove(key);
    _activeKeys.remove(key);
  }

  void cancelAll() {
    for (final t in _timers.values) {
      t.cancel();
    }
    _timers.clear();
    _activeKeys.clear();
  }

  void dispose() => cancelAll();
}
