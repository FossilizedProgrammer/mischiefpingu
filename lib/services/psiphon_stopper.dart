// lib/services/psiphon_stopper.dart
part of 'process_service.dart';

extension ProcessServicePsiphonStopper on ProcessService {
  /// توقف کامل Psiphon + بستن forwarderها + پاک‌سازی state
  Future<void> shutdownPsiphonProcess() async {
    const src = LogSource.psiphon;

    // ─── بستن forwarderها ───
    try {
      await psiphonSocksForwarder?.close();
    } catch (_) {}
    try {
      await psiphonHttpForwarder?.close();
    } catch (_) {}
    psiphonSocksForwarder = null;
    psiphonHttpForwarder = null;

    // ─── بستن سوکت‌های forward فعال ───
    for (final s in List<Socket>.from(activeForwardSockets)) {
      try {
        s.destroy();
      } catch (_) {}
    }
    activeForwardSockets.clear();

    // ─── kill پروسه اصلی ───
    final proc = psiphonProcess;
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
      psiphonProcess = null;
    }

    // ─── ریست state ───
    isPsiphonRunning = false;
    isPsiphonConnected = false;
    lastPsiphonProtocol = null;
    pendingProtocolNotification = null;
    pendingProtocolBinary = null;
    currentPsiphonBinaryName = null;

    addLog('Psiphon & LAN forwarders stopped', source: src);
    touch();
  }
}
