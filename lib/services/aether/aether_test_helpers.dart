library;

import '../port_manager.dart';
import '../process_service.dart';

class AetherTestHelpers {
  final ProcessService processService;

  AetherTestHelpers({required this.processService});

  /// تلاش برای پیدا کردن یک پورت آزاد جدید و به‌روزرسانی تنظیمات.
  /// برمی‌گرداند: پورت جدید یا null در صورت شکست.
  Future<int?> swapPort({
    required int currentPort,
    required void Function(int newPort) onPortChanged,
  }) async {
    try {
      final newPort = await PortManager.findFree();
      processService.addLog(
        '→ Switching Aether local port $currentPort → $newPort',
        source: LogSource.aether,
      );
      onPortChanged(newPort);
      return newPort;
    } catch (e) {
      processService.addLog(
        '⚠ Failed to swap port: $e',
        source: LogSource.aether,
      );
      return null;
    }
  }

  /// اجرای یک تابع async با مدیریت خطا.
  /// خطاها لاگ می‌شوند و null برگردانده می‌شود.
  ///
  /// نکته: type parameter به صراحت `T` تعریف شده تا nullableها
  /// به درستی کار کنند. مثلاً `safe<MapEntry<String, String>?>(...)`
  Future<T?> safe<T>(Future<T> Function() fn) async {
    try {
      return await fn();
    } catch (e) {
      processService.addLog(
        '⚠ step skipped: $e',
        source: LogSource.aether,
      );
      return null;
    }
  }
}
