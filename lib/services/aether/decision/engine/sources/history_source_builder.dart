part of '../../aether_decision_engine.dart';

/// ═══════════════════════════════════════════════════════════════
///  HistorySourceBuilder — candidates از تاریخچه Gateway.
///
///  از top gatewayهای دیتابیس که score بالایی دارن candidate
///  می‌سازه. score با time decay تنظیم می‌شه.
/// ═══════════════════════════════════════════════════════════════
class HistorySourceBuilder {
  final AetherDecisionEngine engine;
  final GatewayHistoryStore historyStore;

  const HistorySourceBuilder({
    required this.engine,
    required this.historyStore,
  });

  Future<void> build(void Function(RankedCandidate) add) async {
    try {
      final top = await historyStore.getTopGateways(
        limit: AetherDecisionEngine.maxHistoryCandidates,
        minScore: AetherDecisionEngine.minHistoryScore,
      );
      if (top.isEmpty) return;

      for (final r in top) {
        final decay = GatewayScoreCalculator.decayFactor(r.updatedAt);
        final effectiveScore = r.score * decay;

        add(
          RankedCandidate(
            protocol: r.protocol,
            masque: r.masqueOption,
            endpoint: r.endpoint,
            score: effectiveScore,
            source: CandidateSource.history,
            reason: 'history score=${r.score.toStringAsFixed(0)} '
                'decay=${decay.toStringAsFixed(2)}',
          ),
        );
      }
    } catch (e) {
      engine.logInternal('⚠ DecisionEngine: history candidates failed: $e');
    }
  }
}
