library;

import 'package:flutter/foundation.dart';

import '../../../services/health/tunnel_health_models.dart';
import 'tunnel_health_tester.dart';
import 'tunnel_probe_result.dart';

/// ═══════════════════════════════════════════════════════════════
///  ProbeManager — اجرای probe روی SOCKS یک تونل.
///
///  ⚠️ این کلاس Stateless است — فقط منطق probe رو داره.
///  مدیریت UI state (isProbing, lastResult) به عهده caller است.
/// ═══════════════════════════════════════════════════════════════
class ProbeManager {
  final TunnelHealthTester tester = const TunnelHealthTester();

  const ProbeManager();

  /// اجرای probe. اگر خطا رخ بده، TunnelProbeResult.failure
  /// برمی‌گردونه.
  Future<TunnelProbeResult> run({
    required TunnelKind kind,
    required int socksPort,
  }) async {
    try {
      debugPrint(
        '[ProbeManager] probing ${kind.displayName} on 127.0.0.1:$socksPort',
      );
      return await tester.probe(kind: kind, socksPort: socksPort);
    } catch (e) {
      debugPrint('[ProbeManager] probe threw: $e');
      return TunnelProbeResult.failure(error: '$e');
    }
  }
}
