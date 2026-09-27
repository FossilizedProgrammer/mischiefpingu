import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/settings_model.dart';

class SstpSwitchesSection extends StatelessWidget {
  final AppSettings settings;
  final VoidCallback onSave;

  const SstpSwitchesSection({
    super.key,
    required this.settings,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        // ═══════════════════════════════════════════════════════════
        //  InfoBox — توضیح رفتار auto-retry
        // ═══════════════════════════════════════════════════════════
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 16,
                color: Colors.green.shade700,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Auto-retry is always on. When the tunnel drops, '
                  'sstp-proxy reconnects itself in 3-5s without restarting '
                  'the process. Keepalive pings every 18-25s keep the '
                  'connection alive.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.green.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text(l10n.shareOnLan),
          value: settings.sstpShareLan,
          onChanged: (v) {
            settings.sstpShareLan = v;
            onSave();
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text(l10n.autoReconnectSstp),
          value: settings.autoReconnectSstp,
          onChanged: (v) {
            settings.autoReconnectSstp = v;
            onSave();
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text(l10n.verboseLogging),
          subtitle: Text(
            l10n.verboseLoggingSubtitle,
            style: const TextStyle(fontSize: 11),
          ),
          value: settings.sstpVerbose,
          onChanged: (v) {
            settings.sstpVerbose = v;
            onSave();
          },
        ),
      ],
    );
  }
}
