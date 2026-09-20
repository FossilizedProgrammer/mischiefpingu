library;

import 'package:flutter/material.dart';

import '../../../services/aether/performance_sample.dart';

/// ═══════════════════════════════════════════════════════════════
///  ردیف سه باکس: Latency / Jitter / Loss.
/// ═══════════════════════════════════════════════════════════════
class AetherMetricsRow extends StatelessWidget {
  final PerformanceReport report;
  final ThemeData theme;

  const AetherMetricsRow({
    super.key,
    required this.report,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricBox(
            label: 'Latency',
            value: '${report.avgLatencyMs}ms',
            color: _latencyColor(report.avgLatencyMs),
            theme: theme,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricBox(
            label: 'Jitter',
            value: '${report.jitterMs}ms',
            color: _jitterColor(report.jitterMs),
            theme: theme,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricBox(
            label: 'Loss',
            value: '${report.packetLossPct.toStringAsFixed(1)}%',
            color: _lossColor(report.packetLossPct),
            theme: theme,
          ),
        ),
      ],
    );
  }

  static Color _latencyColor(int ms) {
    if (ms < 300) return Colors.green;
    if (ms < 800) return Colors.amber;
    return Colors.red;
  }

  static Color _jitterColor(int ms) {
    if (ms < 50) return Colors.green;
    if (ms < 150) return Colors.amber;
    return Colors.red;
  }

  static Color _lossColor(double pct) {
    if (pct < 1) return Colors.green;
    if (pct < 10) return Colors.amber;
    return Colors.red;
  }
}

class _MetricBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final ThemeData theme;

  const _MetricBox({
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
