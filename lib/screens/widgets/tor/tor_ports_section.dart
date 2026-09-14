// lib/screens/widgets/tor/tor_ports_section.dart
import 'package:flutter/material.dart';

class TorPortsSection extends StatelessWidget {
  final int torSocksPort;
  final ValueChanged<String> onSocksPortChanged;
  final int torHttpPort;
  final ValueChanged<String> onHttpPortChanged;

  const TorPortsSection({
    super.key,
    required this.torSocksPort,
    required this.onSocksPortChanged,
    required this.torHttpPort,
    required this.onHttpPortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}
