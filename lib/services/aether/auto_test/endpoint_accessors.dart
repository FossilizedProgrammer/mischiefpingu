// lib/services/aether/auto_test/endpoint_accessors.dart
part of '../../aether_auto_test_service.dart';

/// ═══════════════════════════════════════════════════════════════
///  EndpointAccessors — متدهای دسترسی به endpoint و performance.
///
///  این extension متدهایی را فراهم می‌کند برای:
///    • گرفتن آخرین endpoint موفق
///    • ذخیره endpoint از لاگ
///    • دسترسی به performance tracker
/// ═══════════════════════════════════════════════════════════════
extension AetherAutoTestEndpointAccessors on AetherAutoTestService {
  /// گرفتن آخرین endpoint موفق.
  Future<String?> getLastSuccessfulEndpoint() =>
      _store.getLastSuccessfulEndpoint();

  /// بارگذاری auto winner.
  Future<MapEntry<String, String>?> loadAutoWinner() => _store.loadAutoWinner();

  /// پاک کردن آخرین endpoint.
  Future<void> clearLastEndpoint() => _store.clearLastEndpoint();

  /// ذخیره endpoint واقعی از لاگ.
  Future<void> saveRealEndpointFromLog(
    String endpoint, {
    required String protocol,
    required String masque,
  }) =>
      _store.saveRealEndpointFromLog(
        endpoint,
        protocol: protocol,
        masque: masque,
      );

  /// استخراج endpoint واقعی از یک خط لاگ.
  String? extractRealEndpointFromLog(String line) =>
      _store.extractRealEndpointFromLog(line);

  /// آخرین performance report.
  PerformanceReport? get lastPerformanceReport =>
      _performanceTracker?.lastReport;

  /// دسترسی به performance tracker.
  GatewayPerformanceTracker? get performanceTracker => _performanceTracker;
}
