// lib/providers/sstp_fetcher/sstp_fetcher_health.dart
part of '../sstp_fetcher_provider.dart';

extension SstpFetcherHealth on SstpFetcherProvider {
  List<SstpServer> get visibleServers {
    final list = List<SstpServer>.from(servers);

    list.sort((a, b) {
      final ha = health[a.key];
      final hb = health[b.key];
      final sa = rank(ha);
      final sb = rank(hb);
      if (sa != sb) return sa.compareTo(sb);
      final la = ha?.latencyMs ?? 9999;
      final lb = hb?.latencyMs ?? 9999;
      if (la != lb) return la.compareTo(lb);
      return a.ping.compareTo(b.ping);
    });
    return list;
  }

  int rank(SstpHealthResult? h) {
    switch (h?.status) {
      case SstpHealth.alive:
        return 0;
      case SstpHealth.tcpOnly:
        return 1;
      case SstpHealth.unknown:
        return 2;
      case SstpHealth.checking:
        return 3;
      case SstpHealth.dead:
        return 4;
      default:
        return 2;
    }
  }

  Future<void> checkAllHealth({int concurrency = 20}) async {
    if (isHealthChecking) return;
    if (servers.isEmpty) return;

    isHealthChecking = true;
    cancelHealth = false;
    healthProgressDone = 0;
    healthProgressTotal = servers.length;

    for (final s in servers) {
      health[s.key] = const SstpHealthResult(
        status: SstpHealth.checking,
        latencyMs: 0,
        message: 'checking…',
      );
    }
    touch();

    final queue = List<SstpServer>.from(servers);
    var next = 0;

    Future<void> worker() async {
      while (!cancelHealth) {
        final idx = next++;
        if (idx >= queue.length) return;
        final s = queue[idx];
        try {
          final r = await _healthChecker.check(s.ip, s.port);
          health[s.key] = r;
        } catch (e) {
          health[s.key] = SstpHealthResult(
            status: SstpHealth.dead,
            latencyMs: 0,
            message: shortErr(e),
          );
        }
        healthProgressDone++;
        if (healthProgressDone % 3 == 0 ||
            healthProgressDone == healthProgressTotal) {
          touch();
        }
      }
    }

    final n = concurrency.clamp(1, 60);
    await Future.wait(List.generate(n, (_) => worker()));

    isHealthChecking = false;
    final alive = aliveCount;
    status = '$alive alive / ${servers.length} total';
    processService.addLog(
      '★ SSTP health check done: $status',
      source: 'SstpHealth',
    );
    touch();
  }

  void cancelHealthCheck() {
    if (!isHealthChecking) return;
    cancelHealth = true;
    isHealthChecking = false;
    status = 'Health check cancelled';
    touch();
  }

  String shortErr(Object e) {
    final s = e.toString();
    return s.length > 80 ? '${s.substring(0, 80)}…' : s;
  }
}
