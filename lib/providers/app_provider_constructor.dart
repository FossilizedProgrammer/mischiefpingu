part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  منطق مقداردهی اولیه AppProvider.
///
///  ⚠️ این تابع از constructor خود AppProvider صدا زده می‌شه.
///
///  چرا از تابع استفاده می‌کنیم نه از متد private؟
///    • متد private روی کلاس، نیاز به `late final` داره که
///      قابل مقداردهی از بیرون نیست.
///    • این تابع همه‌ی فیلدها رو مستقیم مقداردهی می‌کنه.
///
///  ⚠️ فیلدهای `late final` در AppProvider به `late` تغییر
///  کردن تا این تابع بتونه مقداردهی کنه. چون هر فیلد فقط
///  یک بار set می‌شه، رفتار نهایی تغییری نمی‌کنه.
/// ═══════════════════════════════════════════════════════════════
void initializeAppProvider(AppProvider p) {
  p.processService.ensureInitialized();
  p.processService.addListener(p.handleProcessServiceChange);

  // ─── Log watchers ───
  p._psiphonLog = PsiphonLogWatcher(log: p.processService.addLog);
  p._torLog = TorLogWatcher(log: p.processService.addLog);
  p._sstpLog = SstpLogWatcher(log: p.processService.addLog);
  p._sstpKeepalive = SstpKeepalive(log: p.processService.addLog);
  p._wireGuardLog = WireGuardLogWatcher(log: p.processService.addLog);

  // ═══════════════════════════════════════════════════════════
  //  🆕 اتصال callbackهای SSTP keepalive به ProcessService
  // ═══════════════════════════════════════════════════════════
  p.processService.onSstpTunnelReady = (socksPort) {
    p._sstpKeepalive.start(socksPort);
  };
  p.processService.onSstpStopped = () {
    p._sstpKeepalive.stop();
  };

  p._logSubscription = p.processService.logStream.listen(
    p.feedLogWatchers,
    onError: (e) {
      p.processService.addLog(
        '⚠ logStream error: $e',
        source: LogSource.app,
      );
    },
  );

  // ─── Recovery + connectivity ───
  p._recoveryCoordinator = RecoveryCoordinator(log: p.processService.addLog);
  p._connectivityProbe = ConnectivityProbe(log: p.processService.addLog);

  // ─── Network change detector ───
  p._networkChangeDetector = NetworkChangeDetector(
    log: p.processService.addLog,
    onChange: p._onNetworkChanged,
  );

  // ═══════════════════════════════════════════════════════════
  //  TunnelHealthRegistry
  // ═══════════════════════════════════════════════════════════
  p._healthRegistry = TunnelHealthRegistry(
    log: p.processService.addLog,
    onReport: (kind, report) {
      if (p.isShuttingDown) return;
      p.touch();
    },
    onDegradationDetected: (kind, reason) {
      if (p.isShuttingDown) return;
      if (!p.settings.watchdogEnabled) return;

      switch (kind) {
        case TunnelKind.psiphon:
          if (p.userStoppedPsiphon) return;
          break;
        case TunnelKind.tor:
          if (p.userStoppedTor) return;
          break;
        case TunnelKind.sstp:
          if (p.userStoppedSstp) return;
          break;
        case TunnelKind.wireguard:
          if (p.userStoppedWireGuard) return;
          break;
      }

      p.processService.addLog(
        '↻ ${kind.displayName} preemptive restart triggered: $reason',
        source: LogSource.app,
      );

      switch (kind) {
        case TunnelKind.psiphon:
          // ignore: discarded_futures
          p.restartPsiphonInternal(reason: 'health degradation: $reason');
          break;
        case TunnelKind.tor:
          // ignore: discarded_futures
          p.restartTorInternal(reason: 'health degradation: $reason');
          break;
        case TunnelKind.sstp:
          // ignore: discarded_futures
          p.restartSstpInternal(reason: 'health degradation: $reason');
          break;
        case TunnelKind.wireguard:
          // ignore: discarded_futures
          p.restartWireGuardInternal(reason: 'health degradation: $reason');
          break;
      }
    },
    onEscalateProfile: (kind, reason) {},
  );
  p._healthRegistry.initialize();

  // ─── Lease callbacks برای reconnect manager ───
  p._reconnectManager.acquireLease = (tunnel) async {
    final tunnelName = p._tunnelDisplayName(tunnel);
    final lease = p._recoveryCoordinator.tryAcquire(
      tunnel: tunnelName,
      action: RecoveryAction.autoReconnect,
      reason: 'process exited unexpectedly',
    );
    return lease != null;
  };

  p._reconnectManager.releaseLease = (tunnel) {
    final tunnelName = p._tunnelDisplayName(tunnel);
    p._recoveryCoordinator.releaseLeaseByTunnel(tunnelName);
  };

  // ─── Network change detector ───
  p._networkChangeDetector.start();

  // ─── Initialize provider (async) ───
  Future.microtask(p.initializeProvider);
}
