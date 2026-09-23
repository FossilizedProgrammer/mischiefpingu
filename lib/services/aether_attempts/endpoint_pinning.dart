// lib/services/aether_attempts/endpoint_pinning.dart

part of '../aether_attempts.dart';

/// ═══════════════════════════════════════════════════════════════
///  Endpoint Pinning — منطق ساخت کاندید برای حالت‌های
///  custom_only و custom_first.
///
///  این extension از `part of` استفاده می‌کنه، پس به فیلدهای
///  AetherAttemptPlanner دسترسی داره.
/// ═══════════════════════════════════════════════════════════════
extension AetherAttemptPlannerEndpointPinning on AetherAttemptPlanner {
  /// ساخت کاندید فقط از endpoint سفارشی.
  ///
  /// در این حالت، protocol و masque از تنظیمات کاربر گرفته میشه.
  /// اگه کاربر در manual profile باشه، aetherProtocol استفاده میشه.
  /// وگرنه 'masque' به عنوان پیش‌فرض.
  List<EndpointAttempt> buildCustomOnlyCandidates() {
    final custom = settings.aetherCustomEndpoint.trim();
    if (custom.isEmpty) return const [];

    final proto = _effectiveProtocol();
    final masque = _effectiveMasque(proto);

    return [
      EndpointAttempt(
        label: 'Custom Only ($custom)',
        protocol: proto,
        masque: masque,
        endpoint: custom,
        isCustomEndpoint: true,
      ),
    ];
  }

  /// ساخت کاندیدهای custom-first.
  ///
  /// در این حالت، endpoint سفارشی با هر دو MASQUE option
  /// (HTTP-3 و HTTP-2) ساخته میشه تا شانس اتصال بیشتر بشه.
  List<EndpointAttempt> buildCustomFirstCandidates() {
    final custom = settings.aetherCustomEndpoint.trim();
    if (custom.isEmpty) return const [];

    final proto = _effectiveProtocol();

    // اگه پروتکل masque یا mim هست، هر دو نسخه HTTP-3 و HTTP-2 رو بساز
    if (proto == 'masque' || proto == 'mim') {
      final preferred = settings.masqueOption == 'HTTP-2' ? 'HTTP-2' : 'HTTP-3';
      final alternate = preferred == 'HTTP-3' ? 'HTTP-2' : 'HTTP-3';

      return [
        EndpointAttempt(
          label: 'Custom First ($custom · $preferred)',
          protocol: proto,
          masque: preferred,
          endpoint: custom,
          isCustomEndpoint: true,
        ),
        EndpointAttempt(
          label: 'Custom First ($custom · $alternate)',
          protocol: proto,
          masque: alternate,
          endpoint: custom,
          isCustomEndpoint: true,
        ),
      ];
    }

    // پروتکل‌های دیگه (gool/wireguard) masque ندارن
    return [
      EndpointAttempt(
        label: 'Custom First ($custom)',
        protocol: proto,
        masque: '',
        endpoint: custom,
        isCustomEndpoint: true,
      ),
    ];
  }

  /// پروتکل مؤثر بر اساس تنظیمات کاربر.
  String _effectiveProtocol() {
    if (settings.aetherProfile == 'manual') {
      return settings.aetherProtocol;
    }
    // در automatic profile، default = masque
    return 'masque';
  }

  /// MASQUE option مؤثر.
  String _effectiveMasque(String proto) {
    if (proto != 'masque' && proto != 'mim') return '';
    return settings.masqueOption == 'HTTP-2' ? 'HTTP-2' : 'HTTP-3';
  }
}
