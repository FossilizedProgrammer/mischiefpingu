part of 'app_provider.dart';

extension AppProviderLogWatchers on AppProvider {
  /// این متد از logStream صدا زده می‌شود — هر خط جدید.
  ///
  /// ⚠️ اصلاح مهم:
  /// قبل از تصمیم به restart، یک probe واقعی روی SOCKS انجام می‌شود
  /// تا مطمئن شویم tunnel واقعاً مرده است.
  void feedLogWatchers(String line) {
    if (isShuttingDown) return;

    if (processService.isPsiphonConnected && !restartingPsiphon) {
      final dead = psiphonLog.feed(line);
      if (dead && !userStoppedPsiphon && !isShuttingDown) {
        _verifyAndRestartPsiphon();
      }
    } else if (!processService.isPsiphonConnected) {
      psiphonLog.reset();
    }

    if (processService.isTorRunning && !restartingTor) {
      final dead = torLog.feed(line);
      if (dead && !userStoppedTor && !isShuttingDown) {
        _verifyAndRestartTor();
      }
    } else if (!processService.isTorRunning) {
      torLog.reset();
    }

    if (processService.isSstpRunning && !restartingSstp) {
      final dead = sstpLog.feed(line);
      if (dead && !userStoppedSstp && !isShuttingDown) {
        _verifyAndRestartSstp();
      }
    } else if (!processService.isSstpRunning) {
      sstpLog.reset();
    }
  }

  /// ⚠️ جدید: قبل از restart، SOCKS probe بزن.
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
