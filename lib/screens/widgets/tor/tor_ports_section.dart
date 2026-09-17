import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            initialValue: torSocksPort.toString(),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.socksPort,
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
            decoration: InputDecoration(
              labelText: l10n.httpPort,
              isDense: true,
            ),
            onChanged: onHttpPortChanged,
          ),
        ),
      ],
    );
  }
}
