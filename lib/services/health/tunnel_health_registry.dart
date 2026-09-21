library;

import 'psiphon_health_source.dart';
import 'sstp_health_source.dart';
import 'tor_health_source.dart';
import 'tunnel_health_models.dart';
import 'tunnel_health_monitor.dart';
import 'tunnel_quality_detector.dart';

part 'registry/psiphon_adapter.dart';
part 'registry/tor_adapter.dart';
part 'registry/sstp_adapter.dart';
part 'registry/tunnel_health_registry_init.dart';
part 'registry/tunnel_health_registry_ops.dart';

/// ═══════════════════════════════════════════════════════════════
///  TunnelHealthRegistry — registry مرکزی همهٔ health monitorها.
///
///  این کلاس فقط state و lifecycle رو نگه می‌داره.
///  عملیات (start/stop/feed/snapshot) در
///  `registry/tunnel_health_registry_ops.dart` تعریف شدن.
///
///  adapterهای هر تونل در `registry/` جدا شده‌اند:
///    • PsiphonAdapter → feed + start/stop source
///    • TorAdapter     → feed + start/stop source
///    • SstpAdapter    → feed + start/stop source
///
///  منطق initialize() در `registry/tunnel_health_registry_init.dart`.
/// ═══════════════════════════════════════════════════════════════
class TunnelHealthRegistry {
  final void Function(String message, {String source}) log;

  /// callback وقتی هر تونل report جدید می‌ده.
  final void Function(TunnelKind kind, TunnelHealthReport report) onReport;

  /// callback وقتی degradation تشخیص داده می‌شه.
  final void Function(TunnelKind kind, String reason) onDegradationDetected;
  final void Function(TunnelKind kind, String reason)? onEscalateProfile;

  // ─── monitors ───
  final Map<TunnelKind, TunnelHealthMonitor> _monitors = {};

  // ─── adapters ───
  PsiphonAdapter? _psiphonAdapter;
  TorAdapter? _torAdapter;
  SstpAdapter? _sstpAdapter;

  // ─── detectors ───
  final Map<TunnelKind, TunnelQualityDetector> _detectors = {};

  TunnelHealthRegistry({
    required this.log,
    required this.onReport,
    required this.onDegradationDetected,
    this.onEscalateProfile,
  });

  /// ساخت monitorها. یک بار در constructor provider صدا زده می‌شه.
  void initialize() => initializeMonitorsAndAdapters();

  /// dispose کامل registry.
  void dispose() {
    for (final m in _monitors.values) {
      m.dispose();
    }
    _psiphonAdapter?.dispose();
    _torAdapter?.dispose();
    _sstpAdapter?.dispose();
    _monitors.clear();
    _detectors.clear();
  }
}
