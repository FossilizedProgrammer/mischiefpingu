part of '../aether_decision_engine.dart';

/// ═══════════════════════════════════════════════════════════════
///  ساخت ranked candidates — منطق کامل.
///
///  منابع candidate به ترتیب اولویت:
///    1. آخرین Gateway موفق (lastRemembered)
///    2. تاریخچه (history)
///    3. Smart Cache (cache)
///    4. پیش‌فرض پروفایل (defaultFallback)
///
///  منطق هر منبع در `engine/sources/` جدا شده‌اند:
///    • HistorySourceBuilder   → candidates از تاریخچه
///    • CacheSourceBuilder     → candidates از Smart Cache
///    • ProfileSourceBuilder   → candidates پیش‌فرض پروفایل
/// ═══════════════════════════════════════════════════════════════
extension AetherDecisionEngineCandidateBuilder on AetherDecisionEngine {
  Future<List<RankedCandidate>> buildRankedCandidatesImpl({
    MapEntry<String, String>? autoWinner,
  }) async {
    final custom = settings.aetherCustomEndpoint.trim();
    if (custom.isNotEmpty) {
      final c = _customCandidate(custom);
      logInternal(
        '→ DecisionEngine: custom endpoint → ${c.label}',
      );
      return [c];
    }

    final list = <RankedCandidate>[];
    final seen = <String>{};

    void add(RankedCandidate c) {
      if (seen.add(c.dedupeKey)) list.add(c);
    }

    if (settings.aetherTryLastEndpointFirst && autoWinner != null) {
      add(_lastRememberedCandidate(autoWinner));
    }

    // ─── منابع candidate ───
    await _addHistoryCandidates(add);
    await _addCacheCandidates(add);
    _addProfileFallbacks(add);

    // ─── مرتب‌سازی ───
    list.sort((a, b) {
      if (a.score == 0 && b.score > 0) return 1;
      if (b.score == 0 && a.score > 0) return -1;
      if (a.score != b.score) return b.score.compareTo(a.score);
      return _sourcePriority(a.source).compareTo(_sourcePriority(b.source));
    });

    _logRankedList(list);
    return list;
  }

  int _sourcePriority(CandidateSource s) {
    switch (s) {
      case CandidateSource.lastRemembered:
        return 0;
      case CandidateSource.custom:
        return 1;
      case CandidateSource.history:
        return 2;
      case CandidateSource.cache:
        return 3;
      case CandidateSource.defaultFallback:
        return 4;
    }
  }

  // ─── delegate به source builderها ───
  Future<void> _addHistoryCandidates(
    void Function(RankedCandidate) add,
  ) async {
    final builder = HistorySourceBuilder(
      engine: this,
      historyStore: historyStore,
    );
    await builder.build(add);
  }

  Future<void> _addCacheCandidates(
    void Function(RankedCandidate) add,
  ) async {
    final builder = CacheSourceBuilder(
      engine: this,
      profileStore: profileStore,
    );
    await builder.build(add);
  }

  void _addProfileFallbacks(void Function(RankedCandidate) add) {
    final builder = ProfileSourceBuilder(engine: this);
    builder.build(add);
  }

  // ─── candidates خاص ───
  RankedCandidate _lastRememberedCandidate(MapEntry<String, String> winner) =>
      RankedCandidate(
        protocol: winner.key,
        masque: winner.value,
        endpoint: '',
        score: 100,
        source: CandidateSource.lastRemembered,
        reason: 'last successful',
      );

  RankedCandidate _customCandidate(String endpoint) {
    final proto =
        settings.aetherProtocol == 'auto' ? 'masque' : settings.aetherProtocol;
    final masque =
        (proto == 'masque' || proto == 'mim') ? settings.masqueOption : '';
    return RankedCandidate(
      protocol: proto,
      masque: masque,
      endpoint: endpoint,
      score: 100,
      source: CandidateSource.custom,
      reason: 'custom endpoint',
    );
  }

  void _logRankedList(List<RankedCandidate> list) {
    logInternal(
      '→ DecisionEngine: ranked ${list.length} candidate(s)',
    );
    for (var i = 0; i < list.length; i++) {
      final c = list[i];
      final scoreStr =
          c.score == 0 ? '  —' : c.score.toStringAsFixed(0).padLeft(3);
      logInternal(
        '   ${(i + 1).toString().padLeft(2)}. [$scoreStr] '
        '${c.label.padRight(22)} (${c.source.name} · ${c.reason})',
      );
    }
  }
}
