// lib/screens/widgets/sstp_fetcher/sstp_server_tile.dart
import 'package:flutter/material.dart';
import '../../../services/sstp_health_checker.dart';
import '../../../services/vpngate_scraper_service.dart';
import 'sstp_country_helpers.dart';
import 'sstp_health_helpers.dart';

/// ═══════════════════════════════════════════════════════════════
///  یک ردیف سرور SSTP در لیست
/// ═══════════════════════════════════════════════════════════════
class SstpServerTile extends StatelessWidget {
  final SstpServer server;
  final bool isCurrent;
  final SstpHealthResult health;
  final VoidCallback onApply;
  final Future<void> Function(String text, String label) onCopy;

  const SstpServerTile({
    super.key,
    required this.server,
    required this.isCurrent,
    required this.health,
    required this.onApply,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final h = health.status;
    final color = SstpHealthHelpers.color(h, theme);
    final badgeColor =
        SstpCountryHelpers.badgeColor(server.countryShort, theme);
    final hasCountry =
        server.country.isNotEmpty || server.countryShort.isNotEmpty;

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: CircleAvatar(
        radius: 14,
        backgroundColor:
            isCurrent ? Colors.green.withValues(alpha: 0.25) : color.withValues(alpha: 0.15),
        child: Icon(
          isCurrent ? Icons.check_circle : SstpHealthHelpers.icon(h),
          size: 16,
          color: isCurrent ? Colors.green : color,
        ),
      ),
      title: Row(
        children: [
          if (hasCountry) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: badgeColor.withValues(alpha: 0.45),
                  width: 0.8,
                ),
              ),
              child: Text(
                SstpCountryHelpers.shortName(
                    server.country, server.countryShort),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: badgeColor,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              '${server.ip}:${server.port}',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          _subtitle(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 10,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            tooltip: 'Copy ip:port',
            visualDensity: VisualDensity.compact,
            onPressed: () =>
                onCopy('${server.ip}:${server.port}', 'Server'),
          ),
          if (isCurrent)
            const Icon(Icons.check_circle, color: Colors.green, size: 20)
          else
            IconButton(
              icon: const Icon(Icons.play_arrow),
              tooltip: 'Use this server',
              visualDensity: VisualDensity.compact,
              onPressed: onApply,
            ),
        ],
      ),
      onTap: onApply,
    );
  }

  String _subtitle() {
    final h = health;
    return [
      if (h.status == SstpHealth.alive) '${h.latencyMs}ms',
      if (h.status == SstpHealth.tcpOnly)
        'tcp open${h.latencyMs > 0 ? " ${h.latencyMs}ms" : ""}',
      if (h.status == SstpHealth.dead) 'dead',
      if (h.status == SstpHealth.unknown) 'untested',
      if (server.ping > 0) 'ping ${server.ping}ms',
      if (server.speed > 0) '${server.speed} Mbps',
      if (server.operator.isNotEmpty) server.operator,
    ].join(' · ');
  }
}
