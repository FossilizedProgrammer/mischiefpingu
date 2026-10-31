part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  Watchdog Factory — ساخت TunnelWatchdogManager با پارامترها.
///
///  این تابع top-level هست چون:
///    • به fieldهای private نیاز نداره
///    • فقط `AppProvider` رو می‌گیره و از public API اون استفاده می‌کنه
///
///  ⚠️ نکته: از `TunnelWatchdogFactory.build` استفاده می‌کنه که
///  قبلاً در `services/tunnel_watchdog_factory.dart` تعریف شده.
/// ═══════════════════════════════════════════════════════════════
TunnelWatchdogManager _buildWatchdogManager({
  required AppProvider provider,
  required ProcessService processService,
  required Future<bool> Function() isInternetAlive,
  required Future<RecoveryLeaseResult> Function() acquirePsiphonLease,
  required Future<RecoveryLeaseResult> Function() acquireAetherLease,
  required Future<RecoveryLeaseResult> Function() acquireTorLease,
  required Future<RecoveryLeaseResult> Function() acquireSstpLease,
  required Future<RecoveryLeaseResult> Function() acquireWireGuardLease,
}) {
  return TunnelWatchdogFactory.build(
    provider: provider,
    processService: processService,
    isInternetAlive: isInternetAlive,
    acquirePsiphonLease: acquirePsiphonLease,
    acquireAetherLease: acquireAetherLease,
    acquireTorLease: acquireTorLease,
    acquireSstpLease: acquireSstpLease,
    acquireWireGuardLease: acquireWireGuardLease,
    restartPsiphon: () => provider.restartPsiphonInternal(
        reason: 'watchdog detected dead tunnel'),
    restartAether: () =>
        provider.restartAetherInternal(reason: 'watchdog detected dead tunnel'),
    restartTor: () =>
        provider.restartTorInternal(reason: 'watchdog detected dead tunnel'),
    restartSstp: () =>
        provider.restartSstpInternal(reason: 'watchdog detected dead tunnel'),
    restartWireGuard: () => provider.restartWireGuardInternal(
        reason: 'watchdog detected dead tunnel'),
  );
}
