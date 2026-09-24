part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  AppProviderWireGuardInternal — منطق start داخلی.
///
///  ⚠️ نسخهٔ ساده — بدون پشتیبانی vpn:// و Amnezia API.
///  کاربر باید کانفیگ استاندارد یا URI بده.
/// ═══════════════════════════════════════════════════════════════
extension AppProviderWireGuardInternal on AppProvider {
  Future<void> _startWireGuardInternal({
    required bool fromAutoReconnect,
  }) async {
    const src = LogSource.wireguard;

    if (!fromAutoReconnect) {
      _reconnectManager.cancelWireGuardTimer();
    }

    if (fromAutoReconnect && userStoppedWireGuard) {
      processService.addLog(
        '→ WireGuard auto-reconnect skipped (stopped by user)',
        source: src,
      );
      return;
    }

    if (fromAutoReconnect && isWireGuardBusy) {
      processService.addLog(
        '→ WireGuard auto-reconnect skipped (already busy)',
        source: src,
      );
      return;
    }

    if (!fromAutoReconnect && isWireGuardBusy) {
      processService.addLog(
        '→ WireGuard start ignored — already starting',
        source: src,
      );
      return;
    }

    if (processService.isWireGuardRunning && !fromAutoReconnect) {
      processService.addLog(
        '→ WireGuard is already running — ignoring redundant start',
        source: src,
      );
      return;
    }

    // ─── preflight باینری ───
    if (!await _preflightWireGuardBinary(src)) return;

    // ─── preflight کانفیگ ───
    final parsedConfig = WireGuardConfigParser.parse(
      settings.wireguardConfigRaw,
    );
    if (parsedConfig == null || !parsedConfig.isValid) {
      processService.addLog(
        '✗ Invalid or empty WireGuard config',
        source: src,
      );
      wireGuardStatus = 'WireGuard: Invalid config';
      processService.setPortConflictMessage(
        'WireGuard config is invalid. Please check PrivateKey, PublicKey, and Endpoint.',
      );
      touch();
      return;
    }

    // ─── preflight پورت ───
    if (!await _preflightWireGuardPort(src)) return;

    if (!fromAutoReconnect) {
      userStoppedWireGuard = false;
    }

    isWireGuardBusy = true;
    wireGuardStatus = 'WireGuard: Starting…';
    touch();

    final myGeneration = nextWireGuardGeneration();

    try {
      final coreType = settings.wireGuardCoreType;

      final builder = WireGuardConfigBuilder(processService: processService);
      final wrapperPath = await builder.build(
        config: parsedConfig,
        socksPort: settings.wireguardSocksPort,
        shareOnLan: settings.wireguardShareLan,
        coreType: coreType,
      );

      if (userStoppedWireGuard) {
        processService.addLog(
          'WireGuard start cancelled by user (after config build)',
          source: src,
        );
        return;
      }

      final ok = await processService.startWireGuard(
        wrapperConfigPath: wrapperPath,
        coreType: coreType,
      );

      if (userStoppedWireGuard) {
        processService.addLog(
          'WireGuard start cancelled by user (after process start)',
          source: src,
        );
        try {
          await processService.stopWireGuard();
        } catch (_) {}
        wireGuardStatus = 'WireGuard: Stopped';
        touch();
        return;
      }

      wireGuardStatus =
          ok ? 'WireGuard: Connected' : 'WireGuard: Failed to start';

      if (myGeneration != _wireGuardGeneration) {
        processService.addLog(
          '→ WireGuard start completed but a newer start superseded it',
          source: src,
        );
      }
    } catch (e) {
      processService.addLog('✗ connectWireGuard error: $e', source: src);
      wireGuardStatus = 'WireGuard: Error';
    } finally {
      if (myGeneration == _wireGuardGeneration) {
        isWireGuardBusy = false;
      }
      await AppDataService.fixDataDirOwnership();
      touch();
    }
  }
}
