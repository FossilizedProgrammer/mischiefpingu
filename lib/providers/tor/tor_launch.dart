part of '../app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  منطق start Tor (internal).
///
///  ⚠️ بازآرایی: guardها و آماده‌سازی config به فایل‌های
///  part جداگانه منتقل شدن:
///    • tor/tor_launch_guards.dart  → _checkTorStartGuards
///    • tor/tor_launch_prepare.dart → _prepareTorConfig
///
///  ⚠️ نکات مهم:
///   • isTorBusy با generation check در finally
///   • چک userStoppedTor بعد از هر await طولانی
/// ═══════════════════════════════════════════════════════════════
extension AppProviderTorLaunch on AppProvider {
  Future<void> startTorInternal({required bool fromAutoReconnect}) async {
    const src = LogSource.tor;

    if (!fromAutoReconnect) {
      _reconnectManager.cancelTorTimer();
    }

    // ═══════════════════════════════════════════════════════════
    //  Guardها
    // ═══════════════════════════════════════════════════════════
    final guards = _checkTorStartGuards(src, fromAutoReconnect);
    if (!guards.proceed) return;

    if (!await checkTorBinary()) return;
    if (!await checkTorPorts()) return;

    if (!fromAutoReconnect) {
      userStoppedTor = false;
    }

    isTorBusy = true;
    torStatus = 'Tor: Starting…';
    touch();

    final myGeneration = nextTorGeneration();

    try {
      // ═══════════════════════════════════════════════════════════
      //  resolve upstream
      // ═══════════════════════════════════════════════════════════
      final upstream = await resolveTorUpstream(
        fromAutoReconnect: fromAutoReconnect,
      );

      if (userStoppedTor) {
        _logTorCancel(src, 'after upstream resolve');
        return;
      }

      if (!upstream.ok) return;

      // ═══════════════════════════════════════════════════════════
      //  آماده‌سازی config
      // ═══════════════════════════════════════════════════════════
      await saveSettings();

      if (userStoppedTor) {
        _logTorCancel(src, 'after saveSettings');
        return;
      }

      final prep = await _prepareTorConfig(src);
      if (prep == null) return; // cancel شده

      if (userStoppedTor) {
        _logTorCancel(src, 'before process start');
        torStatus = 'Tor: Stopped';
        touch();
        return;
      }

      // ═══════════════════════════════════════════════════════════
      //  start process
      // ═══════════════════════════════════════════════════════════
      torStatus = 'Tor: Bootstrapping…';
      touch();

      processService.prepareTorNotification(
        upstream.type,
        upstream.detail,
      );

      final ok = await processService.startTor(
        torrcPath: prep.torrcPath,
        workDir: prep.workDir,
        env: prep.env,
        shareLan: settings.torShareLan,
        socksPort: settings.torSocksPort,
        httpPort: settings.torHttpPort,
        internalSocksPort: prep.internalSocks,
        internalHttpPort: prep.internalHttp,
      );

      if (userStoppedTor) {
        _logTorCancel(src, 'after process start — stopping');
        try {
          await processService.stopTor();
        } catch (_) {}
        torStatus = 'Tor: Stopped';
        touch();
        return;
      }

      torStatus = ok ? 'Tor: Bootstrapping…' : 'Tor: Failed to start';
      if (!ok) {
        processService.addLog(
          '✗ Tor failed to start — is `tor` installed? '
          '(Core Updates can fetch it)',
          source: src,
        );
      }

      if (myGeneration != _torGeneration) {
        processService.addLog(
          '→ Tor start completed but a newer start superseded it',
          source: src,
        );
      }
    } catch (e) {
      processService.addLog('✗ connectTor error: $e', source: src);
      torStatus = 'Tor: Error';
    } finally {
      if (myGeneration == _torGeneration) {
        isTorBusy = false;
      }
      await AppDataService.fixDataDirOwnership();
      touch();
    }
  }

  /// لاگ cancel Tor.
  void _logTorCancel(String src, String phase) {
    processService.addLog(
      'Tor start cancelled by user ($phase)',
      source: src,
    );
  }
}
