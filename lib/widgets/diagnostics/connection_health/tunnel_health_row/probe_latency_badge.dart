library;

import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════
///  ProbeLatencyBadge — badge نمایش latency آخرین probe.
///
///  وقتی report معتبر نداریم ولی probe موفق داشتیم، latency
///  رو به این شکل نشون می‌دیم.
/// ═══════════════════════════════════════════════════════════════
class ProbeLatencyBadge extends StatelessWidget {
  final int latencyMs;

  const ProbeLatencyBadge({super.key, required this.latencyMs});

  @override
  Widget build(BuildContext context) {
    final color = _latencyColor(latencyMs);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        '${latencyMs}ms',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  static Color _latencyColor(int ms) {
    if (ms < 300) return Colors.green;
    if (ms < 800) return Colors.amber;
    return Colors.red;
  }
}
