/// برچسب‌های استاندارد منبع لاگ.
class LogSource {
  static const String psiphon = 'Psiphon';
  static const String aether = 'Aether';
  static const String tor = 'Tor';
  static const String sstp = 'SSTP';
  static const String app = 'App';
  static const String system = 'System';
  static const String empty = '';

  /// لیست تمام منابع لاگ برای استفاده در فیلترها.
  static const List<String> all = [psiphon, aether, tor, sstp, app, system];
}
