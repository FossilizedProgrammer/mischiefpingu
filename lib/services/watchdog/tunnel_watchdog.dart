library;

import 'dart:async';

import 'watchdog_circuit_breaker.dart';
import 'watchdog_config.dart';
import 'watchdog_internet_gate.dart';
import 'watchdog_params.dart';
import 'watchdog_prober.dart';
import 'watchdog_quality_metrics.dart';
import 'watchdog_quality_tracker.dart';
import 'watchdog_restart_decider.dart';
import 'watchdog_types.dart';

export 'watchdog_types.dart'
    show ProbeResult, RecoveryLeaseResult, RecoveryLeaseHandle;

part 'tunnel_watchdog/check_runner.dart';

/// ═══════════════════════════════════════════════════════════════
///  TunnelWatchdog — حلقهٔ اصلی probe + تصمیم restart.
///
///  فاز ۵: حالا علاوه بر "alive/dead"، کیفیت probe را هم
///  رصد می‌کند و در صورت افت شدید کیفیت (چند بار متوالی
///  latency بالا یا خطای HTTP)، restart می‌کند.
///
///  منطق پیچیده در فایل‌های جدا:
///    • WatchdogRestartDecider → تصمیم نهایی restart
///    • WatchdogInternetGate   → چک اینترنت پایه
///    • WatchdogCircuitBreaker → circuit breaker
///    • WatchdogProber         → probe با metric
///    • WatchdogQualityTracker → ردیابی افت کیفیت
///
///  منطق `_check()` در `tunnel_watchdog/check_runner.dart`.
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

  // ⚠️ این فیلدها public شدن تا partها دسترسی داشته باشن
  //    و getter/setter اضافی لازم نباشه (رفع lint).
  int failures = 0;
  bool checkRunning = false;
  bool disposed = false;
  bool restartInProgress = false;

  bool _started = false;

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

  late final WatchdogQualityTracker _qualityTracker = WatchdogQualityTracker();

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
    isRestartInProgress: () => restartInProgress,
    setRestartInProgress: (v) => restartInProgress = v,
    resetFailures: () {
      failures = 0;
      _qualityTracker.reset();
    },
    holdFailuresAtThreshold: () => failures = params.maxFailures - 1,
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

  WatchdogProber get prober => _prober;
  WatchdogCircuitBreaker get circuit => _circuit;
  WatchdogInternetGate get internetGate => _internetGate;
  WatchdogQualityTracker get qualityTracker => _qualityTracker;
  WatchdogRestartDecider get decider => _decider;

  void start() {
    if (disposed) return;
    if (_started) return;
    _started = true;
    _timer = Timer.periodic(interval, (_) => runCheck());
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
    failures = 0;
    _qualityTracker.reset();
  }

  void dispose() {
    disposed = true;
    stop();
  }

  void resetFailures() {
    failures = 0;
    _qualityTracker.reset();
  }

  void resetGracePeriod() {
    _decider.resetGracePeriod();
  }

  void resetCircuitBreaker() {
    _circuit.reset();
    log('→ $name watchdog: circuit breaker reset', source: logSource);
  }
}
