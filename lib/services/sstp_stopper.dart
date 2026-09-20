part of 'process_service.dart';

extension ProcessServiceSstpStopper on ProcessService {
  Future<void> stopSstp() async {
    const src = LogSource.sstp;

    // ═══════════════════════════════════════════════════════════
    //  ⚠️ سرکوب sad notification چون کاربر دستی stop کرده
    // ═══════════════════════════════════════════════════════════
    suppressSadNotification = true;

    final proc = sstpProcess;
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
      sstpProcess = null;
    }

    isSstpRunning = false;
    isSstpConnected = false;
    isSstpTunnelReady = false;
    sstpAssignedIp = null;
    pendingSstpTransportType = null;
    pendingSstpTransportDetail = null;
    pendingSstpNotification = null;
    addLog('SSTP stopped', source: src);
    touch();
  }
}
