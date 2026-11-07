library;

import 'watchdog_network_profile.dart';
import 'watchdog_profile_params.dart';

/// ═══════════════════════════════════════════════════════════════
///  WatchdogConfig — مقادیر پیش‌فرض سراسری.
///
///  ⚠️ تغییر مهم:
///  مقادیر hardcode قبلی حالا از WatchdogProfileParams می‌آیند.
///  این فایل فقط به عنوان fallback و برای سازگاری نگه داشته شده.
///
///  ⚠️ نکته عملکرد: `_default` یکبار ساخته می‌شود (static final).
///  این getterها در hot path (probe loop) استفاده نمی‌شن.
/// ═══════════════════════════════════════════════════════════════
class WatchdogConfig {
  WatchdogConfig._();

  // ─── fallback: همان normal profile ───
  static final WatchdogProfileParams _default =
      WatchdogProfileParams.forProfile(WatchdogNetworkProfile.normal);

  static Duration get psiphonInterval => _default.psiphonInterval;
  static Duration get aetherInterval => _default.aetherInterval;
  static Duration get torInterval => _default.torInterval;
  static Duration get sstpInterval => _default.sstpInterval;

  static int get maxFailures => _default.maxFailures;
  static Duration get restartGracePeriod => _default.restartGracePeriod;

  static Duration get connectTimeout => _default.connectTimeout;
  static Duration get socksTimeout => _default.socksTimeout;
  static Duration get httpProbeTimeout => _default.httpProbeTimeout;

  static int get circuitBreakerMaxRestarts =>
      _default.circuitBreakerMaxRestarts;
  static Duration get circuitBreakerWindow => _default.circuitBreakerWindow;
  static Duration get circuitBreakerCooldown => _default.circuitBreakerCooldown;

  static bool get suppressRestartWhenInternetDead => true;

  static int get highLatencyMs => _default.highLatencyMs;
  static bool get enableQualityBasedRestart =>
      _default.enableQualityBasedRestart;
  static int get degradedConsecutiveLimit => _default.degradedConsecutiveLimit;

  static Duration intervalFor(String tunnelName) =>
      _default.intervalFor(tunnelName);
}

class WatchdogConfigGrace {
  WatchdogConfigGrace._();

  static Duration get gracePeriod => WatchdogConfig.restartGracePeriod;
}
