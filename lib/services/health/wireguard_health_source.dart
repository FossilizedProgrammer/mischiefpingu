// lib/services/health/wireguard_health_source.dart

library;

import 'dart:async';

/// ═══════════════════════════════════════════════════════════════
///  WireGuardHealthSource — استخراج metric از لاگ‌های wireproxy.
///
///  ⚠️ تغییرات مهم:
///    • دیگر از `WireGuardLogWatcher` استفاده نمی‌کند (تداخل)
///    • از regexهای دقیق‌تر استفاده می‌کند (به جای `contains('failed')`)
///    • حالت‌های مختلف line رو تشخیص می‌ده
///
///  خطوط مهم wireproxy:
///    • "SOCKS5 server listening on 127.0.0.1:25344"
///    • "Socks5 proxy listening on ..."
///    • "peer ... handshake completed"
///    • "Failed to connect to endpoint"
///    • "handshake failed"
///    • "no valid peers"
///    • "endpoint unreachable"
/// ═══════════════════════════════════════════════════════════════
class WireGuardHealthSource {
  final void Function(String message, {String source}) log;

  final void Function({
    required int latencyMs,
    required int jitterMs,
    required double packetLossPct,
    required int successCount,
    required int totalSamples,
    required Map<String, dynamic> extra,
  }) onReport;

  WireGuardHealthSource({required this.log, required this.onReport});

  // ─── state ───
  int _successCount = 0;
  int _totalSamples = 0;
  int _failures = 0;
  int _currentLatencyMs = 0;
  int _lastLatencyMs = 0;
  DateTime? _lastEventAt;

  Timer? _reportTimer;

  // ═══════════════════════════════════════════════════════════
  //  regexهای دقیق برای خطوط wireproxy
  // ═══════════════════════════════════════════════════════════

  /// "SOCKS5 server listening on 127.0.0.1:25344"
  /// "Socks5 proxy listening on 0.0.0.0:25344"
  static final _socksListeningRe = RegExp(
    r'(?:socks5?|socks)\s+(?:proxy\s+)?(?:server\s+)?listening',
    caseSensitive: false,
  );

  /// "handshake completed" / "handshake: OK"
  static final _handshakeOkRe = RegExp(
    r'handshake\s+(?:completed|ok|success)',
    caseSensitive: false,
  );

  /// "tunnel up" / "tunnel is up"
  static final _tunnelUpRe = RegExp(
    r'tunnel\s+(?:is\s+)?(?:up|ready)',
    caseSensitive: false,
  );

  /// "Failed to connect to endpoint" / "handshake failed"
  static final _failureRe = RegExp(
    r'(?:handshake\s+failed|failed\s+to\s+connect|'
    r'no\s+valid\s+peers|endpoint\s+unreachable|'
    r'timeout\s+waiting\s+for\s+handshake|'
    r'connection\s+refused|connection\s+reset)',
    caseSensitive: false,
  );

  // ═══════════════════════════════════════════════════════════
  //  API عمومی
  // ═══════════════════════════════════════════════════════════

  void start() {
    _successCount = 0;
    _totalSamples = 0;
    _failures = 0;
    _currentLatencyMs = 0;
    _lastLatencyMs = 0;
    _lastEventAt = null;

    _reportTimer?.cancel();
    _reportTimer = Timer.periodic(
      const Duration(seconds: 12),
      (_) => _emitReport(),
    );
  }

  void stop() {
    _reportTimer?.cancel();
    _reportTimer = null;
  }

  void feed(String line) {
    if (line.isEmpty) return;

    // ─── نشانه‌های موفقیت ───
    if (_socksListeningRe.hasMatch(line) ||
        _handshakeOkRe.hasMatch(line) ||
        _tunnelUpRe.hasMatch(line)) {
      _successCount++;
      _totalSamples++;
      _lastEventAt = DateTime.now();

      // ─── latency تخمینی: از زمان آخرین رویداد ───
      final last = _lastEventAt;
      if (last != null) {
        _currentLatencyMs = DateTime.now().difference(last).inMilliseconds;
      }
      return;
    }

    // ─── نشانه‌های شکست ───
    if (_failureRe.hasMatch(line)) {
      _failures++;
      _totalSamples++;
      return;
    }
  }

  void _emitReport() {
    if (_totalSamples == 0) return;

    final jitter = (_currentLatencyMs - _lastLatencyMs).abs();
    _lastLatencyMs = _currentLatencyMs;

    final lossPct =
        _totalSamples > 0 ? (_failures / _totalSamples) * 100.0 : 0.0;

    onReport(
      latencyMs: _currentLatencyMs,
      jitterMs: jitter,
      packetLossPct: lossPct.clamp(0.0, 100.0),
      successCount: _successCount,
      totalSamples: _totalSamples,
      extra: {
        'failures': _failures,
      },
    );
  }

  void reset() {
    _successCount = 0;
    _totalSamples = 0;
    _failures = 0;
    _currentLatencyMs = 0;
    _lastLatencyMs = 0;
    _lastEventAt = null;
    _reportTimer?.cancel();
    _reportTimer = null;
  }

  void dispose() {
    reset();
  }
}
