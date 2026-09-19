library;

import 'watchdog_circuit_breaker.dart';
import 'watchdog_config.dart';
import 'watchdog_internet_gate.dart';
import 'watchdog_params.dart';
import 'watchdog_types.dart';

/// ═══════════════════════════════════════════════════════════════
///  تصمیم‌گیرندهٔ restart — قلب منطق watchdog.
///
///  ترتیب چک‌ها:
///    1. آیا Internet پایه سالم است؟  (internet gate)
///    2. آیا circuit breaker اجازه می‌دهد؟
///    3. آیا recovery lease می‌توانیم بگیریم؟
///    4. restart کن
/// ═══════════════════════════════════════════════════════════════
class WatchdogRestartDecider {
  final WatchdogParams params;
  final Future<void> Function() onRestart;
  final bool Function() isUserStopped;
  final Future<bool> Function()? isInternetAlive;
  final Future<RecoveryLeaseResult> Function()? acquireRecoveryLease;
  final WatchdogCircuitBreaker circuit;
  final WatchdogInternetGate internetGate;
  final void Function(String message, {String source}) log;
  final String logSource;

  final bool Function() isRestartInProgress;
  final void Function(bool) setRestartInProgress;
  final void Function() resetFailures;
  final void Function() holdFailuresAtThreshold;

  DateTime? _lastRestartAt;

  WatchdogRestartDecider({
    required this.params,
    required this.onRestart,
    required this.isUserStopped,
    required this.isInternetAlive,
    required this.acquireRecoveryLease,
    required this.circuit,
    required this.internetGate,
    required this.log,
    required this.logSource,
    required this.isRestartInProgress,
    required this.setRestartInProgress,
    required this.resetFailures,
    required this.holdFailuresAtThreshold,
  });

  /// آیا الان در grace period هستیم؟
  bool isInGracePeriod() {
    final last = _lastRestartAt;
    if (last == null) return false;
    final elapsed = DateTime.now().difference(last);
    return elapsed < WatchdogConfigGrace.gracePeriod;
  }

  Duration graceTimeRemaining() {
    final last = _lastRestartAt;
    if (last == null) return Duration.zero;
    final elapsed = DateTime.now().difference(last);
    final remaining = WatchdogConfigGrace.gracePeriod - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  void resetGracePeriod() {
    _lastRestartAt = null;
  }

  /// تلاش برای restart با تمام چک‌ها.
  Future<void> attemptRestart() async {
    if (isRestartInProgress()) {
      log(
        '→ restart already in progress — skipping',
        source: logSource,
      );
      return;
    }

    final internetOk = await internetGate.isHealthy();
    if (!internetOk) {
      holdFailuresAtThreshold();
      return;
    }

    if (!circuit.canRestart()) {
      resetFailures();
      return;
    }

    RecoveryLeaseResult? leaseResult;
    final leaseAcquirer = acquireRecoveryLease;
    if (leaseAcquirer != null) {
      final result = await leaseAcquirer();
      if (!result.granted) {
        log(
          '→ restart blocked by RecoveryCoordinator '
          '(${result.blockReason ?? "unknown reason"})',
          source: logSource,
        );
        holdFailuresAtThreshold();
        return;
      }
      leaseResult = result;
    }

    resetFailures();
    setRestartInProgress(true);
    circuit.recordRestart();

    log(
      '↻ restarting tunnel '
      '(restart #${circuit.restartCount} in window)',
      source: logSource,
    );

    try {
      await onRestart();
      _lastRestartAt = DateTime.now();
      log('★ restart completed', source: logSource);
    } catch (e) {
      log('✗ restart failed: $e', source: logSource);
    } finally {
      setRestartInProgress(false);
      final lease = leaseResult;
      if (lease != null) {
        try {
          lease.release();
        } catch (_) {}
      }
    }
  }
}
