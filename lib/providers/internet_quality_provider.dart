library;

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/diagnostics/diagnostic_models.dart';
import '../services/diagnostics/internet_quality_monitor.dart';
import '../services/process_service.dart';

/// ═══════════════════════════════════════════════════════════════
///  InternetQualityProvider — مدیریت state کیفیت اینترنت
///  این provider به UI و watchdog سرویس می‌دهد.
/// ═══════════════════════════════════════════════════════════════

class InternetQualityProvider extends ChangeNotifier {
  final ProcessService processService;

  late final InternetQualityMonitor _monitor = InternetQualityMonitor(
    log: processService.addLog,
    onUpdate: _onMonitorUpdate,
  );

  InternetDiagnosticResult? _result;
  InternetDiagnosticResult? get result => _result;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  MonitoringLevel _level = MonitoringLevel.idle;
  MonitoringLevel get level => _level;

  InternetQualityProvider({required this.processService});

  /// چک سریع — برای watchdog.
  Future<bool> isInternetAlive() => _monitor.isInternetAlive();

  /// آخرین نتیجه یا null.
  InternetDiagnosticResult? get lastResult => _result;

  /// ═══════════════════════════════════════════════════════════════
  ///  ⚠️ جدید: invalidate کردن cache داخلی.
  ///
  ///  از AppProvider (وقتی NetworkChangeDetector تغییر شبکه رو
  ///  تشخیص داد) صدا زده می‌شه.
  /// ═══════════════════════════════════════════════════════════════
  void invalidateCache() {
    _monitor.invalidateCache();
  }

  /// اجرای diagnostic فوری و انتظار برای نتیجه.
  Future<InternetDiagnosticResult> testNow() async {
    if (_isLoading) {
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _result!;
    }

    _isLoading = true;
    notifyListeners();
    try {
      final r = await _monitor.runNow();
      _result = r;
      return r;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تغییر سطح مانیتورینگ.
  void setLevel(MonitoringLevel level) {
    if (_level == level) return;
    _level = level;
    _monitor.start(level);
    notifyListeners();
  }

  /// شروع مانیتورینگ (اگر تنظیمات اجازه دهد).
  void autoStart() {
    if (_level != MonitoringLevel.idle) return;
    setLevel(MonitoringLevel.light);
  }

  @override
  void dispose() {
    _monitor.dispose();
    super.dispose();
  }

  void _onMonitorUpdate(InternetDiagnosticResult r) {
    _result = r;
    notifyListeners();
  }
}
