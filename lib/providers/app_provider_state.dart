part of 'app_provider.dart';

/// ═══════════════════════════════════════════════════════════════
///  AppProviderState — state fields مشترک AppProvider.
///
///  این extension فقط holder هست — منطق نداره. تمام فیلدهای
///  عمومی که در چند جای مختلف استفاده می‌شن اینجا جمع شدن.
///
///  ⚠️ چون از `part of` استفاده می‌کنه، فیلدها مستقیماً روی
///  AppProvider تعریف می‌شن.
/// ═══════════════════════════════════════════════════════════════
extension AppProviderState on AppProvider {
  // این extension خالیه — چون فیلدها باید مستقیماً روی
  // AppProvider تعریف بشن، نه در extension.
  //
  // این فایل برای اینه که اگه بعداً خواستی helper methods
  // state-related اضافه کنی، جای مشخصی داشته باشی.
  //
  // فیلدهای واقعی در app_provider.dart باقی می‌مونن چون
  // Dart اجازه نمی‌ده extension فیلد instance اضافه کنه.

  /// پاک کردن state مربوط به Aether (استفاده در logout/reset).
  void clearAetherState() {
    lastAetherConnectedProtocol = null;
    lastAetherConnectedGatewayKey = null;
    lastAetherConnectedAt = null;
    aetherReconnectCount = 0;
  }

  /// پاک کردن state مربوط به یک تونل خاص.
  void clearTunnelState(String tunnelName) {
    switch (tunnelName.toLowerCase()) {
      case 'psiphon':
        // Psiphon state در ProcessService مدیریت می‌شه
        break;
      case 'aether':
        clearAetherState();
        break;
      case 'tor':
        torStatus = 'Tor: Ready';
        break;
      case 'sstp':
        sstpStatus = 'SSTP: Ready';
        break;
    }
  }
}
