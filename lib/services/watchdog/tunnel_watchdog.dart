library;

import 'dart:async';

import 'watchdog_circuit_breaker.dart';
import 'watchdog_internet_gate.dart';
import 'watchdog_params.dart';
import 'watchdog_prober.dart';
import 'watchdog_restart_decider.dart';
import 'watchdog_types.dart';

export 'watchdog_types.dart'
    show ProbeResult, RecoveryLeaseResult, RecoveryLeaseHandle;

/// ═══════════════════════════════════════════════════════════════
///  TunnelWatchdog — حلقهٔ اصلی probe + تصمیم restart.
///
///  منطق پیچیده در فایل‌های جدا:
///    • WatchdogRestartDecider → تصمیم نهایی restart
///    • WatchdogInternetGate   → چک اینترنت پایه
///    • WatchdogCircuitBreaker → circuit breaker
///    • WatchdogProber         → probe واقعی
/// ═══════════════════════════════════════════════════════════════
class TunnelWatchdog {
  final WatchdogParams params;
  final bool Function() isConnected;
  final bool Function() isUserStopped;
  final bool Function()? isBusy;
  final Future<void> Function() onRestart;
  final void Function(String message, {String source}) log;
  final String logSource;

  final Future<bool> Function()? isInternetAlive;
  final Future<RecoveryLeaseResult> Function()? acquireRecoveryLease;

  Timer? _timer;
  int _failures = 0;
  bool _checkRunning = false;
  bool _disposed = false;
  bool _started = false;
  bool _restartInProgress = false;

  late final WatchdogProber _prober = WatchdogProber(
    socksPort: params.socksPort,
    probeHost: params.probeHost,
    probePort: params.probePort,
    doHttpProbe: params.doHttpProbe,
    connectTimeout: params.connectTimeout,
    socksTimeout: params.socksTimeout,
    httpProbeTimeout: params.httpProbeTimeout,
    log: log,
    logSource: logSource,
  );

  late final WatchdogCircuitBreaker _circuit = WatchdogCircuitBreaker(
    log: log,
    logSource: logSource,
  );

  late final WatchdogInternetGate _internetGate = WatchdogInternetGate(
    isInternetAlive: isInternetAlive,
    log: log,
    logSource: logSource,
  );

  late final WatchdogRestartDecider _decider = WatchdogRestartDecider(
    params: params,
    onRestart: onRestart,
    isUserStopped: isUserStopped,
    isInternetAlive: isInternetAlive,
    acquireRecoveryLease: acquireRecoveryLease,
    circuit: _circuit,
    internetGate: _internetGate,
    log: log,
    logSource: logSource,
    isRestartInProgress: () => _restartInProgress,
    setRestartInProgress: (v) => _restartInProgress = v,
    resetFailures: () => _failures = 0,
    holdFailuresAtThreshold: () => _failures = params.maxFailures - 1,
  );

  TunnelWatchdog({
    required this.params,
    required this.isConnected,
    required this.isUserStopped,
    required this.onRestart,
    required this.log,
    required this.logSource,
    this.isBusy,
    this.isInternetAlive,
    this.acquireRecoveryLease,
  });

  String get name => params.name;
  Duration get interval => params.interval;
  int get maxFailures => params.maxFailures;

  void start() {
    if (_disposed) return;
    if (_started) return;
    _started = true;
    _timer = Timer.periodic(interval, (_) => _check());
    log(
      '→ $name watchdog started (every ${interval.inSeconds}s)',
      source: logSource,
    );
  }

  void stop() {
    if (!_started) return;
    _started = false;
    _timer?.cancel();
    _timer = null;
    _failures = 0;
  }

  void dispose() {
    _disposed = true;
    stop();
  }

  void resetFailures() {
    _failures = 0;
  }

  void resetGracePeriod() {
    _decider.resetGracePeriod();
  }

  void resetCircuitBreaker() {
    _circuit.reset();
    log(
      '→ $name watchdog: circuit breaker reset',
      source: logSource,
    );
  }

  Future<void> _check() async {
    if (_disposed || _checkRunning || _restartInProgress) return;

    if (_circuit.isOpen()) {
      final remaining = _circuit.timeUntilClose();
      log(
        '→ $name watchdog: circuit OPEN, '
        '${remaining.inSeconds}s remaining — skipping probe',
        source: logSource,
      );
      return;
    }

    if (_circuit.wasJustClosed()) {
      log(
        '★ $name watchdog: circuit CLOSED — resuming probes',
        source: logSource,
      );
    }

    if (_decider.isInGracePeriod()) {
      final remaining = _decider.graceTimeRemaining();
      log(
        '→ $name watchdog: in grace period, '
        '${remaining.inSeconds}s remaining',
        source: logSource,
      );
      return;
    }

    if (!isConnected()) {
      _failures = 0;
      return;
    }
    if (isUserStopped()) {
      _failures = 0;
      return;
    }
    if (isBusy?.call() ?? false) {
      log(
        '→ $name watchdog: busy, skipping probe',
        source: logSource,
      );
      return;
    }

    _checkRunning = true;
    try {
      final result = await _prober.probe();
      if (_disposed) return;

      if (result == ProbeResult.alive) {
        if (_failures > 0) {
          log(
            '★ $name watchdog: tunnel recovered (was $_failures/$maxFailures)',
            source: logSource,
          );
        }
        _failures = 0;
        return;
      }
      if (result == ProbeResult.skipped) return;

      _failures++;
      log(
        '⚠ $name watchdog: probe failed ($_failures/$maxFailures)',
        source: logSource,
      );

      if (_failures >= maxFailures) {
        await _decider.attemptRestart();
      }
    } catch (e) {
      log('⚠ $name watchdog error: $e', source: logSource);
    } finally {
      _checkRunning = false;
    }
  }
}
