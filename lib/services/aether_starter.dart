part of 'process_service.dart';

ServerSocket? _aetherSocksForwarder;

extension ProcessServiceAetherStarter on ProcessService {
  Future<bool> startAether(List<String> args) async {
    await ensureInitialized();
    if (isAetherRunning) return false;
    const src = LogSource.aether;

    try {
      final dataDir = await AppDataService.getDataDir();

      final binaryPath = await AppDataService.resolveBinaryPath('aether') ??
          await AppDataService.getBinaryPath('aether');

      if (!await checkBinaryExists(
        binaryPath: binaryPath,
        source: src,
        customMessage:
            'Aether binary not found. Please click "Show more" and download it from "Core Updates".',
      )) {
        return false;
      }

      final effectiveArgs = List<String>.from(args);
      final bindInfo = parseAetherBindArgs(effectiveArgs, (m) {
        addLog('ERROR: $m', source: src);
      });
      if (bindInfo == null) return false;

      final prepared = await prepareAetherArgs(
        effectiveArgs: effectiveArgs,
        info: bindInfo,
      );

      addLog('Starting Aether with args: ${prepared.args}', source: src);
      final proc = await spawnAndVerify(
        binaryPath: binaryPath,
        args: prepared.args,
        workingDirectory: dataDir,
        source: src,
        label: 'Aether',
        startupGrace: const Duration(milliseconds: 900),
      );
      if (proc == null) return false;

      aetherProcess = proc;
      isAetherRunning = true;

      // ═══════════════════════════════════════════════════════════
      //  ⚠️ ریست کردن isAetherTunnelReady — تا وقتی Aether خودش
      //  خط "socks5 server listening" را چاپ نکند، false می‌ماند.
      // ═══════════════════════════════════════════════════════════
      isAetherTunnelReady = false;
      aetherAttemptError = null;

      addLog('Aether is running (PID: ${proc.pid})', source: src);

      if (bindInfo.shareLan &&
          prepared.publicPort != null &&
          prepared.internalPort != null) {
        _aetherSocksForwarder = await setupAetherLanForwarder(
          publicPort: prepared.publicPort!,
          internalPort: prepared.internalPort!,
        );
        if (_aetherSocksForwarder == null) {
          addLog(
            '✗ Aether Share on LAN could not bind public port ${prepared.publicPort}',
            source: src,
          );
          await killProcessSafely(proc, graceMs: 500);
          aetherProcess = null;
          isAetherRunning = false;
          isAetherTunnelReady = false;
          touch();
          return false;
        }
      }

      if (bindInfo.shareLan && prepared.publicPort != null) {
        addLog(
          '→ Share on LAN: SOCKS available on 0.0.0.0:${prepared.publicPort}',
          source: src,
        );
      } else if (prepared.internalPort != null) {
        addLog(
          '→ Aether SOCKS starting on 127.0.0.1:${prepared.internalPort} (waiting for tunnel validation)',
          source: src,
        );
      }
      touch();

      // ═══════════════════════════════════════════════════════════
      //  ⚠️ listener مخصوص برای تشخیص آماده شدن tunnel
      // ═══════════════════════════════════════════════════════════
      attachProcessListeners(
        process: proc,
        handleLine: (line) {
          if (line.isEmpty) return;
          addLog(line, source: src);

          // ─── تشخیص آماده شدن واقعی tunnel ───
          _checkAetherTunnelReady(line);

          // ─── شکست قطعی attempt (endpoint سنجاق‌شدهٔ خراب) ───
          _checkAetherAttemptFailure(line);
        },
      );

      proc.exitCode.then((code) async {
        try {
          await _aetherSocksForwarder?.close();
        } catch (_) {}
        _aetherSocksForwarder = null;
        final wasRunning = isAetherRunning;
        isAetherRunning = false;
        isAetherTunnelReady = false;
        aetherProcess = null;

        checkHappyTransition(
          tunnelName: 'Aether',
          wasConnected: wasRunning,
          isConnected: false,
        );

        if (wasRunning && !suppressSadNotification) {
          addLog('⚠ Aether exited unexpectedly (code=$code)', source: src);
          setSadNotification('Aether');
        }
        suppressSadNotification = false;

        addLog('Aether exited with code $code', source: src);
        touch();
      });

      return true;
    } catch (e) {
      try {
        await _aetherSocksForwarder?.close();
      } catch (_) {}
      _aetherSocksForwarder = null;
      await killProcessSafely(aetherProcess);
      aetherProcess = null;
      isAetherRunning = false;
      isAetherTunnelReady = false;
      addLog('Failed to start Aether: $e', source: src);
      touch();
      return false;
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  ///  _checkAetherTunnelReady — تشخیص خطوطی که نشان می‌دهند
  ///  Aether واقعاً tunnel را validate کرده و SOCKS آماده است.
  ///
  ///  خطوطی که Aether چاپ می‌کند:
  ///    [+] wireguard tunnel validated (end-to-end data confirmed); exposing socks5
  ///    [+] socks5 server listening on 127.0.0.1:1819
  ///    [*] ... validated ... exposing socks5
  ///
  ///  در این لحظه است که SOCKS **واقعاً** قابل استفاده است.
  /// ═══════════════════════════════════════════════════════════════
  void _checkAetherTunnelReady(String line) {
    if (isAetherTunnelReady) return; // قبلاً set شده

    final lower = line.toLowerCase();

    // ─── علامت اصلی: socks5 server listening ───
    // این خط فقط بعد از validate شدن tunnel چاپ می‌شود.
    if (lower.contains('socks5 server listening')) {
      _markAetherTunnelReady(
        '★ Aether tunnel ready — SOCKS is now available',
      );
      return;
    }

    // ─── علامت دوم: exposing socks5 ───
    if (lower.contains('exposing socks5')) {
      _markAetherTunnelReady('★ Aether tunnel ready — exposing socks5');
      return;
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  ///  اعلام آماده شدن تونل + happy notification.
  ///
  ///  happy قبلاً فقط در پایان probe سطح اپ صدا زده می‌شد. اگر probe
  ///  دیرتر از خط «socks5 listening» تمام می‌شد (یا شکست می‌خورد و
  ///  بعداً هسته ready می‌شد)، دکمه سبز می‌شد ولی صدا/پنگوئن نمی‌آمد.
  ///  حالا همان لحظه‌ای که خود هسته ready را اعلام می‌کند fired می‌شود؛
  ///  ProcessHappyDetector جلوی تکرار در مسیرهای بعدی را می‌گیرد.
  /// ═══════════════════════════════════════════════════════════════
  void _markAetherTunnelReady(String message) {
    isAetherTunnelReady = true;
    addLog(message, source: LogSource.aether);
    checkHappyTransition(
      tunnelName: 'Aether',
      wasConnected: false,
      isConnected: true,
    );
    touch();
  }

  /// ═══════════════════════════════════════════════════════════════
  ///  _checkAetherAttemptFailure — هسته خودش می‌گوید این attempt
  ///  جواب نمی‌دهد؛ با endpoint سنجاق‌شده (`--peer`) هسته در همان حالت
  ///  reconnect می‌کند و هرگز ready نمی‌شود، پس انتظار تا timeout پروب
  ///  فقط اتلاف وقت است.
  ///
  ///  نمونهٔ واقعی (MASQUE/H2 با peer مرده):
  ///    [h2] connect-ip status: 400
  ///    [-] MASQUE tunnel ended: other: [masque] tunnel failed before
  ///        validation: masque: h2 connect-ip status 400; reconnecting
  /// ═══════════════════════════════════════════════════════════════
  void _checkAetherAttemptFailure(String line) {
    if (isAetherTunnelReady || aetherAttemptError != null) return;

    final lower = line.toLowerCase();

    final rejected = lower.contains('connect-ip status:') &&
        !lower.contains('connect-ip status: 2');
    if (rejected || lower.contains('tunnel failed before validation')) {
      aetherAttemptError = line;
      addLog(
        '✗ Aether attempt rejected by core — aborting wait for this endpoint',
        source: LogSource.aether,
      );
    }
  }
}
