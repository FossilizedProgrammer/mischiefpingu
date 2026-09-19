library;

import 'dart:io';
import 'dart:math';

class PortManager {
  PortManager._();

  /// پورت‌های ترجیحی برای Aether (به ترتیب اولویت).
  static const List<int> preferredAetherPorts = [
    1819,
    1820,
    1821,
    1822,
    2080,
    3080,
    7891,
    10808,
  ];

  /// بررسی می‌کند که آیا پورت [port] روی 127.0.0.1 آزاد است.
  ///
  /// ⚠️ این متد هم برای checkPorts و هم برای findFree استفاده
  /// میشود تا مطمئن شویم منطق یکسان است.
  static Future<bool> isFree(int port) async {
    if (port < 1 || port > 65535) return false;
    ServerSocket? s;
    try {
      s = await ServerSocket.bind(
        InternetAddress.loopbackIPv4,
        port,
        shared: false,
      );
      return true;
    } catch (_) {
      return false;
    } finally {
      try {
        await s?.close();
      } catch (_) {}
    }
  }

  /// بررسی می‌کند که آیا چیزی روی پورت [port] گوش می‌دهد.
  ///
  /// ⚠️ تغییر مهم: قبلاً از Socket.connect استفاده می‌شد که
  /// وقتی پروسه روی 0.0.0.0 گوش میداد ولی loopback مسدود بود،
  /// false negative میداد.
  ///
  /// حالا از ServerSocket.bind با try استفاده میکنیم:
  /// اگر bind شکست بخورد یعنی چیزی روی آن پورت گوش میدهد.
  ///
  /// ⚠️ نکته: این متد از این به بعد "isInUse" را از منظر
  /// "قابل bind بودن روی loopback" تعریف میکند، که دقیقاً
  /// همان چیزی است که برای راه‌اندازی تونل نیاز داریم.
  static Future<bool> isInUse(int port) async {
    final free = await isFree(port);
    return !free;
  }

  /// اولین پورت آزاد از لیست ترجیحی را برمی‌گرداند،
  /// در غیر این صورت یک پورت تصادفی آزاد.
  static Future<int> findFree({List<int>? preferred}) async {
    final candidates = preferred ?? preferredAetherPorts;

    for (final port in candidates) {
      if (await isFree(port)) return port;
    }

    final random = Random();
    for (var i = 0; i < 20; i++) {
      final port = 20000 + random.nextInt(20000);
      if (await isFree(port)) return port;
    }

    ServerSocket? s;
    try {
      s = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final port = s.port;
      return port;
    } finally {
      try {
        await s?.close();
      } catch (_) {}
    }
  }

  /// اگر [publicPort] + offset آزاد باشد آن را برمی‌گرداند،
  /// در غیر این صورت یک پورت آزاد دیگر.
  static Future<int> internalFor({
    required int publicPort,
    int offset = 10000,
  }) async {
    final candidate = publicPort + offset;
    if (candidate >= 1 &&
        candidate <= 65535 &&
        candidate != publicPort &&
        await isFree(candidate)) {
      return candidate;
    }
    return findFree(preferred: const []);
  }
}
