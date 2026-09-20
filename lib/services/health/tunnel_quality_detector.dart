library;

import '../process/log_source.dart';
import 'tunnel_health_models.dart';

/// ═══════════════════════════════════════════════════════════════
///  TunnelQualityDetector — تشخیص افت کیفیت در همهٔ تونل‌ها.
///
///  سه سطح trigger:
///    1. **Score critical** — امتیاز برای چند tick متوالی زیر آستانه
///    2. **Latency jump** — جهش ناگهانی latency (>= 3x baseline)
///    3. **Sustained degradation** — trend در حال افت برای چند tick
///
///  و دو callback:
///    • onDegradationDetected  → restart کن
///    • onEscalateProfile      → profile رو سخت‌گیرتر کن (فقط Aether)
/// ═══════════════════════════════════════════════════════════════
class TunnelQualityDetector {
  final TunnelKind kind;
  final void Function(String reason) onDegradationDetected;

  /// اختیاری: برای Aether که profile داره.
  final void Function(String reason)? onEscalateProfile;

  final void Function(String message, {String source}) log;

  final List<TunnelHealthReport> _history = [];
  static const int _maxHistory = 8;

  // ─── آستانه‌ها ───
  static const double criticalScore = 35.0;
  static const int minConsecutiveDegraded = 3;
  static const double latencyJumpFactor = 3.0;
  static const double packetLossThreshold = 8.0;

  // ─── state ───
  int _consecutiveDegraded = 0;
  bool _restartInProgress = false;
  DateTime? _lastTriggerAt;
  DateTime? _lastEscalationAt;

  static const Duration _cooldown = Duration(minutes: 3);
  static const Duration _escalationCooldown = Duration(minutes: 5);

  TunnelQualityDetector({
    required this.kind,
    required this.onDegradationDetected,
    this.onEscalateProfile,
    required this.log,
  });

  void ingest(TunnelHealthReport report) {
    if (!report.isValid) return;

    _history.add(report);
    if (_history.length > _maxHistory) _history.removeAt(0);

    // ═══════════════════════════════════════════════════════════
    //  اگر 100% packet loss داریم و Aether هست و escalate می‌تونیم
    // ═══════════════════════════════════════════════════════════
    if (report.packetLossPct >= 99.0 &&
        onEscalateProfile != null &&
        _canEscalate()) {
      _lastEscalationAt = DateTime.now();
      log(
        '⚠ ${kind.displayName} quality detector: '
        '100% packet loss — escalating profile',
        source: LogSource.app,
      );
      onEscalateProfile!(
        '100% packet loss (tunnel up but no data)',
      );
      return;
    }

    // اگر الان در حال restart هستیم، تریگر جدید نزن
    if (_restartInProgress) return;

    // cooldown چک
    final last = _lastTriggerAt;
    if (last != null && DateTime.now().difference(last) < _cooldown) {
      return;
    }

    // ─── حالت 2: score بحرانی ───
    if (report.score < criticalScore) {
      _consecutiveDegraded++;
      if (_consecutiveDegraded >= minConsecutiveDegraded) {
        _trigger(
          'Health score critically low '
          '(${report.score.toStringAsFixed(1)} for '
          '$_consecutiveDegraded consecutive checks)',
        );
        return;
      }
    } else {
      _consecutiveDegraded = 0;
    }

    // ─── حالت 3: جهش latency ───
    if (_history.length >= 4) {
      final baseline = _history.first.latencyMs;
      final current = report.latencyMs;
      if (baseline > 50 && current > baseline * latencyJumpFactor) {
        _trigger(
          'Latency jumped ${baseline}ms → ${current}ms '
          '(factor ${(current / baseline).toStringAsFixed(1)}x)',
        );
        return;
      }
    }

    // ─── حالت 4: packet loss ───
    if (report.packetLossPct > packetLossThreshold) {
      _trigger(
        'Packet loss ${report.packetLossPct.toStringAsFixed(1)}% '
        'exceeds threshold ($packetLossThreshold%)',
      );
      return;
    }

    // ─── حالت 5: trend نزولی مستمر ───
    if (report.trend == HealthTrend.degrading && _history.length >= 4) {
      final recent = _history.skip(_history.length - 3);
      if (recent.every((h) => h.trend == HealthTrend.degrading)) {
        _trigger('Sustained degrading trend across 3 checks');
      }
    }
  }

  bool _canEscalate() {
    final last = _lastEscalationAt;
    if (last == null) return true;
    return DateTime.now().difference(last) > _escalationCooldown;
  }

  void _trigger(String reason) {
    if (_restartInProgress) return;
    _restartInProgress = true;
    _lastTriggerAt = DateTime.now();

    log(
      '⚠ ${kind.displayName} quality degradation detected: $reason',
      source: LogSource.app,
    );
    onDegradationDetected(reason);

    Future.delayed(_cooldown, () {
      _restartInProgress = false;
    });
  }

  void reset() {
    _history.clear();
    _consecutiveDegraded = 0;
    _restartInProgress = false;
    _lastEscalationAt = null;
    _lastTriggerAt = null;
  }
}
