part of 'app_provider.dart';

extension AppProviderWatchdogs on AppProvider {
  void ensureWatchdogs() {
    if (_watchdogManager != null) return;

    Future<bool> internetAliveCheck() async {
      final q = _qualityProvider;
      if (q != null) {
        try {
          return await q.isInternetAlive();
        } catch (e) {
          processService.addLog(
            '⚠ qualityProvider.isInternetAlive threw: $e — '
            'falling back to ConnectivityProbe',
            source: LogSource.app,
          );
        }
      }
      return _connectivityProbe.isInternetAlive();
    }

    Future<RecoveryLeaseResult> acquirePsiphonLease() async {
      final lease = _recoveryCoordinator.tryAcquire(
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
        lease: _LeaseHandleWrapper(lease, _recoveryCoordinator),
      );
    }

    Future<RecoveryLeaseResult> acquireAetherLease() async {
      final lease = _recoveryCoordinator.tryAcquire(
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
        lease: _LeaseHandleWrapper(lease, _recoveryCoordinator),
      );
    }

    Future<RecoveryLeaseResult> acquireTorLease() async {
      final lease = _recoveryCoordinator.tryAcquire(
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
        lease: _LeaseHandleWrapper(lease, _recoveryCoordinator),
      );
    }

    Future<RecoveryLeaseResult> acquireSstpLease() async {
      final lease = _recoveryCoordinator.tryAcquire(
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
        lease: _LeaseHandleWrapper(lease, _recoveryCoordinator),
      );
    }

    _watchdogManager = TunnelWatchdogFactory.build(
      provider: this,
      processService: processService,
      isInternetAlive: internetAliveCheck,
      acquirePsiphonLease: acquirePsiphonLease,
      acquireAetherLease: acquireAetherLease,
      acquireTorLease: acquireTorLease,
      acquireSstpLease: acquireSstpLease,
      restartPsiphon: () => restartPsiphonInternal(
        reason: 'watchdog detected dead tunnel',
      ),
      restartAether: () => restartAetherInternal(
        reason: 'watchdog detected dead tunnel',
      ),
      restartTor: () => restartTorInternal(
        reason: 'watchdog detected dead tunnel',
      ),
      restartSstp: () => restartSstpInternal(
        reason: 'watchdog detected dead tunnel',
      ),
    );
  }

  void syncWatchdogs() {
    ensureWatchdogs();
    _watchdogManager!.syncWithConnectionState(
      psiphonConnected: processService.isPsiphonConnected,
      aetherConnected: processService.isAetherRunning && !isAutoTesting,
      torConnected: processService.isTorConnected,
      sstpConnected: processService.isSstpConnected,
    );
  }
}

/// wrapper ساده برای lease.
class _LeaseHandleWrapper implements RecoveryLeaseHandle {
  final RecoveryLease _lease;
  final RecoveryCoordinator _coordinator;

  _LeaseHandleWrapper(this._lease, this._coordinator);

  @override
  void release() {
    _coordinator.release(_lease);
  }
}
