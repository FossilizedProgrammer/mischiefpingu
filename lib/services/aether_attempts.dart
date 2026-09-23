library;

import '../models/gateway_record.dart';
import '../models/settings_model.dart';
import 'aether/aether_args_builder.dart';
import 'aether/decision/aether_decision_engine.dart';
import 'aether/decision/ranked_candidate.dart';
import 'database/gateway_history_store.dart';
import 'database/profile_performance_store.dart';

part 'aether_attempts/attempt_planner_legacy.dart';

/// ═══════════════════════════════════════════════════════════════
///  EndpointAttempt — یک کاندید اتصال به Aether.
/// ═══════════════════════════════════════════════════════════════
class EndpointAttempt {
  final String label;
  final String protocol;
  final String masque;
  final String endpoint;
  final bool fragmentH2;
  final double? historicalScore;
  final bool fromHistory;
  final bool fromProfileCache;

  /// فاز v4: کاندید اصلی (اگر از DecisionEngine آمده باشد).
  final RankedCandidate? rankedSource;

  EndpointAttempt({
    required this.label,
    required this.protocol,
    required this.masque,
    required this.endpoint,
    this.fragmentH2 = false,
    this.historicalScore,
    this.fromHistory = false,
    this.fromProfileCache = false,
    this.rankedSource,
  });

  String get dedupeKey => '$protocol|$masque|$endpoint|$fragmentH2';

  String get cacheTag {
    if (fromProfileCache) return 'profile cache';
    if (fromHistory) return 'history';
    return 'default';
  }

  @override
  String toString() =>
      'EndpointAttempt($label, score=${historicalScore?.toStringAsFixed(1) ?? "-"}, '
      'fromHistory=$fromHistory, fromProfileCache=$fromProfileCache)';
}

/// ═══════════════════════════════════════════════════════════════
///  AetherAttemptPlanner — ساخت لیست کاندیدها.
///
///  فاز v4: به DecisionEngine واگذار می‌کند.
///  Fallback: منطق legacy در `aether_attempts/attempt_planner_legacy.dart`.
/// ═══════════════════════════════════════════════════════════════
class AetherAttemptPlanner {
  final AppSettings settings;
  final GatewayHistoryStore? historyStore;
  final ProfilePerformanceStore? profileStore;
  final AetherDecisionEngine? decisionEngine;

  late final AetherArgsBuilder _argsBuilder = AetherArgsBuilder(settings);

  AetherAttemptPlanner(
    this.settings, {
    this.historyStore,
    this.profileStore,
    this.decisionEngine,
  });

  Future<List<EndpointAttempt>> buildCandidates({
    MapEntry<String, String>? autoWinner,
  }) async {
    // ─── مسیر جدید: DecisionEngine ───
    final engine = decisionEngine;
    if (engine != null) {
      final ranked = await engine.buildRankedCandidates(autoWinner: autoWinner);
      return ranked.map(_fromRanked).toList();
    }

    // ─── Fallback: منطق legacy ───
    return legacyBuild(autoWinner);
  }

  EndpointAttempt _fromRanked(RankedCandidate c) => EndpointAttempt(
        label: c.label,
        protocol: c.protocol,
        masque: c.masque,
        endpoint: c.endpoint,
        fragmentH2: c.fragmentH2,
        historicalScore: c.score,
        fromHistory: c.source == CandidateSource.history ||
            c.source == CandidateSource.lastRemembered,
        fromProfileCache: c.source == CandidateSource.cache,
        rankedSource: c,
      );

  // ─── Public static helpers (برای دسترسی از part) ───
  static String labelFor(ProfileCandidate c) => _labelFor(c);
  static String labelForGateway(GatewayRecord r) => _labelForGateway(r);
  static String labelForProfilePerf({
    required String protocol,
    required String masque,
    required double rate,
  }) =>
      _labelForProfilePerf(protocol: protocol, masque: masque, rate: rate);

  static String _labelFor(ProfileCandidate c) {
    switch (c.protocol) {
      case 'masque':
        return 'MASQUE/${c.masque}${c.fragmentH2 ? "+fragment" : ""}';
      case 'mim':
        return 'MIM/${c.masque}${c.fragmentH2 ? "+fragment" : ""}';
      case 'gool':
        return 'GOOL (WARP-in-WARP)';
      case 'wireguard':
        return 'WIREGUARD';
      default:
        return c.protocol.toUpperCase();
    }
  }

  static String _labelForGateway(GatewayRecord r) {
    final proto = r.protocol.toUpperCase();
    final masque = r.masqueOption.isNotEmpty ? '/${r.masqueOption}' : '';
    final score = r.score.toStringAsFixed(0);
    return '$proto$masque (history score=$score)';
  }

  static String _labelForProfilePerf({
    required String protocol,
    required String masque,
    required double rate,
  }) {
    final proto = protocol.toUpperCase();
    final m = masque.isNotEmpty ? '/$masque' : '';
    final pct = (rate * 100).toStringAsFixed(0);
    return '$proto$m (profile rate=$pct%)';
  }

  String resolveProtocolForEndpoint(String userChoice, String endpoint) {
    if (userChoice != 'auto') return userChoice;
    return 'masque';
  }

  List<String> argsFor({
    required String protocol,
    required String masqueOption,
    required int port,
    String endpointOverride = '',
    bool forceFragmentH2 = false,
  }) =>
      _argsBuilder.build(
        protocol: protocol,
        masqueOption: masqueOption,
        port: port,
        endpointOverride: endpointOverride,
        forceFragmentH2: forceFragmentH2,
      );
}
