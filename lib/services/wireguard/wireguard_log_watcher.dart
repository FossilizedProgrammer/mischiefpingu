library;

/// ═══════════════════════════════════════════════════════════════
///  WireGuardLogWatcher — تشخیص مرگ تونل از روی لاگ wireproxy.
///
///  wireproxy لاگ‌هایی مثل این تولید می‌کنه:
///    "Failed to connect to endpoint"
///    "handshake failed"
///    "SOCKS5 server listening"
///    "Received packet from unknown peer"
/// ═══════════════════════════════════════════════════════════════
class WireGuardLogWatcher {
  final void Function(String message, {String source}) log;
  static const String _source = 'WireGuard';

  /// تعداد failure متوالی بدون success.
  int _consecutiveFailures = 0;

  /// آستانه — بعد از این تعداد failure پیوسته، restart می‌کنیم.
  static const int _consecutiveLimit = 15;

  WireGuardLogWatcher({required this.log});

  bool feed(String line) {
    if (line.isEmpty) return false;

    final lower = line.toLowerCase();

    // ─── نشانه‌های شکست ───
    final suspicious =
        (lower.contains('handshake') && lower.contains('failed')) ||
            lower.contains('failed to connect') ||
            lower.contains('no valid peers') ||
            lower.contains('endpoint unreachable') ||
            lower.contains('timeout waiting for handshake');

    if (suspicious) {
      _consecutiveFailures++;
      if (_consecutiveFailures >= _consecutiveLimit) {
        _consecutiveFailures = 0;
        log(
          '⚠ WireGuard log watcher: $_consecutiveLimit '
          'شکست متوالی — تونل احتمالاً مرده است',
          source: _source,
        );
        return true;
      }
      return false;
    }

    // ─── نشانه‌های موفقیت ───
    if (lower.contains('socks5') && lower.contains('listening') ||
        lower.contains('handshake completed') ||
        lower.contains('tunnel up')) {
      _consecutiveFailures = 0;
    }

    return false;
  }

  void reset() {
    _consecutiveFailures = 0;
  }
}
