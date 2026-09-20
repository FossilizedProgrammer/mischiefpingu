library;

import 'watchdog_config.dart';
import 'watchdog_quality_metrics.dart';

/// ═══════════════════════════════════════════════════════════════
///  WatchdogQualityTracker — ردیابی افت کیفیت در طول زمان.
/// ═══════════════════════════════════════════════════════════════
class WatchdogQualityTracker {
  int _degradedStreak = 0;

  /// آستانه‌ی پیش‌فرض — از WatchdogConfig خونده می‌شه تا هم‌راستا بمونه.
  static int get defaultDegradedConsecutiveLimit =>
      WatchdogConfig.degradedConsecutiveLimit;

  /// latency آستانه — از WatchdogConfig خونده می‌شه.
  static int get highLatencyMs => WatchdogConfig.highLatencyMs;

  bool get shouldRestartForQuality =>
      _degradedStreak >= WatchdogConfig.degradedConsecutiveLimit;

  int get degradedStreak => _degradedStreak;

  /// ثبت یک probe جدید.
  QualityLevel record(WatchdogQualityMetrics metrics) {
    final level = metrics.classify(highLatencyMs: highLatencyMs);

    if (level == QualityLevel.excellent || level == QualityLevel.good) {
      _degradedStreak = 0;
    } else {
      _degradedStreak++;
    }

    return level;
  }

  void reset() {
    _degradedStreak = 0;
  }
}
