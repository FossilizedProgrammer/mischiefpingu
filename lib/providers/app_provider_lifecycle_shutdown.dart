part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  AppProviderLifecycleShutdown — منطق shutdown کامل برنامه.
///
///  این extension از `app_provider_lifecycle.dart` جدا شده
///  تا فایل اصلی فقط startup رو نگه داره.
///
///  ⚠️ ترتیب خاموش‌کردن مهم است: هر تونلی که ممکن است آپ‌استریم تونل
///  دیگری باشد باید *قبل* از آپ‌استریمش بسته شود، وگرنه اتصالش وسط کار
///  قطع می‌شود و ممکن است پروسه‌ای زنده بماند.
/// ═══════════════════════════════════════════════════════════════
extension AppProviderLifecycleShutdown on AppProvider {
  /// یک تونل را — اگر واقعاً فعال باشد — می‌بندد.
  ///
  /// خطای یک تونل بقیه را متوقف نمی‌کند؛ نتیجهٔ false یعنی این یکی
  /// تمیز بسته نشد و باید در خلاصهٔ پایانی گزارش شود.
  Future<bool> _stopTunnel(
    String label,
    bool Function() isActive,
    Future<void> Function() stop,
  ) async {
    if (!isActive()) return true;
    processService.addLog('→ Stopping $label…', source: LogSource.app);
    try {
      await stop();
      return true;
    } catch (e) {
      processService.addLog(
        '⚠ $label shutdown error: $e',
        source: LogSource.app,
      );
      return false;
    }
  }

  Future<void> shutdownAllInternal() async {
    if (isShuttingDown) return;
    isShuttingDown = true;
    try {
      watchdogManager?.disposeAll();
    } catch (_) {}
    processService.addLog(
      '→ App is closing — disconnecting all active tunnels…',
      source: LogSource.app,
    );
    reconnectManager.cancelAll();

    // ⚠️ قبل از هر توقفی، همه را «دستی متوقف‌شده» علامت می‌زنیم. هر start
    // در جریان بعد از هر await با همین پرچم کنسل می‌شود (و اگر پروسه را
    // تازه ساخته باشد، خودش می‌بندد) و upstream resolverها هم دیگر تونل
    // تازه‌ای بالا نمی‌آورند؛ وگرنه ممکن است بعد از این پاس خاموش‌کردن یک
    // تونل تازه بالا بیاید و زنده رها شود.
    userStoppedPsiphon = true;
    userStoppedTor = true;
    userStoppedSstp = true;
    userStoppedWireGuard = true;
    userStoppedFfvpn = true;
    userStoppedLantern = true;
    userStoppedGeph = true;

    final ps = processService;

    // ─── گروه ۱: تونل‌های «لایهٔ بالا» ───
    // Geph / Lantern / Firefox VPN هم می‌توانند آپ‌استریم یکدیگر باشند و هم
    // آپ‌استریم Tor/Psiphon/SSTP/WireGuard؛ پس اول این‌ها بسته می‌شوند.
    // داخل هر گروه توقف‌ها موازی اجرا می‌شوند تا با چند تونلِ هم‌زمان،
    // انتظار از بودجهٔ بستن پنجره رد نشود.
    final dependents = await Future.wait([
      _stopTunnel(
        'Geph',
        () => ps.isGephRunning || isGephBusy,
        ps.stopGeph,
      ),
      _stopTunnel(
        'Lantern',
        () => ps.isLanternRunning || isLanternBusy,
        ps.stopLantern,
      ),
      _stopTunnel(
        'Firefox VPN',
        () => ps.isFfvpnRunning || isFfvpnBusy,
        ps.stopFfvpn,
      ),
    ]);

    // ─── گروه ۲: آپ‌استریم‌ها ───
    final upstreams = await Future.wait([
      _stopTunnel('Tor', () => ps.isTorRunning || isTorBusy, ps.stopTor),
      _stopTunnel(
        'Psiphon',
        () => ps.isPsiphonRunning || isPsiphonBusy,
        ps.stopPsiphon,
      ),
      _stopTunnel('SSTP', () => ps.isSstpRunning || isSstpBusy, ps.stopSstp),
      _stopTunnel(
        'WireGuard',
        () => ps.isWireGuardRunning || isWireGuardBusy,
        ps.stopWireGuard,
      ),
    ]);

    try {
      await ps.closeAllForwardSockets();
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 300));

    final failedTunnels =
        [...dependents, ...upstreams].where((ok) => !ok).length;

    // تأیید نهایی از روی state واقعی پروسه‌ها، نه فقط موفق‌بودن فراخوانی stop.
    final stillRunning = <String>[
      if (ps.isGephRunning) 'Geph',
      if (ps.isLanternRunning) 'Lantern',
      if (ps.isFfvpnRunning) 'Firefox VPN',
      if (ps.isTorRunning) 'Tor',
      if (ps.isPsiphonRunning) 'Psiphon',
      if (ps.isSstpRunning) 'SSTP',
      if (ps.isWireGuardRunning) 'WireGuard',
    ];

    if (failedTunnels == 0 && stillRunning.isEmpty) {
      processService.addLog(
        '★ All tunnels disconnected. Safe to exit.',
        source: LogSource.app,
      );
    } else {
      final details = [
        if (failedTunnels > 0) '$failedTunnels stop error(s)',
        if (stillRunning.isNotEmpty)
          'still running: ${stillRunning.join(', ')}',
      ].join(' — ');
      processService.addLog(
        '⚠ Shutdown did not stop cleanly ($details) — a leftover process may '
        'still be alive; see the errors above.',
        source: LogSource.app,
      );
    }
  }
}
