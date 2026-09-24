part of 'process_service.dart';

/// ═══════════════════════════════════════════════════════════════
///  ProcessServiceWireGuard — start/stop باینری wireproxy / wireproxy-awg.
///
///  ⚠️ این فایل `part of` است و نباید import مستقل داشته باشد.
///  `WireGuardCoreType` از طریق type alias در library اصلی
///  (process_service.dart) در scope این فایل قرار میگیرد.
/// ═══════════════════════════════════════════════════════════════
extension ProcessServiceWireGuard on ProcessService {
  Future<bool> startWireGuard({
    required String wrapperConfigPath,
    required WireGuardCoreType coreType,
  }) async {
    await ensureInitialized();
    if (isWireGuardRunning) return false;
    const src = LogSource.wireguard;

    try {
      final binaryPath = await WireGuardPaths.resolveBinary(coreType);
      if (binaryPath == null) {
        addLog(
          '✗ ${WireGuardPaths.binaryName(coreType)} binary not found. Place '
          '"${WireGuardPaths.binaryName(coreType)}${AppDataService.exeExt}" in the data folder '
          'or download from Core Updates.',
          source: src,
        );
        return false;
      }

      final workingDir = await WireGuardPaths.workDir();

      addLog(
        'Starting ${WireGuardPaths.binaryName(coreType)} with: $binaryPath -c $wrapperConfigPath',
        source: src,
      );

      wireGuardProcess = await Process.start(
        binaryPath,
        ['-c', wrapperConfigPath],
        workingDirectory: workingDir,
        mode: ProcessStartMode.normal,
      );
      await Future.delayed(const Duration(milliseconds: 900));

      bool exitedQuickly = false;
      try {
        final code = await wireGuardProcess!.exitCode.timeout(
          const Duration(milliseconds: 250),
        );
        exitedQuickly = true;
        addLog(
          '${WireGuardPaths.binaryName(coreType)} exited immediately (code=$code)',
          source: src,
        );
      } catch (_) {
        exitedQuickly = false;
      }

      if (exitedQuickly) {
        isWireGuardRunning = false;
        wireGuardProcess = null;
        touch();
        return false;
      }

      isWireGuardRunning = true;
      isWireGuardConnected = false;
      isWireGuardTunnelReady = false;
      addLog(
        '${WireGuardPaths.binaryName(coreType)} is running (PID: ${wireGuardProcess!.pid})',
        source: src,
      );
      touch();

      _attachWireGuardListeners();
      return true;
    } catch (e) {
      addLog('Failed to start WireGuard: $e', source: src);
      isWireGuardRunning = false;
      wireGuardProcess = null;
      touch();
      return false;
    }
  }

  void _attachWireGuardListeners() {
    const src = LogSource.wireguard;

    void handleLine(String line) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) return;
      addLog(trimmed, source: src);

      final lower = trimmed.toLowerCase();

      if (!isWireGuardTunnelReady) {
        final isResolving = lower.contains('resolving address for');
        final isInitializing = lower.contains('interface up requested') ||
            lower.contains('interface state was down, requested up') ||
            lower.contains('received handshake response');

        if (isResolving || isInitializing) {
          final wasConnected = isWireGuardConnected;
          isWireGuardTunnelReady = true;
          isWireGuardConnected = true;

          checkHappyTransition(
            tunnelName: 'WireGuard',
            wasConnected: wasConnected,
            isConnected: true,
          );

          addLog(
            '★ WireGuard tunnel ready — SOCKS is now available',
            source: src,
          );
          touch();
        }
      }
    }

    wireGuardProcess!.stdout.transform(utf8.decoder).listen((data) {
      for (final line in data.split('\n')) {
        handleLine(line);
      }
    });
    wireGuardProcess!.stderr.transform(utf8.decoder).listen((data) {
      for (final line in data.split('\n')) {
        handleLine(line);
      }
    });

    wireGuardProcess!.exitCode.then((code) {
      final wasConnected = isWireGuardConnected;
      isWireGuardRunning = false;
      isWireGuardConnected = false;
      isWireGuardTunnelReady = false;
      wireGuardProcess = null;

      checkHappyTransition(
        tunnelName: 'WireGuard',
        wasConnected: wasConnected,
        isConnected: false,
      );

      if (wasConnected && !suppressSadNotification) {
        addLog('⚠ wireproxy exited unexpectedly (code=$code)', source: src);
        setSadNotification('WireGuard');
      }
      suppressSadNotification = false;

      addLog('wireproxy exited with code $code', source: src);
      touch();
    });
  }

  Future<void> stopWireGuard() async {
    const src = LogSource.wireguard;
    suppressSadNotification = true;

    final proc = wireGuardProcess;
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
      wireGuardProcess = null;
    }

    isWireGuardRunning = false;
    isWireGuardConnected = false;
    isWireGuardTunnelReady = false;
    addLog('WireGuard stopped', source: src);
    touch();
  }
}
