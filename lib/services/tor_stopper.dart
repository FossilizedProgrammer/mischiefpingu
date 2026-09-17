part of 'process_service.dart';

extension ProcessServiceTorStopper on ProcessService {
  Future<void> stopTor() async {
    const src = LogSource.tor;

    try {
      await torSocksForwarder?.close();
    } catch (_) {}
    try {
      await torHttpForwarder?.close();
    } catch (_) {}
    torSocksForwarder = null;
    torHttpForwarder = null;

    final proc = torProcess;
    if (proc != null) {
      try {
        proc.kill(ProcessSignal.sigterm);
        await proc.exitCode.timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            try {
              proc.kill(ProcessSignal.sigkill);
            } catch (_) {}
            return -1;
          },
        );
      } catch (_) {
        try {
          proc.kill(ProcessSignal.sigkill);
        } catch (_) {}
      }
      torProcess = null;
    }

    isTorRunning = false;
    isTorConnected = false;
    torBootstrapProgress = 0;
    pendingTorTransportType = null;
    pendingTorTransportDetailPrepared = null;
    addLog('Tor stopped', source: src);
    touch();
  }
}
