library;

/// ═══════════════════════════════════════════════════════════════
///  HealthTrend — روند کیفیت.
/// ═══════════════════════════════════════════════════════════════
enum HealthTrend {
  improving,
  stable,
  degrading;

  String get label {
    switch (this) {
      case HealthTrend.improving:
        return '↑ improving';
      case HealthTrend.stable:
        return '→ stable';
      case HealthTrend.degrading:
        return '↓ degrading';
    }
  }
}
