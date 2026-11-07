library;

/// ═══════════════════════════════════════════════════════════════
///  محاسبهٔ backoff + retry tracking برای auto-reconnect.
/// ═══════════════════════════════════════════════════════════════
class ReconnectBackoff {
  static const int _maxQuickRetries = 3;
  static const Duration _retryWindow = Duration(minutes: 5);
  static const int _backoffBaseSeconds = 15;
  static const Duration _maxBackoff = Duration(minutes: 5);

  final Map<String, int> _retryCounts = {};
  final Map<String, DateTime> _lastAttempt = {};

  /// پاک‌سازی retry count اگر از پنجرهٔ زمانی گذشته.
  void pruneIfStale(String key) {
    final last = _lastAttempt[key];
    if (last == null) return;
    if (DateTime.now().difference(last) > _retryWindow) {
      _retryCounts.remove(key);
      _lastAttempt.remove(key);
    }
  }

  int retryCountFor(String key) => _retryCounts[key] ?? 0;

  /// محاسبهٔ delay نهایی بر اساس retry count فعلی.
  Duration computeDelay(Duration base, int retryCount) {
    if (retryCount < _maxQuickRetries) return base;
    final extraAttempts = retryCount - _maxQuickRetries + 1;
    final backoffSeconds = _backoffBaseSeconds * (1 << (extraAttempts - 1));
    final backoff = Duration(seconds: backoffSeconds);
    return backoff > _maxBackoff ? _maxBackoff : base + backoff;
  }

  /// ثبت یک تلاش جدید.
  void recordAttempt(String key, int currentRetryCount) {
    _retryCounts[key] = currentRetryCount + 1;
    _lastAttempt[key] = DateTime.now();
  }

  void resetRetries(String key) {
    _retryCounts.remove(key);
    _lastAttempt.remove(key);
  }

  void resetAll() {
    _retryCounts.clear();
    _lastAttempt.clear();
  }
}
