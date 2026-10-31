library;

import '../../models/gateway_record.dart';
import '../aether_attempt_runner.dart';
import '../aether_socks_probe.dart';
import '../database/gateway_history_store.dart';
import '../process_service.dart';
import 'decision/aether_decision_engine.dart';
import 'decision/ranked_candidate.dart';
import 'gateway_performance_tracker.dart';
import 'util/endpoint_parser.dart';

part 'gateway_reconnect/gateway_reconnect_phase1.dart';
part 'gateway_reconnect/gateway_reconnect_phase2.dart';
part 'gateway_reconnect/gateway_reconnect_args.dart';

/// ═══════════════════════════════════════════════════════════════
///  GatewayReconnectOrchestrator — reconnect هوشمند چند مرحله‌ای.
///
///  فاز v4:
///    مرحله 1: آخرین Gateway موفق (Same Gateway + Protocol)
///    مرحله 2: Top 3 Ranked Candidates از DecisionEngine
///    مرحله 3: Scan کامل (خارج از این کلاس)
///
///  ⚠️ API جدید (برای fast-path):
///    tryEndpointDirect  — تلاش مستقیم با endpoint خام
///    tryGateway         — تلاش با GatewayRecord
///
///  بخش‌های داخلی در `gateway_reconnect/` جدا شده‌اند:
///    • GatewayReconnectPhase1 → آخرین Gateway + tryEndpointDirect
///    • GatewayReconnectPhase2 → Ranked Candidates
///    • GatewayReconnectArgs   → ساخت args
/// ═══════════════════════════════════════════════════════════════
class GatewayReconnectOrchestrator {
  final ProcessService processService;
  final GatewayHistoryStore historyStore;
  final AetherAttemptRunner runner;
  final GatewayPerformanceTracker? performanceTracker;

  /// ═══ فاز v4: DecisionEngine برای ranked candidates ═══
  final AetherDecisionEngine? decisionEngine;

  static const int maxSecondaryAttempts = 3;
  static const double minSecondaryScore = 15.0;

  const GatewayReconnectOrchestrator({
    required this.processService,
    required this.historyStore,
    required this.runner,
    this.performanceTracker,
    this.decisionEngine,
  });

  /// ═══════════════════════════════════════════════════════════════
  ///  نقطهٔ ورود اصلی — attemptSmartReconnect.
  /// ═══════════════════════════════════════════════════════════════
  Future<bool> attemptSmartReconnect({
    required int port,
    required bool Function() isCancelRequested,
    String currentProtocol = '',
    String currentMasque = '',
    String currentSni = '',
    String currentEndpoint = '',
  }) async {
    // ─── مرحله 1: آخرین Gateway موفق ───
    final last = await getLastSuccessfulGateway();
    if (last != null) {
      if (isCancelRequested()) return false;

      logMessage(
        '→ Smart reconnect [phase 1]: trying last successful '
        '${last.protocol}${last.masqueOption.isNotEmpty ? "/${last.masqueOption}" : ""} '
        '(score=${last.score.toStringAsFixed(0)})',
      );

      final ok = await tryGateway(
        record: last,
        port: port,
        isCancelRequested: isCancelRequested,
      );
      if (ok) {
        logMessage('★ Smart reconnect: last successful gateway worked');
        return true;
      }
      logMessage('→ Smart reconnect: last successful gateway failed');
    } else {
      logMessage('→ Smart reconnect [phase 1]: no history DB entry');
    }

    // ─── مرحله 2: Top 3 از DecisionEngine ───
    final candidates = await getRankedCandidates(
      exclude: last,
      isCancelRequested: isCancelRequested,
    );

    if (candidates.isEmpty) {
      logMessage('→ Smart reconnect [phase 2]: no ranked candidates');
      return false;
    }

    logMessage(
      '→ Smart reconnect [phase 2]: trying ${candidates.length} '
      'ranked candidate(s)',
    );

    for (var i = 0; i < candidates.length; i++) {
      if (isCancelRequested()) return false;
      final c = candidates[i];
      logMessage(
        '→ Smart reconnect [phase 2, ${i + 1}/${candidates.length}]: '
        '${c.label} (score=${c.score.toStringAsFixed(0)})',
      );

      final ok = await tryRankedCandidate(
        candidate: c,
        port: port,
        isCancelRequested: isCancelRequested,
      );
      if (ok) {
        logMessage('★ Smart reconnect: ranked candidate worked');
        return true;
      }
    }

    logMessage('→ Smart reconnect: all attempts failed');
    return false;
  }

  /// helper لاگ.
  void logMessage(String msg) =>
      processService.addLog(msg, source: LogSource.aether);
}
