part of '../app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  Guardهای شروع Tor.
/// ═══════════════════════════════════════════════════════════════
class TorStartGuardResult {
  final bool proceed;
  final String? reason;

  const TorStartGuardResult({required this.proceed, this.reason});

  static const TorStartGuardResult allowed = TorStartGuardResult(proceed: true);
}

extension AppProviderTorStartGuards on AppProvider {
  TorStartGuardResult _checkTorStartGuards(
    String src,
    bool fromAutoReconnect,
  ) {
    if (fromAutoReconnect && userStoppedTor) {
      processService.addLog(
        '→ Tor auto-reconnect skipped (stopped by user)',
        source: src,
      );
      return const TorStartGuardResult(
        proceed: false,
        reason: 'stopped-by-user',
      );
    }

    if (fromAutoReconnect && isTorBusy) {
      processService.addLog(
        '→ Tor auto-reconnect skipped (already busy)',
        source: src,
      );
      return const TorStartGuardResult(
        proceed: false,
        reason: 'already-busy',
      );
    }

    if (!fromAutoReconnect && isTorBusy) {
      processService.addLog(
        '→ Tor start ignored — already starting',
        source: src,
      );
      return const TorStartGuardResult(
        proceed: false,
        reason: 'already-starting',
      );
    }

    if (processService.isTorRunning && !fromAutoReconnect) {
      processService.addLog(
        '→ Tor is already running — ignoring redundant start',
        source: src,
      );
      return const TorStartGuardResult(
        proceed: false,
        reason: 'already-running',
      );
    }

    return TorStartGuardResult.allowed;
  }
}
