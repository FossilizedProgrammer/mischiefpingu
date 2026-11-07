library;

class ProcessHappyDetector {
  final void Function(String tunnelName) onHappy;

  /// نگه‌داشتن آخرین وضعیت هر تونل.
  final Map<String, bool> _lastState = {};

  /// cooldown بین دو happy notification برای یک تونل.
  final Map<String, DateTime> _lastFired = {};
  static const Duration _cooldown = Duration(seconds: 5);

  ProcessHappyDetector({required this.onHappy});

  /// این متد از listenerهای پروسه صدا زده می‌شود.
  ///
  /// ⚠️ مهم: `wasConnected` را از state *قبل* از تغییر بدهید،
  /// نه از state جدید. اگر فقط `isConnected` بدهید، ما خودمان
  /// بر اساس `_lastState` تشخیص می‌دهیم.
  void checkTransition({
    required String tunnelName,
    required bool wasConnected,
    required bool isConnected,
  }) {
    if (!isConnected) {
      _lastState[tunnelName] = false;
      return;
    }

    final previous = _lastState[tunnelName] ?? false;
    if (previous) return;

    _lastState[tunnelName] = true;

    final lastFired = _lastFired[tunnelName];
    final now = DateTime.now();
    if (lastFired != null && now.difference(lastFired) < _cooldown) {
      return;
    }
    _lastFired[tunnelName] = now;

    onHappy(tunnelName);
  }

  /// ریست کردن state یک تونل (مثلاً وقتی کاربر دستی stop می‌کند).
  void reset(String tunnelName) {
    _lastState[tunnelName] = false;
    _lastFired.remove(tunnelName);
  }

  /// ریست کامل.
  void resetAll() {
    _lastState.clear();
    _lastFired.clear();
  }
}
