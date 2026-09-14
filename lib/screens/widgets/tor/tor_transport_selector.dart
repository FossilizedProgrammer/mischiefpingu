// lib/screens/widgets/tor/tor_transport_selector.dart
import 'package:flutter/material.dart';

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
    return DropdownButtonFormField<String>(
      key: ValueKey('tor-transport:$torTransport'),
      initialValue: torTransport,
      decoration: InputDecoration(
        labelText: transportLabel,
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
    );
  }
}
