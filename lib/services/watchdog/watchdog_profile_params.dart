library;

import 'watchdog_network_profile.dart';

/// ═══════════════════════════════════════════════════════════════
///  WatchdogProfileParams — پارامترهای runtime بر اساس پروفایل.
///
///  ⚠️ این تنها جایی است که اعداد جادویی واچ‌داگ تعریف می‌شوند.
///  تغییر پروفایل در runtime از طریق rebuild کل watchdog manager
///  انجام می‌شود (نه با تغییر instance فعلی).
///
///  ⚠️ توجه درباره رابطهٔ requireHttpSuccess و tolerateHttpFailureAfterConnect:
///    • requireHttpSuccess = true  ⇒ tolerateHttpFailureAfterConnect = false
///      (stable: اگر HTTP موفق نشد، تونل dead محسوب می‌شود)
///    • requireHttpSuccess = false ⇒ tolerateHttpFailureAfterConnect = true
///      (normal/harsh: فقط SOCKS CONNECT موفق کافی است)
///
///  این دو فیلد عمداً هر دو نگه داشته شدند تا در آینده بتوان
///  ترکیب‌های دیگری (مثلاً "HTTP اجباری ولی فقط برای لاگ") را
///  پیاده کرد. فعلاً منطق probe آن‌ها را به‌صورت معکوس هم می‌بیند.
/// ═══════════════════════════════════════════════════════════════
class WatchdogProfileParams {
  // ─── interval per tunnel ───
  final Duration psiphonInterval;
  final Duration aetherInterval;
  final Duration torInterval;
  final Duration sstpInterval;

  // ─── آستانه‌ها ───
  final int maxFailures;

  // ─── timeoutها ───
  final Duration connectTimeout;
  final Duration socksTimeout;
  final Duration httpProbeTimeout;

  // ─── grace period ───
  final Duration restartGracePeriod;

  // ─── circuit breaker ───
  final int circuitBreakerMaxRestarts;
  final Duration circuitBreakerWindow;
  final Duration circuitBreakerCooldown;

  // ─── سیاست probe ───
  /// آیا برای alive بودن، پاسخ HTTP موفق لازم است؟
  ///
  ///  • stable:  true  (سخت‌گیر)
  ///  • normal:  false (SOCKS CONNECT کافی است)
  ///  • harsh:   false (SOCKS CONNECT کافی است)
  final bool requireHttpSuccess;

  /// اگر true باشد، شکست HTTP پس از CONNECT موفق به معنی dead نیست.
  ///
  ///  • stable:  false (HTTP مهم است)
  ///  • normal:  true  (HTTP ناموفق = dead نیست)
  ///  • harsh:   true  (HTTP ناموفق = dead نیست)
  final bool tolerateHttpFailureAfterConnect;

  /// اگر true باشد، در harsh فقط وقتی همه هدف‌ها fail شوند probe fail می‌شود.
  ///
  ///  • stable:  false
  ///  • normal:  false
  ///  • harsh:   true
  final bool requireAllTargetsFailToMarkDead;

  /// آیا از Cloudflare به عنوان هدف probe استفاده شود؟
  ///
  ///  • stable:  true
  ///  • normal:  true
  ///  • harsh:   false (به دلیل فیلترینگ احتمالی Cloudflare)
  final bool includeCloudflareTarget;

  /// enableQualityBasedRestart — فقط در stable به صورت محافظه‌کار.
  final bool enableQualityBasedRestart;

  /// آستانه latency بالا (ms) برای کیفیت.
  final int highLatencyMs;

  /// تعداد probeهای degraded متوالی برای restart.
  final int degradedConsecutiveLimit;

