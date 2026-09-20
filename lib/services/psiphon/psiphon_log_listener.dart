part of '../process_service.dart';

extension ProcessServicePsiphonListener on ProcessService {
  void attachPsiphonListeners(String binaryName) {
    const src = LogSource.psiphon;

    void handleLine(String trimmed) {
      if (trimmed.isEmpty) return;
      addLog(trimmed, source: src);

      if (!trimmed.contains('"noticeType":"ActiveTunnel"')) {
        return;
      }

      final protocol = LogLineParsers.parseActiveTunnelProtocol(trimmed);
      if (protocol == null || protocol.isEmpty) {
        return;
      }

      final wasConnected = isPsiphonConnected;
      isPsiphonConnected = true;
      lastPsiphonProtocol = protocol;
      pendingProtocolNotification = protocol;
      pendingProtocolBinary = binaryName;

      checkHappyTransition(
        tunnelName: 'Psiphon',
        wasConnected: wasConnected,
        isConnected: true,
      );

      touch();
    }

    psiphonProcess!.stdout.transform(utf8.decoder).listen((data) {
      for (final line in data.split('\n')) {
        handleLine(line.trim());
      }
    });
    psiphonProcess!.stderr.transform(utf8.decoder).listen((data) {
      for (final line in data.split('\n')) {
        handleLine(line.trim());
      }
    });

    psiphonProcess!.exitCode.then((code) {
      final wasConnected = isPsiphonConnected;
      isPsiphonRunning = false;
      isPsiphonConnected = false;
      lastPsiphonProtocol = null;
      pendingProtocolNotification = null;
      pendingProtocolBinary = null;
      currentPsiphonBinaryName = null;
      psiphonProcess = null;

      checkHappyTransition(
        tunnelName: 'Psiphon',
        wasConnected: wasConnected,
        isConnected: false,
      );

      // ═══════════════════════════════════════════════════════════
      //  ⚠️ sad notification هنگام خروج غیرمنتظره
      //
      //  اگر کاربر خودش stop نکرده باشد (suppressSadNotification
      //  false باشد) و تونل قبلاً وصل بوده، پنگوئن غمگین می‌شود.
      // ═══════════════════════════════════════════════════════════
      if (wasConnected && !suppressSadNotification) {
        addLog(
          '⚠ Psiphon exited unexpectedly (code=$code)',
          source: src,
        );
        setSadNotification('Psiphon');
      }
      suppressSadNotification = false;

      addLog('Psiphon exited with code $code', source: src);
      touch();
    });
  }
}
