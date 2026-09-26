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
  p._wireGuardLog = WireGuardLogWatcher(log: p.processService.addLog);

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

  // ─── Gateway history store ───
  p._gatewayHistoryStore = GatewayHistoryStore(
    log: (msg, {source = LogSource.empty}) =>
        p.processService.addLog(msg, source: source),
  );

  // ─── Structured logging ───
  p._aetherEventStore = AetherEventStore(log: p.processService.addLog);
  p._aetherLogger = AetherLogger(
    store: p._aetherEventStore,
    log: p.processService.addLog,
  );

  // ─── Smart cache ───
  p._profilePerformanceStore = ProfilePerformanceStore(
    log: p.processService.addLog,
  );

  p._aetherTestService = AetherAutoTestService(
    processService: p.processService,
    settings: p.settings,
  );

  // ═══════════════════════════════════════════════════════════
  //  DecisionEngine — باید قبل از attachAllStores ساخته شود
  // ═══════════════════════════════════════════════════════════
  p._decisionEngine = AetherDecisionEngine(
    settings: p.settings,
    historyStore: p._gatewayHistoryStore,
    profileStore: p._profilePerformanceStore,
    logger: p._aetherLogger,
    log: p.processService.addLog,
  );

  // ─── تزریق storeها با یک rebuild واحد ───
  p._aetherTestService.attachAllStores(
    historyStore: p._gatewayHistoryStore,
    profileStore: p._profilePerformanceStore,
    logger: p._aetherLogger,
    decisionEngine: p._decisionEngine,
  );

  // ═══════════════════════════════════════════════════════════
  //  HealthMonitor + DegradationDetector + Stats
  // ═══════════════════════════════════════════════════════════
  p._healthMonitor = ConnectionHealthMonitor(
    onUpdate: (h) {
      p._currentHealth = h;
      if (p.isShuttingDown) return;
      if (p._isHealthMeaningfullyChanged(h)) {
        p._lastNotifiedHealth = h;
        p.touch();
      }
    },
    log: p.processService.addLog,
  );

  p._degradationDetector = QualityDegradationDetector(
    onDegradationDetected: (reason) {
      if (p.userStoppedAether || p.isShuttingDown) return;
      if (!p.settings.watchdogEnabled) return;

      p.processService.addLog(
        '↻ Preemptive Aether restart triggered: $reason',
        source: LogSource.aether,
      );
      // ignore: discarded_futures
      p.restartAetherInternal(reason: 'quality degradation: $reason');
    },
    onEscalateProfile: (reason) {
      if (p.userStoppedAether || p.isShuttingDown) return;
      if (!p.settings.watchdogEnabled) return;
      if (p._escalationInProgress) {
        p.processService.addLog(
          '→ Escalation skipped (already in progress)',
          source: LogSource.aether,
        );
        return;
      }

      final current = p.settings.aetherProfile;
      final next = p._nextProfile(current);

      if (next == null) {
        p.processService.addLog(
          '⚠ Cannot escalate profile: already at strict. '
          'Reason: $reason',
          source: LogSource.aether,
        );
        // ignore: discarded_futures
        p.restartAetherInternal(reason: 'no profile left: $reason');
        return;
      }

      p._escalationInProgress = true;
      p.processService.addLog(
        '↻ Auto-escalating Aether profile: '
        '$current → $next (reason: $reason)',
        source: LogSource.aether,
      );

      p.settings.applyAetherProfile(next);
      p.saveSettings();

      // ignore: discarded_futures
      p._performEscalationRestart(reason: reason);
    },
    log: p.processService.addLog,
  );

  p._statsService = QualityStatisticsService(
    eventStore: p._aetherEventStore,
    log: p.processService.addLog,
  );

  // ═══════════════════════════════════════════════════════════
  //  TunnelHealthRegistry
  // ═══════════════════════════════════════════════════════════
  p._healthRegistry = TunnelHealthRegistry(
    log: p.processService.addLog,
    onReport: (kind, report) {
      if (kind == TunnelKind.aether) return;
      if (p.isShuttingDown) return;
      p.touch();
    },
    onDegradationDetected: (kind, reason) {
      if (p.isShuttingDown) return;
      if (!p.settings.watchdogEnabled) return;
      if (kind == TunnelKind.aether) return;

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
        case TunnelKind.aether:
          return;
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
        case TunnelKind.aether:
          break;
        case TunnelKind.wireguard:
          // ignore: discarded_futures
          p.restartWireGuardInternal(reason: 'health degradation: $reason');
          break;
      }
    },
    onEscalateProfile: (kind, reason) {
      if (kind != TunnelKind.aether) return;
    },
  );
  p._healthRegistry.initialize();

  // ─── Orchestrator برای reconnect هوشمند ───
  p._gatewayReconnectOrchestrator = GatewayReconnectOrchestrator(
    processService: p.processService,
    historyStore: p._gatewayHistoryStore,
    runner: p._aetherTestService.internalRunner,
    performanceTracker: p._aetherTestService.performanceTracker,
    decisionEngine: p._decisionEngine,
  );

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

  // ─── Health poll timer ───
  p._startHealthPollTimer();

  // ─── Network change detector ───
  p._networkChangeDetector.start();

  // ─── Initialize provider (async) ───
  Future.microtask(p.initializeProvider);
}
