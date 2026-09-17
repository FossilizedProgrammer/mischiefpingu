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

      addLog('Psiphon exited with code $code', source: src);
      touch();
    });
  }
}
