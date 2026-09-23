part of '../aether_attempts.dart';

/// ═══════════════════════════════════════════════════════════════
///  LEGACY FALLBACK — فقط وقتی DecisionEngine در دسترس نباشه.
/// ═══════════════════════════════════════════════════════════════
extension AetherAttemptPlannerLegacy on AetherAttemptPlanner {
  Future<List<EndpointAttempt>> legacyBuild(
    MapEntry<String, String>? autoWinner,
  ) async {
    final list = <EndpointAttempt>[];
    final seen = <String>{};

    void add(EndpointAttempt a) {
      if (seen.add(a.dedupeKey)) list.add(a);
    }

    // 1. Custom endpoint
    final custom = settings.aetherCustomEndpoint.trim();
    if (custom.isNotEmpty) {
      final proto = resolveProtocolForEndpoint(
        settings.isAetherProfileAutomatic ? 'auto' : settings.aetherProtocol,
        custom,
      );
      final masque =
          (proto == 'masque' || proto == 'mim') ? settings.masqueOption : '';
      add(
        EndpointAttempt(
          label: 'Custom Endpoint ($custom)',
          protocol: proto,
          masque: masque,
          endpoint: custom,
        ),
      );
      return list;
    }

    // 2. Last winner
    if (settings.aetherTryLastEndpointFirst && autoWinner != null) {
      add(
        EndpointAttempt(
          label: 'Last remembered (${autoWinner.key})',
          protocol: autoWinner.key,
          masque: autoWinner.value,
          endpoint: '',
          fromHistory: true,
        ),
      );
    }

    // 3. History
    await _addHistoricalCandidates(add);

    // 4. Cache
    await _addProfilePerformanceCandidates(add);

    // 5. Profile
    if (settings.isAetherProfileAutomatic) {
      _addProfileCandidates(add);
    } else {
      _addManualCandidate(add);
    }

    return list;
  }

  Future<void> _addHistoricalCandidates(
    void Function(EndpointAttempt) add,
  ) async {
    final store = historyStore;
    if (store == null) return;
    try {
      final top = await store.getTopGateways(limit: 5, minScore: 20.0);
      for (final r in top) {
        add(
          EndpointAttempt(
            label: AetherAttemptPlanner.labelForGateway(r),
            protocol: r.protocol,
            masque: r.masqueOption,
            endpoint: r.endpoint,
            historicalScore: r.score,
            fromHistory: true,
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> _addProfilePerformanceCandidates(
    void Function(EndpointAttempt) add,
  ) async {
    final store = profileStore;
    if (store == null) return;
    if (!settings.isAetherProfileAutomatic) return;

    try {
      final best = await store.bestProtocols(
        profile: settings.aetherProfile,
        networkType: settings.ipType,
        limit: 3,
      );
      for (final b in best) {
        if (b.rate < 0.5) continue;
        add(
          EndpointAttempt(
            label: AetherAttemptPlanner.labelForProfilePerf(
              protocol: b.protocol,
              masque: b.masque,
              rate: b.rate,
            ),
            protocol: b.protocol,
            masque: b.masque,
            endpoint: '',
            historicalScore: b.rate * 100,
            fromHistory: true,
            fromProfileCache: true,
          ),
        );
      }
    } catch (_) {}
  }

  void _addProfileCandidates(void Function(EndpointAttempt) add) {
    final profile = settings.activeAetherProfile;
    final candidates = profile?.candidates ?? const <ProfileCandidate>[];

    if (candidates.isEmpty) {
      for (final c in const [
        ProfileCandidate(protocol: 'masque', masque: 'HTTP-3'),
        ProfileCandidate(protocol: 'masque', masque: 'HTTP-2'),
        ProfileCandidate(protocol: 'wireguard'),
        ProfileCandidate(protocol: 'gool'),
      ]) {
        add(
          EndpointAttempt(
            label: AetherAttemptPlanner.labelFor(c),
            protocol: c.protocol,
            masque: c.masque,
            endpoint: '',
            fragmentH2: c.fragmentH2,
          ),
        );
      }
      return;
    }

    for (final c in candidates) {
      add(
        EndpointAttempt(
          label: AetherAttemptPlanner.labelFor(c),
          protocol: c.protocol,
          masque: c.masque,
          endpoint: '',
          fragmentH2: c.fragmentH2,
        ),
      );
    }
  }

  void _addManualCandidate(void Function(EndpointAttempt) add) {
    final proto = settings.aetherProtocol;
    final masque =
        (proto == 'masque' || proto == 'mim') ? settings.masqueOption : '';
    final frag = settings.aetherProfile == 'strict' && masque == 'HTTP-2';
    add(
      EndpointAttempt(
        label: AetherAttemptPlanner.labelFor(
          ProfileCandidate(protocol: proto, masque: masque, fragmentH2: frag),
        ),
        protocol: proto,
        masque: masque,
        endpoint: '',
        fragmentH2: frag,
      ),
    );
  }
}
