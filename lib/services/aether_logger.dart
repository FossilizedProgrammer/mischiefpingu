library;

import '../models/aether_event.dart';
import '../models/settings_model.dart';
import '../services/database/aether_event_store.dart';
import '../services/process/log_source.dart';

/// ═══════════════════════════════════════════════════════════════
///  AetherLogger — نقطهٔ واحد ثبت رویدادهای ساختاریافته.
///
///  این logger روی EventStore کار می‌کند و اطلاعات context
///  (profile, network type, ...) را از AppSettings می‌گیرد.
///
///  الگوی استفاده:
///    logger.connectionStarted(candidate, profile)
///    logger.connectionSuccess(candidate, latency)
///    logger.connectionFailed(candidate, error, duration)
///    logger.connectionLost(uptime, reason)
///    logger.reconnectAttempt(attempt, gateway)
/// ═══════════════════════════════════════════════════════════════
class AetherLogger {
  final AetherEventStore store;
  final void Function(String message, {String source}) log;

  late final _EventEmitter _emitter;

  AetherLogger({
    required AetherEventStore store,
    required void Function(String message, {String source}) log,
  })  : store = store,
        log = log {
    _emitter = _EventEmitter(store: store, log: log);
  }

  /// ثبت شروع اتصال.
  void connectionStarted({
    required AppSettings settings,
    required String protocol,
    required String masque,
    required String endpoint,
    String scanMode = '',
  }) {
    _emitter.emit(
      AetherEvent(
        timestamp: DateTime.now(),
        eventType: AetherEventType.connectionStarted,
        profile: settings.aetherProfile,
        protocol: protocol,
        masqueOption: masque,
        endpoint: endpoint,
        scanMode: scanMode.isNotEmpty ? scanMode : settings.aetherScanMode,
        networkType: settings.ipType,
      ),
    );
  }

  /// ثبت اتصال موفق.
  void connectionSuccess({
    required AppSettings settings,
    required String protocol,
    required String masque,
    required String endpoint,
    required int durationMs,
    int latencyMs = 0,
  }) {
    _emitter.emit(
      AetherEvent(
        timestamp: DateTime.now(),
        eventType: AetherEventType.connectionSuccess,
        profile: settings.aetherProfile,
        protocol: protocol,
        masqueOption: masque,
        endpoint: endpoint,
        result: 'success',
        durationMs: durationMs,
        latencyMs: latencyMs,
        networkType: settings.ipType,
      ),
    );
  }

  /// ثبت شکست اتصال.
  void connectionFailed({
    required AppSettings settings,
    required String protocol,
    required String masque,
    required String endpoint,
    required String error,
    required int durationMs,
  }) {
    _emitter.emit(
      AetherEvent(
        timestamp: DateTime.now(),
        eventType: AetherEventType.connectionFailed,
        profile: settings.aetherProfile,
        protocol: protocol,
        masqueOption: masque,
        endpoint: endpoint,
        result: 'failed',
        durationMs: durationMs,
        error: error,
        networkType: settings.ipType,
      ),
    );
  }

  /// ثبت قطع اتصال.
  void connectionLost({
    required AppSettings settings,
    required String protocol,
    required String masque,
    required Duration uptime,
    required String reason,
    int reconnectCount = 0,
  }) {
    _emitter.emit(
      AetherEvent(
        timestamp: DateTime.now(),
        eventType: AetherEventType.connectionLost,
        profile: settings.aetherProfile,
        protocol: protocol,
        masqueOption: masque,
        result: reason,
        durationMs: uptime.inMilliseconds,
        attemptNumber: reconnectCount,
        networkType: settings.ipType,
      ),
    );
  }

  /// ثبت تلاش reconnect.
  void reconnectAttempt({
    required AppSettings settings,
    required int attemptNumber,
    required String protocol,
    required String masque,
    required String endpoint,
  }) {
    _emitter.emit(
      AetherEvent(
        timestamp: DateTime.now(),
        eventType: AetherEventType.reconnectAttempt,
        profile: settings.aetherProfile,
        protocol: protocol,
        masqueOption: masque,
        endpoint: endpoint,
        attemptNumber: attemptNumber,
        networkType: settings.ipType,
      ),
    );
  }

  /// ثبت نمونهٔ عملکرد.
  void performanceSample({
    required AppSettings settings,
    required String protocol,
    required String masque,
    required int latencyMs,
    required int jitterMs,
    required double packetLossPct,
  }) {
    _emitter.emit(
      AetherEvent(
        timestamp: DateTime.now(),
        eventType: AetherEventType.performanceSample,
        profile: settings.aetherProfile,
        protocol: protocol,
        masqueOption: masque,
        latencyMs: latencyMs,
        jitterMs: jitterMs,
        packetLossPct: packetLossPct,
        networkType: settings.ipType,
      ),
    );
  }
}

/// emitter داخلی — fire-and-forget با لاگ خطا.
class _EventEmitter {
  final AetherEventStore store;
  final void Function(String message, {String source}) log;

  const _EventEmitter({required this.store, required this.log});

  void emit(AetherEvent event) {
    // fire-and-forget — هرگز caller را block نمی‌کند
    // ignore: discarded_futures
    store.record(event).catchError((e) {
      log('⚠ AetherLogger: event write failed: $e', source: LogSource.aether);
    });
  }
}
