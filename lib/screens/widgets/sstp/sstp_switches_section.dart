// lib/screens/widgets/sstp/sstp_switches_section.dart
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
