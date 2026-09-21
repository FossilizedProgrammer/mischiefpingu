library;

import 'dart:convert';

import 'package:meta/meta.dart';

part 'gateway_record/gateway_record_serialization.dart';

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

  // ─── API عمومی بدون تغییر ───

  static String buildKey({
    required String ip,
    required int port,
    required String protocol,
    String masqueOption = '',
    String sni = '',
  }) {
    return GatewayRecordSerialization.buildKey(
      ip: ip,
      port: port,
      protocol: protocol,
      masqueOption: masqueOption,
      sni: sni,
    );
  }

  double get successRate => GatewayRecordSerialization.successRateOf(this);

  DateTime? get lastActivityAt =>
      GatewayRecordSerialization.lastActivityAtOf(this);

  bool get isFresh => GatewayRecordSerialization.isFreshOf(this);

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

  Map<String, Object?> toMap() => GatewayRecordSerialization.toMapOf(this);

  factory GatewayRecord.fromMap(Map<String, Object?> m) =>
      GatewayRecordSerialization.fromMap(m);

  @override
  String toString() =>
      'GatewayRecord($uniqueKey, score=${score.toStringAsFixed(1)}, '
      'success=$successCount, failure=$failureCount, '
      'lat=${avgLatencyMs}ms, uptime=${avgSessionUptimeSec}s, '
      'reconnects=$reconnectCount)';
}
