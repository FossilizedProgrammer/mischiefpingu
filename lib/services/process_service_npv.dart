part of 'process_service.dart';

/// ═══════════════════════════════════════════════════════════════
///  ProcessServiceNpv — start/stop باینری npv (NPV Tunnel V2raySSH).
///
///  npv کانفیگ‌های فایل `.npvs` را رمزگشایی می‌کند و روی یک پورت SOCKS/HTTP
///  محلی سرو می‌کند. دو مسیر استارت داریم:
///    • `connect` → همه (یا با `-s` فقط همان یکی) را با یک درخواست واقعی
///      می‌سنجد، بعد سریع‌ترین جواب‌دهنده را سرویس می‌کند. کند است.
///    • `serve -s N` → بدون سنجش، همان شماره را سرویس می‌کند.
///
///  اگر کاربر همین الان «بررسی سرورها» زده باشد (`npvCheckedServeIndex`)،
///  اتصال از همان نتیجه سرو می‌شود و probe تکراری اجرا نمی‌شود. چون `serve`
///  خودِ کانفیگ را نمی‌سنجد، بعد از بالا آمدن یک probe واقعی روی SOCKS محلی
///  زده می‌شود؛ اگر ترافیک رد نشد، کش باطل و یک‌بار با `connect` سنجیده
///  می‌شود.
///
///  خروجی stdout (xray در حالت connect خاموش است):
///    • "npv-go: N of M configs answered, connecting to the fastest" → سنجش تمام شد
///    • "  socks5:  socks5://127.0.0.1:1086" → تونل آماده است
///    • "npv-go: connect: none of the …" → هیچ کانفیگی زنده نیست
/// ═══════════════════════════════════════════════════════════════
extension ProcessServiceNpv on ProcessService {
  Future<bool> startNpv({
    required String binaryPath,
    required String configPath,
    required int socksPort,
    required int httpPort, // 0 = غیرفعال
    required int probeTimeoutSeconds,
    required int probeJobs,
    String? probeUrl,
    String? pinnedIndex,
    bool shareOnLan = false,
  }) async {
    await ensureInitialized();
    if (isNpvRunning) return false;
    const src = LogSource.npv;

    npvSelectedConfig = '';
    final host = shareOnLan ? '0.0.0.0' : '127.0.0.1';

    final checked = npvCheckedServeIndex(
      list: npvServerList,
      checked: npvScanChecked,
      checkedAt: npvScanTime,
      checkedConfigPath: npvScanConfigPath,
      configPath: configPath,
      pinnedIndex: pinnedIndex,
    );

    if (checked != null) {
      addLog(
        '→ NPV serves #$checked from your last check — no re-probing',
        source: src,
      );
      final up = await _runNpv(
        binaryPath: binaryPath,
        host: host,
        args: npvServeArgs(
          configPath: configPath,
          bindHost: host,
          socksPort: socksPort,
          httpPort: httpPort,
          selectedIndex: checked,
        ),
      );
      if (up) {
        if (await _npvCheckedTunnelCarriesTraffic(socksPort)) return true;
        addLog(
          '↻ Config #$checked no longer carries traffic — measuring again',
          source: src,
        );
        await stopNpv();
      } else {
        // کانفیگِ آن چک دیگر جواب نمی‌دهد؛ بگذار سنجش واقعی تکرار شود.
        addLog(
          '↻ That checked config did not come up — measuring again',
          source: src,
        );
      }
      npvScanChecked = false;
    }

    return _runNpv(
      binaryPath: binaryPath,
      host: host,
      args: npvConnectArgs(
        configPath: configPath,
        bindHost: host,
        socksPort: socksPort,
        httpPort: httpPort,
        probeTimeoutSeconds: probeTimeoutSeconds,
        probeJobs: probeJobs,
        probeUrl: probeUrl,
        pinnedIndex: pinnedIndex,
      ),
    );
  }

