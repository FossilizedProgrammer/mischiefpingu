// lib/models/wireguard_core_type.dart

library;

/// ═══════════════════════════════════════════════════════════════
///  WireGuardCoreType — نوع هستهٔ WireGuard.
///
///    • standard  → wireproxy (سازگار با WireGuard معمولی)
///    • amnezia   → wireproxy-awg (پشتیبانی از AmneziaWG)
/// ═══════════════════════════════════════════════════════════════
enum WireGuardCoreType {
  standard,
  amnezia,
}
