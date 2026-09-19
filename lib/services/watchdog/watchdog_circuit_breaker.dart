library;

import 'watchdog_config.dart';

/// ═══════════════════════════════════════════════════════════════
///  Circuit breaker: اگر watchdog چند بار پشت‌سرهم restart کند،
///  برای مدتی probe را متوقف می‌کند تا از حلقهٔ بی‌پایان جلوگیری شود.
/// ═══════════════════════════════════════════════════════════════
class WatchdogCircuitBreaker {
  final void Function(String message, {String source}) log;
  final String logSource;

  final List<DateTime> _recentRestarts = [];
  DateTime? _openUntil;
  bool _wasJustClosed = false;

  WatchdogCircuitBreaker({required this.log, required this.logSource});

  /// آیا circuit الان باز است (probe متوقف)؟
  bool isOpen() {
    final openUntil = _openUntil;
    if (openUntil == null) return false;
    if (DateTime.now().isBefore(openUntil)) return true;

    _openUntil = null;
    _recentRestarts.clear();
    _wasJustClosed = true;
    return false;
  }

  /// آیا همین الان بسته شد؟ (فقط یک بار true برمی‌گرداند)
  bool wasJustClosed() {
    if (_wasJustClosed) {
      _wasJustClosed = false;
      return true;
    }
    return false;
  }

  /// چقدر تا بسته شدن circuit مانده.
  Duration timeUntilClose() {
    final openUntil = _openUntil;
    if (openUntil == null) return Duration.zero;
    final remaining = openUntil.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// قبل از restart صدا زده می‌شود.
  ///
  /// خروجی:
  ///   - true  → restart مجاز است (breaker بسته)
  ///   - false → restart ممنوع (breaker الان باز شد)
  bool canRestart() {
    final now = DateTime.now();
    _recentRestarts.removeWhere(
      (t) => now.difference(t) > WatchdogConfig.circuitBreakerWindow,
    );

    if (_recentRestarts.length >= WatchdogConfig.circuitBreakerMaxRestarts) {
      _openUntil = now.add(WatchdogConfig.circuitBreakerCooldown);
      log(
        '⚠ circuit breaker OPEN — '
        '${_recentRestarts.length} restarts in '
        '${WatchdogConfig.circuitBreakerWindow.inMinutes}min. '
        'Cooling down for '
        '${WatchdogConfig.circuitBreakerCooldown.inMinutes}min.',
        source: logSource,
      );
      return false;
    }
    return true;
  }

  /// بعد از یک restart موفق صدا زده می‌شود.
  void recordRestart() {
    _recentRestarts.add(DateTime.now());
  }

  int get restartCount => _recentRestarts.length;

  void reset() {
    _recentRestarts.clear();
    _openUntil = null;
    _wasJustClosed = false;
  }
}
