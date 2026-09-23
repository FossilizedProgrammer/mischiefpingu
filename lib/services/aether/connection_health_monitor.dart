library;

import 'dart:async';

import '../../services/process/log_source.dart';
import '../health/tunnel_health_models.dart';
import 'connection_health.dart';
import 'performance_sample.dart';

/// ═══════════════════════════════════════════════════════════════
///  ConnectionHealthMonitor — محاسبهٔ Health Score زنده.
///
///  در زمان اتصال فعال:
///    • هر 15 ثانیه یک tick می‌زند
///    • PerformanceReportهای جدید را ingest می‌کند
///    • Health Score را محاسبه و به UI می‌فرستد
///
///  ⚠️ این monitor مخصوص Aether است. ConnectionHealth در
///  `connection_health.dart` تعریف شده و HealthTrend از لایهٔ
///  مشترک (`tunnel_health_models.dart`) import می‌شود.
/// ═══════════════════════════════════════════════════════════════
class ConnectionHealthMonitor {
  final void Function(ConnectionHealth health) onUpdate;
  final void Function(String message, {String source}) log;

  Timer? _timer;
  final List<PerformanceReport> _recentReports = [];
  int _reconnectCount = 0;
  int _errorCount = 0;
  DateTime? _connectedAt;

  static const Duration _interval = Duration(seconds: 15);
  static const int _maxHistory = 8;

  ConnectionHealthMonitor({required this.onUpdate, required this.log});

  /// شروع مانیتورینگ.
  void start(DateTime connectedAt, {int initialReconnectCount = 0}) {
    _connectedAt = connectedAt;
    _reconnectCount = initialReconnectCount;
    _errorCount = 0;
    _recentReports.clear();
    _timer?.cancel();
    _timer = Timer.periodic(_interval, (_) => _tick());
    log(
      '→ HealthMonitor: started (uptime baseline set)',
      source: LogSource.aether,
    );
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _connectedAt = null;
    _recentReports.clear();
    log('→ HealthMonitor: stopped', source: LogSource.aether);
  }

  void recordReconnect() {
    _reconnectCount++;
    _tick();
  }

  void recordError() {
    _errorCount++;
  }

  /// ingest یک report از PerformanceTracker.
  void ingestReport(PerformanceReport report) {
    if (!report.isValid) return;
    _recentReports.add(report);
    if (_recentReports.length > _maxHistory) {
      _recentReports.removeAt(0);
    }
    _tick();
  }

  void _tick() {
    if (_connectedAt == null) return;
    final report = _recentReports.isNotEmpty ? _recentReports.last : null;
    final health = _compute(report);
    onUpdate(health);
  }

  ConnectionHealth _compute(PerformanceReport? report) {
    final uptime = _connectedAt != null
        ? DateTime.now().difference(_connectedAt!)
        : Duration.zero;

    if (report == null || !report.isValid) {
      return ConnectionHealth(
        score: 0,
        latencyMs: 0,
        jitterMs: 0,
        packetLossPct: 0,
        uptime: uptime,
        reconnectCount: _reconnectCount,
        errorCount: _errorCount,
        trend: HealthTrend.stable,
      );
    }

    final latencyScore = _latencyScore(report.avgLatencyMs);
    final jitterScore = _jitterScore(report.jitterMs);
    final lossScore = _lossScore(report.packetLossPct);

    // ─── penalties ───
    final reconnectPenalty = (_reconnectCount * 3).clamp(0, 20).toDouble();
    final errorPenalty = (_errorCount * 2).clamp(0, 15).toDouble();

    // ─── uptime bonus (حداکثر +10) ───
    final uptimeBonus = (uptime.inMinutes / 30.0).clamp(0.0, 1.0) * 10;

    final raw = latencyScore * 0.45 +
        jitterScore * 0.20 +
        lossScore * 0.25 +
        uptimeBonus -
        reconnectPenalty -
        errorPenalty;

    final score = raw.clamp(0.0, 100.0);

    return ConnectionHealth(
      score: double.parse(score.toStringAsFixed(1)),
      latencyMs: report.avgLatencyMs,
      jitterMs: report.jitterMs,
      packetLossPct: report.packetLossPct,
      uptime: uptime,
      reconnectCount: _reconnectCount,
      errorCount: _errorCount,
      trend: _computeTrend(),
    );
  }

  HealthTrend _computeTrend() {
    if (_recentReports.length < 3) return HealthTrend.stable;
    final recent = _recentReports.sublist(_recentReports.length - 3);
    final latencies = recent.map((r) => r.avgLatencyMs).toList();
    if (latencies[2] > latencies[0] * 1.4) return HealthTrend.degrading;
    if (latencies[2] < latencies[0] * 0.8) return HealthTrend.improving;
    return HealthTrend.stable;
  }

  double _latencyScore(int ms) {
    if (ms <= 100) return 100;
    if (ms >= 1500) return 0;
    return 100.0 * (1.0 - (ms - 100) / 1400.0);
  }

  double _jitterScore(int ms) {
    if (ms <= 20) return 100;
    if (ms >= 300) return 0;
    return 100.0 * (1.0 - (ms - 20) / 280.0);
  }

  double _lossScore(double pct) {
    if (pct <= 0) return 100;
    if (pct >= 20) return 0;
    return 100.0 * (1.0 - pct / 20.0);
  }

  void dispose() {
    stop();
  }
}
