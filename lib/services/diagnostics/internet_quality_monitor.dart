library;

import 'dart:async';

import '../process/log_source.dart';
import 'diagnostic_models.dart';
import 'internet_diagnostic_service.dart';

/// ═══════════════════════════════════════════════════════════════
///  InternetQualityMonitor — مانیتورینگ پس‌زمینه
///
///  سطوح:
///    • idle   — مانیتور نمی‌کند
///    • light  — هر ۱۵ ثانیه connectivity سریع
///    • normal — هر ۲ دقیقه quality measurement
///    • deep   — فقط دستی
/// ═══════════════════════════════════════════════════════════════

class InternetQualityMonitor {
  final void Function(String message, {String source})? log;
  final void Function(InternetDiagnosticResult result)? onUpdate;

  late final InternetDiagnosticService _diagnostic = InternetDiagnosticService(
    log: log,
  );

  MonitoringLevel _level = MonitoringLevel.idle;
  Timer? _timer;
  bool _running = false;
  bool _disposed = false;

  InternetDiagnosticResult? _lastResult;
  InternetDiagnosticResult? get lastResult => _lastResult;

  /// ⚠️ جدید: cache کوتاه برای isInternetAlive تا watchdog
  /// هر بار ۳ ثانیه block نشود.
  bool? _cachedAlive;
  DateTime? _cachedAliveAt;
  static const Duration _aliveCacheTtl = Duration(seconds: 8);

  InternetQualityMonitor({this.log, this.onUpdate});

  MonitoringLevel get level => _level;

  /// شروع مانیتورینگ. اگر از قبل روشن باشد، فقط level را تغییر می‌دهد.
  void start(MonitoringLevel level) {
    if (_disposed) return;
    if (level == MonitoringLevel.idle) {
      stop();
      return;
    }
    _level = level;
    _restartTimer();
    _log('→ InternetQualityMonitor: started (level=${level.name})');
  }

  /// توقف مانیتورینگ.
  void stop() {
    _timer?.cancel();
    _timer = null;
    _running = false;
    _level = MonitoringLevel.idle;
    _log('→ InternetQualityMonitor: stopped');
  }

  /// اجرای فوری یک diagnostic (مثلاً وقتی user دکمه Test Internet می‌زند).
  Future<InternetDiagnosticResult> runNow() async {
    if (_disposed) {
      throw StateError('InternetQualityMonitor is disposed');
    }
    final result = await _diagnostic.diagnose();
    _lastResult = result;

    _cachedAlive = result.overall != InternetQuality.dead;
    _cachedAliveAt = DateTime.now();
    onUpdate?.call(result);
    return result;
  }

  /// چک سریع که آیا Internet alive است — برای watchdog.
  ///
  /// ⚠️ با cache: اگر در ۸ ثانیه اخیر probe شده، همان نتیجه را برمی‌گرداند.
  /// این جلوگیری می‌کند از block شدن watchdog برای ۳ ثانیه در هر probe.
  Future<bool> isInternetAlive() async {
    final cached = _cachedAlive;
    final cachedAt = _cachedAliveAt;
    if (cached != null &&
        cachedAt != null &&
        DateTime.now().difference(cachedAt) < _aliveCacheTtl) {
      return cached;
    }

    final alive = await _diagnostic.isInternetAlive();
    _cachedAlive = alive;
    _cachedAliveAt = DateTime.now();
    return alive;
  }

  void dispose() {
    _disposed = true;
    stop();
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = null;

    final interval = _intervalForLevel(_level);
    if (interval == null) return;

    _timer = Timer.periodic(interval, (_) => _tick());
  }

  Duration? _intervalForLevel(MonitoringLevel level) {
    switch (level) {
      case MonitoringLevel.idle:
        return null;
      case MonitoringLevel.light:
        return const Duration(seconds: 15);
      case MonitoringLevel.normal:
        return const Duration(minutes: 2);
      case MonitoringLevel.deep:
        return const Duration(minutes: 5);
    }
  }

  Future<void> _tick() async {
    if (_running || _disposed) return;
    _running = true;
    try {
      if (_level == MonitoringLevel.light) {
        final alive = await _diagnostic.isInternetAlive();

        _cachedAlive = alive;
        _cachedAliveAt = DateTime.now();
        _log(
          '→ InternetQualityMonitor: light check — '
          '${alive ? "ALIVE" : "DEAD"}',
        );
      } else {
        final result = await _diagnostic.diagnose();
        _lastResult = result;
        _cachedAlive = result.overall != InternetQuality.dead;
        _cachedAliveAt = DateTime.now();
        onUpdate?.call(result);
      }
    } catch (e) {
      _log('⚠ InternetQualityMonitor tick error: $e');
    } finally {
      _running = false;
    }
  }

  void _log(String msg) {
    log?.call(msg, source: LogSource.app);
  }
}
