part of 'process_service.dart';

/// ═══════════════════════════════════════════════════════════════
///  ProcessServiceWireGuard — start/stop باینری wireproxy.
///
///  ⚠️ تغییرات:
///    • پارامترهای استفاده‌نشده shareLan/socksPort حذف شدن
///    • منطق LAN از طریق `WireGuardConfigBuilder` انجام می‌شه
///      (BindAddress = 0.0.0.0 در wrapper)
///    • ✅ اصلاح تشخیص "tunnel ready": چون wireproxy خط
///      "listening" چاپ نمی‌کند، به جای آن نشانه‌های DEBUG
///      (interface up / handshake response / resolving address)
///      بررسی می‌شوند.
/// ═══════════════════════════════════════════════════════════════
extension ProcessServiceWireGuard on ProcessService {
  Future<bool> startWireGuard({
    required String wrapperConfigPath,
  }) async {
    await ensureInitialized();
    if (isWireGuardRunning) return false;
    const src = LogSource.wireguard;

    try {
      final binaryPath = await WireGuardPaths.resolveBinary();
      if (binaryPath == null) {
        addLog(
          '✗ wireproxy binary not found. Place '
          '"wireproxy${AppDataService.exeExt}" in the data folder '
          'or download from Core Updates.',
          source: src,
        );
        return false;
      }

      final workingDir = await WireGuardPaths.workDir();

      addLog(
        'Starting wireproxy with: $binaryPath -c $wrapperConfigPath',
        source: src,
      );

      wireGuardProcess = await Process.start(
        binaryPath,
        ['-c', wrapperConfigPath],
        workingDirectory: workingDir,
        mode: ProcessStartMode.normal,
      );
      await Future.delayed(const Duration(milliseconds: 900));

      // بررسی اینکه همان لحظه exit نکرده باشد
      bool exitedQuickly = false;
      try {
        final code = await wireGuardProcess!.exitCode.timeout(
          const Duration(milliseconds: 250),
        );
        exitedQuickly = true;
        addLog('wireproxy exited immediately (code=$code)', source: src);
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
        'wireproxy is running (PID: ${wireGuardProcess!.pid})',
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

      // ═══════════════════════════════════════════════════════════
      //  ✅ تشخیص آماده شدن SOCKS
      //
      //  ⚠️ نکته مهم: wireproxy خط "socks5 server listening" چاپ
      //  نمی‌کند. به جای آن، ما به دنبال نشانه‌های DEBUG می‌گردیم
      //  که ثابت می‌کنند تونل راه افتاده:
      //
      //    • "Interface up requested"
      //    • "Interface state was Down, requested Up, now Up"
      //    • "Received handshake response"
      //    • "Resolving address for ..."  ← مطمئن‌ترین نشانه
      // ═══════════════════════════════════════════════════════════
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
