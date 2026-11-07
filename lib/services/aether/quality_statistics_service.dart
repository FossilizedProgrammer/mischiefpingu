library;

import '../../services/database/aether_event_store.dart';
import '../../models/aether_event.dart';

/// ═══════════════════════════════════════════════════════════════
///  QualityStatisticsService — گزارش آماری داخلی.
///
///  برای دیباگ و تحلیل عملکرد استفاده می‌شود.
///  داده‌ها از aether_events استخراج می‌شوند.
/// ═══════════════════════════════════════════════════════════════
class QualityStatisticsService {
  final AetherEventStore eventStore;
  final void Function(String message, {String source}) log;

  QualityStatisticsService({required this.eventStore, required this.log});

  /// گزارش 24 ساعت اخیر به تفکیک پروتکل.
  Future<ProtocolStats> computeLast24h() async {
    final events = await eventStore.recent(limit: 2000);
    return _compute(events, const Duration(hours: 24));
  }

  /// گزارش 7 روز اخیر.
  Future<ProtocolStats> computeLast7d() async {
    final events = await eventStore.recent(limit: 5000);
    return _compute(events, const Duration(days: 7));
  }

  ProtocolStats _compute(List<AetherEvent> events, Duration window) {
    final cutoff = DateTime.now().subtract(window).millisecondsSinceEpoch;

    // ─── گروه‌بندی بر اساس protocol ───
    final byProtocol = <String, List<AetherEvent>>{};
    for (final e in events) {
      if (e.timestamp.millisecondsSinceEpoch < cutoff) continue;
      if (e.eventType != AetherEventType.connectionSuccess &&
          e.eventType != AetherEventType.connectionFailed) {
        continue;
      }
      byProtocol.putIfAbsent(e.protocol, () => []).add(e);
    }

    final stats = <String, ProtocolStat>{};
    for (final entry in byProtocol.entries) {
      final proto = entry.key;
      final list = entry.value;

      final successes = list
          .where((e) => e.eventType == AetherEventType.connectionSuccess)
          .toList();
      final failures = list
          .where((e) => e.eventType == AetherEventType.connectionFailed)
          .toList();

      final total = list.length;
      final successRate = total == 0 ? 0.0 : successes.length / total;

      final latencies = successes
          .where((e) => e.latencyMs > 0)
          .map((e) => e.latencyMs)
          .toList();
      final avgLatency = latencies.isEmpty
          ? 0
          : (latencies.reduce((a, b) => a + b) / latencies.length).round();

      stats[proto] = ProtocolStat(
        protocol: proto,
        totalAttempts: total,
        successCount: successes.length,
        failureCount: failures.length,
        successRate: successRate,
        avgLatencyMs: avgLatency,
      );
    }

    return ProtocolStats(
      window: window,
      computedAt: DateTime.now(),
      byProtocol: stats,
    );
  }

  /// تولید یک رشتهٔ متنی زیبا برای نمایش در لاگ.
  String formatReport(ProtocolStats stats) {
    if (stats.byProtocol.isEmpty) {
      return 'No statistics available yet.';
    }

    final buffer = StringBuffer();
    buffer.writeln('═══ Performance Report ═══');
    buffer.writeln('Window: last ${_formatWindow(stats.window)}');
    buffer.writeln('');

    final sorted = stats.byProtocol.values.toList()
      ..sort((a, b) => b.successRate.compareTo(a.successRate));

    for (final s in sorted) {
      buffer.writeln('${s.protocol.toUpperCase()}:');
      buffer.writeln(
        '  Success: ${(s.successRate * 100).toStringAsFixed(1)}% '
        '(${s.successCount}/${s.totalAttempts})',
      );
      buffer.writeln('  Avg latency: ${s.avgLatencyMs}ms');
      buffer.writeln('');
    }

    return buffer.toString();
  }

  String _formatWindow(Duration d) {
    if (d.inDays >= 1) return '${d.inDays}d';
    if (d.inHours >= 1) return '${d.inHours}h';
    return '${d.inMinutes}min';
  }
}

class ProtocolStats {
  final Duration window;
  final DateTime computedAt;
  final Map<String, ProtocolStat> byProtocol;

  const ProtocolStats({
    required this.window,
    required this.computedAt,
    required this.byProtocol,
  });
}

class ProtocolStat {
  final String protocol;
  final int totalAttempts;
  final int successCount;
  final int failureCount;
  final double successRate;
  final int avgLatencyMs;

  const ProtocolStat({
    required this.protocol,
    required this.totalAttempts,
    required this.successCount,
    required this.failureCount,
    required this.successRate,
    required this.avgLatencyMs,
  });
}
