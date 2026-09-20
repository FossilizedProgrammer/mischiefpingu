library;

import 'dart:convert';

import 'package:meta/meta.dart';

/// ═══════════════════════════════════════════════════════════════
///  GatewayRecord — رکورد یک Gateway در تاریخچه.
/// ═══════════════════════════════════════════════════════════════
@immutable
class GatewayRecord {
  final int? id;
  final String uniqueKey;
  final String ip;
  final int port;
  final String protocol;
  final String masqueOption;
  final String sni;
  final String endpoint;

  final DateTime? lastSuccessAt;
  final DateTime? lastFailureAt;

  final int successCount;
  final int failureCount;

  final int avgLatencyMs;
  final int avgJitterMs;
  final double packetLossPct;

  final String lastNetworkType;
  final String lastNetworkName;

  final double score;

  // ─── v4: Quality fields ───
  final int avgSessionUptimeSec;
  final int reconnectCount;
  final int totalAttempts;
  final List<int> lastUptimeSamples;

  final DateTime createdAt;
  final DateTime updatedAt;

  const GatewayRecord({
    this.id,
    required this.uniqueKey,
    required this.ip,
    required this.port,
    required this.protocol,
    this.masqueOption = '',
    this.sni = '',
    this.endpoint = '',
    this.lastSuccessAt,
    this.lastFailureAt,
    this.successCount = 0,
    this.failureCount = 0,
    this.avgLatencyMs = 0,
    this.avgJitterMs = 0,
    this.packetLossPct = 0.0,
    this.lastNetworkType = '',
    this.lastNetworkName = '',
    this.score = 0.0,
    this.avgSessionUptimeSec = 0,
    this.reconnectCount = 0,
    this.totalAttempts = 0,
    this.lastUptimeSamples = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  static String buildKey({
    required String ip,
    required int port,
    required String protocol,
    String masqueOption = '',
    String sni = '',
  }) {
    return '$ip:$port|$protocol|$masqueOption|$sni';
  }

  double get successRate {
    final total = successCount + failureCount;
    if (total == 0) return 0.0;
    return successCount / total;
  }

  DateTime? get lastActivityAt {
    final s = lastSuccessAt;
    final f = lastFailureAt;
    if (s == null) return f;
    if (f == null) return s;
    return s.isAfter(f) ? s : f;
  }

  bool get isFresh => successCount + failureCount == 0;

  GatewayRecord copyWith({
    int? id,
    String? uniqueKey,
    String? ip,
    int? port,
    String? protocol,
    String? masqueOption,
    String? sni,
    String? endpoint,
    DateTime? lastSuccessAt,
    DateTime? lastFailureAt,
    int? successCount,
    int? failureCount,
    int? avgLatencyMs,
    int? avgJitterMs,
    double? packetLossPct,
    String? lastNetworkType,
    String? lastNetworkName,
    double? score,
    int? avgSessionUptimeSec,
    int? reconnectCount,
    int? totalAttempts,
    List<int>? lastUptimeSamples,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GatewayRecord(
      id: id ?? this.id,
      uniqueKey: uniqueKey ?? this.uniqueKey,
      ip: ip ?? this.ip,
      port: port ?? this.port,
      protocol: protocol ?? this.protocol,
      masqueOption: masqueOption ?? this.masqueOption,
      sni: sni ?? this.sni,
      endpoint: endpoint ?? this.endpoint,
      lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
      lastFailureAt: lastFailureAt ?? this.lastFailureAt,
      successCount: successCount ?? this.successCount,
      failureCount: failureCount ?? this.failureCount,
      avgLatencyMs: avgLatencyMs ?? this.avgLatencyMs,
      avgJitterMs: avgJitterMs ?? this.avgJitterMs,
      packetLossPct: packetLossPct ?? this.packetLossPct,
      lastNetworkType: lastNetworkType ?? this.lastNetworkType,
      lastNetworkName: lastNetworkName ?? this.lastNetworkName,
      score: score ?? this.score,
      avgSessionUptimeSec: avgSessionUptimeSec ?? this.avgSessionUptimeSec,
      reconnectCount: reconnectCount ?? this.reconnectCount,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      lastUptimeSamples: lastUptimeSamples ?? this.lastUptimeSamples,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'unique_key': uniqueKey,
      'ip': ip,
      'port': port,
      'protocol': protocol,
      'masque_option': masqueOption,
      'sni': sni,
      'endpoint': endpoint,
      'last_success_at': lastSuccessAt?.millisecondsSinceEpoch,
      'last_failure_at': lastFailureAt?.millisecondsSinceEpoch,
      'success_count': successCount,
      'failure_count': failureCount,
      'avg_latency_ms': avgLatencyMs,
      'avg_jitter_ms': avgJitterMs,
      'packet_loss_pct': packetLossPct,
      'last_network_type': lastNetworkType,
      'last_network_name': lastNetworkName,
      'score': score,
      'avg_session_uptime_sec': avgSessionUptimeSec,
      'reconnect_count': reconnectCount,
      'total_attempts': totalAttempts,
      'last_uptime_samples': jsonEncode(lastUptimeSamples),
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory GatewayRecord.fromMap(Map<String, Object?> m) {
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

  @override
  String toString() =>
      'GatewayRecord($uniqueKey, score=${score.toStringAsFixed(1)}, '
      'success=$successCount, failure=$failureCount, '
      'lat=${avgLatencyMs}ms, uptime=${avgSessionUptimeSec}s, '
      'reconnects=$reconnectCount)';
}