  const WatchdogProfileParams({
    required this.psiphonInterval,
    required this.aetherInterval,
    required this.torInterval,
    required this.sstpInterval,
    required this.maxFailures,
    required this.connectTimeout,
    required this.socksTimeout,
    required this.httpProbeTimeout,
    required this.restartGracePeriod,
    required this.circuitBreakerMaxRestarts,
    required this.circuitBreakerWindow,
    required this.circuitBreakerCooldown,
    required this.requireHttpSuccess,
    required this.tolerateHttpFailureAfterConnect,
    required this.requireAllTargetsFailToMarkDead,
    required this.includeCloudflareTarget,
    required this.enableQualityBasedRestart,
    required this.highLatencyMs,
    required this.degradedConsecutiveLimit,
  });

  /// ساخت پارامترها بر اساس پروفایل.
  static WatchdogProfileParams forProfile(WatchdogNetworkProfile profile) {
    switch (profile) {
      case WatchdogNetworkProfile.stable:
        return const WatchdogProfileParams(
          psiphonInterval: Duration(seconds: 50),
          aetherInterval: Duration(seconds: 50),
          torInterval: Duration(seconds: 75),
          sstpInterval: Duration(seconds: 50),
          maxFailures: 3,
          connectTimeout: Duration(seconds: 7),
          socksTimeout: Duration(seconds: 9),
          httpProbeTimeout: Duration(seconds: 11),
          restartGracePeriod: Duration(minutes: 2),
          circuitBreakerMaxRestarts: 2,
          circuitBreakerWindow: Duration(minutes: 10),
          circuitBreakerCooldown: Duration(minutes: 15),
          requireHttpSuccess: true,
          tolerateHttpFailureAfterConnect: false,
          requireAllTargetsFailToMarkDead: false,
          includeCloudflareTarget: true,
          enableQualityBasedRestart: false,
          highLatencyMs: 5000,
          degradedConsecutiveLimit: 4,
        );

      case WatchdogNetworkProfile.normal:
        return const WatchdogProfileParams(
          psiphonInterval: Duration(seconds: 75),
          aetherInterval: Duration(seconds: 75),
          torInterval: Duration(seconds: 100),
          sstpInterval: Duration(seconds: 75),
          maxFailures: 5,
          connectTimeout: Duration(seconds: 11),
          socksTimeout: Duration(seconds: 13),
          httpProbeTimeout: Duration(seconds: 16),
          restartGracePeriod: Duration(minutes: 2, seconds: 30),
          circuitBreakerMaxRestarts: 3,
          circuitBreakerWindow: Duration(minutes: 10),
          circuitBreakerCooldown: Duration(minutes: 12),
          requireHttpSuccess: false,
          tolerateHttpFailureAfterConnect: true,
          requireAllTargetsFailToMarkDead: false,
          includeCloudflareTarget: true,
          enableQualityBasedRestart: false,
          highLatencyMs: 8000,
          degradedConsecutiveLimit: 5,
        );

      case WatchdogNetworkProfile.harsh:
        return const WatchdogProfileParams(
          psiphonInterval: Duration(seconds: 105),
          aetherInterval: Duration(seconds: 105),
          torInterval: Duration(seconds: 120),
          sstpInterval: Duration(seconds: 105),
          maxFailures: 9,
          connectTimeout: Duration(seconds: 13),
          socksTimeout: Duration(seconds: 17),
          httpProbeTimeout: Duration(seconds: 22),
          restartGracePeriod: Duration(minutes: 4),
          circuitBreakerMaxRestarts: 5,
          circuitBreakerWindow: Duration(minutes: 15),
          circuitBreakerCooldown: Duration(minutes: 20),
          requireHttpSuccess: false,
          tolerateHttpFailureAfterConnect: true,
          requireAllTargetsFailToMarkDead: true,
          includeCloudflareTarget: false,
          enableQualityBasedRestart: false,
          highLatencyMs: 12000,
          degradedConsecutiveLimit: 8,
        );
    }
  }

  Duration intervalFor(String tunnelName) {
    switch (tunnelName.toLowerCase()) {
      case 'psiphon':
        return psiphonInterval;
      case 'aether':
        return aetherInterval;
      case 'tor':
        return torInterval;
      case 'sstp':
        return sstpInterval;
      default:
        return psiphonInterval;
    }
  }
}
