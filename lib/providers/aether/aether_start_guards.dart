part of '../app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  Guardهای شروع Aether.
///
///  این تابع در ابتدای `_startAetherInternal` صدا زده می‌شه و
///  بررسی می‌کنه که آیا ادامه دادن منطقی هست یا نه.
///
///  شرایط توقف:
///    • auto-reconnect وقتی user دستی stop کرده
///    • auto-reconnect وقتی already auto-testing
///    • start معمولی وقتی already running
///
///  خروجی: (`proceed` = آیا ادامه بدیم، `reason` = دلیل توقف)
/// ═══════════════════════════════════════════════════════════════
class AetherStartGuardResult {
  final bool proceed;
  final String? reason;

  const AetherStartGuardResult({required this.proceed, this.reason});

  static const AetherStartGuardResult allowed =
      AetherStartGuardResult(proceed: true);
}

extension AppProviderAetherStartGuards on AppProvider {
  /// بررسی guardها قبل از شروع Aether.
  ///
  /// این تابع هیچ side-effectی نداره — فقط بررسی می‌کنه.
  /// لاگ توقف‌ها هم اینجا انجام می‌شه.
  AetherStartGuardResult _checkAetherStartGuards(
    String src,
    bool fromAutoReconnect,
  ) {
    // ─── Guard 1: auto-reconnect توسط user متوقف شده ───
    if (fromAutoReconnect && userStoppedAether) {
      processService.addLog(
        '→ Aether auto-reconnect skipped (stopped by user)',
        source: src,
      );
      return const AetherStartGuardResult(
        proceed: false,
        reason: 'stopped-by-user',
      );
    }

    // ─── Guard 2: auto-reconnect در حالی که auto-testing هست ───
    if (fromAutoReconnect && isAutoTesting) {
      processService.addLog(
        '→ Aether auto-reconnect skipped (already auto-testing)',
        source: src,
      );
      return const AetherStartGuardResult(
        proceed: false,
        reason: 'already-auto-testing',
      );
    }

    // ─── Guard 3: start معمولی در حالی که running هست ───
    if (processService.isAetherRunning && !fromAutoReconnect) {
      processService.addLog(
        '→ Aether is already running — ignoring redundant start',
        source: src,
      );
      return const AetherStartGuardResult(
        proceed: false,
        reason: 'already-running',
      );
    }

    return AetherStartGuardResult.allowed;
  }
}