  /// یک پروسهٔ npv با این آرگومان‌ها بالا می‌آورد. false یعنی همان لحظه
  /// مرده است (آدرس اشغال‌شده، فایل بد، کانفیگِ سرویس‌ناشدنی).
  Future<bool> _runNpv({
    required String binaryPath,
    required String host,
    required List<String> args,
  }) async {
    const src = LogSource.npv;
    try {
      addLog('Starting npv with: $binaryPath ${args.join(' ')}', source: src);

      final process = await Process.start(
        binaryPath,
        args,
        mode: ProcessStartMode.normal,
      );
      npvProcess = process;

      _attachNpvListeners(process, host);

      // آدرس اشغال‌شده، فایل نامعتبر و «no usable configs» همه در کسری از
      // ثانیه خارج می‌شوند؛ چک سریع exit جلوی استارت بی‌صدا را می‌گیرد.
      bool exitedQuickly = false;
      try {
        final code = await process.exitCode.timeout(
          const Duration(milliseconds: 250),
        );
        exitedQuickly = true;
        addLog('npv exited immediately (code=$code)', source: src);
      } catch (_) {
        exitedQuickly = false;
      }

      if (exitedQuickly) {
        isNpvRunning = false;
        isNpvConnected = false;
        npvProcess = null;
        touch();
        return false;
      }

      isNpvRunning = true;
      isNpvConnected = false;
      addLog('npv is running (PID: ${process.pid})', source: src);
      touch();
      return true;
    } catch (e) {
      addLog('Failed to start NPV: $e', source: src);
      isNpvRunning = false;
      isNpvConnected = false;
      npvProcess = null;
      touch();
      return false;
    }
  }

  /// باز شدن listener به خودش معنا ندارد: `serve` کانفیگ را نمی‌سنجد، پس یک
  /// ردیفِ مرده در چکِ قدیمی هم تونل را «بالا» نشان می‌دهد بدون اینکه ترافیک
  /// رد شود. اینجا همان چیزی چک می‌شود که کاربر برایش پول/زمان گذاشته است.
  ///
  /// با SOCKS غیرفعال (پورت ۰) چیزی برای سنجیدن نیست و true برمی‌گردد.
  Future<bool> _npvCheckedTunnelCarriesTraffic(int socksPort) async {
    if (socksPort <= 0) return true;
    const src = LogSource.npv;

    // تا باز شدن خط "socks5:" روی stdout صبر می‌کنیم؛ وگرنه probe زودتر از
    // آماده شدن listener اجرا می‌شود و مرده به نظر می‌رسد.
    final deadline = DateTime.now().add(const Duration(seconds: 6));
    while (
        isNpvRunning && !isNpvConnected && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    if (!isNpvConnected) {
      addLog('⚠ NPV listeners never opened', source: src);
      return false;
    }

    final result = await const TunnelHealthTester().probe(
      kind: TunnelKind.npv,
      socksPort: socksPort,
    );
    if (result.success) {
      addLog(
        '✓ NPV carries traffic — verified in ${result.latencyMs}ms',
        source: src,
      );
    } else {
      addLog('⚠ NPV SOCKS probe failed: ${result.error}', source: src);
    }
    return result.success;
  }

  void _attachNpvListeners(Process process, String bindHost) {
    const src = LogSource.npv;

    void handleLine(String line) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) return;
      addLog(trimmed, source: src);

      // کانفیگ انتخاب‌شده: "npv-go: configraygan-16 (ss) via tcp/none"
      final via = trimmed.indexOf(') via ');
      if (trimmed.startsWith('npv-go:') && via > 0) {
        final open = trimmed.lastIndexOf('(', via);
        final remark =
            trimmed.substring('npv-go:'.length, open > 7 ? open : via).trim();
        if (remark.isNotEmpty) {
          npvSelectedConfig = remark;
          touch();
        }
      }

      // آماده‌باش: باینری بعد از سنجش، listenerها را این‌طور اعلام می‌کند
      //   "  socks5:  socks5://127.0.0.1:1086"  /  "  http:    http://…"
      if (!isNpvConnected &&
          (trimmed.startsWith('socks5:') || trimmed.startsWith('http:'))) {
        final wasConnected = isNpvConnected;
        isNpvConnected = true;

        checkHappyTransition(
          tunnelName: 'NPV',
          wasConnected: wasConnected,
          isConnected: true,
        );

        addLog(
          '★ NPV tunnel ready — local proxy is now available on $bindHost',
          source: src,
        );
        touch();
      }

      if (trimmed.contains('none of the') ||
          trimmed.contains('no config answered')) {
        addLog(
          '⚠ NPV: no config in this export answered — try another .npvs file',
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
      final wasConnected = isNpvConnected;
      isNpvRunning = false;
      isNpvConnected = false;
      npvProcess = null;

      checkHappyTransition(
        tunnelName: 'NPV',
        wasConnected: wasConnected,
        isConnected: false,
      );

      if (wasConnected && !suppressSadNotification) {
        addLog('⚠ npv exited unexpectedly (code=$code)', source: src);
        setSadNotification('NPV');
      }
      suppressSadNotification = false;

      addLog('npv exited with code $code', source: src);
      touch();
    });
  }

