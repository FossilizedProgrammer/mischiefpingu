library;

/// ثابت‌های پیکربندی diagnostic.
class DiagnosticConfig {
  DiagnosticConfig._();

  static const int samplesPerMetric = 8;
  static const Duration sampleInterval = Duration(milliseconds: 100);
  static const Duration dnsTimeout = Duration(seconds: 3);
  static const Duration tcpTimeout = Duration(seconds: 3);
  static const Duration httpsTimeout = Duration(seconds: 5);

  /// User-Agent شبیه مرورگر — تا برخی ISPها بلاک نکنند.
  static const String httpsUserAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

  /// IPهای پایدار برای TCP probe (بدون DNS).
  static const List<({String ip, int port})> tcpTargets = [
    (ip: '1.1.1.1', port: 443),
    (ip: '8.8.8.8', port: 443),
    (ip: '9.9.9.9', port: 443),
  ];

  /// Hostnameهای پایدار برای DNS probe.
  static const List<String> dnsTargets = [
    'cloudflare.com',
    'google.com',
    'example.com',
  ];

  /// Hostnameهای پایدار برای HTTPS probe.
  ///
  /// ⚠️ اینها hostname هستند نه IP — تا SNI در TLS handshake
  /// پر شود و ISP با DPI آن را بلاک نکند.
  static const List<String> httpsTargets = [
    'www.cloudflare.com',
    'www.google.com',
    'www.microsoft.com',
  ];
}
