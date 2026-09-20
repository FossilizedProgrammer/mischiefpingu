part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  Process listener — واکنش به تغییرات ProcessService
///
///  ⚠️ نکته مهم:
///  این listener روی *هر* notifyListeners از ProcessService صدا زده
///  می‌شود — و ProcessService روی هر خط لاگ notify می‌کند!
///
///  برای جلوگیری از:
///    • حلقهٔ restart بین watchdog و auto-reconnect
///    • sync مداوم watchdog (start/stop پشت سر هم)
///    • بار زیاد روی checkAutoReconnects
///
///  فقط وقتی state *واقعی* تونل‌ها تغییر کرد، منطق سنگین اجرا می‌شود.
///
///  ⚠️ کلاس `_TunnelStateSnapshot` در `app_provider.dart` تعریف
///  شده — اینجا فقط استفاده می‌شود. آن را دوباره تعریف نکنید!
///
///  ⚠️ اضافه‌شده در این نسخه:
///  `tryParseAetherRealEndpoint` — استخراج endpoint واقعی از لاگ
///  Aether و ذخیرهٔ آن برای fast-path بعدی.
/// ═══════════════════════════════════════════════════════════════
extension AppProviderProcessListener on AppProvider {
  void handleProcessServiceChange() {
    if (isShuttingDown) return;

    final logs = processService.fullLog;
    if (logs.isNotEmpty) {
      final last = logs.last;
      tryParseFoundFronting(last);
      tryParseBuildRev(last);

      // ═══════════════════════════════════════════════════════════
      //  ⚠️ اضافه‌شده: استخراج endpoint واقعی Aether
      // ═══════════════════════════════════════════════════════════
      tryParseAetherRealEndpoint(last);
    }

    final currentState = _TunnelStateSnapshot(
      psiphonRunning: processService.isPsiphonRunning,
      psiphonConnected: processService.isPsiphonConnected,
      aetherRunning: processService.isAetherRunning,
      torRunning: processService.isTorRunning,
      torConnected: processService.isTorConnected,
      torBootstrapProgress: processService.torBootstrapProgress,
      sstpRunning: processService.isSstpRunning,
      sstpConnected: processService.isSstpConnected,
    );

    final previousState = _lastTunnelState;
    final stateChanged = previousState != currentState;
    _lastTunnelState = currentState;

    if (stateChanged) {
      checkAutoReconnects();
      updateTunnelStatuses();
      syncWatchdogs();

      _syncHealthMonitors(currentState, previousState);
    }

    touch();
  }

  void _syncHealthMonitors(
    _TunnelStateSnapshot current,
    _TunnelStateSnapshot? previous,
  ) {
    // ─── Psiphon ───
    final psiphonWasConnected = previous?.psiphonConnected ?? false;
    final psiphonIsConnected = current.psiphonConnected;

    if (psiphonIsConnected && !psiphonWasConnected) {
      _healthRegistry.startMonitor(
        TunnelKind.psiphon,
        DateTime.now(),
      );
      processService.addLog(
        '→ Psiphon health monitor started',
        source: LogSource.app,
      );
    } else if (!psiphonIsConnected && psiphonWasConnected) {
      _healthRegistry.stopMonitor(TunnelKind.psiphon);
      processService.addLog(
        '→ Psiphon health monitor stopped',
        source: LogSource.app,
      );
    }

    // ─── Tor ───
    final torWasConnected = previous?.torConnected ?? false;
    final torIsConnected = current.torConnected;

    if (torIsConnected && !torWasConnected) {
      _healthRegistry.startMonitor(
        TunnelKind.tor,
        DateTime.now(),
      );
      processService.addLog(
        '→ Tor health monitor started',
        source: LogSource.app,
      );
    } else if (!torIsConnected && torWasConnected) {
      _healthRegistry.stopMonitor(TunnelKind.tor);
      processService.addLog(
        '→ Tor health monitor stopped',
        source: LogSource.app,
      );
    }

    // ─── SSTP ───
    final sstpWasConnected = previous?.sstpConnected ?? false;
    final sstpIsConnected = current.sstpConnected;

    if (sstpIsConnected && !sstpWasConnected) {
      _healthRegistry.startMonitor(
        TunnelKind.sstp,
        DateTime.now(),
      );
      processService.addLog(
        '→ SSTP health monitor started',
        source: LogSource.app,
      );
    } else if (!sstpIsConnected && sstpWasConnected) {
      _healthRegistry.stopMonitor(TunnelKind.sstp);
      processService.addLog(
        '→ SSTP health monitor stopped',
        source: LogSource.app,
      );
    }
  }
}
