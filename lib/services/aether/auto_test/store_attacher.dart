part of '../../aether_auto_test_service.dart';

/// ═══════════════════════════════════════════════════════════════
///  منطق attach کردن storeها به AetherAutoTestService.
///
///  این منطق قبلاً مستقیماً روی کلاس بود. حالا در یه extension
///  جدا قرار گرفته تا کلاس اصلی فقط lifecycle رو نگه داره.
///
///  ⚠️ این extension از `part of` استفاده می‌کنه، پس به
///  فیلدهای private AetherAutoTestService دسترسی داره.
/// ═══════════════════════════════════════════════════════════════
extension AetherAutoTestStoreAttacher on AetherAutoTestService {
  /// پیاده‌سازی واقعی `attachAllStores`.
  ///
  /// اگه هیچ‌کدوم از پارامترها null نباشن، `rebuildCollaborators`
  /// صدا زده می‌شه.
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
