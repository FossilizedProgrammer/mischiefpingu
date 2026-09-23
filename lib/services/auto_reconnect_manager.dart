library;

import 'dart:async';

import 'process_service.dart';
import 'reconnect/reconnect_backoff.dart';
import 'reconnect/reconnect_scheduler.dart';

export 'reconnect/reconnect_scheduler.dart' show ReconnectLogFn;

/// ═══════════════════════════════════════════════════════════════
///  AutoReconnectManager — timerها و retry tracking.
///
///  منطق backoff در `ReconnectBackoff` جدا شده.
///  منطق scheduling در `ReconnectScheduler` جدا شده.
/// ═══════════════════════════════════════════════════════════════
class AutoReconnectManager {
  static const Duration defaultDelay = Duration(seconds: 60);
  static const Duration slowTunnelDelay = Duration(seconds: 120);

  final ReconnectBackoff _backoff = ReconnectBackoff();
  final ReconnectScheduler _scheduler = ReconnectScheduler();

  Future<bool> Function(String tunnel)? acquireLease;
  void Function(String tunnel)? releaseLease;

  void schedulePsiphonReconnect({
    Duration delay = defaultDelay,
    required bool Function() shouldReconnect,
    required void Function() onReconnect,
    required ReconnectLogFn log,
  }) {
    _scheduler.schedule(
      key: 'psiphon',
      baseDelay: delay,
      shouldReconnect: shouldReconnect,
      onReconnect: onReconnect,
      log: log,
      logSource: LogSource.psiphon,
      backoff: _backoff,
      acquireLease: acquireLease,
      releaseLease: releaseLease,
    );
  }

  void scheduleAetherReconnect({
    Duration delay = defaultDelay,
    required bool Function() shouldReconnect,
    required void Function() onReconnect,
    required ReconnectLogFn log,
  }) {
    _scheduler.schedule(
      key: 'aether',
      baseDelay: delay,
      shouldReconnect: shouldReconnect,
      onReconnect: onReconnect,
      log: log,
      logSource: LogSource.aether,
      backoff: _backoff,
      acquireLease: acquireLease,
      releaseLease: releaseLease,
    );
  }

  void scheduleTorReconnect({
    Duration delay = slowTunnelDelay,
    required bool Function() shouldReconnect,
    required void Function() onReconnect,
    required ReconnectLogFn log,
  }) {
    _scheduler.schedule(
      key: 'tor',
      baseDelay: delay,
      shouldReconnect: shouldReconnect,
      onReconnect: onReconnect,
      log: log,
      logSource: LogSource.tor,
      backoff: _backoff,
      acquireLease: acquireLease,
      releaseLease: releaseLease,
    );
  }

  void scheduleSstpReconnect({
    Duration delay = defaultDelay,
    required bool Function() shouldReconnect,
    required void Function() onReconnect,
    required ReconnectLogFn log,
  }) {
    _scheduler.schedule(
      key: 'sstp',
      baseDelay: delay,
      shouldReconnect: shouldReconnect,
      onReconnect: onReconnect,
      log: log,
      logSource: LogSource.sstp,
      backoff: _backoff,
      acquireLease: acquireLease,
      releaseLease: releaseLease,
    );
  }

  void scheduleWireGuardReconnect({
    Duration delay = defaultDelay,
    required bool Function() shouldReconnect,
    required void Function() onReconnect,
    required ReconnectLogFn log,
  }) {
    _scheduler.schedule(
      key: 'wireguard',
      baseDelay: delay,
      shouldReconnect: shouldReconnect,
      onReconnect: onReconnect,
      log: log,
      logSource: LogSource.wireguard,
      backoff: _backoff,
      acquireLease: acquireLease,
      releaseLease: releaseLease,
    );
  }

  void cancelPsiphonTimer() => _scheduler.cancel('psiphon');
  void cancelAetherTimer() => _scheduler.cancel('aether');
  void cancelTorTimer() => _scheduler.cancel('tor');
  void cancelSstpTimer() => _scheduler.cancel('sstp');
  void cancelWireGuardTimer() => _scheduler.cancel('wireguard');

  void cancelAll() => _scheduler.cancelAll();

  void resetRetries(String tunnel) => _backoff.resetRetries(tunnel);

  void resetAllRetries() => _backoff.resetAll();

  int retryCountFor(String tunnel) => _backoff.retryCountFor(tunnel);

  void dispose() => _scheduler.dispose();
}
