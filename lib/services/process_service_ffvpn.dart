part of 'process_service.dart';

/// ═══════════════════════════════════════════════════════════════
///  ProcessServiceFfvpn — start/stop باینری ffvpn (Firefox VPN).
///
///  ffvpn یک پروکسی محلی SOCKS5/HTTP بالا می‌آورد که ترافیک را از
///  لبهٔ IP Protection فایرفاکس عبور می‌دهد. احراز هویت با
///  sessionToken حساب Firefox Account انجام می‌شود.
///
///  خروجی Go `log` روی stderr می‌آید؛ خطوط مهم:
///    • "SOCKS5 proxy listening on …" → تونل آماده است
///    • "guardian: … (HTTP 403/451)" → خطای سمت سرور
/// ═══════════════════════════════════════════════════════════════
extension ProcessServiceFfvpn on ProcessService {
  Future<bool> startFfvpn({
    required String binaryPath,
    required String sessionToken,
    required int socksPort,
    required int httpPort, // 0 = غیرفعال
    String? country,
    String? sni, // SNI سفارشی برای ClientHello (خالی = نام لبه)
    String? dialProxy, // آپ‌استریم SOCKS: socks5://[user:pass@]host:port
  }) async {
    await ensureInitialized();
    if (isFfvpnRunning) return false;
    const src = LogSource.ffvpn;

    try {
      final args = <String>[
        '--session-token',
        sessionToken,
        '--socks',
        '127.0.0.1:$socksPort',
      ];
      if (httpPort > 0) {
        args.addAll(['--http', '127.0.0.1:$httpPort']);
      }
      if (country != null && country.isNotEmpty) {
        args.addAll(['--country', country]);
      }
      if (sni != null && sni.isNotEmpty) {
        args.addAll(['--sni', sni]);
      }
      if (dialProxy != null && dialProxy.isNotEmpty) {
        args.addAll(['--dial-proxy', dialProxy]);
      }

      // ⚠️ sessionToken معادل کلید حساب است و گذرواژهٔ آپ‌استریم هم در لاگ
      // ماسک می‌شود.
      final maskedArgs = args.map((a) {
        if (a == sessionToken) return '****';
        if (dialProxy != null && a == dialProxy) {
          return FfvpnUpstreamBuilder.maskCredentials(a);
        }
        return a;
      }).join(' ');
      addLog(
        'Starting ffvpn with: $binaryPath $maskedArgs',
        source: src,
      );

      final process = await Process.start(
        binaryPath,
        args,
        mode: ProcessStartMode.normal,
      );
      ffvpnProcess = process;

      _attachFfvpnListeners(process);

      // ffvpn اگر توکن/اشتراک نامعتبر داشته باشد در کمتر از یک ثانیه
      // خارج می‌شود؛ مثل WireGuard یک چک سریع exit انجام می‌دهیم.
      await Future.delayed(const Duration(milliseconds: 900));

      bool exitedQuickly = false;
      try {
        final code = await process.exitCode.timeout(
          const Duration(milliseconds: 250),
        );
        exitedQuickly = true;
        addLog('ffvpn exited immediately (code=$code)', source: src);
      } catch (_) {
        exitedQuickly = false;
      }

      if (exitedQuickly) {
        isFfvpnRunning = false;
        isFfvpnConnected = false;
        ffvpnProcess = null;
        touch();
        return false;
      }

      isFfvpnRunning = true;
      isFfvpnConnected = false;
      addLog('ffvpn is running (PID: ${process.pid})', source: src);
      touch();
      return true;
    } catch (e) {
      addLog('Failed to start Firefox VPN: $e', source: src);
      isFfvpnRunning = false;
      isFfvpnConnected = false;
      ffvpnProcess = null;
      touch();
      return false;
    }
  }

  void _attachFfvpnListeners(Process process) {
    const src = LogSource.ffvpn;

    void handleLine(String line) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) return;
      addLog(trimmed, source: src);

      final lower = trimmed.toLowerCase();

      if (!isFfvpnConnected &&
          (lower.contains('proxy listening on') ||
              lower.contains('connect proxy listening'))) {
        final wasConnected = isFfvpnConnected;
        isFfvpnConnected = true;

        checkHappyTransition(
          tunnelName: 'Firefox VPN',
          wasConnected: wasConnected,
          isConnected: true,
        );

        addLog(
          '★ Firefox VPN tunnel ready — local proxy is now available',
          source: src,
        );
        touch();
      }

      if (lower.contains('quota exceeded')) {
        addLog(
          '⚠ Firefox VPN bandwidth quota exceeded — waiting for reset/retry',
          source: src,
        );
      }
    }

    process.stdout.transform(utf8.decoder).listen((data) {
      for (final line in data.split('\n')) {
        handleLine(line);
      }
    });
    process.stderr.transform(utf8.decoder).listen((data) {
      for (final line in data.split('\n')) {
        handleLine(line);
      }
    });

    process.exitCode.then((code) {
      final wasConnected = isFfvpnConnected;
      isFfvpnRunning = false;
      isFfvpnConnected = false;
      ffvpnProcess = null;

      checkHappyTransition(
        tunnelName: 'Firefox VPN',
        wasConnected: wasConnected,
        isConnected: false,
      );

      if (wasConnected && !suppressSadNotification) {
        addLog('⚠ ffvpn exited unexpectedly (code=$code)', source: src);
        setSadNotification('Firefox VPN');
      }
      suppressSadNotification = false;

      addLog('ffvpn exited with code $code', source: src);
      touch();
    });
  }

  Future<void> stopFfvpn() async {
    const src = LogSource.ffvpn;
    suppressSadNotification = true;

    final proc = ffvpnProcess;
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
      ffvpnProcess = null;
    }

    isFfvpnRunning = false;
    isFfvpnConnected = false;
    addLog('Firefox VPN stopped', source: src);
    touch();
  }
}
