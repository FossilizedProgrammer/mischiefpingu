library;

/// ═══════════════════════════════════════════════════════════════
///  DatabaseSchema — ثابت‌های schema دیتابیس.
///
///  تاریخچه نسخه‌ها:
///    • v1: جدول gateway_history
///    • v2: جدول aether_events (Structured Logging)
///    • v3: جدول profile_performance (Smart Cache)
///    • v4: ستون‌های uptime/reconnect در gateway_history
/// ═══════════════════════════════════════════════════════════════
class DatabaseSchema {
  DatabaseSchema._();

  /// نسخه فعلی schema.
  static const int currentVersion = 4;

  // ─── ستون‌های مشترک ───
  static const String colId = 'id';
  static const String colIp = 'ip';
  static const String colPort = 'port';
  static const String colProtocol = 'protocol';
  static const String colMasqueOption = 'masque_option';
  static const String colSni = 'sni';
  static const String colEndpoint = 'endpoint';

  static const String colLastSuccessAt = 'last_success_at';
  static const String colLastFailureAt = 'last_failure_at';
  static const String colSuccessCount = 'success_count';
  static const String colFailureCount = 'failure_count';

  static const String colAvgLatencyMs = 'avg_latency_ms';
  static const String colAvgJitterMs = 'avg_jitter_ms';
  static const String colPacketLossPct = 'packet_loss_pct';

  static const String colLastNetworkType = 'last_network_type';
  static const String colLastNetworkName = 'last_network_name';

  static const String colScore = 'score';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
  static const String colUniqueKey = 'unique_key';

  // ─── v4: ستون‌های جدید Quality ───
  static const String colAvgSessionUptimeSec = 'avg_session_uptime_sec';
  static const String colReconnectCount = 'reconnect_count';
  static const String colTotalAttempts = 'total_attempts';
  static const String colLastUptimeSamples = 'last_uptime_samples';

  // ═══════════════════════════════════════════════════════════════
  //  v1: gateway_history
  // ═══════════════════════════════════════════════════════════════

  static const String tableGatewayHistory = 'gateway_history';

  static const String createTableGatewayHistory =
      '''
    CREATE TABLE $tableGatewayHistory (
      $colId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colUniqueKey TEXT NOT NULL UNIQUE,
      $colIp TEXT NOT NULL,
      $colPort INTEGER NOT NULL,
      $colProtocol TEXT NOT NULL,
      $colMasqueOption TEXT NOT NULL DEFAULT '',
      $colSni TEXT NOT NULL DEFAULT '',
      $colEndpoint TEXT NOT NULL DEFAULT '',
      $colLastSuccessAt INTEGER,
      $colLastFailureAt INTEGER,
      $colSuccessCount INTEGER NOT NULL DEFAULT 0,
      $colFailureCount INTEGER NOT NULL DEFAULT 0,
      $colAvgLatencyMs INTEGER NOT NULL DEFAULT 0,
      $colAvgJitterMs INTEGER NOT NULL DEFAULT 0,
      $colPacketLossPct REAL NOT NULL DEFAULT 0.0,
      $colLastNetworkType TEXT NOT NULL DEFAULT '',
      $colLastNetworkName TEXT NOT NULL DEFAULT '',
      $colScore REAL NOT NULL DEFAULT 0.0,
      $colAvgSessionUptimeSec INTEGER NOT NULL DEFAULT 0,
      $colReconnectCount INTEGER NOT NULL DEFAULT 0,
      $colTotalAttempts INTEGER NOT NULL DEFAULT 0,
      $colLastUptimeSamples TEXT NOT NULL DEFAULT '[]',
      $colCreatedAt INTEGER NOT NULL,
      $colUpdatedAt INTEGER NOT NULL
    )
  ''';

  static const String createIndexScore =
      'CREATE INDEX idx_gateway_score ON $tableGatewayHistory($colScore DESC)';

  static const String createIndexProtocol =
      'CREATE INDEX idx_gateway_protocol ON $tableGatewayHistory($colProtocol)';

  static const String createIndexLastSuccess =
      'CREATE INDEX idx_gateway_last_success ON $tableGatewayHistory($colLastSuccessAt DESC)';

  // ═══════════════════════════════════════════════════════════════
  //  v2: aether_events
  // ═══════════════════════════════════════════════════════════════

  static const String tableAetherEvents = 'aether_events';

  static const String colTimestamp = 'timestamp';
  static const String colEventType = 'event_type';
  static const String colProfile = 'profile';
  static const String colScanMode = 'scan_mode';
  static const String colResult = 'result';
  static const String colDurationMs = 'duration_ms';
  static const String colLatencyMs = 'latency_ms';
  static const String colJitterMs = 'jitter_ms';
  static const String colAttemptNumber = 'attempt_number';
  static const String colNetworkType = 'network_type';
  static const String colNetworkName = 'network_name';
  static const String colError = 'error';

  static const String createTableAetherEvents =
      '''
    CREATE TABLE $tableAetherEvents (
      $colId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colTimestamp INTEGER NOT NULL,
      $colEventType TEXT NOT NULL,
      $colProfile TEXT NOT NULL DEFAULT '',
      $colProtocol TEXT NOT NULL DEFAULT '',
      $colMasqueOption TEXT NOT NULL DEFAULT '',
      $colEndpoint TEXT NOT NULL DEFAULT '',
      $colScanMode TEXT NOT NULL DEFAULT '',
      $colResult TEXT NOT NULL DEFAULT '',
      $colDurationMs INTEGER NOT NULL DEFAULT 0,
      $colLatencyMs INTEGER NOT NULL DEFAULT 0,
      $colJitterMs INTEGER NOT NULL DEFAULT 0,
      $colPacketLossPct REAL NOT NULL DEFAULT 0.0,
      $colAttemptNumber INTEGER NOT NULL DEFAULT 0,
      $colNetworkType TEXT NOT NULL DEFAULT '',
      $colNetworkName TEXT NOT NULL DEFAULT '',
      $colError TEXT
    )
  ''';

  static const String createIndexAetherEventsTs =
      'CREATE INDEX idx_aether_events_ts ON $tableAetherEvents($colTimestamp DESC)';

  static const String createIndexAetherEventsProfile =
      'CREATE INDEX idx_aether_events_profile ON $tableAetherEvents($colProfile, $colProtocol)';

  // ═══════════════════════════════════════════════════════════════
  //  v3: profile_performance
  // ═══════════════════════════════════════════════════════════════

  static const String tableProfilePerformance = 'profile_performance';

  static const String createTableProfilePerformance =
      '''
    CREATE TABLE $tableProfilePerformance (
      $colId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colUniqueKey TEXT NOT NULL UNIQUE,
      $colProfile TEXT NOT NULL,
      $colProtocol TEXT NOT NULL,
      $colMasqueOption TEXT NOT NULL DEFAULT '',
      $colNetworkType TEXT NOT NULL DEFAULT '',
      $colSuccessCount INTEGER NOT NULL DEFAULT 0,
      $colFailureCount INTEGER NOT NULL DEFAULT 0,
      $colAvgLatencyMs INTEGER NOT NULL DEFAULT 0,
      $colLastSuccessAt INTEGER,
      $colLastFailureAt INTEGER,
      $colUpdatedAt INTEGER NOT NULL
    )
  ''';

  static const String createIndexProfilePerf =
      'CREATE INDEX idx_profile_perf ON $tableProfilePerformance($colProfile, $colNetworkType)';
}
