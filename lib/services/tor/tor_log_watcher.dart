library;

class TorLogWatcher {
  final void Function(String message, {String source}) log;
  static const String _source = 'Tor';

  final List<DateTime> _recentFailures = [];
  static const Duration _window = Duration(minutes: 5);

  /// ⚠️ افزایش یافته از ۳۰ به ۶۰.
  static const int _windowThreshold = 60;

  /// ⚠️ جدید: شکست‌های متوالی بدون هیچ پیشرفتی.
  int _consecutiveNoSuccess = 0;
  static const int _maxConsecutiveNoSuccess = 20;

  TorLogWatcher({required this.log});

  bool feed(String line) {
    final lower = line.toLowerCase();
    var suspicious = false;

    if (lower.contains('failed to get consensus') &&
        lower.contains('giving up')) {
      suspicious = true;
    }
    if (lower.contains('no usable guards') ||
        lower.contains('all directory servers are failing')) {
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
          '⚠ Tor log watcher: $_windowThreshold قطعی در '
          '${_window.inMinutes} دقیقه',
          source: _source,
        );
        return true;
      }

      if (_consecutiveNoSuccess >= _maxConsecutiveNoSuccess) {
        _recentFailures.clear();
        _consecutiveNoSuccess = 0;
        log(
          '⚠ Tor log watcher: $_maxConsecutiveNoSuccess شکست متوالی '
          'بدون هیچ پیشرفتی',
          source: _source,
        );
        return true;
      }
    }

    if (lower.contains('bootstrapped 100%') ||
        lower.contains('circuit established')) {
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
