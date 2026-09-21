import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../providers/sstp_fetcher_provider.dart';

class SstpFetcherControls extends StatelessWidget {
  final SstpFetcherProvider fetcher;
  final ThemeData theme;

  const SstpFetcherControls({
    super.key,
    required this.fetcher,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.fetchVia,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.tertiary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: fetcher.proxyMode,
          decoration: InputDecoration(labelText: l10n.fetchVia, isDense: true),
          items: [
            DropdownMenuItem(
              value: 'auto',
              child: Text(l10n.autoFirstRunningProxy),
            ),
            DropdownMenuItem(value: 'direct', child: Text(l10n.directNoProxy)),
            const DropdownMenuItem(value: 'psiphon', child: Text('Psiphon')),
            const DropdownMenuItem(value: 'aether', child: Text('Aether')),
            const DropdownMenuItem(value: 'tor', child: Text('Tor')),
            const DropdownMenuItem(value: 'sstp', child: Text('SSTP')),
          ],
          onChanged: fetcher.isLoading
              ? null
              : (v) => fetcher.setProxyMode(v ?? 'auto'),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text(l10n.autoRefresh15Min),
          subtitle: Text(
            l10n.autoRefreshSubtitle,
            style: const TextStyle(fontSize: 11),
          ),
          value: fetcher.autoRefresh,
          onChanged: fetcher.setAutoRefresh,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: fetcher.isLoading ? null : fetcher.fetchNow,
                icon: fetcher.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download),
                label: Text(fetcher.isLoading ? l10n.fetching : l10n.fetch),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: fetcher.servers.isEmpty
                    ? null
                    : (fetcher.isHealthChecking
                          ? fetcher.cancelHealthCheck
                          : fetcher.checkAllHealth),
                icon: Icon(
                  fetcher.isHealthChecking ? Icons.stop : Icons.network_check,
                ),
                label: Text(
                  fetcher.isHealthChecking
                      ? '${l10n.stopHealthCheck} (${fetcher.healthProgressDone}/${fetcher.healthProgressTotal})'
                      : l10n.checkHealth,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: fetcher.isHealthChecking
                      ? Colors.red
                      : theme.colorScheme.tertiary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        if (fetcher.isHealthChecking) ...[
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: fetcher.healthProgressTotal == 0
                ? null
                : fetcher.healthProgressDone / fetcher.healthProgressTotal,
          ),
        ],
      ],
    );
  }
}
