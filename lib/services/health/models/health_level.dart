library;

/// ═══════════════════════════════════════════════════════════════
///  HealthLevel — سطح کیفیت.
/// ═══════════════════════════════════════════════════════════════
enum HealthLevel {
  excellent, // >= 80
  good,      // >= 60
  fair,      // >= 40
  degraded,  // >= 20
  failing;   // < 20

  static HealthLevel fromScore(double score) {
    if (score >= 80) return HealthLevel.excellent;
    if (score >= 60) return HealthLevel.good;
    if (score >= 40) return HealthLevel.fair;
    if (score >= 20) return HealthLevel.degraded;
    return HealthLevel.failing;
  }

  int get colorHex {
    switch (this) {
      case HealthLevel.excellent:
        return 0xFF10B981;
      case HealthLevel.good:
        return 0xFF22C55E;
      case HealthLevel.fair:
        return 0xFFF59E0B;
      case HealthLevel.degraded:
        return 0xFFF97316;
      case HealthLevel.failing:
        return 0xFFEF4444;
    }
  }
}
