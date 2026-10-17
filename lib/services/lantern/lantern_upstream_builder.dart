// lib/services/lantern/lantern_upstream_builder.dart
//
// آپ‌استریم برای تونل لنترن.
//
// لنترن با فلگ سراسری `--upstream-proxy` (socks5:// ، http:// یا https://)
// هم کانفیگ و کنترل‌پلین را می‌گیرد، هم به سرورهای خودش (که معمولاً IPشان
// بلاک است) وصل می‌شود و در نبودِ سرور سالم، ترافیک داده را هم از همان
// پروکسی رد می‌کند. این کلاس تنظیمات `lanternUpstreamType` را به همان URL
// تبدیل می‌کند.

import '../../models/settings_model.dart';
import '../process_service.dart';

class LanternUpstreamBuilder {
  /// بدون آپ‌استریم — اتصال مستقیم.
  static const int direct = 0;

  /// پروکسی دستی که خود کاربر آدرس/پورت‌اش را می‌دهد.
  static const int manual = 1;

  /// SOCKS محلی Psiphon.
  static const int psiphon = 3;

  /// SOCKS محلی Tor.
  static const int tor = 4;

  /// SOCKS محلی SSTP.
  static const int sstp = 5;

  /// SOCKS محلی WireGuard.
  static const int wireguard = 6;

  /// SOCKS محلی Firefox VPN.
  static const int ffvpn = 7;

  /// SOCKS محلی Geph.
  static const int geph = 9;

  final AppSettings settings;
  final ProcessService processService;

  LanternUpstreamBuilder({
    required this.settings,
    required this.processService,
  });

  int get type => settings.lanternUpstreamType;

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
      case ffvpn:
        return 'Firefox VPN';
      case geph:
        return 'Geph';
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
      case ffvpn:
        return settings.ffvpnSocksPort;
      case geph:
        return settings.gephSocksPort;
      default:
        return null;
    }
  }

  /// URL کامل برای `--upstream-proxy`.
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

  /// آیا آپ‌استریم انتخابی همین الان در دسترس است؟
  ///
  /// برای تونل‌های داخلی، SOCKS محلی باید بالا باشد؛ برای حالت دستی فقط
  /// آدرس/پورت کافی است.
  bool get isAvailable {
    if (!hasUpstream) return true;
    if (type == manual) return buildUrl().isNotEmpty;
    switch (type) {
      case psiphon:
        return processService.isPsiphonRunning;
      case tor:
        return processService.isTorRunning;
      case sstp:
        return processService.isSstpRunning;
      case wireguard:
        return processService.isWireGuardRunning;
      case ffvpn:
        return processService.isFfvpnRunning;
      case geph:
        return processService.isGephRunning;
      default:
        return true;
    }
  }

  /// argv مربوط به آپ‌استریم را اضافه می‌کند؛ اگر پیکربندی ناقص باشد فقط
  /// هشدار می‌دهد و اتصال مستقیم ادامه پیدا می‌کند.
  void apply(List<String> args) {
    if (!hasUpstream) return;
    final url = buildUrl();
    if (url.isEmpty) {
      processService.addLog(
        '⚠ Lantern upstream is set to $label but the proxy host/port is '
        'empty — connecting directly',
        source: LogSource.lantern,
      );
      return;
    }
    args.addAll(['--upstream-proxy', url]);
    processService.addLog(
      '→ Lantern upstream: $label (${maskCredentials(url)})',
      source: LogSource.lantern,
    );
  }

  String _manualUrl() {
    final host = settings.lanternProxyIp.trim();
    final port = settings.lanternProxyPort;
    if (host.isEmpty || port <= 0) return '';

    var url = '${settings.lanternProxyType}://';
    final user = settings.lanternProxyUser.trim();
    if (user.isNotEmpty) {
      url += '${Uri.encodeComponent(user)}:'
          '${Uri.encodeComponent(settings.lanternProxyPass)}@';
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
