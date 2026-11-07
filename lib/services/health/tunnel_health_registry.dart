library;

import 'psiphon_health_source.dart';
import 'sstp_health_source.dart';
import 'tor_health_source.dart';
import 'wireguard_health_source.dart';
import 'tunnel_health_models.dart';
import 'tunnel_health_monitor.dart';
import 'tunnel_quality_detector.dart';

part 'registry/psiphon_adapter.dart';
part 'registry/tor_adapter.dart';
part 'registry/sstp_adapter.dart';
part 'registry/tunnel_health_registry_init.dart';
part 'registry/tunnel_health_registry_ops.dart';
part 'registry/wireguard_adapter.dart';

/// ═══════════════════════════════════════════════════════════════
///  TunnelHealthRegistry — registry مرکزی همهٔ health monitorها.
/// ═══════════════════════════════════════════════════════════════
class TunnelHealthRegistry {
  final void Function(String message, {String source}) log;

  final void Function(TunnelKind kind, TunnelHealthReport report) onReport;
  final void Function(TunnelKind kind, String reason) onDegradationDetected;
  final void Function(TunnelKind kind, String reason)? onEscalateProfile;

  final Map<TunnelKind, TunnelHealthMonitor> _monitors = {};

  PsiphonAdapter? _psiphonAdapter;
  TorAdapter? _torAdapter;
  SstpAdapter? _sstpAdapter;
  WireGuardAdapter? _wireguardAdapter;

  final Map<TunnelKind, TunnelQualityDetector> _detectors = {};

  TunnelHealthRegistry({
    required this.log,
    required this.onReport,
    required this.onDegradationDetected,
    this.onEscalateProfile,
  });

  void initialize() => initializeMonitorsAndAdapters();

  void dispose() {
    for (final m in _monitors.values) {
      m.dispose();
    }
    _psiphonAdapter?.dispose();
    _torAdapter?.dispose();
    _sstpAdapter?.dispose();
    _wireguardAdapter?.dispose(); // ⚠️ اضافه شد
    _monitors.clear();
    _detectors.clear();
  }
}
