part of 'app_provider.dart';

/// snapshot از state تونل‌ها برای تشخیص تغییر واقعی.
class _TunnelStateSnapshot {
  final bool psiphonRunning;
  final bool psiphonConnected;
  final bool aetherRunning;
  final bool torRunning;
  final bool torConnected;
  final int torBootstrapProgress;
  final bool sstpRunning;
  final bool sstpConnected;
  final bool wireGuardRunning;
  final bool wireGuardConnected;
  // ═══════════════════════════════════════════════════════════
  //  🆕 اضافه شد: آماده بودن تونل WireGuard (نه فقط running)
  // ═══════════════════════════════════════════════════════════
  final bool wireGuardTunnelReady;

  const _TunnelStateSnapshot({
    required this.psiphonRunning,
    required this.psiphonConnected,
    required this.aetherRunning,
    required this.torRunning,
    required this.torConnected,
    required this.torBootstrapProgress,
    required this.sstpRunning,
    required this.sstpConnected,
    required this.wireGuardRunning,
    required this.wireGuardConnected,
    required this.wireGuardTunnelReady,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _TunnelStateSnapshot &&
        other.psiphonRunning == psiphonRunning &&
        other.psiphonConnected == psiphonConnected &&
        other.aetherRunning == aetherRunning &&
        other.torRunning == torRunning &&
        other.torConnected == torConnected &&
        other.torBootstrapProgress == torBootstrapProgress &&
        other.sstpRunning == sstpRunning &&
        other.sstpConnected == sstpConnected &&
        other.wireGuardRunning == wireGuardRunning &&
        other.wireGuardConnected == wireGuardConnected &&
        other.wireGuardTunnelReady == wireGuardTunnelReady;
  }

  @override
  int get hashCode => Object.hash(
        psiphonRunning,
        psiphonConnected,
        aetherRunning,
        torRunning,
        torConnected,
        torBootstrapProgress,
        sstpRunning,
        sstpConnected,
        wireGuardRunning,
        wireGuardConnected,
        wireGuardTunnelReady,
      );
}
