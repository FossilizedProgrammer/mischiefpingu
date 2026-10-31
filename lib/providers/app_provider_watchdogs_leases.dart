part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  Watchdog Lease Acquirers — callbackهای acquireRecoveryLease.
///
///  این توابع top-level هستن (نه متد روی AppProvider) چون:
///    • نیازی به دسترسی به fieldهای private ندارن
///    • `RecoveryCoordinator` مستقیم پاس داده می‌شه
///    • تست‌پذیرتر هستن
///
///  الگوی مشترک:
///    1. tryAcquire از coordinator
///    2. اگه موفق نبود → denied با reason
///    3. اگه موفق بود → granted + wrapper برای release
/// ═══════════════════════════════════════════════════════════════

// ─── Internet alive check ───

/// ساخت callback چک Internet alive.
///
/// اگه `_qualityProvider` موجود باشه از اون استفاده می‌کنه،
/// وگرنه fallback به `_connectivityProbe`.
Future<bool> Function() _buildInternetAliveCheck(AppProvider p) {
  return () async {
    final q = p.qualityProvider;
    if (q != null) {
      try {
        return await q.isInternetAlive();
      } catch (e) {
        p.processService.addLog(
          '⚠ qualityProvider.isInternetAlive threw: $e — '
          'falling back to ConnectivityProbe',
          source: LogSource.app,
        );
      }
    }
    return p.connectivityProbe.isInternetAlive();
  };
}

// ─── Lease acquirerها ───

/// ساخت callback acquire Psiphon lease.
Future<RecoveryLeaseResult> Function() _makePsiphonLeaseAcquirer(
  AppProvider p,
  RecoveryCoordinator coordinator,
) {
  return () async {
    final lease = coordinator.tryAcquire(
      tunnel: 'Psiphon',
      action: RecoveryAction.watchdogRestart,
      reason: 'watchdog detected dead tunnel',
    );
    if (lease == null) {
      return const RecoveryLeaseResult.denied(
        'another recovery is in progress',
      );
    }
    return RecoveryLeaseResult(
      granted: true,
      lease: _LeaseHandleWrapper(lease, coordinator),
    );
  };
}

/// ساخت callback acquire Aether lease.
Future<RecoveryLeaseResult> Function() _makeAetherLeaseAcquirer(
  AppProvider p,
  RecoveryCoordinator coordinator,
) {
  return () async {
    final lease = coordinator.tryAcquire(
      tunnel: 'Aether',
      action: RecoveryAction.watchdogRestart,
      reason: 'watchdog detected dead tunnel',
    );
    if (lease == null) {
      return const RecoveryLeaseResult.denied(
        'another recovery is in progress',
      );
    }
    return RecoveryLeaseResult(
      granted: true,
      lease: _LeaseHandleWrapper(lease, coordinator),
    );
  };
}

/// ساخت callback acquire Tor lease.
Future<RecoveryLeaseResult> Function() _makeTorLeaseAcquirer(
  AppProvider p,
  RecoveryCoordinator coordinator,
) {
  return () async {
    final lease = coordinator.tryAcquire(
      tunnel: 'Tor',
      action: RecoveryAction.watchdogRestart,
      reason: 'watchdog detected dead tunnel',
    );
    if (lease == null) {
      return const RecoveryLeaseResult.denied(
        'another recovery is in progress',
      );
    }
    return RecoveryLeaseResult(
      granted: true,
      lease: _LeaseHandleWrapper(lease, coordinator),
    );
  };
}

/// ساخت callback acquire SSTP lease.
Future<RecoveryLeaseResult> Function() _makeSstpLeaseAcquirer(
  AppProvider p,
  RecoveryCoordinator coordinator,
) {
  return () async {
    final lease = coordinator.tryAcquire(
      tunnel: 'SSTP',
      action: RecoveryAction.watchdogRestart,
      reason: 'watchdog detected dead tunnel',
    );
    if (lease == null) {
      return const RecoveryLeaseResult.denied(
        'another recovery is in progress',
      );
    }
    return RecoveryLeaseResult(
      granted: true,
      lease: _LeaseHandleWrapper(lease, coordinator),
    );
  };
}

/// ساخت callback acquire WireGuard lease.
Future<RecoveryLeaseResult> Function() _makeWireGuardLeaseAcquirer(
  AppProvider p,
  RecoveryCoordinator coordinator,
) {
  return () async {
    final lease = coordinator.tryAcquire(
      tunnel: 'WireGuard',
      action: RecoveryAction.watchdogRestart,
      reason: 'watchdog detected dead tunnel',
    );
    if (lease == null) {
      return const RecoveryLeaseResult.denied(
        'another recovery is in progress',
      );
    }
    return RecoveryLeaseResult(
      granted: true,
      lease: _LeaseHandleWrapper(lease, coordinator),
    );
  };
}
