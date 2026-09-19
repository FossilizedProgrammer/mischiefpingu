library;

class PsiphonLogWatcher {
  final void Function(String message, {String source}) log;
  static const String _source = 'Psiphon';

  final List<DateTime> _recentFailures = [];
  static const Duration _window = Duration(minutes: 5);

  /// ⚠️ افزایش یافته از ۲۵ به ۵۰.
  ///
  /// دلیل: در فیلترینگ سنگین، Psiphon مرتب پیام‌های
  /// "tunnel connection failed ... giving up" میدهد — ولی
  /// تونل اصلی همچنان ممکن است زنده باشد. با آستانهٔ ۲۵
  /// خیلی سریع false positive میداد.
  static const int _windowThreshold = 50;

  /// ⚠️ جدید: شمارش تلاش‌های ناموفق *متوالی* بدون هیچ success.
  /// اگر بین آن‌ها یک موفقیت دیده شود، counter ریست میشود.
  int _consecutiveNoSuccess = 0;
  static const int _maxConsecutiveNoSuccess = 15;

  PsiphonLogWatcher({required this.log});

  bool feed(String line) {
    final lower = line.toLowerCase();
    var suspicious = false;

    if (lower.contains('tunnel connection failed') &&
        lower.contains('giving up')) {
      suspicious = true;
    }

    if (lower.contains('no server entries') ||
        lower.contains('no usable servers')) {
      suspicious = true;
    }

    if (suspicious) {
      final now = DateTime.now();
      _recentFailures.add(now);
      _recentFailures.removeWhere((t) => now.difference(t) > _window);
      _consecutiveNoSuccess++;

      if (_recentFailures.length >= _windowThreshold) {
        _recentFailures.clear();
        _consecutiveNoSuccess = 0;
        log(
          '⚠ Psiphon log watcher: $_windowThreshold قطعی در '
          '${_window.inMinutes} دقیقه',
          source: _source,
        );
        return true;
      }

      if (_consecutiveNoSuccess >= _maxConsecutiveNoSuccess) {
        _recentFailures.clear();
        _consecutiveNoSuccess = 0;
        log(
          '⚠ Psiphon log watcher: $_maxConsecutiveNoSuccess شکست متوالی '
          'بدون هیچ اتصال موفق',
          source: _source,
        );
        return true;
      }
    }

    if (lower.contains('"noticetype":"activetunnel"') ||
        lower.contains('tunnel established')) {
      _recentFailures.clear();
      _consecutiveNoSuccess = 0;
    }

    return false;
  }

  void reset() {
    _recentFailures.clear();
    _consecutiveNoSuccess = 0;
  }
}
