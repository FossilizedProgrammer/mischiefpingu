library;

import 'dart:async';

/// ═══════════════════════════════════════════════════════════════
///  SstpHealthSource — استخراج metric از لاگ‌های SSTP.
///
///  SSTP لاگ‌هاش ساده‌ست ولی می‌شه از این‌ها استفاده کرد:
///    • "tunnel is UP"          → اتصال
///    • "proxies ready"         → آماده
///    • "assigned IP X.X.X.X"   → IP گرفته
///    • "handshake failed"      → خطا
///    • "certificate verify"    → خطا
/// ═══════════════════════════════════════════════════════════════
class SstpHealthSource {
  final void Function(String message, {String source}) log;

  final void Function({
    required int latencyMs,
    required int jitterMs,
    required double packetLossPct,
    required int successCount,
    required int totalSamples,
    required Map<String, dynamic> extra,
  })
  onReport;

  SstpHealthSource({required this.log, required this.onReport});

  int _successCount = 0;
  int _totalSamples = 0;
  int _handshakeFailures = 0;
  int _reconnectSignals = 0;
  int _lastLatencyMs = 0;
  int _currentLatencyMs = 0;
  String? _assignedIp;
  Timer? _reportTimer;

  static final _assignedIpRe = RegExp(
    r'assigned IP\s+(\d+\.\d+\.\d+\.\d+)',
    caseSensitive: false,
  );

  void start() {
    _successCount = 0;
    _totalSamples = 0;
    _handshakeFailures = 0;
    _reconnectSignals = 0;
    _lastLatencyMs = 0;
    _currentLatencyMs = 0;
    _assignedIp = null;

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
    final lower = line.toLowerCase();

    // ─── tunnel up ───
    if (lower.contains('tunnel is up') || lower.contains('proxies ready')) {
      _successCount++;
      _totalSamples++;
      return;
    }

    // ─── assigned IP ───
    final ipMatch = _assignedIpRe.firstMatch(line);
    if (ipMatch != null) {
      _assignedIp = ipMatch.group(1);
      return;
    }

    // ─── handshake failures ───
    if (lower.contains('handshake failed') ||
        lower.contains('certificate verify failed')) {
      _handshakeFailures++;
      _totalSamples++;
      return;
    }

    // ─── reconnect signals ───
    if (lower.contains('reconnecting') || lower.contains('retrying')) {
      _reconnectSignals++;
    }
  }

  void _emitReport() {
    if (_totalSamples == 0) return;

    final latency = _currentLatencyMs;
    final jitter = (_currentLatencyMs - _lastLatencyMs).abs();
    _lastLatencyMs = _currentLatencyMs;

    final lossPct = _totalSamples > 0
        ? (_handshakeFailures / _totalSamples) * 100.0
        : 0.0;

    onReport(
      latencyMs: latency,
      jitterMs: jitter,
      packetLossPct: lossPct.clamp(0.0, 100.0),
      successCount: _successCount,
      totalSamples: _totalSamples,
      extra: {
        'assignedIp': _assignedIp ?? '',
        'handshakeFailures': _handshakeFailures,
        'reconnectSignals': _reconnectSignals,
      },
    );
  }

  void reset() {
    _successCount = 0;
    _totalSamples = 0;
    _handshakeFailures = 0;
    _reconnectSignals = 0;
    _lastLatencyMs = 0;
    _currentLatencyMs = 0;
    _assignedIp = null;
    _reportTimer?.cancel();
    _reportTimer = null;
  }

  void dispose() {
    reset();
  }
}
