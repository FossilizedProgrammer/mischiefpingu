// lib/services/ffvpn/ffvpn_upstream_builder.dart
//
// آپ‌استریم SOCKS برای تونل Firefox VPN.
//
// ffvpn به لبهٔ IP Protection فایرفاکس با TLS وصل می‌شود؛ اگر لبه از
// شبکهٔ محلی قابل دسترسی نباشد (یا برای عبور از فیلتر لازم باشد) می‌توان
// رسیدن به آن را از یک SOCKS5 دیگر رد کرد. باینری Go این کار را با فلگ
// `--dial-proxy socks5://[user:pass@]host:port` انجام می‌دهد و این کلاس
// تنظیمات `ffvpnUpstreamType` را به همان URL تبدیل می‌کند.

import '../../models/settings_model.dart';
import '../process_service.dart';

class FfvpnUpstreamBuilder {
  /// بدون آپ‌استریم — اتصال مستقیم به لبه.
  static const int direct = 0;

  /// SOCKS5 دستی که خود کاربر آدرس/پورت‌اش را می‌دهد.
  static const int manual = 1;

  /// SOCKS محلی Psiphon.
  static const int psiphon = 3;

  /// SOCKS محلی Tor.
  static const int tor = 4;

  /// SOCKS محلی SSTP.
  static const int sstp = 5;

  /// SOCKS محلی WireGuard.
  static const int wireguard = 6;

  final AppSettings settings;
  final ProcessService processService;

  FfvpnUpstreamBuilder({
    required this.settings,
    required this.processService,
  });

  int get type => settings.ffvpnUpstreamType;

  /// آیا آپ‌استریمی انتخاب شده است؟
  bool get hasUpstream => type != direct;

  /// نام نمایشی آپ‌استریم انتخاب‌شده.
  String get label {
    switch (type) {
      case manual:
        return 'Manual';
      case psiphon:
        return 'Psiphon';
      case tor:
        return 'Tor';
      case sstp:
        return 'SSTP';
      case wireguard:
        return 'WireGuard';
      default:
        return 'Direct';
    }
  }

  /// پورت SOCKS محلی آپ‌استریم (برای `direct` و `manual` بی‌معنی است).
  int? get socksPort {
    switch (type) {
      case psiphon:
        return settings.socksPort;
      case tor:
        return settings.torSocksPort;
      case sstp:
        return settings.sstpSocksPort;
      case wireguard:
        return settings.wireguardSocksPort;
      default:
        return null;
    }
  }

  /// URL کامل برای `--dial-proxy`.
  ///
  /// رشتهٔ خالی یعنی «بدون آپ‌استریم»: یا `direct` است، یا آپ‌استریم
  /// دستی هنوز آدرس/پورت ندارد.
  String buildUrl() {
    if (!hasUpstream) return '';
    if (type == manual) return _manualUrl();
    final port = socksPort;
    if (port == null) return '';
    return 'socks5://127.0.0.1:$port';
  }

  /// همان URL با گذرواژه ماسک‌شده، برای لاگ.
  String describeUrl() => maskCredentials(buildUrl());

  /// argv مربوط به آپ‌استریم را اضافه می‌کند؛ اگر پیکربندی ناقص باشد فقط
  /// هشدار می‌دهد و اتصال مستقیم ادامه پیدا می‌کند.
  void apply(List<String> args) {
    if (!hasUpstream) return;
    final url = buildUrl();
    if (url.isEmpty) {
      processService.addLog(
        '⚠ Firefox VPN upstream is set to $label but the proxy host/port is '
        'empty — connecting directly',
        source: LogSource.ffvpn,
      );
      return;
    }
    args.addAll(['--dial-proxy', url]);
    processService.addLog(
      '→ Firefox VPN upstream: $label (${maskCredentials(url)})',
      source: LogSource.ffvpn,
    );
  }

  String _manualUrl() {
    final host = settings.ffvpnProxyIp.trim();
    final port = settings.ffvpnProxyPort;
    if (host.isEmpty || port <= 0) return '';

    var url = '${settings.ffvpnProxyType}://';
    final user = settings.ffvpnProxyUser.trim();
    if (user.isNotEmpty) {
      url += '${Uri.encodeComponent(user)}:'
          '${Uri.encodeComponent(settings.ffvpnProxyPass)}@';
    }
    url += '$host:$port';
    return url;
  }

  /// `scheme://user:pass@host` → `scheme://user:****@host`.
  static String maskCredentials(String url) {
    if (url.isEmpty) return url;
    final schemeSep = url.indexOf('//');
    final at = url.indexOf('@');
    if (schemeSep < 0 || at < schemeSep) return url;
    final credentials = url.substring(schemeSep + 2, at);
    final colon = credentials.indexOf(':');
    if (colon < 0) return url; // بدون گذرواژه — چیزی برای ماسک کردن نیست
    return '${url.substring(0, schemeSep + 2)}'
        '${credentials.substring(0, colon)}:****${url.substring(at)}';
  }
}
