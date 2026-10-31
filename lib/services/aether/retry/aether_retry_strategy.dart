// lib/services/aether/retry/aether_retry_strategy.dart

library;

/// ═══════════════════════════════════════════════════════════════
///  AetherRetryStrategy — استراتژی retry با تاخیر افزایشی و
///  جابه‌جایی H2/H3.
///
///  این کلاس مسئول:
///    • تعیین تاخیر بین تلاش‌ها (exponential backoff)
///    • تعیین MASQUE option برای هر تلاش (alternating H2/H3)
///    • تعیین حداکثر تعداد تلاش
///    • تصمیم‌گیری در مورد ادامه/توقف
///
///  ⚠️ این کلاس stateless است — همه‌ی state در caller است.
/// ═══════════════════════════════════════════════════════════════
class AetherRetryStrategy {
  AetherRetryStrategy._();

  /// حداکثر تعداد تلاش کل (شامل تلاش اول).
  static const int maxAttempts = 8;

  /// تاخیرها به میلی‌ثانیه — اندیس 0 برای بعد از تلاش اول.
  ///
  ///   3s → 6s → 12s → 24s → 48s → 60s → 60s
  static const List<Duration> delays = [
    Duration(seconds: 3),
    Duration(seconds: 6),
    Duration(seconds: 12),
    Duration(seconds: 24),
    Duration(seconds: 48),
    Duration(seconds: 60),
    Duration(seconds: 60),
  ];

  /// گرفتن تاخیر برای تلاش بعدی.
  ///
  /// [attemptIndex] اندیس تلاش بعدی است (1-based).
  /// یعنی بعد از تلاش اول، attemptIndex=2 → delay[0] برمی‌گرده.
  static Duration delayAfterAttempt(int attemptIndex) {
    if (attemptIndex <= 1) return Duration.zero;
    final idx = attemptIndex - 2;
    if (idx < 0) return Duration.zero;
    if (idx >= delays.length) return delays.last;
    return delays[idx];
  }

  /// گرفتن MASQUE option برای یک تلاش خاص.
  ///
  /// استراتژی:
  ///   • تلاش 1  → مقدار اصلی کاربر
  ///   • تلاش 2  → مخالف مقدار اصلی
  ///   • تلاش 3  → مقدار اصلی
  ///   • الی آخر
  ///
  /// ⚠️ این کار باعث میشه اگه ISP یکی از دو نسخه رو بلاک کرده باشه،
  /// تلاش بعدی خودکار اون یکی رو امتحان کنه.
  static String masqueForAttempt({
    required String preferredMasque,
    required int attemptIndex,
  }) {
    // نرمال‌سازی
    final preferred = preferredMasque == 'HTTP-2' ? 'HTTP-2' : 'HTTP-3';
    final alternate = preferred == 'HTTP-3' ? 'HTTP-2' : 'HTTP-3';

    // تلاش‌های فرد (1, 3, 5, ...) → preferred
    // تلاش‌های زوج (2, 4, 6, ...) → alternate
    if (attemptIndex <= 0) return preferred;
    return (attemptIndex % 2 == 1) ? preferred : alternate;
  }

  /// آیا باید بعد از این تلاش، تلاش دیگه‌ای انجام بشه؟
  static bool shouldContinue({
    required int attemptIndex,
    required bool success,
  }) {
    if (success) return false;
    return attemptIndex < maxAttempts;
  }

  /// رشته‌ی توصیفی برای نمایش در UI/لاگ.
  static String describeAttempt({
    required int attemptIndex,
    required String masque,
    required String protocol,
  }) {
    return 'Attempt $attemptIndex/$maxAttempts · '
        '${protocol.toUpperCase()}${masque.isNotEmpty ? "/$masque" : ""}';
  }
}
