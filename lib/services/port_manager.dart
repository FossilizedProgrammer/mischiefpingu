// lib/services/port_manager.dart
//
// ═══════════════════════════════════════════════════════════════
//  PortManager — مدیریت پورت‌های محلی
//
//  این کلاس کاملاً مستقل است و به هیچ سرویس دیگری وابسته نیست.
//  (خودش مستقیماً Socket.connect را برای بررسی آزاد بودن پورت
//   صدا می‌زند، نه ProcessService را.)
//
//  منطق مشترک بین Aether, Tor و Psiphon:
//    • پیدا کردن پورت آزاد (با لیست ترجیحی یا تصادفی)
//    • محاسبهٔ پورت داخلی برای حالت Share-on-LAN
// ═══════════════════════════════════════════════════════════════
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

  // ═══════════════════════════════════════════
  //  بررسی آزاد بودن پورت (مستقل از ProcessService)
  // ═══════════════════════════════════════════
  /// بررسی می‌کند که آیا پورت [port] روی 127.0.0.1 آزاد است.
  /// از دو روش استفاده می‌کند:
  ///   1. تلاش برای bind کردن — اگر موفق شد، آزاد است
  ///   2. اگر bind شکست خورد، یعنی چیزی آن را اشغال کرده
  static Future<bool> isFree(int port) async {
    try {
      final s = await ServerSocket.bind(
        InternetAddress.loopbackIPv4,
        port,
      );
      await s.close();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// بررسی می‌کند که آیا چیزی روی پورت [port] گوش می‌دهد.
  /// (معادل `ProcessService.isPortInUse` ولی مستقل)
  static Future<bool> isInUse(int port) async {
    try {
      final s = await Socket.connect(
        '127.0.0.1',
        port,
        timeout: const Duration(milliseconds: 400),
      );
      s.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ═══════════════════════════════════════════
  //  پیدا کردن پورت آزاد
  // ═══════════════════════════════════════════
  /// اولین پورت آزاد از لیست ترجیحی را برمی‌گرداند،
  /// در غیر این صورت یک پورت تصادفی آزاد.
  ///
  /// اگر [preferred] خالی باشد، مستقیماً سراغ پورت تصادفی می‌رود.
  static Future<int> findFree({List<int>? preferred}) async {
    final candidates = preferred ?? preferredAetherPorts;

    // مرحله ۱: امتحان پورت‌های ترجیحی
    for (final port in candidates) {
      if (await isFree(port)) return port;
    }

    // مرحله ۲: پورت تصادفی در محدودهٔ امن
    // (بازهٔ 20000-40000 عمداً انتخاب شده تا با پورت‌های ephemeral
    //  سیستمی — که معمولاً بالای 49152 هستند — تداخل نکند)
    final random = Random();
    for (var i = 0; i < 20; i++) {
      final port = 20000 + random.nextInt(20000);
      if (await isFree(port)) return port;
    }

    // مرحله ۳: آخرین راه‌حل — پورت system-assigned
    final s = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final port = s.port;
    await s.close();
    return port;
  }

  // ═══════════════════════════════════════════
  //  پورت داخلی برای Share-on-LAN
  // ═══════════════════════════════════════════
  /// اگر [publicPort] + offset آزاد باشد آن را برمی‌گرداند،
  /// در غیر این صورت یک پورت آزاد دیگر.
  ///
  /// برای حالت Share-on-LAN استفاده می‌شود: باینری روی پورت داخلی
  /// گوش می‌دهد و forwarder Dart روی پورت عمومی.
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
