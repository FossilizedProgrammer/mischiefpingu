// lib/widgets/aether/aether_connection_mode_section.dart
//
// ═══════════════════════════════════════════════════════════════
//  بخش Connection Mode + Custom Endpoint کارت Aether
//  (تفکیک شده از aether_protocol_card.dart)
// ═══════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class AetherConnectionModeSection extends StatelessWidget {
  final bool isRunning;

  const AetherConnectionModeSection({
    super.key,
    required this.isRunning,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final s = provider.settings;
    final theme = Theme.of(context);

    void save() {
      provider.saveSettings();
      provider.touch();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connection Mode',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: const Text('Try last successful endpoint first'),
          subtitle: const Text(
            'If enabled, will try the last working endpoint before scanning',
            style: TextStyle(fontSize: 11),
          ),
          value: s.aetherTryLastEndpointFirst,
          onChanged: isRunning
              ? null
              : (v) {
                  s.aetherTryLastEndpointFirst = v;
                  save();
                },
        ),
        const SizedBox(height: 12),
        Text(
          'Custom Endpoint (optional)',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'If set, will connect directly to this endpoint without scanning',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: s.aetherCustomEndpoint,
          decoration: const InputDecoration(
            labelText: 'Endpoint (e.g., 1.2.3.4:2408)',
            border: InputBorder.none,
            hintText: 'Leave empty for auto-scan',
          ),
          enabled: !isRunning,
          onChanged: (v) {
            s.aetherCustomEndpoint = v.trim();
            save();
          },
        ),
      ],
    );
  }
}
