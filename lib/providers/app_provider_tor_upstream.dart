// lib/providers/app_provider_tor_upstream.dart
part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  هندل کردن upstream (Aether / Psiphon / SSTP) برای Tor
/// ═══════════════════════════════════════════════════════════════
extension AppProviderTorUpstream on AppProvider {
  Future<({bool ok, String type, String detail})> resolveTorUpstream({
    required bool fromAutoReconnect,
  }) async {
    const src = LogSource.tor;

    // ─── Aether ───
    if (settings.torTransport == 'aether') {
      if (processService.isAetherRunning) {
        processService.addLog('→ Tor upstream: Aether already running',
            source: src);
        return (ok: true, type: 'aether', detail: 'via Aether');
      }

      if (fromAutoReconnect && userStoppedAether) {
        torStatus = 'Tor: upstream Aether stopped by user — skipped';
        processService.addLog(
          '→ Tor auto-reconnect skipped (upstream Aether was stopped by user)',
          source: src,
        );
        touch();
        return (ok: false, type: 'aether', detail: '');
      }

      torStatus = 'Tor: starting Aether upstream…';
      touch();

      isAutoTesting = true;
      final ok = await _aetherTestService.ensureHealthy(showUi: false);
      isAutoTesting = false;

      if (userStoppedTor) {
        processService.addLog('Tor start cancelled by user', source: src);
        return (ok: false, type: 'aether', detail: '');
      }

      if (!ok && !processService.isAetherRunning) {
        torStatus = 'Tor: Aether unavailable — Tor not started';
        processService.addLog('✗ Aether unavailable → Tor not started',
            source: src);
        return (ok: false, type: 'aether', detail: '');
      }

      processService.addLog(
        '→ Tor will chain through Aether (Tor-over-Aether)',
        source: src,
      );
      return (ok: true, type: 'aether', detail: 'via Aether');
    }

    // ─── Psiphon ───
    if (settings.torTransport == 'psiphon') {
      if (processService.isPsiphonRunning) {
        processService.addLog('→ Tor upstream: Psiphon already running',
            source: src);
        return (ok: true, type: 'psiphon', detail: 'via Psiphon');
      }

      if (fromAutoReconnect && userStoppedPsiphon) {
        torStatus = 'Tor: upstream Psiphon stopped by user — skipped';
        processService.addLog(
          '→ Tor auto-reconnect skipped (upstream Psiphon was stopped by user)',
          source: src,
        );
        touch();
        return (ok: false, type: 'psiphon', detail: '');
      }

      torStatus = 'Tor: starting Psiphon upstream…';
      touch();

      await connectPsiphon(fromAutoReconnect: fromAutoReconnect);

      if (userStoppedTor) {
        processService.addLog('Tor start cancelled by user', source: src);
        return (ok: false, type: 'psiphon', detail: '');
      }

      if (!processService.isPsiphonRunning) {
        torStatus = 'Tor: Psiphon unavailable — Tor not started';
        processService.addLog('✗ Psiphon unavailable → Tor not started',
            source: src);
        return (ok: false, type: 'psiphon', detail: '');
      }

      processService.addLog('→ Tor will chain through Psiphon', source: src);
      return (ok: true, type: 'psiphon', detail: 'via Psiphon');
    }

    // ─── SSTP ───
    if (settings.torTransport == 'sstp') {
      if (processService.isSstpRunning) {
        processService.addLog('→ Tor upstream: SSTP already running',
            source: src);
        return (ok: true, type: 'sstp', detail: 'via SSTP');
      }

      if (fromAutoReconnect && userStoppedSstp) {
        torStatus = 'Tor: upstream SSTP stopped by user — skipped';
        processService.addLog(
          '→ Tor auto-reconnect skipped (upstream SSTP was stopped by user)',
          source: src,
        );
        touch();
        return (ok: false, type: 'sstp', detail: '');
      }

      torStatus = 'Tor: starting SSTP upstream…';
      touch();

      await connectSstp(fromAutoReconnect: fromAutoReconnect);

      if (userStoppedTor) {
        processService.addLog('Tor start cancelled by user', source: src);
        return (ok: false, type: 'sstp', detail: '');
      }

      if (!processService.isSstpRunning) {
        torStatus = 'Tor: SSTP unavailable — Tor not started';
        processService.addLog('✗ SSTP unavailable → Tor not started',
            source: src);
        return (ok: false, type: 'sstp', detail: '');
      }

      processService.addLog('→ Tor will chain through SSTP', source: src);
      return (ok: true, type: 'sstp', detail: 'via SSTP');
    }

    // ─── Bridge ───
    if (settings.torTransport == 'bridge') {
      final bridges = settings.torBridges.trim();
      String detail = 'direct connection';
      if (bridges.isNotEmpty) {
        if (bridges.contains('obfs4')) {
          detail = 'using obfs4 bridge';
        } else if (bridges.contains('snowflake')) {
          detail = 'using Snowflake bridge';
        } else if (bridges.contains('meek')) {
          detail = 'using Meek bridge';
        } else if (bridges.contains('webtunnel')) {
          detail = 'using WebTunnel bridge';
        } else {
          detail = 'using custom bridge';
        }
      }
      return (ok: true, type: 'bridge', detail: detail);
    }

    // ─── Direct ───
    return (ok: true, type: 'direct', detail: 'direct connection');
  }
}
