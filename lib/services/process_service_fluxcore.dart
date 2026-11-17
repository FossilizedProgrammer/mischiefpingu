part of 'process_service.dart';

/// ═══════════════════════════════════════════════════════════════
///  ProcessServiceFluxcore — start/stop باینری `fluxcore`.
///
///  Fluxcore یک پروکسی محلی (بدون TUN) است که روی یک پورت هم SOCKS5 و هم
///  HTTP سرو می‌کند. هسته خودش discovery، امضای دایرکتوری، انتخاب گیت‌وی،
///  مولتی‌هاپ و reconnect را انجام می‌دهد؛ اینجا فقط پروسه را با تنظیمات
///  کاربر بالا می‌آوریم و خط «connected» را به‌عنوان آماده‌بودن تونل
///  می‌خوانیم. باز شدن listener به‌تنهایی یعنی پروکسی بالا آمده، نه اینکه
///  تونل به گیت‌وی وصل شده باشد.
/// ═══════════════════════════════════════════════════════════════
extension ProcessServiceFluxcore on ProcessService {
  Future<bool> startFluxcore({
    required String binaryPath,
    required String configHome,
    required int port,
    required int httpPort,
    required String country,
    required String transport,
    required bool multihop,
    required String entry,
    required String exit,
    required bool killSwitch,
    required bool autoReconnect,
  }) async {
    await ensureInitialized();
    if (isFluxcoreRunning) return false;
    const src = LogSource.fluxcore;

    fluxcoreSelectedRoute = '';

    final args = <String>[
      'run',
      '--listen',
      '127.0.0.1:$port',
      '--http-listen',
      '127.0.0.1:$httpPort',
    ];
    final selector = country.trim();
    if (selector.isNotEmpty) args.addAll(['--country', selector]);

    switch (transport) {
      case 'stealth':
        args.add('--stealth');
        break;
      case 'speed':
        args.add('--speed');
        break;
      default:
        args.add('--auto');
    }

    if (multihop && entry.trim().isNotEmpty && exit.trim().isNotEmpty) {
      args.addAll(['--entry', entry.trim(), '--exit', exit.trim()]);
    }
    if (!killSwitch) args.add('--no-kill-switch');
    // روشن‌بودن این گزینه یعنی خود Fluxcore هم بعد از قطعی دوباره وصل شود؛
    // خاموش‌بودنش پروسه را در اولین قطعی/شکست خارج می‌کند.
    if (!autoReconnect) args.add('--no-reconnect');

    // کانفیگ/هویت Fluxcore در پوشهٔ دادهٔ خود اپ می‌ماند، نه در ~/.config
    // عمومی کاربر. os.UserConfigDir داخل فرزند این متغیر را می‌خواند.
    final configDir = Directory(configHome);
    try {
      await configDir.create(recursive: true);
    } catch (_) {}

    final env = <String, String>{
      if (Platform.isWindows)
        'APPDATA': configHome
      else
        'XDG_CONFIG_HOME': configHome,
    };

    try {
      addLog('Starting Fluxcore with: $binaryPath ${args.join(' ')}',
          source: src);

      final process = await Process.start(
        binaryPath,
        args,
        workingDirectory: configHome,
        environment: env,
        includeParentEnvironment: true,
        mode: ProcessStartMode.normal,
      );
      fluxcoreProcess = process;

      _attachFluxcoreListeners(process);

      // پورت اشغال، باینری ناسازگار و خطای آرگومان فوراً خارج می‌شوند.
      bool exitedQuickly = false;
      try {
        final code = await process.exitCode.timeout(
          const Duration(milliseconds: 300),
        );
        exitedQuickly = true;
        addLog('fluxcore exited immediately (code=$code)', source: src);
      } catch (_) {
        exitedQuickly = false;
      }

      if (exitedQuickly) {
        isFluxcoreRunning = false;
        isFluxcoreConnected = false;
        fluxcoreProcess = null;
        touch();
        return false;
      }

      isFluxcoreRunning = true;
      isFluxcoreConnected = false;
      addLog('fluxcore is running (PID: ${process.pid})', source: src);
      touch();
      return true;
    } catch (e) {
      addLog('Failed to start Fluxcore: $e', source: src);
      isFluxcoreRunning = false;
      isFluxcoreConnected = false;
      fluxcoreProcess = null;
      touch();
      return false;
    }
  }

  void _attachFluxcoreListeners(Process process) {
    const src = LogSource.fluxcore;

    void handleLine(String line) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) return;
      addLog(trimmed, source: src);

      // خط «connected» بعد از handshake موفق چاپ می‌شود؛ خط proxy فقط
      // یعنی listener محلی باز شده است.
      if (trimmed == 'connected') {
        final wasConnected = isFluxcoreConnected;
        isFluxcoreConnected = true;
        checkHappyTransition(
          tunnelName: 'Fluxcore',
          wasConnected: wasConnected,
          isConnected: true,
        );
        addLog('★ Fluxcore tunnel is connected', source: src);
        touch();
        return;
      }

      if (trimmed.startsWith('exit ') || trimmed.startsWith('entry ')) {
        fluxcoreSelectedRoute = trimmed.replaceAll(RegExp(r'\s+'), ' ');
        touch();
        return;
      }

      if (trimmed.startsWith('tunnel lost') ||
          trimmed.startsWith('connect failed') ||
          trimmed.startsWith('tunnel lost and auto-reconnect')) {
        if (isFluxcoreConnected) {
          final wasConnected = isFluxcoreConnected;
          isFluxcoreConnected = false;
          checkHappyTransition(
            tunnelName: 'Fluxcore',
            wasConnected: wasConnected,
            isConnected: false,
          );
          touch();
        }
      }

      if (trimmed.contains('no gateways') ||
          trimmed.contains('Stealth mode:') ||
          trimmed.contains('entry hop cannot use wg-tls')) {
        addLog('⚠ Fluxcore: $trimmed', source: src);
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
      final wasConnected = isFluxcoreConnected;
      isFluxcoreRunning = false;
      isFluxcoreConnected = false;
      fluxcoreProcess = null;

      checkHappyTransition(
        tunnelName: 'Fluxcore',
        wasConnected: wasConnected,
        isConnected: false,
      );

      if (wasConnected && !suppressSadNotification) {
        addLog('⚠ fluxcore exited unexpectedly (code=$code)', source: src);
        setSadNotification('Fluxcore');
      }
      suppressSadNotification = false;

      addLog('fluxcore exited with code $code', source: src);
      touch();
    });
  }

  Future<void> stopFluxcore() async {
    const src = LogSource.fluxcore;
    suppressSadNotification = true;

    final proc = fluxcoreProcess;
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
      fluxcoreProcess = null;
    }

    isFluxcoreRunning = false;
    isFluxcoreConnected = false;
    fluxcoreSelectedRoute = '';
    addLog('Fluxcore stopped', source: src);
    touch();
  }
}
