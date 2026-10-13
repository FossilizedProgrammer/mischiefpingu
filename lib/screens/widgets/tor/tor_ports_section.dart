import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../widgets/settings/port_text_field.dart';

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
          child: PortTextField(
            labelText: l10n.socksPort,
            initialValue: torSocksPort.toString(),
            onChanged: onSocksPortChanged,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: PortTextField(
            labelText: l10n.httpPort,
            initialValue: torHttpPort.toString(),
            onChanged: onHttpPortChanged,
          ),
        ),
      ],
    );
  }
}
