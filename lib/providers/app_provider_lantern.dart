part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  AppProviderLantern — entry point + stop برای تونل لنترن.
///
///  ⚠️ preflightها در `lantern/lantern_preflight.dart` جدا شدن:
///    • _preflightLanternBinary
///    • _preflightLanternPorts
/// ═══════════════════════════════════════════════════════════════
extension AppProviderLantern on AppProvider {
  /// connectLantern — entry point عمومی (toggle connect/stop).
  Future<void> connectLantern() async {
    final isCurrentlyActive =
        processService.isLanternRunning || isLanternBusy;

    if (isCurrentlyActive) {
      await stopLanternByUser();
      return;
    }

    await _startLanternInternal();
  }

  /// توقف کامل لنترن.
  Future<void> stopLanternByUser() async {
    const src = LogSource.lantern;

    userStoppedLantern = true;
    nextLanternGeneration();

    try {
      await processService.stopLantern();
    } catch (e) {
      processService.addLog('⚠ Lantern stop error: $e', source: src);
    }

    isLanternBusy = false;
    lanternStatus = 'Lantern: Stopped';

    await AppDataService.fixDataDirOwnership();
    touch();
  }

  Future<void> _startLanternInternal() async {
    const src = LogSource.lantern;

    if (isLanternBusy) {
      processService.addLog(
        '→ Lantern start ignored — already starting',
        source: src,
      );
      return;
    }

    if (processService.isLanternRunning) {
      processService.addLog(
        '→ Lantern is already running — ignoring redundant start',
        source: src,
      );
      return;
    }

    // ─── preflight باینری ───
    final binaryPath = await _preflightLanternBinary(src);
    if (binaryPath == null) return;

    // ─── preflight پورت ───
    if (!await _preflightLanternPorts(src)) return;

    userStoppedLantern = false;
    isLanternBusy = true;
    lanternStatus = 'Lantern: Starting…';
    touch();

    final myGeneration = nextLanternGeneration();

    try {
      await saveSettings();

      if (userStoppedLantern) {
        processService.addLog(
          'Lantern start cancelled by user (after saveSettings)',
          source: src,
        );
        return;
      }

      // ═══════════════════════════════════════════════════════════
      //  آپ‌استریم (--upstream-proxy): دستی یا زنجیره به تونل دیگر
      // ═══════════════════════════════════════════════════════════
      if (!await resolveLanternUpstream()) return;

      if (userStoppedLantern) {
        processService.addLog(
          'Lantern start cancelled by user (after upstream resolve)',
          source: src,
        );
        lanternStatus = 'Lantern: Stopped';
        touch();
        return;
      }

      final upstream = LanternUpstreamBuilder(
        settings: settings,
        processService: processService,
      );
      final dialUrl = upstream.buildUrl();

      final cli = LanternCliService(
        settings: settings,
        processService: processService,
      );
      final args = cli.startArgs(upstreamUrl: dialUrl);

      final ok = await processService.startLantern(
        binaryPath: binaryPath,
        args: args,
      );

      if (userStoppedLantern) {
        processService.addLog(
          'Lantern start cancelled by user (after process start)',
          source: src,
        );
        try {
          await processService.stopLantern();
        } catch (_) {}
        lanternStatus = 'Lantern: Stopped';
        touch();
        return;
      }

      lanternStatus =
          ok ? 'Lantern: Starting…' : 'Lantern: Failed to start';

      if (myGeneration != _lanternGeneration) {
        processService.addLog(
          '→ Lantern start completed but a newer start superseded it',
          source: src,
        );
      }
    } catch (e) {
      processService.addLog('✗ connectLantern error: $e', source: src);
      lanternStatus = 'Lantern: Error';
    } finally {
      if (myGeneration == _lanternGeneration) {
        isLanternBusy = false;
      }
      await AppDataService.fixDataDirOwnership();
      touch();
    }
  }

