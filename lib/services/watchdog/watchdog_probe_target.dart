library;

/// ═══════════════════════════════════════════════════════════════
///  WatchdogProbeTarget — یک هدف probe.
///
///  ⚠️ ترتیب targets در لیست مهم است — اول‌ها زودتر امتحان می‌شوند.
///  ⚠️ لیست نباید به Cloudflare وابسته باشد.
/// ═══════════════════════════════════════════════════════════════
class WatchdogProbeTarget {
  final String host;
  final int port;

  const WatchdogProbeTarget(this.host, this.port);

  String get label => '$host:$port';

  @override
  String toString() => label;

  @override
  bool operator ==(Object other) =>
      other is WatchdogProbeTarget &&
      other.host == host &&
      other.port == port;

  @override
  int get hashCode => Object.hash(host, port);
}

/// ═══════════════════════════════════════════════════════════════
///  WatchdogProbeTargets — لیست‌های هدف probe.
///
///  ⚠️ اصل حیاتی: واچ‌داگ نباید به یک هدف واحد (مخصوصاً
///  Cloudflare) وابسته باشد.
/// ═══════════════════════════════════════════════════════════════
class WatchdogProbeTargets {
  WatchdogProbeTargets._();

  /// اهداف عمومی — بدون Cloudflare.
  ///
  /// ترتیب: دامنه‌های پایدار و IPهای عمومی.
  static const List<WatchdogProbeTarget> general = [
    WatchdogProbeTarget('www.google.com', 443),
    WatchdogProbeTarget('www.microsoft.com', 443),
    WatchdogProbeTarget('8.8.8.8', 443),
    WatchdogProbeTarget('1.1.1.1', 443),
    WatchdogProbeTarget('9.9.9.9', 443),
    WatchdogProbeTarget('www.wikipedia.org', 443),
  ];

  /// اهداف با Cloudflare (برای پروفایل‌های stable/normal).
  static const List<WatchdogProbeTarget> withCloudflare = [
    WatchdogProbeTarget('www.google.com', 443),
    WatchdogProbeTarget('www.microsoft.com', 443),
    WatchdogProbeTarget('www.cloudflare.com', 443),
    WatchdogProbeTarget('8.8.8.8', 443),
    WatchdogProbeTarget('1.1.1.1', 443),
    WatchdogProbeTarget('9.9.9.9', 443),
  ];

  /// انتخاب لیست بر اساس پروفایل و شماره دور (برای چرخش).
  static List<WatchdogProbeTarget> forRound({
    required bool includeCloudflare,
    required int round,
  }) {
    final base = includeCloudflare ? withCloudflare : general;
    if (base.isEmpty) return base;
    final offset = round % base.length;
    return [
      ...base.skip(offset),
      ...base.take(offset),
    ];
  }

  /// گرفتن SNI برای یک host (اگر IP باشد، SNI مناسب).
  static String sniFor(String host) {
    if (looksLikeIPv4(host)) {
      switch (host) {
        case '8.8.8.8':
          return 'dns.google';
        case '1.1.1.1':
          return 'one.one.one.one';
        case '9.9.9.9':
          return 'dns.quad9.net';
        default:
          return 'www.google.com';
      }
    }
    return host;
  }

  /// ⚠️ public شده تا از WatchdogProber هم قابل دسترسی باشه.
  static bool looksLikeIPv4(String s) {
    final parts = s.split('.');
    if (parts.length != 4) return false;
    for (final p in parts) {
      final n = int.tryParse(p);
      if (n == null || n < 0 || n > 255) return false;
    }
    return true;
  }
}
