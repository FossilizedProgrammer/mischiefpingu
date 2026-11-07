library;

/// ═══════════════════════════════════════════════════════════════
///  TunnelHealthModels — barrel export.
///
///  این فایل قبلاً 253 خط بود و همه چیز داخلش بود. الان فقط
///  re-export می‌کنه تا importهای موجود در سراسر پروژه بدون
///  تغییر کار کنن:
///
///    import 'services/health/tunnel_health_models.dart';
///
///  ساختار جدید:
///    • models/tunnel_kind.dart          → enum TunnelKind
///    • models/health_trend.dart         → enum HealthTrend
///    • models/health_level.dart         → enum HealthLevel
///    • models/tunnel_health_report.dart → class TunnelHealthReport
///    • models/health_snapshot.dart      → class HealthSnapshot
/// ═══════════════════════════════════════════════════════════════

export 'models/tunnel_kind.dart';
export 'models/health_trend.dart';
export 'models/health_level.dart';
export 'models/tunnel_health_report.dart';
export 'models/health_snapshot.dart';
