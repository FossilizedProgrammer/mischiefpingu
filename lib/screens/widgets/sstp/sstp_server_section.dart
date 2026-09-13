import 'package:flutter/material.dart';

class SstpServerSection extends StatelessWidget {
  final ThemeData theme;
  final String sstpServer;
  final ValueChanged<String> onServerChanged;
  final int sstpPort;
  final ValueChanged<String> onPortChanged;
  final String sstpUser;
  final ValueChanged<String> onUserChanged;
  final String sstpPass;
  final ValueChanged<String> onPassChanged;

  const SstpServerSection({
    super.key,
    required this.theme,
    required this.sstpServer,
    required this.onServerChanged,
    required this.sstpPort,
    required this.onPortChanged,
    required this.sstpUser,
    required this.onUserChanged,
    required this.sstpPass,
    required this.onPassChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Server',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.tertiary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                initialValue: sstpServer,
                decoration: const InputDecoration(
                  labelText: 'Server address',
                  hintText: '60.121.223.189',
                  isDense: true,
                ),
                onChanged: onServerChanged,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: TextFormField(
                initialValue: sstpPort.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '443',
                  labelText: 'Port',
                  isDense: true,
                ),
                onChanged: onPortChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Authentication (optional)',
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
                initialValue: sstpUser,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  hintText: 'vpn',
                  isDense: true,
                ),
                onChanged: onUserChanged,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                initialValue: sstpPass,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  isDense: true,
                ),
                onChanged: onPassChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
