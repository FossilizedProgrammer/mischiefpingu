part of 'process_service.dart';

/// ═══════════════════════════════════════════════════════════════
///  ProcessServiceGeph — start/stop باینری geph5-proxy.
///
///  گف به‌جای تصرف کل سیستم، یک پروکسی محلی SOCKS5/HTTP بالا می‌آورد و
///  ترافیک را از خروجی‌های Geph5 عبور می‌دهد. argv را
///  `GephCliService.runArgs` می‌سازد.
///
///  خطوط مهم خروجی:
///    • "SOCKS5 proxy : socks5h://…" → پورت‌های محلی بالا آمدند
///    • "connected    : NL via …"    → تونل وصل شد
///    • خروجی با کد غیرصفر            → باینری زودتر از موعد مرد
///      (کد حساب اشتباه، بروکر در دسترس نیست، پورت اشغال و…)
/// ═══════════════════════════════════════════════════════════════
extension ProcessServiceGeph on ProcessService {
  /// argv (شامل فلگ‌های سراسری و زیرفرمان run) باید آماده باشد؛
  /// ساخت آن بر عهدهٔ [GephCliService.runArgs] است.
  Future<bool> startGeph({
    required String binaryPath,
    required List<String> args,
  }) async {
    await ensureInitialized();
    if (isGephRunning) return false;
    const src = LogSource.geph;

    try {
      addLog(
        'Starting geph5-proxy with: $binaryPath '
        '${GephCliService.maskArgs(args)}',
        source: src,
      );

      final process = await Process.start(
        binaryPath,
        args,
        mode: ProcessStartMode.normal,
        environment: GephCliService.environment,
      );
      gephProcess = process;

      _attachGephListeners(process);

      // اگر کد حساب ذخیره نشده باشد یا آرگومانی اشتباه باشد، باینری سریع
      // خارج می‌شود؛ مثل ffvpn/lantern یک چک سریع exit انجام می‌دهیم.
      await Future.delayed(const Duration(milliseconds: 900));

      var exitedQuickly = false;
      try {
        final code = await process.exitCode.timeout(
          const Duration(milliseconds: 250),
        );
        exitedQuickly = true;
        addLog('geph5-proxy exited immediately (code=$code)', source: src);
      } catch (_) {
        exitedQuickly = false;
      }

      if (exitedQuickly) {
        isGephRunning = false;
        isGephConnected = false;
        gephProcess = null;
        touch();
        return false;
      }

      isGephRunning = true;
      isGephConnected = false;
      addLog('geph5-proxy is running (PID: ${process.pid})', source: src);
      touch();
      return true;
    } catch (e) {
      addLog('Failed to start Geph: $e', source: src);
      isGephRunning = false;
      isGephConnected = false;
      gephProcess = null;
      touch();
      return false;
    }
  }

  void _attachGephListeners(Process process) {
    const src = LogSource.geph;

    void handleLine(String raw) {
      final trimmed = GephCliService.sanitizeLine(raw);
      if (trimmed.isEmpty) return;
      addLog(trimmed, source: src);

      final lower = trimmed.toLowerCase();

      if (lower.startsWith('socks5 proxy') || lower.startsWith('http proxy')) {
        addLog(
          '★ Geph local proxy is up — point your apps at '
          '127.0.0.1',
          source: src,
        );
        touch();
      }

      if (!isGephConnected && lower.startsWith('connected')) {
        final wasConnected = isGephConnected;
        isGephConnected = true;

        checkHappyTransition(
          tunnelName: 'Geph',
          wasConnected: wasConnected,
          isConnected: true,
        );

        addLog(
          '★ Geph tunnel ready — traffic now leaves through the Geph exit',
          source: src,
        );
        touch();
      }

      if (lower.contains('incorrect account code') ||
          lower.contains('broker unreachable')) {
        addLog(
          '⚠ Geph cannot reach the broker or the account code is wrong — '
          'check the Geph settings',
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
      final wasConnected = isGephConnected;
      isGephRunning = false;
      isGephConnected = false;
      gephProcess = null;

      checkHappyTransition(
        tunnelName: 'Geph',
        wasConnected: wasConnected,
        isConnected: false,
      );

      if (wasConnected && !suppressSadNotification) {
        addLog('⚠ geph5-proxy exited unexpectedly (code=$code)', source: src);
        setSadNotification('Geph');
      }
      suppressSadNotification = false;

      addLog('geph5-proxy exited with code $code', source: src);
      touch();
    });
  }

  Future<void> stopGeph() async {
    const src = LogSource.geph;
    suppressSadNotification = true;

    final proc = gephProcess;
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
      gephProcess = null;
    }

    isGephRunning = false;
    isGephConnected = false;
    addLog('Geph stopped', source: src);
    touch();
  }
}
