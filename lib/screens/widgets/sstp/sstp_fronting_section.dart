import 'package:flutter/material.dart';

class SstpFrontingSection extends StatelessWidget {
  final ThemeData theme;
  final String sstpSni;
  final ValueChanged<String> onSniChanged;
  final String sstpFingerprint;
  final ValueChanged<String?> onFingerprintChanged;

  const SstpFrontingSection({
    super.key,
    required this.theme,
    required this.sstpSni,
    required this.onSniChanged,
    required this.sstpFingerprint,
    required this.onFingerprintChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fronting (advanced, optional)',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.tertiary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: sstpSni,
                decoration: const InputDecoration(
                  labelText: 'SNI',
                  hintText: 'aparat.com',
                  isDense: true,
                ),
                onChanged: onSniChanged,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: sstpFingerprint.isEmpty ? null : sstpFingerprint,
                decoration: const InputDecoration(
                  labelText: 'Fingerprint',
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: 'chrome', child: Text('Chrome')),
                  DropdownMenuItem(value: 'firefox', child: Text('Firefox')),
                  DropdownMenuItem(value: 'safari', child: Text('Safari')),
                  DropdownMenuItem(value: 'edge', child: Text('Edge')),
                  DropdownMenuItem(value: 'random', child: Text('Random')),
                ],
                onChanged: onFingerprintChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
