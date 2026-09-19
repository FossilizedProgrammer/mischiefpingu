library;

import '../../l10n/app_localizations.dart';
import 'diagnostic_models.dart';

/// ═══════════════════════════════════════════════════════════════
///  Helper برای تبدیل enum به label و رنگ
///
///  ⚠️ توابع label حالا AppLocalizations می‌گیرند تا ترجمه‌پذیر باشند.
///  توابع رنگ همچنان static هستند چون به زبان وابسته نیستند.
/// ═══════════════════════════════════════════════════════════════

class QualityLabels {
  QualityLabels._();

  static String overallLabel(InternetQuality q, AppLocalizations l10n) {
    switch (q) {
      case InternetQuality.excellent:
        return l10n.internetQualityExcellent;
      case InternetQuality.good:
        return l10n.internetQualityGood;
      case InternetQuality.degraded:
        return l10n.internetQualityDegraded;
      case InternetQuality.unstable:
        return l10n.internetQualityUnstable;
      case InternetQuality.dead:
        return l10n.internetQualityDown;
      case InternetQuality.unknown:
        return l10n.internetQualityNotTested;
    }
  }

  static String metricLabel(MetricStatus s, AppLocalizations l10n) {
    switch (s) {
      case MetricStatus.ok:
        return l10n.internetQualityStatusOk;
      case MetricStatus.slow:
        return l10n.internetQualityStatusSlow;
      case MetricStatus.partial:
        return l10n.internetQualityStatusPartial;
      case MetricStatus.failing:
        return l10n.internetQualityStatusFailing;
      case MetricStatus.unknown:
        return l10n.internetQualityStatusUnknown;
    }
  }

  /// 0xFF... رنگ hex برای استفاده در UI.
  static int overallColorHex(InternetQuality q) {
    switch (q) {
      case InternetQuality.excellent:
        return 0xFF10B981;
      case InternetQuality.good:
        return 0xFF22C55E;
      case InternetQuality.degraded:
        return 0xFFF59E0B;
      case InternetQuality.unstable:
        return 0xFFEF4444;
      case InternetQuality.dead:
        return 0xFF991B1B;
      case InternetQuality.unknown:
        return 0xFF94A3B8;
    }
  }

  static int metricColorHex(MetricStatus s) {
    switch (s) {
      case MetricStatus.ok:
        return 0xFF10B981;
      case MetricStatus.slow:
        return 0xFFF59E0B;
      case MetricStatus.partial:
        return 0xFFF97316;
      case MetricStatus.failing:
        return 0xFFEF4444;
      case MetricStatus.unknown:
        return 0xFF94A3B8;
    }
  }
}
