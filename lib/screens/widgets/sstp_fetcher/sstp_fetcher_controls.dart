import 'package:flutter/material.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fetch via',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.tertiary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: fetcher.proxyMode,
          decoration: const InputDecoration(
            labelText: 'Proxy for vpngate fetch',
            isDense: true,
          ),
          items: const [
            DropdownMenuItem(
                value: 'auto', child: Text('Auto (first running proxy)')),
            DropdownMenuItem(value: 'direct', child: Text('Direct (no proxy)')),
            DropdownMenuItem(value: 'psiphon', child: Text('Psiphon')),
            DropdownMenuItem(value: 'aether', child: Text('Aether')),
            DropdownMenuItem(value: 'tor', child: Text('Tor')),
            DropdownMenuItem(value: 'sstp', child: Text('SSTP')),
          ],
          onChanged: fetcher.isLoading
              ? null
              : (v) => fetcher.setProxyMode(v ?? 'auto'),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: const Text('Auto-refresh every 15 minutes'),
          subtitle: const Text(
            'Fetches new servers and re-checks health automatically',
            style: TextStyle(fontSize: 11),
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
                label: Text(fetcher.isLoading ? 'Fetching…' : 'Fetch'),
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
                icon: Icon(fetcher.isHealthChecking
                    ? Icons.stop
                    : Icons.network_check),
                label: Text(fetcher.isHealthChecking
                    ? 'Stop (${fetcher.healthProgressDone}/${fetcher.healthProgressTotal})'
                    : 'Check health'),
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
