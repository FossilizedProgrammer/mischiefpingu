part of '../app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  Guardهای شروع SSTP.
///
///  این تابع در ابتدای `startSstpInternal` صدا زده می‌شه.
///
///  شرایط توقف:
///    • auto-reconnect وقتی user دستی stop کرده
///    • auto-reconnect وقتی already busy
///    • start معمولی وقتی already busy
///    • start معمولی وقتی already running
/// ═══════════════════════════════════════════════════════════════
class SstpStartGuardResult {
  final bool proceed;
  final String? reason;

  const SstpStartGuardResult({required this.proceed, this.reason});

  static const SstpStartGuardResult allowed =
      SstpStartGuardResult(proceed: true);
}

extension AppProviderSstpStartGuards on AppProvider {
  SstpStartGuardResult _checkSstpStartGuards(
    String src,
    bool fromAutoReconnect,
  ) {
    if (fromAutoReconnect && userStoppedSstp) {
      processService.addLog(
        '→ SSTP auto-reconnect skipped (stopped by user)',
        source: src,
      );
      return const SstpStartGuardResult(
        proceed: false,
        reason: 'stopped-by-user',
      );
    }

    if (fromAutoReconnect && isSstpBusy) {
      processService.addLog(
        '→ SSTP auto-reconnect skipped (already busy)',
        source: src,
      );
      return const SstpStartGuardResult(
        proceed: false,
        reason: 'already-busy',
      );
    }

    if (!fromAutoReconnect && isSstpBusy) {
      processService.addLog(
        '→ SSTP start ignored — already starting',
        source: src,
      );
      return const SstpStartGuardResult(
        proceed: false,
        reason: 'already-starting',
      );
    }

    if (processService.isSstpRunning && !fromAutoReconnect) {
      processService.addLog(
        '→ SSTP is already running — ignoring redundant start',
        source: src,
      );
      return const SstpStartGuardResult(
        proceed: false,
        reason: 'already-running',
      );
    }

    return SstpStartGuardResult.allowed;
  }
}
