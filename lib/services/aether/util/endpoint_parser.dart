library;

/// ═══════════════════════════════════════════════════════════════
///  EndpointParser — تنها منبع حقیقت برای پارس endpoint.
///
///  قبل از این فایل، سه جای مختلف منطق تکراری داشتن:
///    • AetherEndpointStore._isValidPublicEndpoint
///    • GatewayReconnectPhase1._parseEndpoint
///    • OutcomeRecorder._parseEndpoint
///    • AetherFailureHandler.parseEndpoint
///
///  همه اینا الان این‌جا جمع شدن.
/// ═══════════════════════════════════════════════════════════════
class EndpointParser {
  EndpointParser._();

  /// بازه‌های IP خصوصی که نباید به عنوان endpoint ذخیره شوند.
  static final List<RegExp> _privateIpPatterns = [
    RegExp(r'^10\.'),
    RegExp(r'^172\.(1[6-9]|2\d|3[0-1])\.'),
    RegExp(r'^192\.168\.'),
    RegExp(r'^127\.'),
    RegExp(r'^169\.254\.'), // link-local
    RegExp(r'^0\.'),
    RegExp(r'^255\.'),
  ];

  /// آیا این IP یک IP private است؟
  static bool isPrivate(String ip) {
    for (final pattern in _privateIpPatterns) {
      if (pattern.hasMatch(ip)) return true;
    }
    return false;
  }

  /// پارس `host:port`. اگر نامعتبر بود null.
  ///
  /// توجه: `host` می‌تونه IPv4 یا hostname باشه — IPv6 پشتیبانی نمی‌شه.
  static (String host, int port)? parse(String endpoint) {
    if (endpoint.isEmpty) return null;
    final idx = endpoint.lastIndexOf(':');
    if (idx <= 0 || idx == endpoint.length - 1) return null;

    final host = endpoint.substring(0, idx);
    final portStr = endpoint.substring(idx + 1);
    final port = int.tryParse(portStr);
    if (port == null || port < 1 || port > 65535) return null;
    if (host.isEmpty) return null;
    return (host, port);
  }

  /// آیا این endpoint یک IPv4 معتبر عمومی است؟
  ///
  /// این متد برای تصمیم «ذخیره کردن یا نه» استفاده می‌شود.
  /// hostname‌ها (مثل `cloudflare.com`) هم معتبر در نظر گرفته می‌شن.
  static bool isValidPublicEndpoint(String endpoint) {
    final parsed = parse(endpoint);
    if (parsed == null) return false;
    final host = parsed.$1;

    // اگه IPv4 است، باید public باشه
    if (_looksLikeIPv4(host)) {
      return !isPrivate(host);
    }

    // hostname معتبر
    return true;
  }

  /// آیا رشته شبیه IPv4 است؟ (بدون چک کردن بازه)
  static bool _looksLikeIPv4(String s) {
    final parts = s.split('.');
    if (parts.length != 4) return false;
    for (final p in parts) {
      final n = int.tryParse(p);
      if (n == null || n < 0 || n > 255) return false;
    }
    return true;
  }
}
