import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/aether_protocol_card.dart';

class AetherSettingsTile extends StatelessWidget {
  const AetherSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final s = provider.settings;
    final theme = Theme.of(context);

    void save() {
      provider.saveSettings();
      provider.touch();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: EdgeInsets.zero,
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.05),
          collapsedBackgroundColor: Colors.transparent,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.cloud_outlined,
                    size: 18, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(
                'Aether Settings',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  s.aetherProtocol == 'auto'
                      ? 'Auto'
                      : s.aetherProtocol.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AetherProtocolCard(),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: const Text('Share on LAN (bind 0.0.0.0)'),
                      value: s.aetherShareLan,
                      onChanged: (v) {
                        s.aetherShareLan = v;
                        save();
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: const Text('Auto-reconnect Aether'),
                      value: s.autoReconnectAether,
                      onChanged: (v) {
                        s.autoReconnectAether = v;
                        save();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