  /// آپ‌استریم انتخاب‌شده را برای لنترن آماده می‌کند.
  ///
  /// برای تونل‌های داخلی (Psiphon/Tor/SSTP/WireGuard) اگر از قبل بالا
  /// نباشند، اول خودشان را بالا می‌آورد؛ برای حالت دستی فقط برنامه را
  /// لاگ می‌کند و ناقص بودن آدرس با هشدار رد می‌شود.
  Future<bool> resolveLanternUpstream() async {
    const src = LogSource.lantern;
    final builder = LanternUpstreamBuilder(
      settings: settings,
      processService: processService,
    );
    if (!builder.hasUpstream) return true;

    if (builder.type == LanternUpstreamBuilder.manual) {
      if (builder.buildUrl().isEmpty) {
        processService.addLog(
          '⚠ Lantern upstream is set to Manual but the proxy host/port '
          'is empty — connecting directly',
          source: src,
        );
      } else {
        processService.addLog(
          '→ Lantern will reach its servers through '
          '${builder.describeUrl()}',
          source: src,
        );
      }
      return true;
    }

    final port = builder.socksPort;
    switch (builder.type) {
      case LanternUpstreamBuilder.psiphon:
        return _ensureLanternUpstreamTunnel(
          name: 'Psiphon',
          port: port,
          isRunning: () => processService.isPsiphonRunning,
          start: () => connectPsiphon(fromAutoReconnect: false),
        );
      case LanternUpstreamBuilder.tor:
        return _ensureLanternUpstreamTunnel(
          name: 'Tor',
          port: port,
          isRunning: () => processService.isTorRunning,
          start: () => connectTor(fromAutoReconnect: false),
        );
      case LanternUpstreamBuilder.sstp:
        return _ensureLanternUpstreamTunnel(
          name: 'SSTP',
          port: port,
          isRunning: () => processService.isSstpRunning,
          start: () => connectSstp(fromAutoReconnect: false),
        );
      case LanternUpstreamBuilder.wireguard:
        return _ensureLanternUpstreamTunnel(
          name: 'WireGuard',
          port: port,
          isRunning: () => processService.isWireGuardRunning,
          start: () => connectWireGuard(fromAutoReconnect: false),
        );
      case LanternUpstreamBuilder.ffvpn:
        return _ensureLanternUpstreamTunnel(
          name: 'Firefox VPN',
          port: port,
          isRunning: () => processService.isFfvpnRunning,
          start: () => connectFfvpn(),
        );
      case LanternUpstreamBuilder.geph:
        return _ensureLanternUpstreamTunnel(
          name: 'Geph',
          port: port,
          isRunning: () => processService.isGephRunning,
          start: () => connectGeph(),
        );
      default:
        return true;
    }
  }

  /// بالا آوردن تونل آپ‌استریم اگر لازم باشد؛ false یعنی لنترن شروع نشود.
  Future<bool> _ensureLanternUpstreamTunnel({
    required String name,
    required int? port,
    required bool Function() isRunning,
    required Future<void> Function() start,
  }) async {
    const src = LogSource.lantern;

    if (isRunning()) {
      processService.addLog(
        '→ Lantern upstream: $name already running',
        source: src,
      );
      return true;
    }

    lanternStatus = 'Lantern: starting $name upstream…';
    touch();

    await start();

    if (userStoppedLantern) {
      processService.addLog(
        'Lantern start cancelled by user (after $name upstream)',
        source: src,
      );
      lanternStatus = 'Lantern: Stopped';
      touch();
      return false;
    }

    if (!isRunning()) {
      lanternStatus = 'Lantern: $name unavailable — not started';
      processService.addLog(
        '✗ $name unavailable → Lantern not started',
        source: src,
      );
      return false;
    }

    processService.addLog(
      '→ Lantern will chain through $name (SOCKS 127.0.0.1:$port)',
      source: src,
    );
    return true;
  }
}
