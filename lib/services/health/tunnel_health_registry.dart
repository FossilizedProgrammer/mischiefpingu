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

/// ═══════════════════════════════════════════════════════════════
///  TunnelHealthRegistry — registry مرکزی همهٔ health monitorها.
///
///  این کلاس:
///    • یک monitor برای هر تونل می‌سازه
///    • adapterهای مخصوص هر تونل رو مدیریت می‌کنه
///    • health snapshot ترکیبی می‌ده به UI
///    • callbackهای degradation رو به provider وصل می‌کنه
///
///  adapterهای هر تونل در `registry/` جدا شده‌اند:
///    • PsiphonAdapter → feed + start/stop source
///    • TorAdapter     → feed + start/stop source
///    • SstpAdapter    → feed + start/stop source
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
  void initialize() {
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

    // ─── ساخت adapterها ───
    _psiphonAdapter = PsiphonAdapter(
      log: log,
      monitor: _monitors[TunnelKind.psiphon]!,
    );

    _torAdapter = TorAdapter(
      log: log,
      monitor: _monitors[TunnelKind.tor]!,
    );

    _sstpAdapter = SstpAdapter(
      log: log,
      monitor: _monitors[TunnelKind.sstp]!,
    );
  }

  /// شروع monitor یک تونل.
  void startMonitor(TunnelKind kind, DateTime connectedAt) {
    _monitors[kind]?.start(connectedAt);

    switch (kind) {
      case TunnelKind.psiphon:
        _psiphonAdapter?.start();
        break;
      case TunnelKind.tor:
        _torAdapter?.start();
        break;
      case TunnelKind.sstp:
        _sstpAdapter?.start();
        break;
      case TunnelKind.aether:
        // Aether از tracker خودش استفاده می‌کنه
        break;
    }
  }

  /// توقف monitor یک تونل.
  void stopMonitor(TunnelKind kind) {
    _monitors[kind]?.stop();

    switch (kind) {
      case TunnelKind.psiphon:
        _psiphonAdapter?.reset();
        break;
      case TunnelKind.tor:
        _torAdapter?.reset();
        break;
      case TunnelKind.sstp:
        _sstpAdapter?.reset();
        break;
      case TunnelKind.aether:
        break;
    }

    _detectors[kind]?.reset();
  }

  /// feed یک log line به adapter مربوطه.
  ///
  /// این متد از `feedLogWatchers` در provider صدا زده می‌شه.
  void feedLog(String line, {TunnelKind? onlyFor}) {
    if (onlyFor == null || onlyFor == TunnelKind.psiphon) {
      _psiphonAdapter?.feed(line);
    }
    if (onlyFor == null || onlyFor == TunnelKind.tor) {
      _torAdapter?.feed(line);
    }
    if (onlyFor == null || onlyFor == TunnelKind.sstp) {
      _sstpAdapter?.feed(line);
    }
  }

  /// ثبت reconnect.
  void recordReconnect(TunnelKind kind) {
    _monitors[kind]?.recordReconnect();
  }

  /// ثبت error.
  void recordError(TunnelKind kind) {
    _monitors[kind]?.recordError();
  }

  /// گرفتن report یک تونل.
  TunnelHealthReport? reportFor(TunnelKind kind) => _monitors[kind]?.current;

  /// گرفتن snapshot از همه.
  HealthSnapshot snapshot() {
    final reports = <TunnelKind, TunnelHealthReport>{};
    for (final entry in _monitors.entries) {
      final r = entry.value.current;
      if (r != null) reports[entry.key] = r;
    }
    return HealthSnapshot(
      reports: reports,
      timestamp: DateTime.now(),
    );
  }

  /// گرفتن monitor خام یک تونل (برای Aether که adapter جدا داره).
  TunnelHealthMonitor? monitorFor(TunnelKind kind) => _monitors[kind];

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
