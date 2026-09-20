library;

/// ═══════════════════════════════════════════════════════════════
///  AetherEvent — یک رویداد ساختاریافته در چرخهٔ حیات اتصال.
///
///  این کلاس پایهٔ Structured Logging است. هر اتصال/قطع/شکست
///  به صورت یک رکورد ثبت می‌شود تا بعداً قابل تحلیل باشد.
/// ═══════════════════════════════════════════════════════════════

enum AetherEventType {
  connectionStarted,
  connectionSuccess,
  connectionFailed,
  connectionLost,
  reconnectAttempt,
  performanceSample,
}

extension AetherEventTypeX on AetherEventType {
  String get id {
    switch (this) {
      case AetherEventType.connectionStarted:
        return 'connection_started';
      case AetherEventType.connectionSuccess:
        return 'connection_success';
      case AetherEventType.connectionFailed:
        return 'connection_failed';
      case AetherEventType.connectionLost:
        return 'connection_lost';
      case AetherEventType.reconnectAttempt:
        return 'reconnect_attempt';
      case AetherEventType.performanceSample:
        return 'performance_sample';
    }
  }

  static AetherEventType fromId(String id) {
    for (final t in AetherEventType.values) {
      if (t.id == id) return t;
    }
    return AetherEventType.connectionFailed;
  }
}

class AetherEvent {
  final int? id;
  final DateTime timestamp;
  final AetherEventType eventType;
  final String profile;
  final String protocol;
  final String masqueOption;
  final String endpoint;
  final String scanMode;
  final String result;
  final int durationMs;
  final int latencyMs;
  final int jitterMs;
  final double packetLossPct;
  final int attemptNumber;
  final String networkType;
  final String networkName;
  final String? error;

  const AetherEvent({
    this.id,
    required this.timestamp,
    required this.eventType,
    this.profile = '',
    this.protocol = '',
    this.masqueOption = '',
    this.endpoint = '',
    this.scanMode = '',
    this.result = '',
    this.durationMs = 0,
    this.latencyMs = 0,
    this.jitterMs = 0,
    this.packetLossPct = 0.0,
    this.attemptNumber = 0,
    this.networkType = '',
    this.networkName = '',
    this.error,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'event_type': eventType.id,
        'profile': profile,
        'protocol': protocol,
        'masque_option': masqueOption,
        'endpoint': endpoint,
        'scan_mode': scanMode,
        'result': result,
        'duration_ms': durationMs,
        'latency_ms': latencyMs,
        'jitter_ms': jitterMs,
        'packet_loss_pct': packetLossPct,
        'attempt_number': attemptNumber,
        'network_type': networkType,
        'network_name': networkName,
        'error': error,
      };

  factory AetherEvent.fromMap(Map<String, Object?> m) {
    return AetherEvent(
      id: m['id'] as int?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (m['timestamp'] as int?) ?? 0,
      ),
      eventType: AetherEventTypeX.fromId((m['event_type'] as String?) ?? ''),
      profile: (m['profile'] as String?) ?? '',
      protocol: (m['protocol'] as String?) ?? '',
      masqueOption: (m['masque_option'] as String?) ?? '',
      endpoint: (m['endpoint'] as String?) ?? '',
      scanMode: (m['scan_mode'] as String?) ?? '',
      result: (m['result'] as String?) ?? '',
      durationMs: (m['duration_ms'] as int?) ?? 0,
      latencyMs: (m['latency_ms'] as int?) ?? 0,
      jitterMs: (m['jitter_ms'] as int?) ?? 0,
      packetLossPct: ((m['packet_loss_pct'] as num?) ?? 0).toDouble(),
      attemptNumber: (m['attempt_number'] as int?) ?? 0,
      networkType: (m['network_type'] as String?) ?? '',
      networkName: (m['network_name'] as String?) ?? '',
      error: m['error'] as String?,
    );
  }
}
