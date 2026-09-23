library;

import 'watchdog/tunnel_watchdog.dart';

class TunnelWatchdogManager {
  final TunnelWatchdog psiphon;
  final TunnelWatchdog aether;
  final TunnelWatchdog tor;
  final TunnelWatchdog sstp;
  final TunnelWatchdog wireguard;

  const TunnelWatchdogManager({
    required this.psiphon,
    required this.aether,
    required this.tor,
    required this.sstp,
    required this.wireguard,
  });

  /// همه watchdogها — شامل wireguard.
  List<TunnelWatchdog> get all => [psiphon, aether, tor, sstp, wireguard];

  /// start watchdogها بر اساس وضعیت فعلی اتصال.
  /// این متد idempotent است — می‌توانی هر بار از
  /// _onProcessServiceChanged صدا بزنی.
  void syncWithConnectionState({
    required bool psiphonConnected,
    required bool aetherConnected,
    required bool torConnected,
    required bool sstpConnected,
    required bool wireGuardConnected,
  }) {
    _sync(psiphon, psiphonConnected);
    _sync(aether, aetherConnected);
    _sync(tor, torConnected);
    _sync(sstp, sstpConnected);
    _sync(wireguard, wireGuardConnected);
  }

  void _sync(TunnelWatchdog wd, bool connected) {
    if (connected) {
      wd.start();
    } else {
      wd.stop();
    }
  }

  void resetAllFailures() {
    for (final wd in all) {
      wd.resetFailures();
    }
  }

  void stopAll() {
    for (final wd in all) {
      wd.stop();
    }
  }

  void disposeAll() {
    for (final wd in all) {
      wd.dispose();
    }
  }
}
