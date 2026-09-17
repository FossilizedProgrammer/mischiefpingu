part of 'app_provider.dart';

extension AppProviderLogWatchers on AppProvider {
  /// این متد از logStream صدا زده می‌شود — هر خط جدید.
  void feedLogWatchers(String line) {
    if (isShuttingDown) return;

    if (processService.isPsiphonConnected && !restartingPsiphon) {
      final dead = psiphonLog.feed(line);
      if (dead && !userStoppedPsiphon && !isShuttingDown) {
        processService.addLog(
          '↻ Psiphon log watcher suggests restart',
          source: LogSource.psiphon,
        );
        watchdogRestartPsiphon();
      }
    } else if (!processService.isPsiphonConnected) {
      psiphonLog.reset();
    }

    if (processService.isTorRunning && !restartingTor) {
      final dead = torLog.feed(line);
      if (dead && !userStoppedTor && !isShuttingDown) {
        processService.addLog(
          '↻ Tor log watcher suggests restart',
          source: LogSource.tor,
        );
        watchdogRestartTor();
      }
    } else if (!processService.isTorRunning) {
      torLog.reset();
    }

    if (processService.isSstpRunning && !restartingSstp) {
      final dead = sstpLog.feed(line);
      if (dead && !userStoppedSstp && !isShuttingDown) {
        processService.addLog(
          '↻ SSTP log watcher suggests restart',
          source: LogSource.sstp,
        );
        watchdogRestartSstp();
      }
    } else if (!processService.isSstpRunning) {
      sstpLog.reset();
    }
  }
}
