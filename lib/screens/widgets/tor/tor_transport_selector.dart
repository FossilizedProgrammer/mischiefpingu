import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class TorTransportSelector extends StatelessWidget {
  final String transportLabel;
  final String torTransport;
  final ValueChanged<String?> onTransportChanged;

  const TorTransportSelector({
    super.key,
    required this.transportLabel,
    required this.torTransport,
    required this.onTransportChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DropdownButtonFormField<String>(
      key: ValueKey('tor-transport:$torTransport'),
      initialValue: torTransport,
      decoration: InputDecoration(labelText: transportLabel, isDense: true),
      items: [
        DropdownMenuItem(value: 'direct', child: Text(l10n.torDirect)),
        DropdownMenuItem(value: 'bridge', child: Text(l10n.torBridge)),
        DropdownMenuItem(value: 'aether', child: Text(l10n.torViaAether)),
        DropdownMenuItem(value: 'psiphon', child: Text(l10n.torViaPsiphon)),
        DropdownMenuItem(value: 'sstp', child: Text(l10n.torViaSstp)),
      ],
      onChanged: onTransportChanged,
    );
  }
}
