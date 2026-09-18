library;

import 'dart:async';

import 'log_source.dart';

class LogStore {
  static const int maxLines = 1000;
  static const int maxDedupeBufferSize = 100;

  final List<String> _logs = [];
  final Set<String> _dedupeBuffer = {};

  final StreamController<String> _logStream =
      StreamController<String>.broadcast();

  bool _disposed = false;

  /// Stream خطوط جدید (برای log watcherها).
  Stream<String> get stream => _logStream.stream;

  /// آیا logging فعال است؟
  bool enabled = true;

  /// لیست غیرقابل‌تغییر همهٔ خطوط.
  List<String> get fullLog => List.unmodifiable(_logs);

  /// اضافه کردن یک خط. [notify] برای زمانی که صاحب store
  /// می‌خواهد بعد از add، listenerها را خبر کند.
  void add(String message, {String source = LogSource.empty}) {
    if (!enabled || _disposed) return;

    final time = DateTime.now().toString().substring(11, 19);
    final tag = source.isNotEmpty ? '[$source] ' : '';
    final fullLine = '$time $tag$message';

    _logs.add(fullLine);
    if (_logs.length > maxLines) _logs.removeAt(0);

    final dedupeKey = '$source|$message';
    if (!_dedupeBuffer.contains(dedupeKey)) {
      _dedupeBuffer.add(dedupeKey);
      if (_dedupeBuffer.length > maxDedupeBufferSize) {
        _dedupeBuffer.remove(_dedupeBuffer.first);
      }
      if (!_logStream.isClosed) {
        _logStream.add(fullLine);
      }
    }
  }

  void clear() {
    _logs.clear();
    _dedupeBuffer.clear();
  }

  void dispose() {
    _disposed = true;
    _logStream.close();
  }
}
