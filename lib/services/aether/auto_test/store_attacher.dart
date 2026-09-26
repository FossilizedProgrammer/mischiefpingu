// lib/services/aether/auto_test/store_attacher.dart
part of '../../aether_auto_test_service.dart';

/// ═══════════════════════════════════════════════════════════════
///  Logic attach کردن storeها به AetherAutoTestService.
/// ═══════════════════════════════════════════════════════════════
extension AetherAutoTestStoreAttacher on AetherAutoTestService {
  /// پیاده‌سازی واقعی `attachAllStores`.
  void attachAllStoresInternal({
    GatewayHistoryStore? historyStore,
    ProfilePerformanceStore? profileStore,
    AetherLogger? logger,
    AetherDecisionEngine? decisionEngine,
  }) {
    var changed = false;
    if (historyStore != null) {
      gatewayHistoryStore = historyStore;
      changed = true;
    }
    if (profileStore != null) {
      profilePerformanceStore = profileStore;
      changed = true;
    }
    if (logger != null) {
      aetherLogger = logger;
      changed = true;
    }
    if (decisionEngine != null) {
      this.decisionEngine = decisionEngine;
      changed = true;
    }
    if (changed) rebuildCollaborators();
  }
}
