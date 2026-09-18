library;

import 'dart:async';

import 'watchdog_config.dart';
import 'watchdog_params.dart';
import 'watchdog_prober.dart';

/// نتیجهٔ یک probe.
enum ProbeResult { alive, dead, skipped }

class TunnelWatchdog {
  final WatchdogParams params;
  final bool Function() isConnected;
  final bool Function() isUserStopped;
  final bool Function()? isBusy;
  final Future<void> Function() onRestart;
  final void Function(String message, {String source}) log;
  final String logSource;

  Timer? _timer;
  int _failures = 0;
  bool _checkRunning = false;
  bool _disposed = false;
  bool _started = false;

  /// ⚠️ زمان آخرین restart برای grace period.
  DateTime? _lastRestartAt;

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

  TunnelWatchdog({
    required this.params,
    required this.isConnected,
    required this.isUserStopped,
    required this.onRestart,
    required this.log,
    required this.logSource,
    this.isBusy,
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

  Future<void> _check() async {
    if (_disposed || _checkRunning) return;

    final lastRestart = _lastRestartAt;
    if (lastRestart != null) {
      final elapsed = DateTime.now().difference(lastRestart);
      if (elapsed < WatchdogConfig.restartGracePeriod) {
        final remaining = WatchdogConfig.restartGracePeriod - elapsed;
        log(
          '→ $name watchdog: in grace period, ${remaining.inSeconds}s remaining',
          source: logSource,
        );
        return;
      }
      _lastRestartAt = null;
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
        _failures = 0;
        log(
          '↻ $name watchdog: tunnel dead after $maxFailures consecutive failures — restarting',
          source: logSource,
        );
        _lastRestartAt = DateTime.now();
        try {
          await onRestart();
        } catch (e) {
          log('⚠ $name watchdog: onRestart error: $e', source: logSource);
        }
      }
    } catch (e) {
      log('⚠ $name watchdog error: $e', source: logSource);
    } finally {
      _checkRunning = false;
    }
  }
}
