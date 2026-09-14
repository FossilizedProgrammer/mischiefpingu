// lib/screens/widgets/tor/tor_bridges_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_provider.dart';
import '../../../services/tor_bridges.dart';

class TorBridgesSection extends StatefulWidget {
  final ThemeData theme;
  final String torTransport;
  final String torBridges;
  final ValueChanged<String> onBridgesChanged;
  final ValueChanged<String?> onTransportChanged;

  const TorBridgesSection({
    super.key,
    required this.theme,
    required this.torTransport,
    required this.torBridges,
    required this.onBridgesChanged,
    required this.onTransportChanged,
  });

  @override
  State<TorBridgesSection> createState() => _TorBridgesSectionState();
}

class _TorBridgesSectionState extends State<TorBridgesSection> {
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

  String get _hintText {
    switch (widget.torTransport) {
      case 'aether':
        return 'Empty = plain Tor-over-Aether. Filled = bridges dial through Aether (TOR_PT_PROXY).';
      case 'psiphon':
        return 'Empty = plain Tor-over-Psiphon. Filled = bridges dial through Psiphon (TOR_PT_PROXY).';
      case 'sstp':
        return 'Empty = plain Tor-over-SSTP. Filled = bridges dial through SSTP (TOR_PT_PROXY).';
      default:
        return 'Paste obfs4 / snowflake / meek / webtunnel / conjure lines. Empty = direct Tor.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          _hintText,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
