library;

class SstpLogWatcher {
  final void Function(String message, {String source}) log;
  static const String _source = 'SSTP';

  final List<DateTime> _recentFailures = [];
  static const Duration _window = Duration(minutes: 5);

  /// ⚠️ افزایش یافته از ۲۵ به ۵۰.
  static const int _windowThreshold = 50;

  int _consecutiveNoSuccess = 0;
  static const int _maxConsecutiveNoSuccess = 15;

  SstpLogWatcher({required this.log});

  bool feed(String line) {
    final lower = line.toLowerCase();
    var suspicious = false;

    if (lower.contains('handshake failed') &&
        (lower.contains('giving up') || lower.contains('aborting'))) {
      suspicious = true;
    }
    if (lower.contains('certificate verify failed')) {
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
          '⚠ SSTP log watcher: $_windowThreshold قطعی در '
          '${_window.inMinutes} دقیقه',
          source: _source,
        );
        return true;
      }

      if (_consecutiveNoSuccess >= _maxConsecutiveNoSuccess) {
        _recentFailures.clear();
        _consecutiveNoSuccess = 0;
        log(
          '⚠ SSTP log watcher: $_maxConsecutiveNoSuccess شکست متوالی '
          'بدون هیچ اتصال موفق',
          source: _source,
        );
        return true;
      }
    }

    if (lower.contains('tunnel is up') || lower.contains('proxies ready')) {
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
