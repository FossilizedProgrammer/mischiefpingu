part of '../tunnel_health_registry.dart';

/// ═══════════════════════════════════════════════════════════════
///  منطق initialize() — ساخت monitorها + adapterها + detectorها.
/// ═══════════════════════════════════════════════════════════════
extension TunnelHealthRegistryInit on TunnelHealthRegistry {
  void initializeMonitorsAndAdapters() {
    for (final kind in TunnelKind.values) {
      _monitors[kind] = TunnelHealthMonitor(
        kind: kind,
        log: log,
        onUpdate: (report) {
          onReport(kind, report);
          _detectors[kind]?.ingest(report);
        },
      );

      _detectors[kind] = TunnelQualityDetector(
        kind: kind,
        log: log,
        onDegradationDetected: (reason) {
          onDegradationDetected(kind, reason);
        },
        onEscalateProfile: onEscalateProfile != null
            ? (reason) => onEscalateProfile!(kind, reason)
            : null,
      );
    }

    _psiphonAdapter = PsiphonAdapter(
      log: log,
      monitor: _monitors[TunnelKind.psiphon]!,
    );

    _torAdapter = TorAdapter(log: log, monitor: _monitors[TunnelKind.tor]!);

    _sstpAdapter = SstpAdapter(log: log, monitor: _monitors[TunnelKind.sstp]!);
  }
}