  Future<void> stopNpv() async {
    const src = LogSource.npv;
    suppressSadNotification = true;

    final proc = npvProcess;
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
      npvProcess = null;
    }

    isNpvRunning = false;
    isNpvConnected = false;
    addLog('NPV stopped', source: src);
    touch();
  }

  /// فهرست کانفیگ‌های فایل، با سنجش اختیاری:
  ///   `npv list -json [-check -timeout 10s -jobs 3] config.npvs`
  ///
  /// خروجی JSON یک خط است (مدل NpvServerList). با `-check` زنده‌ها سریع‌ترین
  /// به قبل می‌آیند؛ بدون آن فقط فهرست است و هیچ verdictی داده نمی‌شود.
  Future<NpvServerList?> scanNpvServers({
    required String binaryPath,
    required String configPath,
    required bool check,
    required int probeTimeoutSeconds,
    required int probeJobs,
    String? probeUrl,
  }) async {
    await ensureInitialized();
    const src = LogSource.npv;
    if (isNpvScanning) return null;

    final args = <String>['list', '-json'];
    if (check) {
      args.addAll([
        '-check',
        '-timeout',
        '${probeTimeoutSeconds}s',
        '-jobs',
        '$probeJobs',
      ]);
      if (probeUrl != null && probeUrl.isNotEmpty) {
        args.addAll(['-url', probeUrl]);
      }
    }
    args.add(configPath);

    isNpvScanning = true;
    npvScanCancelled = false;
    npvScanError = null;
    addLog('Scanning NPV configs: npv ${args.join(' ')}', source: src);
    touch();

    try {
      final process = await Process.start(binaryPath, args);
      npvScanProcess = process;

      // stdout فقط JSON است (خطاها و لاگ‌های xray به stderr می‌روند)،
      // پس هر دو را جدا جمع می‌کنیم.
      final outFuture = process.stdout.transform(utf8.decoder).join();
      final errFuture = process.stderr.transform(utf8.decoder).join();
      final code = await process.exitCode;
      final outText = await outFuture;
      final errText = await errFuture;
      npvScanProcess = null;
      isNpvScanning = false;

      if (npvScanCancelled) {
        npvScanCancelled = false;
        addLog('NPV config scan cancelled', source: src);
        touch();
        return null;
      }

      if (code != 0) {
        final detail = errText.trim();
        // نسخهٔ قدیمی باینری (قبل از -json) این پیام را می‌دهد؛ تا بعد از
        // seeding خودکار عوض شود، پیام فنی Go برای کاربر بی‌معنی است.
        final noJson = detail.contains('-json');
        npvScanError = noJson
            ? 'This npv build does not support the config list — '
                'the core updates itself on the next start.'
            : (detail.isEmpty ? 'npv exited with code $code' : detail);
        addLog('⚠ NPV scan failed: $npvScanError', source: src);
        touch();
        return null;
      }

      final list = NpvServerList.tryParse(outText);
      if (list == null) {
        npvScanError =
            'This npv build did not return a config list — update the core.';
        addLog('⚠ NPV scan: $npvScanError', source: src);
        touch();
        return null;
      }

      npvServerList = list;
      npvScanChecked = check;
      npvScanTime = DateTime.now();
      npvScanConfigPath = configPath;
      addLog(
        check
            ? 'NPV scan: ${list.answered} of ${list.total} configs answered'
            : 'NPV list: ${list.total} configs in this export',
        source: src,
      );
      touch();
      return list;
    } catch (e) {
      isNpvScanning = false;
      npvScanCancelled = false;
      npvScanProcess = null;
      npvScanError = '$e';
      addLog('⚠ NPV scan failed: $e', source: src);
      touch();
      return null;
    }
  }

  void cancelNpvScan() {
    final proc = npvScanProcess;
    if (proc == null) return;
    npvScanCancelled = true;
    try {
      proc.kill(ProcessSignal.sigterm);
    } catch (_) {}
  }
}
