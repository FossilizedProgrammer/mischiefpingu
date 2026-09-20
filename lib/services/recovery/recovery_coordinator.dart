library;

import 'dart:async';

import '../process/log_source.dart';
import 'recovery_lease.dart';
import 'recovery_timeouts.dart';

export 'recovery_lease.dart' show RecoveryAction, RecoveryLease;

/// ═══════════════════════════════════════════════════════════════
///  RecoveryCoordinator — قفل مرکزی برای جلوگیری از restart همزمان
///
///  این coordinator تضمین می‌کند:
///    • در هر لحظه فقط یک recovery operation برای هر tunnel
///    • در هر لحظه فقط یک recovery operation در کل برنامه
///    • timeout دارد تا lock هرگز برای همیشه نگه داشته نشود
/// ═══════════════════════════════════════════════════════════════
class RecoveryCoordinator {
  final void Function(String message, {String source}) log;

  final Map<String, RecoveryLease> _activeLeases = {};
  RecoveryLease? _globalLease;
  final Map<String, Timer> _leaseTimers = {};

  RecoveryCoordinator({required this.log});

  bool get isAnyRecoveryActive =>
      _globalLease != null || _activeLeases.isNotEmpty;

  bool isRecoveryActive(String tunnel) => _activeLeases.containsKey(tunnel);

  RecoveryAction? activeActionFor(String tunnel) =>
      _activeLeases[tunnel]?.action;

  /// تلاش برای گرفتن lease.
  RecoveryLease? tryAcquire({
    required String tunnel,
    required RecoveryAction action,
    required String reason,
    bool allowConcurrentWithTunnel = false,
  }) {
    final existing = _activeLeases[tunnel];
    if (existing != null) {
      if (existing.isExpired(tunnel)) {
        log(
          '⚠ RecoveryCoordinator: stale lease for $tunnel '
          '(${existing.action.name}, ${existing.reason}) — forcing release',
          source: LogSource.app,
        );
        _forceRelease(tunnel);
      } else {
        log(
          '→ RecoveryCoordinator: $tunnel already has active lease '
          '(${existing.action.name}) — ${action.name} blocked',
          source: LogSource.app,
        );
        return null;
      }
    }

    if (!allowConcurrentWithTunnel && _globalLease != null) {
      log(
        '→ RecoveryCoordinator: global recovery in progress '
        '(${_globalLease!.tunnel}/${_globalLease!.action.name}) — '
        '${action.name} for $tunnel blocked',
        source: LogSource.app,
      );
      return null;
    }

    final lease = RecoveryLease(tunnel: tunnel, action: action, reason: reason);

    _activeLeases[tunnel] = lease;
    _globalLease ??= lease;

    final timeout = RecoveryTimeouts.forTunnel(tunnel);
    _leaseTimers[tunnel]?.cancel();
    _leaseTimers[tunnel] = Timer(timeout, () {
      final current = _activeLeases[tunnel];
      if (current != null && identical(current, lease) && !current.isReleased) {
        log(
          '⚠ RecoveryCoordinator: lease for $tunnel '
          '(${lease.action.name}) exceeded timeout '
          '(${timeout.inSeconds}s) — auto-releasing',
          source: LogSource.app,
        );
        _forceRelease(tunnel);
      }
    });

    log(
      '★ RecoveryCoordinator: lease acquired for $tunnel '
      '(${action.name}) — reason: $reason',
      source: LogSource.app,
    );

    return lease;
  }

  void release(RecoveryLease? lease) {
    if (lease == null) return;

    final l = lease;
    if (l.isReleased) return;

    final current = _activeLeases[l.tunnel];
    if (current == null || !identical(current, l)) {
      l.markReleased();
      return;
    }

    _forceRelease(l.tunnel);
  }

  void releaseLeaseByTunnel(String tunnel) {
    if (!_activeLeases.containsKey(tunnel)) {
      log(
        '→ RecoveryCoordinator: releaseLeaseByTunnel($tunnel) — '
        'no active lease, nothing to release',
        source: LogSource.app,
      );
      return;
    }
    _forceRelease(tunnel);
  }

  void _forceRelease(String tunnel) {
    final lease = _activeLeases.remove(tunnel);
    if (lease == null) return;

    lease.markReleased();

    _leaseTimers[tunnel]?.cancel();
    _leaseTimers.remove(tunnel);

    if (_globalLease != null && identical(_globalLease, lease)) {
      _globalLease =
          _activeLeases.values.isNotEmpty ? _activeLeases.values.first : null;
    }

    log(
      '→ RecoveryCoordinator: lease released for $tunnel '
      '(${lease.action.name})',
      source: LogSource.app,
    );
  }

  void releaseAll() {
    for (final tunnel in _activeLeases.keys.toList()) {
      _forceRelease(tunnel);
    }
    _globalLease = null;
  }

  void dispose() {
    for (final t in _leaseTimers.values) {
      t.cancel();
    }
    _leaseTimers.clear();
    _activeLeases.clear();
    _globalLease = null;
  }

  String describe() {
    if (_activeLeases.isEmpty) return 'idle';
    return _activeLeases.entries
        .map((e) => '${e.key}:${e.value.action.name}')
        .join(', ');
  }
}
