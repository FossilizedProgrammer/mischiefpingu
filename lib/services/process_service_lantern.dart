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
  /// ساخت آن بر عهدهٔ [LanternCliService.startArgs] یا
  /// [LanternCliService.radianceStartArgs] است.
  ///
  /// [radiance] را برای باینری موتور Radiance روی true بگذارید تا خط آمادهٔ
  /// `RADIANCE_READY` تشخیص داده شود (خروجی این باینری متفاوت است).
  Future<bool> startLantern({
    required String binaryPath,
    required List<String> args,
    bool radiance = false,
  }) async {
    await ensureInitialized();
    if (isLanternRunning) return false;
    const src = LogSource.lantern;

    try {
      addLog(
        'Starting lantern${radiance ? " (radiance engine)" : ""} with: '
        '$binaryPath ${LanternCliService.maskArgs(args)}',
        source: src,
      );

      final process = await Process.start(
        binaryPath,
        args,
        mode: ProcessStartMode.normal,
      );
      lanternProcess = process;

      _attachLanternListeners(process, radiance: radiance);

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
      // ⚠️ اینجا عمداً isLanternConnected را false نمی‌کنیم: موتور (به‌ویژه
      // radiance با کانفیگ کش‌شده) ممکن است در همان ~۹۰۰ms بالا، خط آمادهٔ
      // RADIANCE_READY را چاپ کند و listener قبلاً isLanternConnected را true
      // کرده باشد. اگر اینجا صفرش کنیم، نوتیف «وصل شد» می‌آید (چون listener
      // یک‌بار fire شده) ولی دکمه سبز نمی‌شود و پروکسی هم قابل استفاده
      // علامت نمی‌خورد. پس حالت connected را دست‌نخورده نگه می‌داریم.
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

  void _attachLanternListeners(Process process, {bool radiance = false}) {
    const src = LogSource.lantern;

    void handleLine(String raw) {
      final trimmed = LanternCliService.sanitizeLine(raw);
      if (trimmed.isEmpty) return;
      addLog(trimmed, source: src);

      final lower = trimmed.toLowerCase();

      // موتور کلاسیک با «local proxy is listening» و موتور Radiance با
      // «RADIANCE_READY» آماده بودن تونل را اعلام می‌کنند.
      final readyMarker =
          radiance ? 'radiance_ready' : 'local proxy is listening';

      if (!isLanternConnected && lower.contains(readyMarker)) {
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

      if (radiance && lower.contains('radiance-engine: connect:')) {
        addLog(
          '⚠ Radiance engine could not connect — see the message above. '
          'Consider enabling an upstream proxy in the Lantern settings.',
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
