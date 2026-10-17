part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  AppProviderFfvpn — entry point + stop برای تونل Firefox VPN.
///
///  ⚠️ preflightها در `ffvpn/ffvpn_preflight.dart` جدا شدن:
///    • _preflightFfvpnBinary
///    • _preflightFfvpnPorts
/// ═══════════════════════════════════════════════════════════════
extension AppProviderFfvpn on AppProvider {
  /// connectFfvpn — entry point عمومی (toggle connect/stop).
  Future<void> connectFfvpn() async {
    final isCurrentlyActive =
        processService.isFfvpnRunning || isFfvpnBusy;

    if (isCurrentlyActive) {
      await stopFfvpnByUser();
      return;
    }

    await _startFfvpnInternal();
  }

  /// توقف کامل Firefox VPN.
  Future<void> stopFfvpnByUser() async {
    const src = LogSource.ffvpn;

    userStoppedFfvpn = true;
    nextFfvpnGeneration();

    try {
      await processService.stopFfvpn();
    } catch (e) {
      processService.addLog('⚠ Firefox VPN stop error: $e', source: src);
    }

    isFfvpnBusy = false;
    ffvpnStatus = 'Firefox VPN: Stopped';

    await AppDataService.fixDataDirOwnership();
    touch();
  }

  Future<void> _startFfvpnInternal() async {
    const src = LogSource.ffvpn;

    if (isFfvpnBusy) {
      processService.addLog(
        '→ Firefox VPN start ignored — already starting',
        source: src,
      );
      return;
    }

    if (processService.isFfvpnRunning) {
      processService.addLog(
        '→ Firefox VPN is already running — ignoring redundant start',
        source: src,
      );
      return;
    }

    // ─── preflight توکن ───
    if (settings.ffvpnSessionToken.isEmpty) {
      processService.addLog(
        '✗ Firefox VPN needs a session token — see the Firefox VPN settings',
        source: src,
      );
      processService.setPortConflictMessage(
        'Firefox VPN needs a session token first. Open the Firefox VPN '
        'settings and follow the guide to copy it from signedInUser.json.',
      );
      touch();
      return;
    }

    // ─── preflight باینری ───
    final binaryPath = await _preflightFfvpnBinary(src);
    if (binaryPath == null) return;

    // ─── preflight پورت ───
    if (!await _preflightFfvpnPorts(src)) return;

    userStoppedFfvpn = false;
    isFfvpnBusy = true;
    ffvpnStatus = 'Firefox VPN: Starting…';
    touch();

    final myGeneration = nextFfvpnGeneration();

    try {
      await saveSettings();

      if (userStoppedFfvpn) {
        processService.addLog(
          'Firefox VPN start cancelled by user (after saveSettings)',
          source: src,
        );
        return;
      }

      // ═══════════════════════════════════════════════════════════
      //  آپ‌استریم SOCKS (Psiphon / Tor / SSTP / WireGuard / دستی)
      // ═══════════════════════════════════════════════════════════
      if (!await resolveFfvpnUpstream()) return;

      if (userStoppedFfvpn) {
        processService.addLog(
          'Firefox VPN start cancelled by user (after upstream resolve)',
          source: src,
        );
        ffvpnStatus = 'Firefox VPN: Stopped';
        touch();
        return;
      }

      final upstream = FfvpnUpstreamBuilder(
        settings: settings,
        processService: processService,
      );
      final sni = SettingsValidation.normalizeFfvpnSni(settings.ffvpnSni);
      final dialProxy = upstream.buildUrl();

      final ok = await processService.startFfvpn(
        binaryPath: binaryPath,
        sessionToken: settings.ffvpnSessionToken,
        socksPort: settings.ffvpnSocksPort,
        httpPort: settings.ffvpnHttpPort,
        country:
            settings.ffvpnCountry.isEmpty ? null : settings.ffvpnCountry,
        sni: sni.isEmpty ? null : sni,
        dialProxy: dialProxy.isEmpty ? null : dialProxy,
      );

      if (userStoppedFfvpn) {
        processService.addLog(
          'Firefox VPN start cancelled by user (after process start)',
          source: src,
        );
        try {
          await processService.stopFfvpn();
        } catch (_) {}
        ffvpnStatus = 'Firefox VPN: Stopped';
        touch();
        return;
      }

      ffvpnStatus =
          ok ? 'Firefox VPN: Starting…' : 'Firefox VPN: Failed to start';

      if (myGeneration != _ffvpnGeneration) {
        processService.addLog(
          '→ Firefox VPN start completed but a newer start superseded it',
          source: src,
        );
      }
    } catch (e) {
      processService.addLog('✗ connectFfvpn error: $e', source: src);
      ffvpnStatus = 'Firefox VPN: Error';
    } finally {
      if (myGeneration == _ffvpnGeneration) {
        isFfvpnBusy = false;
      }
      await AppDataService.fixDataDirOwnership();
      touch();
    }
  }

