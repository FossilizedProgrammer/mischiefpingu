import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_provider.dart';
import '../../../services/tor_bridges.dart';

class TorTransportTile extends StatefulWidget {
  final ThemeData theme;
  final String transportLabel;
  final String torTransport;
  final ValueChanged<String?> onTransportChanged;
  final String torBridges;
  final ValueChanged<String> onBridgesChanged;
  final String torExitCountry;
  final ValueChanged<String?> onExitCountryChanged;
  final int torSocksPort;
  final ValueChanged<String> onSocksPortChanged;
  final int torHttpPort;
  final ValueChanged<String> onHttpPortChanged;
  final List<String> torExitCountries;
  final bool torShareLan;
  final ValueChanged<bool> onShareLanChanged;
  final bool autoReconnectTor;
  final ValueChanged<bool> onAutoReconnectChanged;

  const TorTransportTile({
    super.key,
    required this.theme,
    required this.transportLabel,
    required this.torTransport,
    required this.onTransportChanged,
    required this.torBridges,
    required this.onBridgesChanged,
    required this.torExitCountry,
    required this.onExitCountryChanged,
    required this.torSocksPort,
    required this.onSocksPortChanged,
    required this.torHttpPort,
    required this.onHttpPortChanged,
    required this.torExitCountries,
    required this.torShareLan,
    required this.onShareLanChanged,
    required this.autoReconnectTor,
    required this.onAutoReconnectChanged,
  });

  @override
  State<TorTransportTile> createState() => _TorTransportTileState();
}

class _TorTransportTileState extends State<TorTransportTile> {
  late final TextEditingController _bridgesController;

  @override
  void initState() {
    super.initState();
    _bridgesController = TextEditingController(text: widget.torBridges);
  }

  @override
  void dispose() {
    _bridgesController.dispose();
    super.dispose();
  }

  void _applyPreset(String bridges) {
    widget.onTransportChanged('bridge');
    widget.onBridgesChanged(bridges);
    setState(() {
      _bridgesController.text = bridges;
    });
    context.read<AppProvider>().touch();
  }

  void _clearBridges() {
    widget.onBridgesChanged('');
    setState(() {
      _bridgesController.clear();
    });
    context.read<AppProvider>().touch();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final torTransport = widget.torTransport;
    final onTransportChanged = widget.onTransportChanged;
    final torExitCountry = widget.torExitCountry;
    final onExitCountryChanged = widget.onExitCountryChanged;
    final torSocksPort = widget.torSocksPort;
    final onSocksPortChanged = widget.onSocksPortChanged;
    final torHttpPort = widget.torHttpPort;
    final onHttpPortChanged = widget.onHttpPortChanged;
    final torExitCountries = widget.torExitCountries;
    final torShareLan = widget.torShareLan;
    final onShareLanChanged = widget.onShareLanChanged;
    final autoReconnectTor = widget.autoReconnectTor;
    final onAutoReconnectChanged = widget.onAutoReconnectChanged;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          key: ValueKey('tor-transport:$torTransport'),
          initialValue: torTransport,
          decoration: const InputDecoration(
            labelText: 'Tor connection',
            isDense: true,
          ),
          items: const [
            DropdownMenuItem(
              value: 'direct',
              child: Text('Direct (no bridge, no upstream) — default'),
            ),
            DropdownMenuItem(
              value: 'bridge',
              child: Text('Bridge (obfs4 / snowflake / custom)'),
            ),
            DropdownMenuItem(
              value: 'aether',
              child: Text('Via Aether (Tor-over-Aether)'),
            ),
            DropdownMenuItem(
              value: 'psiphon',
              child: Text('Via Psiphon (Tor-over-Psiphon)'),
            ),
            DropdownMenuItem(
              value: 'sstp',
              child: Text('Via SSTP (Tor-over-SSTP)'),
            ),
          ],
          onChanged: onTransportChanged,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: torSocksPort.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'SOCKS port',
                  isDense: true,
                ),
                onChanged: onSocksPortChanged,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                initialValue: torHttpPort.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'HTTP port',
                  isDense: true,
                ),
                onChanged: onHttpPortChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          key: ValueKey(
              'tor-exit:${torExitCountry.isEmpty ? '' : torExitCountry.toUpperCase()}'),
          initialValue:
              torExitCountry.isEmpty ? '' : torExitCountry.toUpperCase(),
          decoration: const InputDecoration(
            labelText: 'Exit country',
            isDense: true,
          ),
          items: torExitCountries
              .map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c.isEmpty ? 'Any (random)' : c),
                  ))
              .toList(),
          onChanged: onExitCountryChanged,
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: const Text('Share on LAN (bind 0.0.0.0)'),
          value: torShareLan,
          onChanged: onShareLanChanged,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: const Text('Auto-reconnect Tor'),
          value: autoReconnectTor,
          onChanged: onAutoReconnectChanged,
        ),
        const Divider(height: 28),
        if (torTransport != 'direct') ...[
          const SizedBox(height: 12),
          Text(
            'Bridge presets (optional)',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => _applyPreset(TorBridges.meekCdn77),
                child: const Text('Meek'),
              ),
              OutlinedButton(
                onPressed: () => _applyPreset(TorBridges.snowflakeCdn77),
                child: const Text('Snowflake'),
              ),
              OutlinedButton(
                onPressed: () => _applyPreset(TorBridges.obfs4Iat.join('\n')),
                child: const Text('obfs4 (anti-timing)'),
              ),
              OutlinedButton(
                onPressed: () =>
                    _applyPreset(TorBridges.obfs4Public.join('\n')),
                child: const Text('obfs4 (public)'),
              ),
              TextButton(
                onPressed: _clearBridges,
                child: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _bridgesController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText:
                  'Bridges (one per line, custom supported — incl. webtunnel)',
              hintText: 'obfs4 1.2.3.4:443 FINGERPRINT cert=... iat-mode=0',
              alignLabelWithHint: true,
            ),
            onChanged: (v) {
              final provider = context.read<AppProvider>();
              provider.settings.torBridges = v;
              provider.saveSettings();
              widget.onBridgesChanged(v);
            },
          ),
          const SizedBox(height: 4),
          Text(
            torTransport == 'aether'
                ? 'Empty = plain Tor-over-Aether. Filled = bridges dial through Aether (TOR_PT_PROXY).'
                : torTransport == 'psiphon'
                    ? 'Empty = plain Tor-over-Psiphon. Filled = bridges dial through Psiphon (TOR_PT_PROXY).'
                    : torTransport == 'sstp'
                        ? 'Empty = plain Tor-over-SSTP. Filled = bridges dial through SSTP (TOR_PT_PROXY).'
                        : 'Paste obfs4 / snowflake / meek / webtunnel / conjure lines. Empty = direct Tor.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ] else ...[
          const SizedBox(height: 8),
          Text(
            'Direct Tor with no bridges and no upstream.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
