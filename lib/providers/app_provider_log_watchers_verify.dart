part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  AppProviderLogWatchersVerify — منطق verify + restart
///
///  این extension از `app_provider_log_watchers.dart` جدا شده
///  تا فایل اصلی کوتاه‌تر بشه و فقط feedLogWatchers رو نگه داره.
/// ═══════════════════════════════════════════════════════════════
extension AppProviderLogWatchersVerify on AppProvider {
  /// ⚠️ قبل از restart، SOCKS probe بزن.
  /// اگر tunnel واقعاً زنده است، watcher را ریست کن.
  Future<void> _verifyAndRestartPsiphon() async {
    const src = LogSource.psiphon;
    final internetOk = await _connectivityProbe.isInternetAlive();
    if (!internetOk) {
      processService.addLog(
        '⚠ Psiphon log watcher triggered but Internet is DOWN — '
        'skipping restart (watcher reset)',
        source: src,
      );
      psiphonLog.reset();
      return;
    }
    final alive = await _probeSocks(settings.socksPort);
    if (alive) {
      processService.addLog(
        '✅ Psiphon log watcher suggested restart but SOCKS is alive '
        '— skipping restart (watcher reset)',
        source: src,
      );
      psiphonLog.reset();
      return;
    }
    processService.addLog(
      '⚠ Psiphon log watcher suggests restart (verified dead via SOCKS probe)',
      source: src,
    );
    await restartPsiphonInternal(reason: 'log watcher detected dead tunnel');
  }

  Future<void> _verifyAndRestartTor() async {
    const src = LogSource.tor;
    final internetOk = await _connectivityProbe.isInternetAlive();
    if (!internetOk) {
      processService.addLog(
        '⚠ Tor log watcher triggered but Internet is DOWN — '
        'skipping restart (watcher reset)',
        source: src,
      );
      torLog.reset();
      return;
    }
    final alive = await _probeSocks(settings.torSocksPort);
    if (alive) {
      processService.addLog(
        '✅ Tor log watcher suggested restart but SOCKS is alive '
        '— skipping restart (watcher reset)',
        source: src,
      );
      torLog.reset();
      return;
    }
    processService.addLog(
      '⚠ Tor log watcher suggests restart (verified dead via SOCKS probe)',
      source: src,
    );
    await restartTorInternal(reason: 'log watcher detected dead tunnel');
  }

  Future<void> _verifyAndRestartSstp() async {
    const src = LogSource.sstp;
    final internetOk = await _connectivityProbe.isInternetAlive();
    if (!internetOk) {
      processService.addLog(
        '⚠ SSTP log watcher triggered but Internet is DOWN — '
        'skipping restart (watcher reset)',
        source: src,
      );
      sstpLog.reset();
      return;
    }
    final alive = await _probeSocks(settings.sstpSocksPort);
    if (alive) {
      processService.addLog(
        '✅ SSTP log watcher suggested restart but SOCKS is alive '
        '— skipping restart (watcher reset)',
        source: src,
      );
      sstpLog.reset();
      return;
    }
    processService.addLog(
      '⚠ SSTP log watcher suggests restart (verified dead via SOCKS probe)',
      source: src,
    );
    await restartSstpInternal(reason: 'log watcher detected dead tunnel');
  }

  Future<void> _verifyAndRestartWireGuard() async {
    const src = LogSource.wireguard;
    final internetOk = await _connectivityProbe.isInternetAlive();
    if (!internetOk) {
      processService.addLog(
        '⚠ WireGuard log watcher triggered but Internet is DOWN — '
        'skipping restart',
        source: src,
      );
      _wireGuardLog.reset();
      return;
    }
    final alive = await _probeSocks(settings.wireguardSocksPort);
    if (alive) {
      processService.addLog(
        '✅ WireGuard log watcher suggested restart but SOCKS is alive '
        '— skipping',
        source: src,
      );
      _wireGuardLog.reset();
      return;
    }
    processService.addLog(
      '⚠ WireGuard log watcher suggests restart '
      '(verified dead via SOCKS probe)',
      source: src,
    );
    await restartWireGuardInternal(
      reason: 'log watcher detected dead tunnel',
    );
  }

  /// ⚠️ probe واقعی SOCKS5.
  /// true = SOCKS زنده است (greeting درست جواب داد).
  Future<bool> _probeSocks(int port) async {
    Socket? sock;
    try {
      sock = await Socket.connect(
        '127.0.0.1',
        port,
        timeout: const Duration(seconds: 3),
      );
      sock.add([0x05, 0x01, 0x00]);
      await sock.flush();
      final greet = await sock.timeout(const Duration(seconds: 3)).first;
      if (greet.isEmpty) return false;
      if (greet[0] != 0x05) return false;
      return true;
    } catch (_) {
      return false;
    } finally {
      try {
        sock?.destroy();
      } catch (_) {}
    }
  }
}
