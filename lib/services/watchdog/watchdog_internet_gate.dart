library;

import 'watchdog_config.dart';

/// ═══════════════════════════════════════════════════════════════
///  Internet gate: قبل از restart چک می‌کند که Internet پایه
///  سالم است یا نه. اگر Internet مرده باشد، restart بی‌فایده است.
/// ═══════════════════════════════════════════════════════════════
class WatchdogInternetGate {
  final Future<bool> Function()? isInternetAlive;
  final void Function(String message, {String source}) log;
  final String logSource;

  bool _lastCheckFailed = false;

  WatchdogInternetGate({
    required this.isInternetAlive,
    required this.log,
    required this.logSource,
  });

  /// آیا Internet الان سالم است؟
  ///
  /// اگر `suppressRestartWhenInternetDead` خاموش باشد،
  /// همیشه true برمی‌گرداند (restart مجاز است).
  Future<bool> isHealthy() async {
    if (!WatchdogConfig.suppressRestartWhenInternetDead) return true;

    final check = isInternetAlive;
    if (check == null) return true;

    bool ok;
    try {
      ok = await check();
    } catch (e) {
      log(
        '⚠ isInternetAlive threw: $e — assuming OK',
        source: logSource,
      );
      return true;
    }

    if (!ok) {
      if (!_lastCheckFailed) {
        log(
          '⚠ restart SUPPRESSED — underlying Internet appears '
          'unstable/dead. No restart until Internet recovers.',
          source: logSource,
        );
        _lastCheckFailed = true;
      }
      return false;
    }

    if (_lastCheckFailed) {
      log(
        '★ Internet recovered — restart suppression lifted',
        source: logSource,
      );
      _lastCheckFailed = false;
    }
    return true;
  }
}
