// lib/services/tunnel_watchdog_manager.dart
//
// ═══════════════════════════════════════════════════════════════
//  TunnelWatchdogManager — مدیریت متمرکز چهار watchdog
//
//  مسئولیت‌ها:
//   • ساخت watchdog برای هر تونل با پارامترهای صحیح
//   • start/stop خودکار بر اساس وضعیت اتصال
//   • cleanup در shutdown
//
//  ⚠️ نکته: syncWithConnectionState هر بار از
//  _onProcessServiceChanged صدا زده می‌شود (خیلی زیاد).
//  پس TunnelWatchdog.start() باید idempotent باشد —
//  که هست (با فیلد _started).
// ═══════════════════════════════════════════════════════════════
library;

import 'watchdog/tunnel_watchdog.dart';

class TunnelWatchdogManager {
  final TunnelWatchdog psiphon;
  final TunnelWatchdog aether;
  final TunnelWatchdog tor;
  final TunnelWatchdog sstp;

  const TunnelWatchdogManager({
    required this.psiphon,
    required this.aether,
    required this.tor,
    required this.sstp,
  });

  List<TunnelWatchdog> get all => [psiphon, aether, tor, sstp];

  /// start watchdogها بر اساس وضعیت فعلی اتصال.
  /// این متد idempotent است — می‌توانی هر بار از
  /// _onProcessServiceChanged صدا بزنی.
  void syncWithConnectionState({
    required bool psiphonConnected,
    required bool aetherConnected,
    required bool torConnected,
    required bool sstpConnected,
  }) {
    _sync(psiphon, psiphonConnected);
    _sync(aether, aetherConnected);
    _sync(tor, torConnected);
    _sync(sstp, sstpConnected);
  }

  void _sync(TunnelWatchdog wd, bool connected) {
    if (connected) {
      // start() خودش idempotent است — اگر فعال باشد کاری نمی‌کند
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
