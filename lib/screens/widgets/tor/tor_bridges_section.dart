import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          l10n.bridgePresets,
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
              onPressed: () => _applyPreset(TorBridges.obfs4Public.join('\n')),
              child: const Text('obfs4 (public)'),
            ),
            TextButton(onPressed: _clearBridges, child: Text(l10n.clear)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _bridgesController,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: l10n.bridges,
            hintText: l10n.bridgesHint,
            alignLabelWithHint: true,
          ),
          onChanged: (v) {
            final provider = context.read<AppProvider>();
            provider.settings.torBridges = v;
            provider.saveSettings();
            widget.onBridgesChanged(v);
          },
        ),
      ],
    );
  }
}
