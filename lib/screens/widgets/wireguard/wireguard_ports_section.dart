import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';

class WireGuardPortsSection extends StatefulWidget {
  final ThemeData theme;
  final AppLocalizations l10n;
  final int socksPort;
  final ValueChanged<int> onSocksPortChanged;

  const WireGuardPortsSection({
    super.key,
    required this.theme,
    required this.l10n,
    required this.socksPort,
    required this.onSocksPortChanged,
  });

  @override
  State<WireGuardPortsSection> createState() => _WireGuardPortsSectionState();
}

class _WireGuardPortsSectionState extends State<WireGuardPortsSection> {
  late final TextEditingController _controller;

  // ═══════════════════════════════════════════════════════════
  //  🆕 debounce
  // ═══════════════════════════════════════════════════════════
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.socksPort.toString());
  }

  // ═══════════════════════════════════════════════════════════
  //  🆕 sync با parent اگه مقدار عوض شد
  // ═══════════════════════════════════════════════════════════
  @override
  void didUpdateWidget(covariant WireGuardPortsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.socksPort != widget.socksPort) {
      final current = int.tryParse(_controller.text.trim());
      if (current != widget.socksPort) {
        _controller.text = widget.socksPort.toString();
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    final p = int.tryParse(v.trim());
    if (p == null || p < 1 || p > 65535) return;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) widget.onSocksPortChanged(p);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final l10n = widget.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.localProxyPorts,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: l10n.socksPort,
            isDense: true,
          ),
          onChanged: _onChanged,
        ),
      ],
    );
  }
}
