part of 'app_provider.dart';

extension AppProviderHealthHelpers on AppProvider {
  bool _isHealthMeaningfullyChanged(ConnectionHealth h) {
    final prev = _lastNotifiedHealth;
    if (prev == null) return true;
    if ((h.score - prev.score).abs() > 2.0) return true;
    if ((h.latencyMs - prev.latencyMs).abs() > 50) return true;
    if ((h.jitterMs - prev.jitterMs).abs() > 30) return true;
    if ((h.packetLossPct - prev.packetLossPct).abs() > 1.0) return true;
    if (h.reconnectCount != prev.reconnectCount) return true;
    if (h.errorCount != prev.errorCount) return true;
    if (h.trend != prev.trend) return true;
    final uptimeChanged = h.uptime.inSeconds ~/ 10 != prev.uptime.inSeconds ~/ 10;
    if (uptimeChanged) return true;
    return false;
  }

  void _onNetworkChanged() {
    if (isShuttingDown) return;
    processService.addLog(
      '→ Network changed — invalidating connectivity/quality caches',
      source: LogSource.app,
    );
    try {
      _connectivityProbe.invalidateCache();
    } catch (e) {
      processService.addLog('⚠ Failed to invalidate ConnectivityProbe cache: $e', source: LogSource.app);
    }
    try {
      _qualityProvider?.invalidateCache();
    } catch (e) {
      processService.addLog('⚠ Failed to invalidate InternetQuality cache: $e', source: LogSource.app);
    }
  }

  String? _nextProfile(String current) {
    switch (current) {
      case 'adaptive': return 'patchy';
      case 'patchy': return 'strict';
      case 'strict': return null;
      case 'manual': return null;
      default: return 'strict';
    }
  }

  Future<void> _performEscalationRestart({required String reason}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      if (userStoppedAether || isShuttingDown) {
        processService.addLog('→ Escalation restart skipped (user stopped or shutting down)', source: LogSource.aether);
        return;
      }
      if (!settings.watchdogEnabled) {
        processService.addLog('→ Escalation restart skipped (watchdog disabled mid-flight)', source: LogSource.aether);
        return;
      }
      await restartAetherInternal(reason: 'profile escalation: $reason');
    } catch (e) {
      processService.addLog('⚠ Escalation restart failed: $e', source: LogSource.aether);
    } finally {
      await Future.delayed(const Duration(seconds: 30));
      _escalationInProgress = false;
    }
  }

  void _startHealthPollTimer() {
    _healthPollTimer?.cancel();
    _healthPollTimer = Timer.periodic(healthPollInterval, (_) {
      if (isShuttingDown) return;
      if (!processService.isAetherRunning) return;
      if (!settings.watchdogEnabled) return;
      final tracker = _aetherTestService.performanceTracker;
      final report = tracker?.lastReport;
      if (report == null || !report.isValid) return;
      _healthMonitor.ingestReport(report);
      final health = _currentHealth;
      if (health != null && health.isValid) {
        _degradationDetector.ingest(health);
      }
    });
  }
}