  /// آپ‌استریم SOCKS انتخاب‌شده را برای ffvpn آماده می‌کند.
  ///
  /// برای تونل‌های داخلی (Psiphon/Tor/SSTP/WireGuard) اگر از قبل بالا
  /// نباشند، اول خودشان را بالا می‌آورد؛ برای حالت دستی فقط برنامه را
  /// لاگ می‌کند و ناقص بودن آدرس با هشدار رد می‌شود.
  Future<bool> resolveFfvpnUpstream() async {
    const src = LogSource.ffvpn;
    final builder = FfvpnUpstreamBuilder(
      settings: settings,
      processService: processService,
    );
    if (!builder.hasUpstream) return true;

    if (builder.type == FfvpnUpstreamBuilder.manual) {
      if (builder.buildUrl().isEmpty) {
        processService.addLog(
          '⚠ Firefox VPN upstream is set to Manual but the proxy host/port '
          'is empty — connecting directly',
          source: src,
        );
      } else {
        processService.addLog(
          '→ Firefox VPN will reach the edge through '
          '${builder.describeUrl()}',
          source: src,
        );
      }
      return true;
    }

    final port = builder.socksPort;
    switch (builder.type) {
      case FfvpnUpstreamBuilder.psiphon:
        return _ensureFfvpnUpstreamTunnel(
          name: 'Psiphon',
          port: port,
          isRunning: () => processService.isPsiphonRunning,
          start: () => connectPsiphon(fromAutoReconnect: false),
        );
      case FfvpnUpstreamBuilder.tor:
        return _ensureFfvpnUpstreamTunnel(
          name: 'Tor',
          port: port,
          isRunning: () => processService.isTorRunning,
          start: () => connectTor(fromAutoReconnect: false),
        );
      case FfvpnUpstreamBuilder.sstp:
        return _ensureFfvpnUpstreamTunnel(
          name: 'SSTP',
          port: port,
          isRunning: () => processService.isSstpRunning,
          start: () => connectSstp(fromAutoReconnect: false),
        );
      case FfvpnUpstreamBuilder.wireguard:
        return _ensureFfvpnUpstreamTunnel(
          name: 'WireGuard',
          port: port,
          isRunning: () => processService.isWireGuardRunning,
          start: () => connectWireGuard(fromAutoReconnect: false),
        );
      case FfvpnUpstreamBuilder.lantern:
        return _ensureFfvpnUpstreamTunnel(
          name: 'Lantern',
          port: port,
          isRunning: () => processService.isLanternRunning,
          start: () => connectLantern(),
        );
      case FfvpnUpstreamBuilder.geph:
        return _ensureFfvpnUpstreamTunnel(
          name: 'Geph',
          port: port,
          isRunning: () => processService.isGephRunning,
          start: () => connectGeph(),
        );
      default:
        return true;
    }
  }

  /// بالا آوردن تونل آپ‌استریم اگر لازم باشد؛ false یعنی ffvpn شروع نشود.
  Future<bool> _ensureFfvpnUpstreamTunnel({
    required String name,
    required int? port,
    required bool Function() isRunning,
    required Future<void> Function() start,
  }) async {
    const src = LogSource.ffvpn;

    if (isRunning()) {
      processService.addLog(
        '→ Firefox VPN upstream: $name already running',
        source: src,
      );
      return true;
    }

    ffvpnStatus = 'Firefox VPN: starting $name upstream…';
    touch();

    await start();

    if (userStoppedFfvpn) {
      processService.addLog(
        'Firefox VPN start cancelled by user (after $name upstream)',
        source: src,
      );
      ffvpnStatus = 'Firefox VPN: Stopped';
      touch();
      return false;
    }

    if (!isRunning()) {
      ffvpnStatus = 'Firefox VPN: $name unavailable — not started';
      processService.addLog(
        '✗ $name unavailable → Firefox VPN not started',
        source: src,
      );
      return false;
    }

    processService.addLog(
      '→ Firefox VPN will chain through $name (SOCKS 127.0.0.1:$port)',
      source: src,
    );
    return true;
  }
}
