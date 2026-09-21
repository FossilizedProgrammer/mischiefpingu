part of '../../aether_decision_engine.dart';

/// ═══════════════════════════════════════════════════════════════
///  CacheSourceBuilder — candidates از Smart Cache.
///
///  از ProfilePerformanceStore بهترین ترکیب‌های
///  (profile, protocol, masque, networkType) رو می‌گیره.
/// ═══════════════════════════════════════════════════════════════
class CacheSourceBuilder {
  final AetherDecisionEngine engine;
  final ProfilePerformanceStore profileStore;

  const CacheSourceBuilder({required this.engine, required this.profileStore});

  Future<void> build(void Function(RankedCandidate) add) async {
    try {
      final best = await profileStore.bestProtocols(
        profile: engine.settings.aetherProfile,
        networkType: engine.settings.ipType,
        limit: AetherDecisionEngine.maxCacheCandidates,
      );
      if (best.isEmpty) return;

      for (final b in best) {
        if (b.rate < AetherDecisionEngine.minCacheRate) continue;

        final latencyPenalty = (b.latency / 2000.0).clamp(0.0, 0.25);
        final score = (b.rate * 100.0) * (1.0 - latencyPenalty);

        add(
          RankedCandidate(
            protocol: b.protocol,
            masque: b.masque,
            endpoint: '',
            score: score,
            source: CandidateSource.cache,
            reason:
                'cache rate=${(b.rate * 100).toStringAsFixed(0)}% '
                'lat=${b.latency}ms',
          ),
        );
      }
    } catch (e) {
      engine.logInternal('⚠ DecisionEngine: cache candidates failed: $e');
    }
  }
}
