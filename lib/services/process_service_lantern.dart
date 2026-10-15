part of 'process_service.dart';

/// ═══════════════════════════════════════════════════════════════
///  ProcessServiceLantern — start/stop باینری لنترن (headless).
///
///  لنترن یک پروکسی محلی SOCKS5/HTTP بالا می‌آورد که ترافیک را از شبکهٔ
///  لنترن عبور می‌دهد. فلگ `--raw` هنگام اجرا باعث می‌شود خروجی pterm
///  بدون رنگ باشد و خواندن خطوط ساده‌تر شود.
///
///  خطوط مهم خروجی:
///    • "Local proxy is listening — SOCKS5: … HTTP: …" → تونل آماده است
///    • "Data path OK — HTTP 204 …"                    → مسیر داده سالم است
///    • "Data path is NOT working"                     → پورت‌ها بالا ولی
///      ترافیک عبور نمی‌کند (معمولاً یعنی آپ‌استریم لازم است)
///    • "Failed to start Lantern"                      → خطای سمت سرور
/// ═══════════════════════════════════════════════════════════════
extension ProcessServiceLantern on ProcessService {
  /// argv (شامل فلگ‌های سراسری و زیرفرمان start) باید آماده باشد؛
  /// ساخت آن بر عهدهٔ [LanternCliService.startArgs] است.
  Future<bool> startLantern({
    required String binaryPath,
    required List<String> args,
  }) async {
    await ensureInitialized();
    if (isLanternRunning) return false;
    const src = LogSource.lantern;

    try {
      addLog(
        'Starting lantern with: $binaryPath '
        '${LanternCliService.maskArgs(args)}',
        source: src,
      );

      final process = await Process.start(
        binaryPath,
        args,
        mode: ProcessStartMode.normal,
      );
      lanternProcess = process;

      _attachLanternListeners(process);

      // اگر داده‌پس یا فلگی اشتباه باشد، باینری در کمتر از یک ثانیه
      // خارج می‌شود؛ مثل ffvpn یک چک سریع exit انجام می‌دهیم.
      await Future.delayed(const Duration(milliseconds: 900));

      var exitedQuickly = false;
      try {
        final code = await process.exitCode.timeout(
          const Duration(milliseconds: 250),
        );
        exitedQuickly = true;
        addLog('lantern exited immediately (code=$code)', source: src);
      } catch (_) {
        exitedQuickly = false;
      }

      if (exitedQuickly) {
        isLanternRunning = false;
        isLanternConnected = false;
        lanternProcess = null;
        touch();
        return false;
      }

      isLanternRunning = true;
      isLanternConnected = false;
      addLog('lantern is running (PID: ${process.pid})', source: src);
      touch();
      return true;
    } catch (e) {
      addLog('Failed to start Lantern: $e', source: src);
      isLanternRunning = false;
      isLanternConnected = false;
      lanternProcess = null;
      touch();
      return false;
    }
  }

  void _attachLanternListeners(Process process) {
    const src = LogSource.lantern;

    void handleLine(String raw) {
      final trimmed = LanternCliService.sanitizeLine(raw);
      if (trimmed.isEmpty) return;
      addLog(trimmed, source: src);

      final lower = trimmed.toLowerCase();

      if (!isLanternConnected && lower.contains('local proxy is listening')) {
        final wasConnected = isLanternConnected;
        isLanternConnected = true;

        checkHappyTransition(
          tunnelName: 'Lantern',
          wasConnected: wasConnected,
          isConnected: true,
        );

        addLog(
          '★ Lantern tunnel ready — local proxy is now available',
          source: src,
        );
        touch();
      }

      if (lower.contains('data path ok')) {
        addLog(
          '★ Lantern data path verified — traffic leaves through the '
          'Lantern network',
          source: src,
        );
        touch();
      }

      if (lower.contains('data path is not working')) {
        addLog(
          '⚠ Lantern data path is NOT working — the local ports are up but '
          'traffic does not get through. Consider enabling an upstream '
          'proxy in the Lantern settings.',
          source: src,
        );
        touch();
      }

      if (lower.contains('failed to start lantern')) {
        addLog(
          '⚠ Lantern failed to start — see the message above for the cause',
          source: src,
        );
      }
    }

    process.stdout.transform(utf8.decoder).listen((data) {
      for (final line in data.split(RegExp(r'[\r\n]+'))) {
        handleLine(line);
      }
    });
    process.stderr.transform(utf8.decoder).listen((data) {
      for (final line in data.split(RegExp(r'[\r\n]+'))) {
        handleLine(line);
      }
    });

    process.exitCode.then((code) {
      final wasConnected = isLanternConnected;
      isLanternRunning = false;
      isLanternConnected = false;
      lanternProcess = null;

      checkHappyTransition(
        tunnelName: 'Lantern',
        wasConnected: wasConnected,
        isConnected: false,
      );

      if (wasConnected && !suppressSadNotification) {
        addLog('⚠ lantern exited unexpectedly (code=$code)', source: src);
        setSadNotification('Lantern');
      }
      suppressSadNotification = false;

      addLog('lantern exited with code $code', source: src);
      touch();
    });
  }

  Future<void> stopLantern() async {
    const src = LogSource.lantern;
    suppressSadNotification = true;

    final proc = lanternProcess;
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
      lanternProcess = null;
    }

    isLanternRunning = false;
    isLanternConnected = false;
    addLog('Lantern stopped', source: src);
    touch();
  }
}
