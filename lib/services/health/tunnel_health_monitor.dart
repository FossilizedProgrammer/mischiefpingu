library;

import 'dart:async';

import '../process/log_source.dart';
import 'tunnel_health_models.dart';
import 'tunnel_health_score_calculator.dart';

/// ═══════════════════════════════════════════════════════════════
///  TunnelHealthMonitor — monitor مشترک برای همهٔ تونل‌ها.
///
///  این کلاس:
///    • reportهای خام رو ingest می‌کنه (از adapter هر تونل)
///    • history کوتاه مدت نگه می‌داره (برای trend detection)
///    • score نهایی رو محاسبه و به UI می‌فرسته
///
///  یک instance برای هر تونل ساخته می‌شه.
/// ═══════════════════════════════════════════════════════════════
class TunnelHealthMonitor {
  final TunnelKind kind;
  final void Function(TunnelHealthReport report) onUpdate;
  final void Function(String message, {String source}) log;

  /// حداکثر تعداد report که در history نگه داشته می‌شه.
  static const int maxHistory = 12;

  /// بازهٔ tick پیش‌فرض.
  static const Duration defaultTickInterval = Duration(seconds: 15);

  final List<TunnelHealthReport> _history = [];
  Timer? _timer;
  DateTime? _connectedAt;
  int _reconnectCount = 0;
  int _errorCount = 0;

  TunnelHealthReport? _current;

  TunnelHealthMonitor({
    required this.kind,
    required this.onUpdate,
    required this.log,
  });

  TunnelHealthReport? get current => _current;
  List<TunnelHealthReport> get history => List.unmodifiable(_history);

  /// شروع مانیتورینگ.
  void start(DateTime connectedAt, {int initialReconnectCount = 0}) {
    _connectedAt = connectedAt;
    _reconnectCount = initialReconnectCount;
    _errorCount = 0;
    _history.clear();
    _timer?.cancel();
    _timer = Timer.periodic(defaultTickInterval, (_) => _tick());
    log('→ ${kind.displayName} HealthMonitor: started', source: LogSource.app);
  }

  /// توقف.
  void stop() {
    _timer?.cancel();
    _timer = null;
    _connectedAt = null;
    _history.clear();
    _current = null;
    log('→ ${kind.displayName} HealthMonitor: stopped', source: LogSource.app);
  }

  /// ثبت یک reconnect.
  void recordReconnect() {
    _reconnectCount++;
    _tick();
  }

  /// ثبت یک خطا.
  void recordError() {
    _errorCount++;
    _tick();
  }

  /// ingest یک report خام.
  ///
  /// این متد از adapter تونل صدا زده می‌شه.
  void ingestReport({
    required int latencyMs,
    required int jitterMs,
    required double packetLossPct,
    required int successCount,
    required int totalSamples,
    Map<String, dynamic> extra = const {},
  }) {
    if (_connectedAt == null) return;

    final uptime = DateTime.now().difference(_connectedAt!);

    final rawScore = TunnelHealthScoreCalculator.compute(
      latencyMs: latencyMs,
      jitterMs: jitterMs,
      packetLossPct: packetLossPct,
      successCount: successCount,
      totalSamples: totalSamples,
      uptime: uptime,
      reconnectCount: _reconnectCount,
      errorCount: _errorCount,
    );

    final trend = TunnelHealthScoreCalculator.computeTrend(_history);

    final report = TunnelHealthReport(
      kind: kind,
      timestamp: DateTime.now(),
      score: rawScore,
      latencyMs: latencyMs,
      jitterMs: jitterMs,
      packetLossPct: packetLossPct,
      uptime: uptime,
      reconnectCount: _reconnectCount,
      errorCount: _errorCount,
      trend: trend,
      successCount: successCount,
      totalSamples: totalSamples,
      extra: extra,
    );

    _current = report;

    _history.add(report);
    if (_history.length > maxHistory) {
      _history.removeAt(0);
    }

    onUpdate(report);
  }

  /// tick داخلی — اگر report جدیدی نیامده، از آخرین استفاده می‌کنه.
  void _tick() {
    if (_connectedAt == null) return;
    final last = _current;
    if (last == null) return;

    // re-compute با uptime جدید (بدون تغییر metricها)
    final uptime = DateTime.now().difference(_connectedAt!);
    final newScore = TunnelHealthScoreCalculator.compute(
      latencyMs: last.latencyMs,
      jitterMs: last.jitterMs,
      packetLossPct: last.packetLossPct,
      successCount: last.successCount,
      totalSamples: last.totalSamples,
      uptime: uptime,
      reconnectCount: _reconnectCount,
      errorCount: _errorCount,
    );

    final updated = last.copyWith(
      timestamp: DateTime.now(),
      score: newScore,
      uptime: uptime,
      reconnectCount: _reconnectCount,
      errorCount: _errorCount,
    );

    _current = updated;

    _history.add(updated);
    if (_history.length > maxHistory) {
      _history.removeAt(0);
    }

    onUpdate(updated);
  }

  void dispose() {
    stop();
  }
}
