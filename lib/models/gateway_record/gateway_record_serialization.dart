part of '../gateway_record.dart';

/// ═══════════════════════════════════════════════════════════════
///  Serialization + helperهای GatewayRecord.
///
///  این‌ها در extension هستن تا کلاس اصلی کوتاه‌تر بشه، ولی
///  API کلاس تغییری نکرده — همه از طریق GatewayRecord صدا زده
///  می‌شن.
/// ═══════════════════════════════════════════════════════════════
class GatewayRecordSerialization {
  GatewayRecordSerialization._();

  static String buildKey({
    required String ip,
    required int port,
    required String protocol,
    String masqueOption = '',
    String sni = '',
  }) {
    return '$ip:$port|$protocol|$masqueOption|$sni';
  }

  static double successRateOf(GatewayRecord r) {
    final total = r.successCount + r.failureCount;
    if (total == 0) return 0.0;
    return r.successCount / total;
  }

  static DateTime? lastActivityAtOf(GatewayRecord r) {
    final s = r.lastSuccessAt;
    final f = r.lastFailureAt;
    if (s == null) return f;
    if (f == null) return s;
    return s.isAfter(f) ? s : f;
  }

  static bool isFreshOf(GatewayRecord r) =>
      r.successCount + r.failureCount == 0;

  static Map<String, Object?> toMapOf(GatewayRecord r) {
    return {
      'id': r.id,
      'unique_key': r.uniqueKey,
      'ip': r.ip,
      'port': r.port,
      'protocol': r.protocol,
      'masque_option': r.masqueOption,
      'sni': r.sni,
      'endpoint': r.endpoint,
      'last_success_at': r.lastSuccessAt?.millisecondsSinceEpoch,
      'last_failure_at': r.lastFailureAt?.millisecondsSinceEpoch,
      'success_count': r.successCount,
      'failure_count': r.failureCount,
      'avg_latency_ms': r.avgLatencyMs,
      'avg_jitter_ms': r.avgJitterMs,
      'packet_loss_pct': r.packetLossPct,
      'last_network_type': r.lastNetworkType,
      'last_network_name': r.lastNetworkName,
      'score': r.score,
      'avg_session_uptime_sec': r.avgSessionUptimeSec,
      'reconnect_count': r.reconnectCount,
      'total_attempts': r.totalAttempts,
      'last_uptime_samples': jsonEncode(r.lastUptimeSamples),
      'created_at': r.createdAt.millisecondsSinceEpoch,
      'updated_at': r.updatedAt.millisecondsSinceEpoch,
    };
  }

  static GatewayRecord fromMap(Map<String, Object?> m) {
    return GatewayRecord(
      id: m['id'] as int?,
      uniqueKey: (m['unique_key'] as String?) ?? '',
      ip: (m['ip'] as String?) ?? '',
      port: (m['port'] as int?) ?? 0,
      protocol: (m['protocol'] as String?) ?? '',
      masqueOption: (m['masque_option'] as String?) ?? '',
      sni: (m['sni'] as String?) ?? '',
      endpoint: (m['endpoint'] as String?) ?? '',
      lastSuccessAt: _toDate(m['last_success_at']),
      lastFailureAt: _toDate(m['last_failure_at']),
      successCount: (m['success_count'] as int?) ?? 0,
      failureCount: (m['failure_count'] as int?) ?? 0,
      avgLatencyMs: (m['avg_latency_ms'] as int?) ?? 0,
      avgJitterMs: (m['avg_jitter_ms'] as int?) ?? 0,
      packetLossPct: (m['packet_loss_pct'] as num?)?.toDouble() ?? 0.0,
      lastNetworkType: (m['last_network_type'] as String?) ?? '',
      lastNetworkName: (m['last_network_name'] as String?) ?? '',
      score: (m['score'] as num?)?.toDouble() ?? 0.0,
      avgSessionUptimeSec: (m['avg_session_uptime_sec'] as int?) ?? 0,
      reconnectCount: (m['reconnect_count'] as int?) ?? 0,
      totalAttempts: (m['total_attempts'] as int?) ?? 0,
      lastUptimeSamples: _parseUptimeSamples(m['last_uptime_samples']),
      createdAt: _toDate(m['created_at']) ?? DateTime.now(),
      updatedAt: _toDate(m['updated_at']) ?? DateTime.now(),
    );
  }

  static List<int> _parseUptimeSamples(Object? raw) {
    if (raw == null) return const [];
    if (raw is List) {
      return raw.whereType<int>().toList();
    }
    if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return decoded.whereType<int>().toList();
        }
      } catch (_) {}
    }
    return const [];
  }

  static DateTime? _toDate(Object? v) {
    if (v == null) return null;
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is String) return DateTime.tryParse(v);
    return null;
  }
}
