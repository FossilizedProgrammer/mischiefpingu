// lib/services/aether_attempts.dart

library;

import '../models/gateway_record.dart';
import '../models/settings_model.dart';
import 'aether/aether_args_builder.dart';
import 'aether/decision/aether_decision_engine.dart';
import 'aether/decision/ranked_candidate.dart';
import 'database/gateway_history_store.dart';
import 'database/profile_performance_store.dart';

part 'aether_attempts/attempt_planner_legacy.dart';
part 'aether_attempts/endpoint_pinning.dart';

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

  /// ═══════════════════════════════════════════════════════════
  ///  🆕 آیا این attempt از custom endpoint کاربر آمده؟
  ///  برای پیاده‌سازی endpoint pinning لازمه.
  /// ═══════════════════════════════════════════════════════════
  final bool isCustomEndpoint;

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
    this.isCustomEndpoint = false,
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
      'fromHistory=$fromHistory, fromProfileCache=$fromProfileCache, '
      'isCustom=$isCustomEndpoint)';
}

/// ═══════════════════════════════════════════════════════════════
///  AetherAttemptPlanner — ساخت لیست کاندیدها.
///
///  فاز v4: به DecisionEngine واگذار می‌کند.
///  Fallback: منطق legacy در `aether_attempts/attempt_planner_legacy.dart`.
///
///  🆕 Endpoint Pinning: در `aether_attempts/endpoint_pinning.dart`.
///
///  ⚠️ تغییر مهم (رفع باگ custom-first):
///  در حالت custom_first، custom candidate از engine فیلتر می‌شه
///  چون planner خودش اون رو (با هر دو نسخهٔ H2/H3) اضافه می‌کنه.
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

  /// ساخت لیست کاندیدها با در نظر گرفتن endpoint pinning mode.
  Future<List<EndpointAttempt>> buildCandidates({
    MapEntry<String, String>? autoWinner,
  }) async {
    // ═══════════════════════════════════════════════════════════
    //  مرحله 1: Endpoint Pinning
    // ═══════════════════════════════════════════════════════════

    // custom_only: فقط endpoint سفارشی
    if (settings.isEndpointPinningCustomOnly) {
      final pinned = buildCustomOnlyCandidates();
      if (pinned.isNotEmpty) return pinned;
      // اگه custom خالیه (که نباید اتفاق بیفته چون validation انجام شده)
      // fall through به automatic
    }

    // custom_first: endpoint سفارشی اول، بقیه بعدش
    final customCandidates = settings.isEndpointPinningCustomFirst
        ? buildCustomFirstCandidates()
        : const <EndpointAttempt>[];

    // ═══════════════════════════════════════════════════════════
    //  مرحله 2: ساخت لیست اصلی (automatic یا fallback)
    // ═══════════════════════════════════════════════════════════

    List<EndpointAttempt> mainCandidates;

    final engine = decisionEngine;
    if (engine != null) {
      final ranked = await engine.buildRankedCandidates(autoWinner: autoWinner);

      // ═══════════════════════════════════════════════════════════
      //  ⚠️ FIX: در حالت custom_first، custom candidate از engine
      //  رو فیلتر کن چون planner خودش اون رو با هر دو نسخهٔ H2/H3
      //  اضافه کرده. این از تکرار و از دست رفتن fallback جلوگیری
      //  می‌کنه.
      // ═══════════════════════════════════════════════════════════
      final filtered = settings.isEndpointPinningCustomFirst
          ? ranked.where((c) => c.source != CandidateSource.custom)
          : ranked;

      mainCandidates = filtered.map(_fromRanked).toList();
    } else {
      mainCandidates = await legacyBuild(autoWinner);
    }

    // ═══════════════════════════════════════════════════════════
    //  مرحله 3: ادغام custom-first با main
    // ═══════════════════════════════════════════════════════════

    if (customCandidates.isEmpty) {
      return mainCandidates;
    }

    // dedupe: حذف custom endpoint از main اگه تکراری باشه
    final seen = <String>{};
    final result = <EndpointAttempt>[];

    for (final c in customCandidates) {
      if (seen.add(c.dedupeKey)) result.add(c);
    }
    for (final c in mainCandidates) {
      if (seen.add(c.dedupeKey)) result.add(c);
    }

    return result;
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
        isCustomEndpoint: c.source == CandidateSource.custom,
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
