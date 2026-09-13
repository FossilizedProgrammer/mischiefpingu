// lib/services/sstp_launcher.dart
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

      // ⚠️ برای اجرا از getSstpBinaryPathForExecution استفاده می‌کنیم
      // (اول dataDir، بعد platformDir به عنوان fallback)
      final binaryPath = await AppDataService.getSstpBinaryPathForExecution();

      if (!await File(binaryPath).exists()) {
        addLog('✗ SSTP binary not found: $binaryPath', source: src);
        return false;
      }

      addLog('Starting SSTP with args: ${args.join(' ')}', source: src);
      addLog('→ SSTP binary: $binaryPath', source: src);

      sstpProcess = await Process.start(
        binaryPath,
        args,
        workingDirectory: dataDir,
        mode: ProcessStartMode.normal,
      );
      await Future.delayed(const Duration(milliseconds: 900));

      // ─── بررسی خروج سریع ───
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

      _attachSstpListeners();
      return true;
    } catch (e) {
      addLog('Failed to start SSTP: $e', source: LogSource.sstp);
      isSstpRunning = false;
      sstpProcess = null;
      touch();
      return false;
    }
  }

  void _attachSstpListeners() {
    const src = LogSource.sstp;

    void handleLine(String line) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) return;
      addLog(trimmed, source: src);

      if (trimmed.contains('tunnel is UP') ||
          trimmed.contains('proxies ready')) {
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
      isSstpRunning = false;
      isSstpConnected = false;
      isSstpTunnelReady = false;
      sstpAssignedIp = null;
      pendingSstpTransportType = null;
      pendingSstpTransportDetail = null;
      pendingSstpNotification = null;
      sstpProcess = null;
      addLog('SSTP exited with code $code', source: src);
      touch();
    });
  }
}
