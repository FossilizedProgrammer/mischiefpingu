library;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/health/tunnel_health_models.dart';
import 'health_helpers.dart';
import 'health_stat.dart';

/// ═══════════════════════════════════════════════════════════════
///  HealthStats — ردیف آمار سلامت.
///
///  شامل: Latency, Jitter, Loss, Trend, Uptime, Reconnects
///  + فیلدهای اختصاصی هر تونل (از `extra`).
/// ═══════════════════════════════════════════════════════════════
class HealthStats extends StatelessWidget {
  final TunnelHealthReport report;
  final ThemeData theme;

  const HealthStats({super.key, required this.report, required this.theme});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        HealthStat(
          label: l10n.tunnelHealthLatency,
          value: '${report.latencyMs}ms',
          color: HealthHelpers.latencyColor(report.latencyMs),
        ),
        HealthStat(
          label: l10n.tunnelHealthJitter,
          value: '${report.jitterMs}ms',
          color: HealthHelpers.jitterColor(report.jitterMs),
        ),
        HealthStat(
          label: l10n.tunnelHealthLoss,
          value: '${report.packetLossPct.toStringAsFixed(1)}%',
          color: HealthHelpers.lossColor(report.packetLossPct),
        ),
        HealthStat(
          label: l10n.tunnelHealthTrend,
          value: report.trend.label,
          color: HealthHelpers.trendColor(report.trend),
        ),
        HealthStat(
          label: l10n.tunnelHealthUptime,
          value: HealthHelpers.formatDuration(report.uptime),
          color: theme.colorScheme.primary,
        ),
        if (report.reconnectCount > 0)
          HealthStat(
            label: l10n.tunnelHealthReconnects,
            value: '${report.reconnectCount}',
            color: Colors.orange,
          ),
        ..._buildExtraStats(l10n),
      ],
    );
  }

  List<Widget> _buildExtraStats(AppLocalizations l10n) {
    final extras = <Widget>[];

    // ─── Psiphon ───
    final protocol = report.extra['protocol'];
    if (protocol is String && protocol.isNotEmpty && protocol != 'unknown') {
      extras.add(
        HealthStat(
          label: l10n.tunnelHealthProtocol,
          value: protocol,
          color: Colors.blue,
        ),
      );
    }

    final bytesPerSec = report.extra['bytesPerSec'];
    if (bytesPerSec is int && bytesPerSec > 0) {
      extras.add(
        HealthStat(
          label: l10n.tunnelHealthThroughput,
          value: '${HealthHelpers.formatBytes(bytesPerSec)}/s',
          color: Colors.green,
        ),
      );
    }

    // ─── Tor ───
    final circuitCount = report.extra['circuitsEstablished'];
    if (circuitCount is int && circuitCount > 0) {
      extras.add(
        HealthStat(
          label: l10n.tunnelHealthCircuits,
          value: '$circuitCount',
          color: Colors.purple,
        ),
      );
    }

    // ─── SSTP ───
    final assignedIp = report.extra['assignedIp'];
    if (assignedIp is String && assignedIp.isNotEmpty) {
      extras.add(
        HealthStat(
          label: l10n.tunnelHealthIp,
          value: assignedIp,
          color: Colors.teal,
        ),
      );
    }

    return extras;
  }
}
