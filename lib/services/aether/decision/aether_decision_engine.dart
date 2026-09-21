library;

import '../../../models/settings_model.dart';
import '../../database/gateway_history_store.dart';
import '../../database/profile_performance_store.dart';
import '../../database/gateway_score_calculator.dart';
import '../../process/log_source.dart';
import '../../aether_logger.dart';
import '../util/endpoint_parser.dart';   
import 'ranked_candidate.dart';

part 'engine/candidate_builder.dart';
part 'engine/outcome_recorder.dart';
part 'engine/sources/history_source_builder.dart';
part 'engine/sources/cache_source_builder.dart';
part 'engine/sources/profile_source_builder.dart';

/// ═══════════════════════════════════════════════════════════════
///  AetherDecisionEngine — لایهٔ مرکزی تصمیم‌گیری.
///
///  بخش‌های داخلی در `engine/` جدا شده‌اند:
///    • CandidateBuilder    → ساخت ranked candidates
///    • OutcomeRecorder     → ثبت نتیجه (success/failure/session)
///    • HistorySourceBuilder → candidates از تاریخچه
///    • CacheSourceBuilder   → candidates از Smart Cache
///    • ProfileSourceBuilder → candidates پیش‌فرض پروفایل
/// ═══════════════════════════════════════════════════════════════
class AetherDecisionEngine {
  final AppSettings settings;
  final GatewayHistoryStore historyStore;
  final ProfilePerformanceStore profileStore;
  final AetherLogger logger;
  final void Function(String message, {String source}) log;

  static const int maxHistoryCandidates = 5;
  static const int maxCacheCandidates = 5;
  static const double minHistoryScore = 15.0;
  static const double minCacheRate = 0.4;

  AetherDecisionEngine({
    required this.settings,
    required this.historyStore,
    required this.profileStore,
    required this.logger,
    required this.log,
  });

  // ═══════════════════════════════════════════════════════════════
  //  Delegation — منطق در partها
  // ═══════════════════════════════════════════════════════════════

  Future<List<RankedCandidate>> buildRankedCandidates({
    MapEntry<String, String>? autoWinner,
  }) =>
      buildRankedCandidatesImpl(autoWinner: autoWinner);

  Future<void> recordOutcome({
    required RankedCandidate candidate,
    required bool success,
    required int latencyMs,
    String errorMessage = '',
  }) =>
      recordOutcomeImpl(
        candidate: candidate,
        success: success,
        latencyMs: latencyMs,
        errorMessage: errorMessage,
      );

  Future<void> recordSessionEnd({
    required RankedCandidate candidate,
    required Duration uptime,
    required bool wasCleanDisconnect,
    int reconnectCount = 0,
  }) =>
      recordSessionEndImpl(
        candidate: candidate,
        uptime: uptime,
        wasCleanDisconnect: wasCleanDisconnect,
        reconnectCount: reconnectCount,
      );

  /// لاگ داخلی — در دسترس همهٔ partها.
  void logInternal(String msg) => log(msg, source: LogSource.aether);
}
