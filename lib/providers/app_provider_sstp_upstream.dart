part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  هندل upstream (Aether / Psiphon / Tor) برای SSTP
///
///  ⚠️ FIX:
///   • isAutoTesting در try/finally
///   • چک userStoppedSstp بعد از هر await
/// ═══════════════════════════════════════════════════════════════
extension AppProviderSstpUpstream on AppProvider {
  Future<bool> resolveSstpUpstream({required bool fromAutoReconnect}) async {
    const src = LogSource.sstp;

    if (settings.sstpUpstreamType == 2) {
      if (processService.isAetherRunning) {
        processService.addLog(
          '→ SSTP upstream: Aether already running',
          source: src,
        );
        return true;
      }

      if (fromAutoReconnect && userStoppedAether) {
        sstpStatus = 'SSTP: upstream Aether stopped by user — skipped';
        processService.addLog(
          '→ SSTP auto-reconnect skipped (upstream Aether was stopped by user)',
          source: src,
        );
        touch();
        return false;
      }

      sstpStatus = 'SSTP: starting Aether upstream…';
      touch();

      // ⚠️ FIX: isAutoTesting در try/finally
      bool ok = false;
      isAutoTesting = true;
      try {
        ok = await _aetherTestService.ensureHealthy(showUi: false);
      } finally {
        isAutoTesting = false;
      }

      // ⚠️ FIX: چک cancel بعد از await
      if (userStoppedSstp) {
        processService.addLog(
          'SSTP start cancelled by user (during Aether upstream)',
          source: src,
        );
        return false;
      }

      if (!ok && !processService.isAetherRunning) {
        sstpStatus = 'SSTP: Aether unavailable — SSTP not started';
        processService.addLog(
          '✗ Aether unavailable → SSTP not started',
          source: src,
        );
        return false;
      }

      processService.addLog(
        '→ SSTP will use Aether as upstream proxy',
        source: src,
      );
      return true;
    }

    if (settings.sstpUpstreamType == 3) {
      if (processService.isPsiphonRunning) {
        processService.addLog(
          '→ SSTP upstream: Psiphon already running',
          source: src,
        );
        return true;
      }

      if (fromAutoReconnect && userStoppedPsiphon) {
        sstpStatus = 'SSTP: upstream Psiphon stopped by user — skipped';
        processService.addLog(
          '→ SSTP auto-reconnect skipped (upstream Psiphon was stopped by user)',
          source: src,
        );
        touch();
        return false;
      }

      sstpStatus = 'SSTP: starting Psiphon upstream…';
      touch();

      await connectPsiphon(fromAutoReconnect: fromAutoReconnect);

      // ⚠️ FIX: چک cancel
      if (userStoppedSstp) {
        processService.addLog(
          'SSTP start cancelled by user (after Psiphon upstream)',
          source: src,
        );
        return false;
      }

      if (!processService.isPsiphonRunning) {
        sstpStatus = 'SSTP: Psiphon unavailable — SSTP not started';
        processService.addLog(
          '✗ Psiphon unavailable → SSTP not started',
          source: src,
        );
        return false;
      }

      processService.addLog(
        '→ SSTP will use Psiphon as upstream proxy',
        source: src,
      );
      return true;
    }

    if (settings.sstpUpstreamType == 4) {
      if (processService.isTorRunning) {
        processService.addLog(
          '→ SSTP upstream: Tor already running',
          source: src,
        );
        return true;
      }

      if (fromAutoReconnect && userStoppedTor) {
        sstpStatus = 'SSTP: upstream Tor stopped by user — skipped';
        processService.addLog(
          '→ SSTP auto-reconnect skipped (upstream Tor was stopped by user)',
          source: src,
        );
        touch();
        return false;
      }

      sstpStatus = 'SSTP: starting Tor upstream…';
      touch();

      await connectTor(fromAutoReconnect: fromAutoReconnect);

      // ⚠️ FIX: چک cancel
      if (userStoppedSstp) {
        processService.addLog(
          'SSTP start cancelled by user (after Tor upstream)',
          source: src,
        );
        return false;
      }

      if (!processService.isTorRunning) {
        sstpStatus = 'SSTP: Tor unavailable — SSTP not started';
        processService.addLog(
          '✗ Tor unavailable → SSTP not started',
          source: src,
        );
        return false;
      }

      processService.addLog(
        '→ SSTP will use Tor as upstream proxy',
        source: src,
      );
      return true;
    }

    return true;
  }
}
