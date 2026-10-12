part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  منطق dispose AppProvider.
///
///  ⚠️ این تابع از `dispose()` خود AppProvider صدا زده می‌شه.
///  قبل از `super.dispose()` اجرا می‌شه تا مطمئن بشیم همه
///  منابع آزاد شدن.
/// ═══════════════════════════════════════════════════════════════
void disposeAppProvider(AppProvider p) {
  p.isShuttingDown = true;

  p._lastBuiltProfile = null;

  // ─── Network change detector ───
  p._networkChangeDetector.dispose();

  // ─── Health registry ───
  p._healthRegistry.dispose();

  // ─── Watchdogs + recovery ───
  p._watchdogManager?.disposeAll();
  p._recoveryCoordinator.dispose();

  // ─── Log subscription ───
  p._logSubscription?.cancel();
  p._logSubscription = null;

  // ─── Reconnect manager ───
  p._reconnectManager.cancelAll();

  // ─── Listener از processService ───
  p.processService.removeListener(p.handleProcessServiceChange);
}
