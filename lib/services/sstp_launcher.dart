part of 'process_service.dart';

extension ProcessServiceSstpLauncher on ProcessService {
  Future<bool> launchSstpProcess({
    required List<String> args,
    required bool shareLan,
    required int socksPort,
    required int httpPort,
  }) async {
    const src = LogSource.sstp;

    try {
      final dataDir = await AppDataService.getDataDir();
      final binaryPath = await AppDataService.getSstpBinaryPathForExecution();

      if (!await File(binaryPath).exists()) {
        addLog('✗ SSTP binary not found: $binaryPath', source: src);
        return false;
      }

      addLog('Starting SSTP with args: ${args.join(' ')}', source: src);
      addLog('→ SSTP binary: $binaryPath', source: src);

      // ═══════════════════════════════════════════════════════════
      //  🆕 ریست flag هنگام start جدید
      // ═══════════════════════════════════════════════════════════
      sstpStoppedIntentionally = false;

      sstpProcess = await Process.start(
        binaryPath,
        args,
        workingDirectory: dataDir,
        mode: ProcessStartMode.normal,
      );
      await Future.delayed(const Duration(milliseconds: 900));

      bool exitedQuickly = false;
      try {
        final code = await sstpProcess!.exitCode.timeout(
          const Duration(milliseconds: 250),
        );
        exitedQuickly = true;
        addLog('SSTP exited immediately with code $code', source: src);
      } catch (_) {
        exitedQuickly = false;
      }

      if (exitedQuickly) {
        isSstpRunning = false;
        sstpProcess = null;
        touch();
        return false;
      }

      isSstpRunning = true;
      isSstpConnected = false;
      isSstpTunnelReady = false;
      addLog('SSTP is running (PID: ${sstpProcess!.pid})', source: src);
      touch();

      _attachSstpListeners(socksPort);
      return true;
    } catch (e) {
      addLog('Failed to start SSTP: $e', source: LogSource.sstp);
      isSstpRunning = false;
      sstpProcess = null;
      touch();
      return false;
    }
  }

  void _attachSstpListeners(int socksPort) {
    const src = LogSource.sstp;

    void handleLine(String line) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) return;
      addLog(trimmed, source: src);

      if (trimmed.contains('tunnel is UP') ||
          trimmed.contains('proxies ready')) {
        final wasConnected = isSstpConnected;
        final wasReady = isSstpTunnelReady;
        isSstpTunnelReady = true;
        isSstpConnected = true;

        final ipMatch =
            RegExp(r'assigned IP\s+(\d+\.\d+\.\d+\.\d+)').firstMatch(trimmed);
        if (ipMatch != null) {
          sstpAssignedIp = ipMatch.group(1);
        }

        if (pendingSstpTransportType != null) {
          setSstpNotification(
            pendingSstpTransportType!,
            detail: pendingSstpTransportDetail ?? '',
          );
        }

        checkHappyTransition(
          tunnelName: 'SSTP',
          wasConnected: wasConnected,
          isConnected: true,
        );

        // ═══════════════════════════════════════════════════════════
        //  🆕 شروع keepalive — فقط یکبار، وقتی tunnel اولین بار UP شد
        // ═══════════════════════════════════════════════════════════
        if (!wasReady) {
          onSstpTunnelReady?.call(socksPort);
        }

        touch();
      }
    }

    sstpProcess!.stdout.transform(utf8.decoder).listen((data) {
      for (final line in data.split('\n')) {
        handleLine(line);
      }
    });
    sstpProcess!.stderr.transform(utf8.decoder).listen((data) {
      for (final line in data.split('\n')) {
        handleLine(line);
      }
    });

    sstpProcess!.exitCode.then((code) {
      final wasConnected = isSstpConnected;
      isSstpRunning = false;
      isSstpConnected = false;
      isSstpTunnelReady = false;
      sstpAssignedIp = null;
      pendingSstpTransportType = null;
      pendingSstpTransportDetail = null;
      pendingSstpNotification = null;
      sstpProcess = null;

      // ═══════════════════════════════════════════════════════════
      //  🆕 توقف keepalive — ولی فقط اگر stop عمدی نبوده باشه
      //
      //  چرا؟ چون در stopSstp خودمان onSstpStopped را صدا زدیم
      //  و اینجا دوباره صدا زدن باعث duplicate می‌شه.
      // ═══════════════════════════════════════════════════════════
      if (sstpStoppedIntentionally) {
        sstpStoppedIntentionally = false;
        addLog(
          '→ SSTP exit handled (intentional stop — skipped duplicate callback)',
          source: src,
        );
      } else {
        onSstpStopped?.call();
      }

      checkHappyTransition(
        tunnelName: 'SSTP',
        wasConnected: wasConnected,
        isConnected: false,
      );

      if (wasConnected && !suppressSadNotification) {
        addLog('⚠ SSTP exited unexpectedly (code=$code)', source: src);
        setSadNotification('SSTP');
      }
      suppressSadNotification = false;

      addLog('SSTP exited with code $code', source: src);
      touch();
    });
  }
}
