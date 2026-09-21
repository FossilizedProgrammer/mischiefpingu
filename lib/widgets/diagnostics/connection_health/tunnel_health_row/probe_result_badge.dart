library;

import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../tunnel_probe_result.dart';

/// ═══════════════════════════════════════════════════════════════
///  ProbeResultBadge — badge نمایش نتیجه آخرین probe.
///
///  موفق: last probe OK (XXms)
///  ناموفق: last probe failed (reason)
/// ═══════════════════════════════════════════════════════════════
class ProbeResultBadge extends StatelessWidget {
  final TunnelProbeResult result;
  final ThemeData theme;
  final AppLocalizations l10n;

  const ProbeResultBadge({
    super.key,
    required this.result,
    required this.theme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final color = result.success ? Colors.green : Colors.red;
    final icon = result.success ? Icons.check : Icons.close;
    final text = result.success
        ? l10n.tunnelHealthLastProbeOk(result.latencyMs)
        : l10n.tunnelHealthLastProbeFailed(result.error ?? 'unknown');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
