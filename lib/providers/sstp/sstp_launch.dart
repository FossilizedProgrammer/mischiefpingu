part of '../app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  منطق start SSTP.
///
///  ⚠️ بازآرایی: guardها و آماده‌سازی config به فایل‌های
///  part جداگانه منتقل شدن:
///    • sstp/sstp_launch_guards.dart  → _checkSstpStartGuards
///    • sstp/sstp_launch_prepare.dart → _prepareSstpConfig
///
///  ⚠️ نکات مهم:
///   • isSstpBusy با generation check در finally
///   • چک userStoppedSstp بعد از هر await طولانی
///   • چک cancel بعد از resolveSstpUpstream
/// ═══════════════════════════════════════════════════════════════
extension AppProviderSstpLaunch on AppProvider {
  Future<void> startSstpInternal({required bool fromAutoReconnect}) async {
    const src = LogSource.sstp;

    if (!fromAutoReconnect) {
      _reconnectManager.cancelSstpTimer();
    }

    // ═══════════════════════════════════════════════════════════
    //  Guardها
    // ═══════════════════════════════════════════════════════════
    final guards = _checkSstpStartGuards(src, fromAutoReconnect);
    if (!guards.proceed) return;

    if (!await checkSstpBinaryAndServer()) return;
    if (!await checkSstpPorts()) return;

    if (!fromAutoReconnect) {
      userStoppedSstp = false;
    }

    isSstpBusy = true;
    sstpStatus = 'SSTP: Starting…';
    touch();

    final myGeneration = nextSstpGeneration();

    try {
      // ═══════════════════════════════════════════════════════════
      //  resolve upstream
      // ═══════════════════════════════════════════════════════════
      final upstreamOk = await resolveSstpUpstream(
        fromAutoReconnect: fromAutoReconnect,
      );

      if (userStoppedSstp) {
        _logSstpCancel(src, 'after upstream resolve');
        sstpStatus = 'SSTP: Stopped';
        touch();
        return;
      }

      if (!upstreamOk) return;

      // ═══════════════════════════════════════════════════════════
      //  آماده‌سازی config (شامل build + notification)
      // ═══════════════════════════════════════════════════════════
      await saveSettings();

      if (userStoppedSstp) {
        _logSstpCancel(src, 'after saveSettings');
        return;
      }

      final prep = await _prepareSstpConfig(src);
      if (prep == null) return; // cancel شده

      if (userStoppedSstp) {
        _logSstpCancel(src, 'before process start');
        sstpStatus = 'SSTP: Stopped';
        touch();
        return;
      }

      // ═══════════════════════════════════════════════════════════
      //  start process
      // ═══════════════════════════════════════════════════════════
      final ok = await processService.startSstp(
        args: prep.args,
        shareLan: settings.sstpShareLan,
        socksPort: settings.sstpSocksPort,
        httpPort: settings.sstpHttpPort,
      );

      if (userStoppedSstp) {
        _logSstpCancel(src, 'after process start — stopping');
        try {
          await processService.stopSstp();
        } catch (_) {}
        sstpStatus = 'SSTP: Stopped';
        touch();
        return;
      }

      sstpStatus = ok ? 'SSTP: Connected' : 'SSTP: Failed to start';

      if (myGeneration != _sstpGeneration) {
        processService.addLog(
          '→ SSTP start completed but a newer start superseded it',
          source: src,
        );
      }
    } catch (e) {
      processService.addLog('✗ connectSstp error: $e', source: src);
      sstpStatus = 'SSTP: Error';
    } finally {
      if (myGeneration == _sstpGeneration) {
        isSstpBusy = false;
      }
      await AppDataService.fixDataDirOwnership();
      touch();
    }
  }

  /// لاگ cancel SSTP.
  void _logSstpCancel(String src, String phase) {
    processService.addLog(
      'SSTP start cancelled by user ($phase)',
      source: src,
    );
  }
}
