library;

import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../services/health/tunnel_health_models.dart';
import 'mini_stat.dart';

/// ═══════════════════════════════════════════════════════════════
///  StatsWrap — Wrap آمار یک تونل.
///
///  شامل:
///    • Latency
///    • Loss
///    • Uptime
///    • Reconnects (فقط اگه > 0)
/// ═══════════════════════════════════════════════════════════════
class StatsWrap extends StatelessWidget {
  final TunnelHealthReport report;
  final ThemeData theme;

  const StatsWrap({super.key, required this.report, required this.theme});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        MiniStat(
          label: l10n.tunnelHealthLatency,
          value: '${report.latencyMs}ms',
          color: _latencyColor(report.latencyMs),
          theme: theme,
        ),
        MiniStat(
          label: l10n.tunnelHealthLoss,
          value: '${report.packetLossPct.toStringAsFixed(0)}%',
          color: _lossColor(report.packetLossPct),
          theme: theme,
        ),
        MiniStat(
          label: l10n.tunnelHealthUptime,
          value: _formatUptime(report.uptime),
          color: theme.colorScheme.primary,
          theme: theme,
        ),
        if (report.reconnectCount > 0)
          MiniStat(
            label: l10n.tunnelHealthReconnects,
            value: report.reconnectCount.toString(),
            color: Colors.orange,
            theme: theme,
          ),
      ],
    );
  }

  static Color _latencyColor(int ms) {
    if (ms < 300) return Colors.green;
    if (ms < 800) return Colors.amber;
    return Colors.red;
  }

  static Color _lossColor(double pct) {
    if (pct < 1) return Colors.green;
    if (pct < 10) return Colors.amber;
    return Colors.red;
  }

  static String _formatUptime(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    }
    if (d.inMinutes > 0) {
      return '${d.inMinutes}m';
    }
    return '${d.inSeconds}s';
  }
}
