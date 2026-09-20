part of '../app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  Smart reconnect logic برای Aether.
///
///  ⚠️ تغییر مهم:
///  `isAutoTesting` از cancel-check حذف شد. دلیل:
///  وقتی این متد از _startAetherInternal صدا زده می‌شود،
///  `isAutoTesting` ممکن است true باشد (چون caller خودش
///  در حال تست است) و این باعث cancel فوری می‌شد.
///
///  حالا فقط `userStoppedAether` و `isShuttingDown` باعث
///  cancel می‌شوند. `isAutoTesting` صرفاً برای UI است.
/// ═══════════════════════════════════════════════════════════════
extension AppProviderAetherSmartReconnect on AppProvider {
  /// تلاش برای reconnect هوشمند با استفاده از تاریخچه Gateway.
  ///
  /// خروجی: true اگر اتصال برقرار شد.
  Future<bool> _trySmartReconnect() async {
    const src = LogSource.aether;

    final orchestrator = _gatewayReconnectOrchestrator;
    if (orchestrator == null) {
      processService.addLog(
        '→ Smart reconnect skipped (no history store)',
        source: src,
      );
      return false;
    }

    processService.addLog(
      '→ Starting smart reconnect (phase 1+2)…',
      source: src,
    );

    final port = settings.aetherLocalPort;

    try {
      final ok = await orchestrator.attemptSmartReconnect(
        port: port,
        // ⚠️ فقط userStopped و shutdown باعث cancel می‌شوند.
        //    isAutoTesting اینجا نیست چون این متد خودش
        //    یک نوع testing است و باید اجازه داشته باشد اجرا شود.
        isCancelRequested: () => userStoppedAether || isShuttingDown,
      );
      return ok;
    } catch (e) {
      processService.addLog(
        '⚠ Smart reconnect threw: $e',
        source: src,
      );
      return false;
    }
  }
}
