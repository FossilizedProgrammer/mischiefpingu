/// برچسب‌های استاندارد منبع لاگ.
class LogSource {
  static const String psiphon = 'Psiphon';
  static const String aether = 'Aether';
  static const String tor = 'Tor';
  static const String sstp = 'SSTP';
  static const String wireguard = 'WireGuard';
  static const String ffvpn = 'Firefox VPN';
  static const String lantern = 'Lantern';
  static const String geph = 'Geph';
  static const String npv = 'NPV';
  static const String app = 'App';
  static const String system = 'System';
  static const String empty = '';

  /// لیست تمام منابع لاگ برای استفاده در فیلترها.

  static const List<String> all = [
    psiphon,
    aether,
    tor,
    sstp,
    wireguard,
    ffvpn,
    lantern,
    geph,
    npv,
    app,
    system,
  ];
}
