part of '../tunnel_health_registry.dart';

/// ═══════════════════════════════════════════════════════════════
///  عملیات TunnelHealthRegistry: start/stop/feed/snapshot.
///
///  این منطق قبلاً مستقیماً روی کلاس اصلی بود. حالا در یه
///  extension جدا قرار گرفته تا کلاس اصلی فقط state و
///  lifecycle رو نگه داره.
/// ═══════════════════════════════════════════════════════════════
extension TunnelHealthRegistryOps on TunnelHealthRegistry {
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
      case TunnelKind.wireguard:
        _wireguardAdapter?.start();
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
      case TunnelKind.wireguard:
        _wireguardAdapter?.reset();
        break;
    }

    _detectors[kind]?.reset();
  }

  /// feed یک log line به adapter مربوطه.
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
    if (onlyFor == null || onlyFor == TunnelKind.wireguard) {
      _wireguardAdapter?.feed(line);
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
    return HealthSnapshot(reports: reports, timestamp: DateTime.now());
  }

  /// گرفتن monitor خام یک تونل.
  TunnelHealthMonitor? monitorFor(TunnelKind kind) => _monitors[kind];
}
