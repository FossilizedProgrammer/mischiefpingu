import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';

class AetherMasqueSection extends StatelessWidget {
  final bool isRunning;

  const AetherMasqueSection({super.key, required this.isRunning});

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
          'MASQUE HTTP version',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'HTTP-3', label: Text('HTTP-3')),
            ButtonSegment(value: 'HTTP-2', label: Text('HTTP-2')),
          ],
          selected: {s.masqueOption},
          onSelectionChanged: isRunning
              ? null
              : (set) {
                  s.masqueOption = set.first;
                  save();
                },
        ),
      ],
    );
  }
}
