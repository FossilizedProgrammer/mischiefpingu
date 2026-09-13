// lib/services/aether_stopper.dart
part of 'process_service.dart';

extension ProcessServiceAetherStopper on ProcessService {
  Future<void> stopAether() async {
    const src = LogSource.aether;

    // ۱. بستن forwarder
    try {
      await _aetherSocksForwarder?.close();
    } catch (_) {}
    _aetherSocksForwarder = null;

    // ۲. kill + انتظار واقعی
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
