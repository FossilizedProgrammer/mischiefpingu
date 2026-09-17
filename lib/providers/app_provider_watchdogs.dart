// lib/providers/app_provider_watchdogs.dart
part of 'app_provider.dart';

extension AppProviderWatchdogs on AppProvider {
  // ═══════════════════════════════════════════════════════════════
  //  Watchdog bootstrap
  // ═══════════════════════════════════════════════════════════════
  void ensureWatchdogs() {
    if (_watchdogManager != null) return;
    _watchdogManager = TunnelWatchdogFactory.build(
      provider: this,
      processService: processService,
      restartPsiphon: () => watchdogRestartPsiphon(),
      restartAether: () => watchdogRestartAether(),
      restartTor: () => watchdogRestartTor(),
      restartSstp: () => watchdogRestartSstp(),
    );
  }

  Future<void> watchdogRestartPsiphon() async {
    if (restartingPsiphon) return; // ← تغییر
    if (userStoppedPsiphon || isShuttingDown) return;
    restartingPsiphon = true; // ← تغییر
    try {
      processService.addLog(
        '↻ Watchdog: restarting Psiphon',
        source: LogSource.psiphon,
      );
      processService.setSadNotification('Psiphon');

      await processService.stopPsiphon();
      await Future.delayed(const Duration(seconds: 3));
      if (!userStoppedPsiphon && !isShuttingDown) {
        await connectPsiphon(fromAutoReconnect: true);
      }
    } finally {
      restartingPsiphon = false; // ← تغییر
    }
  }

  Future<void> watchdogRestartAether() async {
    if (restartingAether) return; // ← تغییر
    if (userStoppedAether || isShuttingDown) return;
    restartingAether = true; // ← تغییر
    try {
      processService.addLog(
        '↻ Watchdog: restarting Aether',
        source: LogSource.aether,
      );
      processService.setSadNotification('Aether');

      await processService.stopAether();
      await Future.delayed(const Duration(seconds: 3));
      if (!userStoppedAether && !isShuttingDown) {
        await connectAether(fromAutoReconnect: true);
      }
    } finally {
      restartingAether = false; // ← تغییر
    }
  }

  Future<void> watchdogRestartTor() async {
    if (restartingTor) return; // ← تغییر
    if (userStoppedTor || isShuttingDown) return;
    restartingTor = true; // ← تغییر
    try {
      processService.addLog(
        '↻ Watchdog: restarting Tor',
        source: LogSource.tor,
      );
      processService.setSadNotification('Tor');

      await processService.stopTor();
      await Future.delayed(const Duration(seconds: 3));
      if (!userStoppedTor && !isShuttingDown) {
        await connectTor(fromAutoReconnect: true);
      }
    } finally {
      restartingTor = false; // ← تغییر
    }
  }

  Future<void> watchdogRestartSstp() async {
    if (restartingSstp) return; // ← تغییر
    if (userStoppedSstp || isShuttingDown) return;
    restartingSstp = true; // ← تغییر
    try {
      processService.addLog(
        '↻ Watchdog: restarting SSTP',
        source: LogSource.sstp,
      );
      processService.setSadNotification('SSTP');

      await processService.stopSstp();
      await Future.delayed(const Duration(seconds: 3));
      if (!userStoppedSstp && !isShuttingDown) {
        await connectSstp(fromAutoReconnect: true);
      }
    } finally {
      restartingSstp = false; // ← تغییر
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  Sync watchdogها با وضعیت اتصال
  // ═══════════════════════════════════════════════════════════════
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
