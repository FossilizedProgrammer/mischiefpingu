part of 'process_service.dart';

extension ProcessServiceAetherStopper on ProcessService {
  Future<void> stopAether() async {
    const src = LogSource.aether;

    try {
      await _aetherSocksForwarder?.close();
    } catch (_) {}
    _aetherSocksForwarder = null;

    final proc = aetherProcess;
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
      aetherProcess = null;
    }

    isAetherRunning = false;
    addLog('Aether stopped', source: src);
    touch();
  }
}
