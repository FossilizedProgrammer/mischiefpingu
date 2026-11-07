library;

import '../../services/process/log_source.dart';
import '../health/tunnel_health_models.dart';
import 'connection_health.dart';

/// ═══════════════════════════════════════════════════════════════
///  QualityDegradationDetector — تشخیص افت کیفیت.
///
///  ⚠️ تغییرات مهم:
///    • حالا وقتی packet loss 100% هست، به جای restart کردن،
///      callback جداگانه onEscalateProfile رو صدا می‌زنه.
///    • cooldown برای escalation جداست تا پشت سر هم escalate نشه.
///    • HealthTrend از لایهٔ مشترک import می‌شود.
/// ═══════════════════════════════════════════════════════════════
class QualityDegradationDetector {
  final void Function(String reason) onDegradationDetected;

  /// ⚠️ جدید: وقتی تونل زنده‌ست ولی داده عبور نمی‌کنه،
  /// این callback صدا زده می‌شه تا profile رو escalate کنه.
  final void Function(String reason)? onEscalateProfile;

  final void Function(String message, {String source}) log;

  final List<ConnectionHealth> _history = [];
  static const int _maxHistory = 6;

  static const double criticalScore = 40.0;
  static const int minConsecutiveDegraded = 3;
  static const double latencyJumpFactor = 3.0;
  static const double packetLossThreshold = 8.0;

  int _consecutiveDegraded = 0;
  bool _restartInProgress = false;
  DateTime? _lastTriggerAt;

  /// ⚠️ cooldown جدا برای escalation.
  DateTime? _lastEscalationAt;
  static const Duration _escalationCooldown = Duration(minutes: 5);

  static const Duration _cooldown = Duration(minutes: 3);

  QualityDegradationDetector({
    required this.onDegradationDetected,
    this.onEscalateProfile,
    required this.log,
  });

  void ingest(ConnectionHealth health) {
    if (!health.isValid) return;

    _history.add(health);
    if (_history.length > _maxHistory) _history.removeAt(0);

    // ═══════════════════════════════════════════════════════════
    //  ⚠️ چک جدید: packet loss 100% (تونل زنده‌ست ولی داده عبور نمی‌کنه)
    // ═══════════════════════════════════════════════════════════
    if (health.packetLossPct >= 99.0 &&
        onEscalateProfile != null &&
        _canEscalate()) {
      _lastEscalationAt = DateTime.now();
      log(
        '⚠ Quality detector: 100% packet loss — escalating profile',
        source: LogSource.aether,
      );
      onEscalateProfile!('100% packet loss (tunnel up but no data)');
      return;
    }

    if (_restartInProgress) return;
    final last = _lastTriggerAt;
    if (last != null && DateTime.now().difference(last) < _cooldown) {
      return;
    }

    if (health.score < criticalScore) {
      _consecutiveDegraded++;
      if (_consecutiveDegraded >= minConsecutiveDegraded) {
        _trigger(
          'Health score critically low '
          '(${health.score.toStringAsFixed(1)} for '
          '$_consecutiveDegraded consecutive checks)',
        );
        return;
      }
    } else {
      _consecutiveDegraded = 0;
    }

    if (_history.length >= 4) {
      final baseline = _history.first.latencyMs;
      final current = health.latencyMs;
      if (baseline > 50 && current > baseline * latencyJumpFactor) {
        _trigger(
          'Latency jumped ${baseline}ms → ${current}ms '
          '(factor ${(current / baseline).toStringAsFixed(1)}x)',
        );
        return;
      }
    }

    if (health.packetLossPct > packetLossThreshold) {
      _trigger(
        'Packet loss ${health.packetLossPct.toStringAsFixed(1)}% '
        'exceeds threshold ($packetLossThreshold%)',
      );
      return;
    }

    if (health.trend == HealthTrend.degrading && _history.length >= 4) {
      final recent = _history.skip(_history.length - 3);
      if (recent.every((h) => h.trend == HealthTrend.degrading)) {
        _trigger('Sustained degrading trend across 3 checks');
      }
    }
  }

  /// آیا می‌تونیم escalate کنیم؟ (cooldown چک)
  bool _canEscalate() {
    final last = _lastEscalationAt;
    if (last == null) return true;
    return DateTime.now().difference(last) > _escalationCooldown;
  }

  void _trigger(String reason) {
    if (_restartInProgress) return;
    _restartInProgress = true;
    _lastTriggerAt = DateTime.now();

    log('⚠ Quality degradation detected: $reason', source: LogSource.aether);
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
  }
}
