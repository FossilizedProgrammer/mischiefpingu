part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  AppProviderGeph — entry point + stop برای تونل گف (geph5-proxy).
///
///  ⚠️ preflightها در `geph/geph_preflight.dart` جدا شدن:
///    • _preflightGephBinary
///    • _preflightGephAccount
///    • _preflightGephPorts
/// ═══════════════════════════════════════════════════════════════
extension AppProviderGeph on AppProvider {
  /// connectGeph — entry point عمومی (toggle connect/stop).
  Future<void> connectGeph() async {
    final isCurrentlyActive = processService.isGephRunning || isGephBusy;

    if (isCurrentlyActive) {
      await stopGephByUser();
      return;
    }

    await _startGephInternal();
  }

  /// توقف کامل گف.
  Future<void> stopGephByUser() async {
    const src = LogSource.geph;

    userStoppedGeph = true;
    nextGephGeneration();

    try {
      await processService.stopGeph();
    } catch (e) {
      processService.addLog('⚠ Geph stop error: $e', source: src);
    }

    isGephBusy = false;
    gephStatus = 'Geph: Stopped';

    await AppDataService.fixDataDirOwnership();
    touch();
  }

  Future<void> _startGephInternal() async {
    const src = LogSource.geph;

    if (isGephBusy) {
      processService.addLog(
        '→ Geph start ignored — already starting',
        source: src,
      );
      return;
    }

    if (processService.isGephRunning) {
      processService.addLog(
        '→ Geph is already running — ignoring redundant start',
        source: src,
      );
      return;
    }

    // ─── preflight باینری ───
    final binaryPath = await _preflightGephBinary(src);
    if (binaryPath == null) return;

    // ─── preflight کد حساب ───
    if (!await _preflightGephAccount(src)) return;

    // ─── preflight پورت ───
    if (!await _preflightGephPorts(src)) return;

    userStoppedGeph = false;
    isGephBusy = true;
    gephStatus = 'Geph: Starting…';
    touch();

    final myGeneration = nextGephGeneration();

    try {
      await saveSettings();

      if (userStoppedGeph) {
        processService.addLog(
          'Geph start cancelled by user (after saveSettings)',
          source: src,
        );
        return;
      }

      // ═══════════════════════════════════════════════════════════
      //  آپ‌استریم (--upstream): دستی یا زنجیره به تونل دیگر
      // ═══════════════════════════════════════════════════════════
      if (!await resolveGephUpstream()) return;

      if (userStoppedGeph) {
        processService.addLog(
          'Geph start cancelled by user (after upstream resolve)',
          source: src,
        );
        gephStatus = 'Geph: Stopped';
        touch();
        return;
      }

      final upstream = GephUpstreamBuilder(
        settings: settings,
        processService: processService,
      );
      final dialUrl = upstream.buildUrl();

      final cli = GephCliService(
        settings: settings,
        processService: processService,
      );
      final args = await cli.runArgs(upstreamUrl: dialUrl);

      final ok = await processService.startGeph(
        binaryPath: binaryPath,
        args: args,
      );

      if (userStoppedGeph) {
        processService.addLog(
          'Geph start cancelled by user (after process start)',
          source: src,
        );
        try {
          await processService.stopGeph();
        } catch (_) {}
        gephStatus = 'Geph: Stopped';
        touch();
        return;
      }

      gephStatus =
          ok ? 'Geph: Starting…' : 'Geph: Failed to start';

      if (myGeneration != _gephGeneration) {
        processService.addLog(
          '→ Geph start completed but a newer start superseded it',
          source: src,
        );
      }
    } catch (e) {
      processService.addLog('✗ connectGeph error: $e', source: src);
      gephStatus = 'Geph: Error';
    } finally {
      if (myGeneration == _gephGeneration) {
        isGephBusy = false;
      }
      await AppDataService.fixDataDirOwnership();
      touch();
    }
  }

  /// آپ‌استریم انتخاب‌شده را برای گف آماده می‌کند.
  ///
  /// برای تونل‌های داخلی (Psiphon/Tor/SSTP/WireGuard) اگر از قبل بالا
  /// نباشند، اول خودشان را بالا می‌آورد؛ برای حالت دستی فقط برنامه را
  /// لاگ می‌کند و ناقص بودن آدرس با هشدار رد می‌شود.
  Future<bool> resolveGephUpstream() async {
    const src = LogSource.geph;
    final builder = GephUpstreamBuilder(
      settings: settings,
      processService: processService,
    );
    if (!builder.hasUpstream) return true;

    if (builder.type == GephUpstreamBuilder.manual) {
      if (builder.buildUrl().isEmpty) {
        processService.addLog(
          '⚠ Geph upstream is set to Manual but the proxy host/port '
          'is empty — connecting directly',
          source: src,
        );
      } else {
        processService.addLog(
          '→ Geph will reach the broker through '
          '${builder.describeUrl()}',
          source: src,
        );
      }
      return true;
    }

    final port = builder.socksPort;
    switch (builder.type) {
      case GephUpstreamBuilder.psiphon:
        return _ensureGephUpstreamTunnel(
          name: 'Psiphon',
          port: port,
          isRunning: () => processService.isPsiphonRunning,
          start: () => connectPsiphon(fromAutoReconnect: false),
        );
      case GephUpstreamBuilder.tor:
        return _ensureGephUpstreamTunnel(
          name: 'Tor',
          port: port,
          isRunning: () => processService.isTorRunning,
          start: () => connectTor(fromAutoReconnect: false),
        );
      case GephUpstreamBuilder.sstp:
        return _ensureGephUpstreamTunnel(
          name: 'SSTP',
          port: port,
          isRunning: () => processService.isSstpRunning,
          start: () => connectSstp(fromAutoReconnect: false),
        );
      case GephUpstreamBuilder.wireguard:
        return _ensureGephUpstreamTunnel(
          name: 'WireGuard',
          port: port,
          isRunning: () => processService.isWireGuardRunning,
          start: () => connectWireGuard(fromAutoReconnect: false),
        );
      case GephUpstreamBuilder.ffvpn:
        return _ensureGephUpstreamTunnel(
          name: 'Firefox VPN',
          port: port,
          isRunning: () => processService.isFfvpnRunning,
          start: () => connectFfvpn(),
        );
      case GephUpstreamBuilder.lantern:
        return _ensureGephUpstreamTunnel(
          name: 'Lantern',
          port: port,
          isRunning: () => processService.isLanternRunning,
          start: () => connectLantern(),
        );
      default:
        return true;
    }
  }

  /// بالا آوردن تونل آپ‌استریم اگر لازم باشد؛ false یعنی گف شروع نشود.
  Future<bool> _ensureGephUpstreamTunnel({
    required String name,
    required int? port,
    required bool Function() isRunning,
    required Future<void> Function() start,
  }) async {
    const src = LogSource.geph;

    if (isRunning()) {
      processService.addLog(
        '→ Geph upstream: $name already running',
        source: src,
      );
      return true;
    }

    gephStatus = 'Geph: starting $name upstream…';
    touch();

    await start();

    if (userStoppedGeph) {
      processService.addLog(
        'Geph start cancelled by user (after $name upstream)',
        source: src,
      );
      gephStatus = 'Geph: Stopped';
      touch();
      return false;
    }

    if (!isRunning()) {
      gephStatus = 'Geph: $name unavailable — not started';
      processService.addLog(
        '✗ $name unavailable → Geph not started',
        source: src,
      );
      return false;
    }

    processService.addLog(
      '→ Geph will chain through $name (SOCKS 127.0.0.1:$port)',
      source: src,
    );
    return true;
  }
}
