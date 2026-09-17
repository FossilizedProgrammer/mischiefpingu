// lib/services/psiphon/psiphon_log_watcher.dart
//
// ═══════════════════════════════════════════════════════════════
//  PsiphonLogWatcher — تشخیص زودهنگام tunnel-dead از لاگ
//
//  ⚠️ بسیار محافظه‌کار برای اینترنت ناپایدار:
//   • فقط خطاهای قطعی
//   • پنجره 5 دقیقه‌ای
//   • threshold 25
// ═══════════════════════════════════════════════════════════════
library;

class PsiphonLogWatcher {
  final void Function(String message, {String source}) log;
  static const String _source = 'Psiphon';

  final List<DateTime> _recentFailures = [];
  static const Duration _window = Duration(minutes: 5);
  static const int _windowThreshold = 25;

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

      if (_recentFailures.length >= _windowThreshold) {
        _recentFailures.clear();
        log(
          '⚠ Psiphon log watcher: $_windowThreshold قطعی در '
          '${_window.inMinutes} دقیقه',
          source: _source,
        );
        return true;
      }
    }

    if (lower.contains('"noticetype":"activetunnel"') ||
        lower.contains('tunnel established')) {
      _recentFailures.clear();
    }

    return false;
  }

  void reset() {
    _recentFailures.clear();
  }
}
